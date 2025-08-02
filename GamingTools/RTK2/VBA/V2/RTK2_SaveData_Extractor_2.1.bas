' RTK2 ERP / Common Module
' Version : 2.1
'
' Extract and Arrange the Ruler, Province, and General Data from the Save File
'
' Author:  kimpro82
' Date: 2025.08.02.


Option Explicit


Const PATH As String = "C:\Game\Koei\RTK2\"
Public Const FILENAME As String = "SC5TEST"
Const WS_NAME_GENERAL As String = "General"
Const WS_NAME_PROVINCE As String = "Province"
Const WS_NAME_RULER As String = "Ruler"
Const DATA_START_CELL As String = "B5"

' Global variables for extracted data
Public dataBytes() As Byte              ' Raw save file bytes
Public yyy_mm As String                 ' Year-Month string extracted from save file
Public summarizedProvinces As Variant   ' Province summary array
Public summarizedRulers As Variant      ' Ruler summary array


' Reads a binary file and returns its contents as a byte array
' @param filePath: Full path to the binary file
' @return: Byte array containing file data
Function ReadBinaryFile(filePath As String) As Byte()

    Dim fileNum As Integer
    Dim fileLen As Long
    Dim bytes() As Byte

    fileNum = FreeFile
    Open filePath For Binary Access Read As #fileNum
        fileLen = LOF(fileNum)
        ReDim bytes(1 To fileLen)
        Get #fileNum, , bytes
    Close #fileNum

    ReadBinaryFile = bytes

End Function


' Extracts year and month from the save file byte array
' @param dataBytes: Byte array from save file
' @return: String in "YYY-MM" format
Private Function ExtractYearMonth(ByRef dataBytes() As Byte) As String

    Const YEAR_OFFSET As Integer = 13
    Const MONTH_OFFSET As Integer = 15

    Dim yearVal As Byte, monthVal As Byte, yearMonthStr As String
    yearVal = dataBytes(YEAR_OFFSET)
    monthVal = dataBytes(MONTH_OFFSET) + 1 ' Jan:0, Feb:1, so add 1
    If monthVal < 10 Then
        yearMonthStr = CStr(yearVal) & "-0" & CStr(monthVal)
    Else
        yearMonthStr = CStr(yearVal) & "-" & CStr(monthVal)
    End If
    ExtractYearMonth = yearMonthStr

End Function


' Extracts general data from the save file byte array
' @param dataBytes: Byte array from save file
' @return: 2D array [general_idx, fields...]
Function ExtractGenerals(dataBytes() As Byte) As Variant

    Const GENERAL_COUNT As Integer = 255
    Const GENERAL_FIELD_COUNT As Integer = 26
    Const GENERAL_BLOCK_SIZE As Integer = 43
    Const GENERAL_START_OFFSET As Integer = 32

    Dim generals(1 To GENERAL_COUNT, 1 To GENERAL_FIELD_COUNT) As Variant
    Dim i As Integer, offset As Long
    Dim nameBytes() As Byte, nameStr As String
    For i = 1 To GENERAL_COUNT
        offset = GENERAL_START_OFFSET + (i - 1) * GENERAL_BLOCK_SIZE
        nameBytes = MidB(dataBytes, offset + 28, 15)
        nameStr = ""
        Dim j As Integer
        For j = 1 To 15
            If nameBytes(j) = 0 Then Exit For
            nameStr = nameStr & ChrW(nameBytes(j))
        Next j

        generals(i, 1) = i ' general_idx
        generals(i, 2) = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ GENERAL_BLOCK_SIZE + 1 ' next_gen_idx
        generals(i, 3) = nameStr ' name
        generals(i, 4) = dataBytes(offset + 3) ' act
        generals(i, 5) = dataBytes(offset + 4) ' state
        generals(i, 6) = dataBytes(offset + 5) ' int
        generals(i, 7) = dataBytes(offset + 6) ' war
        generals(i, 8) = dataBytes(offset + 7) ' cha
        generals(i, 9) = dataBytes(offset + 8) ' fai
        generals(i, 10) = dataBytes(offset + 9) ' vir
        generals(i, 11) = dataBytes(offset + 10) ' amb
        generals(i, 12) = dataBytes(offset + 11) + 1 ' ruler_idx
        generals(i, 13) = dataBytes(offset + 12) ' loy
        generals(i, 14) = dataBytes(offset + 13) ' exp
        generals(i, 15) = dataBytes(offset + 14) ' spy_idx
        generals(i, 16) = dataBytes(offset + 15) ' spy_exp
        generals(i, 17) = dataBytes(offset + 16) ' syn
        generals(i, 18) = dataBytes(offset + 17) ' blood
        generals(i, 19) = dataBytes(offset + 18) ' blood
        generals(i, 20) = dataBytes(offset + 19) + dataBytes(offset + 20) * 256 ' soldiers
        generals(i, 21) = dataBytes(offset + 21) + dataBytes(offset + 22) * 256 ' weapons
        generals(i, 22) = dataBytes(offset + 23) ' training
        generals(i, 23) = dataBytes(offset + 24) ' unknown
        generals(i, 24) = dataBytes(offset + 25) ' unknown
        generals(i, 25) = dataBytes(offset + 26) ' birth
        generals(i, 26) = dataBytes(offset + 27) + CLng(dataBytes(offset + 28)) * 256 ' face
    Next i

    ExtractGenerals = generals

End Function


' Extracts province data from the save file byte array
' @param dataBytes: Byte array from save file
' @param generals: 2D array of general data
' @return: 2D array [province_idx, fields...]
Function ExtractProvinces(dataBytes() As Byte, generals As Variant) As Variant

    Const PROVINCE_COUNT As Integer = 41
    Const PROVINCE_FIELD_COUNT As Integer = 24
    Const PROVINCE_BLOCK_SIZE As Integer = 35
    Const PROVINCE_START_OFFSET As Integer = 11660

    Dim provinces(1 To PROVINCE_COUNT, 1 To PROVINCE_FIELD_COUNT) As Variant
    Dim i As Integer, offset As Long, govIdx As Integer, rulerIdx As Integer
    For i = 1 To PROVINCE_COUNT
        offset = PROVINCE_START_OFFSET + (i - 1) * PROVINCE_BLOCK_SIZE
        govIdx = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 88) \ 43 + 1
        rulerIdx = dataBytes(offset + 17) + 1

        provinces(i, 1) = i ' province_idx
        provinces(i, 2) = WorksheetFunction.Max((dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 21 - PROVINCE_START_OFFSET) \ PROVINCE_BLOCK_SIZE, -1)
        provinces(i, 3) = govIdx ' governor_idx
        If rulerIdx >= 0 And govIdx > 0 And govIdx <= 255 Then
            provinces(i, 4) = generals(govIdx, 3) ' governor name
        Else
            provinces(i, 4) = ""
        End If
        provinces(i, 5) = dataBytes(offset + 5) ' unknown
        provinces(i, 6) = dataBytes(offset + 6) ' unknown
        provinces(i, 7) = dataBytes(offset + 7) ' unknown
        provinces(i, 8) = dataBytes(offset + 8) ' unknown
        provinces(i, 9) = dataBytes(offset + 9) + dataBytes(offset + 10) * 256 ' gold
        provinces(i, 10) = dataBytes(offset + 11) + CLng(dataBytes(offset + 12)) * 256 + CLng(dataBytes(offset + 13)) * 65536 ' food
        provinces(i, 11) = dataBytes(offset + 14) ' unknown
        provinces(i, 12) = (dataBytes(offset + 15) + CLng(dataBytes(offset + 16) * 256)) * 100 ' population
        provinces(i, 13) = rulerIdx ' ruler_idx
        provinces(i, 14) = dataBytes(offset + 18) ' unknown
        provinces(i, 15) = dataBytes(offset + 19) ' unknown
        provinces(i, 16) = dataBytes(offset + 20) ' unknown
        provinces(i, 17) = (dataBytes(offset + 20) Mod 4) > 0 ' merchant
        provinces(i, 18) = dataBytes(offset + 24) ' loyalty
        provinces(i, 19) = dataBytes(offset + 23) ' land
        provinces(i, 20) = dataBytes(offset + 25) ' flood
        provinces(i, 21) = dataBytes(offset + 26) ' horses
        provinces(i, 22) = dataBytes(offset + 27) ' forts
        provinces(i, 23) = dataBytes(offset + 28) ' rate
        provinces(i, 24) = dataBytes(offset + 35) ' state
    Next i

    ExtractProvinces = provinces

End Function


' Extracts ruler data from the save file byte array
' @param dataBytes: Byte array from save file
' @param generals: 2D array of general data
' @return: 2D array [ruler_idx, fields...]
Function ExtractRulers(dataBytes() As Byte, generals As Variant) As Variant

    Const RULER_COUNT As Integer = 16
    Const RULER_FIELD_COUNT As Integer = 39
    Const RULER_BLOCK_SIZE As Integer = 41
    Const RULER_START_OFFSET As Integer = 11004

    Dim rulers(1 To RULER_COUNT, 1 To RULER_FIELD_COUNT) As Variant
    Dim i As Integer, j As Integer, offset As Long, rulerIdx As Integer, advisorIdx As Integer, capitalIdx As Integer
    For i = 1 To RULER_COUNT
        offset = RULER_START_OFFSET + (i - 1) * RULER_BLOCK_SIZE
        rulerIdx = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ 43 + 1
        capitalIdx = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 21 - 11660) \ 35 ' -333 if empty
        advisorIdx = (dataBytes(offset + 5) + dataBytes(offset + 6) * 256 - 88) \ 43 + 1

        rulers(i, 1) = i
        If rulerIdx >= 0 And rulerIdx <= 255 Then
            rulers(i, 2) = generals(rulerIdx, 3) ' ruler_name
        Else
            rulers(i, 2) = ""
        End If
        If capitalIdx > 0 Then
            rulers(i, 3) = capitalIdx
        Else
            rulers(i, 3) = -1
        End If
        If advisorIdx >= 0 And advisorIdx <= 255 Then
            rulers(i, 4) = generals(advisorIdx, 3) ' advisor_name
        Else
            rulers(i, 4) = ""
        End If
        rulers(i, 5) = dataBytes(offset + 7) ' trust
        rulers(i, 6) = dataBytes(offset + 8) ' unknown
        rulers(i, 7) = dataBytes(offset + 9) ' unknown
        rulers(i, 8) = dataBytes(offset + 10) ' unknown
        rulers(i, 9) = dataBytes(offset + 11) ' unknown
        rulers(i, 10) = dataBytes(offset + 12) ' unknown
        rulers(i, 11) = dataBytes(offset + 13) ' unknown
        rulers(i, 12) = dataBytes(offset + 14) ' unknown
        For j = 15 To 30
            rulers(i, j - 2) = dataBytes(offset + j) ' hostility
        Next j
        rulers(i, 29) = dataBytes(offset + 31) ' unknown
        rulers(i, 30) = dataBytes(offset + 32) ' unknown
        rulers(i, 31) = dataBytes(offset + 33) ' unknown
        rulers(i, 32) = dataBytes(offset + 34) ' unknown
        rulers(i, 33) = dataBytes(offset + 35) ' unknown
        rulers(i, 34) = dataBytes(offset + 36) ' unknown
        rulers(i, 35) = dataBytes(offset + 37) ' unknown
        rulers(i, 36) = dataBytes(offset + 38) ' unknown
        rulers(i, 37) = dataBytes(offset + 39) ' unknown
        rulers(i, 38) = dataBytes(offset + 40) ' unknown
        rulers(i, 39) = dataBytes(offset + 41) ' unknown
    Next i

    ExtractRulers = rulers

End Function


' Traverses the province linked list for each ruler and returns ordered provinces
' @param rulers: 2D array of ruler data
' @param provinces: 2D array of province data
' @return: 2D array of provinces ordered by ruler
Function LinkProvincesByRuler(rulers As Variant, provinces As Variant) As Variant

    Dim linkedRows() As Variant
    Dim visited() As Boolean
    Dim i As Integer, j As Integer, currentIdx As Integer, nextIdx As Integer, rowCount As Integer
    Dim provCount As Integer: provCount = UBound(provinces, 1)
    ReDim visited(1 To provCount)
    ReDim linkedRows(1 To provCount, 1 To UBound(provinces, 2) + 1) ' +1 for ruler_name

    rowCount = 0
    For i = 1 To UBound(rulers, 1)
        currentIdx = rulers(i, 3) ' capital_idx
        Do While currentIdx >= 1 And currentIdx <= provCount
            If Not visited(currentIdx) Then
                visited(currentIdx) = True
                rowCount = rowCount + 1

                For j = 1 To UBound(provinces, 2)
                    linkedRows(rowCount, j) = provinces(currentIdx, j)
                Next j

                linkedRows(rowCount, UBound(provinces, 2) + 1) = rulers(i, 2) ' ruler_name
                nextIdx = provinces(currentIdx, 2) ' next_prov_idx
                currentIdx = nextIdx
            End If
        Loop
    Next i

    ' Add unowned provinces (ruler_idx == 255)
    For i = 1 To provCount
        If Not visited(i) Then
            rowCount = rowCount + 1
            For j = 1 To UBound(provinces, 2)
                linkedRows(rowCount, j) = provinces(i, j)
            Next j
            linkedRows(rowCount, 4) = Empty
        End If
    Next i

    ' ReDim Preserve linkedRows(1 To rowCount, 1 To UBound(provinces, 2) + 1)
    LinkProvincesByRuler = linkedRows

End Function


' Traverses the general linked list for each province and returns ordered generals
' @param linkedProvinces: 2D array of linked provinces
' @param generals: 2D array of general data
' @return: 2D array of generals ordered by province
Function LinkGeneralsByProvince(linkedProvinces As Variant, generals As Variant) As Variant

    Dim linkedRows() As Variant
    Dim rowCount As Integer: rowCount = 0
    Dim genCount As Integer: genCount = UBound(generals, 1)
    Dim i As Integer, currentGenIdx As Integer, nextGenIdx As Integer
    ReDim linkedRows(1 To genCount, 1 To UBound(generals, 2) + 3) ' +3 for prov_idx, prov_governor, prov_ruler

    For i = 1 To UBound(linkedProvinces, 1)
        currentGenIdx = linkedProvinces(i, 3) ' governor_idx
        Dim visitedGen() As Boolean
        ReDim visitedGen(1 To genCount)

        Do While currentGenIdx <> -1 And currentGenIdx >= 1 And currentGenIdx <= genCount
            If Not visitedGen(currentGenIdx) Then
                visitedGen(currentGenIdx) = True
                rowCount = rowCount + 1

                Dim j As Integer
                For j = 1 To UBound(generals, 2)
                    linkedRows(rowCount, j) = generals(currentGenIdx, j)
                Next j

                linkedRows(rowCount, UBound(generals, 2) + 1) = linkedProvinces(i, 1) ' prov_idx
                linkedRows(rowCount, UBound(generals, 2) + 2) = linkedProvinces(i, 4) ' prov_governor
                linkedRows(rowCount, UBound(generals, 2) + 3) = linkedProvinces(i, UBound(linkedProvinces, 2)) ' prov_ruler
                nextGenIdx = generals(currentGenIdx, 2) ' next_gen_idx
                currentGenIdx = nextGenIdx
            End If
        Loop
    Next i

    If rowCount > 0 Then
        ' ReDim Preserve linkedRows(1 To rowCount, 1 To UBound(generals, 2) + 3)
        LinkGeneralsByProvince = linkedRows
    Else
        LinkGeneralsByProvince = Empty
    End If

End Function


' Summarizes province data: total soldiers, general count, free general count
' @param linkedProvinces: 2D array of linked provinces
' @param linkedGenerals: 2D array of linked generals
' @return: 2D array of province summary
Function SummarizeProvinceWithGenerals(linkedProvinces As Variant, linkedGenerals As Variant) As Variant

    Dim summaryRows() As Variant
    Dim i As Integer, j As Integer, rowCount As Integer
    Dim provCount As Integer: provCount = UBound(linkedProvinces, 1)
    ReDim summaryRows(1 To provCount, 1 To UBound(linkedProvinces, 2) + 3) ' +3 for soldiers_sum, gen_cnt, free_cnt

    For i = 1 To provCount
        Dim soldiersSum As Long: soldiersSum = 0
        Dim genCnt As Long: genCnt = 0
        Dim freeCnt As Long: freeCnt = 0
        Dim provIdx As Integer: provIdx = linkedProvinces(i, 1)
        Dim provRulerIdx As Integer: provRulerIdx = linkedProvinces(i, 13)

        For j = 1 To UBound(linkedGenerals, 1)
            If linkedGenerals(j, UBound(linkedGenerals, 2) - 2) = provIdx And linkedGenerals(j, 25) > 0 Then
                soldiersSum = soldiersSum + linkedGenerals(j, 20) ' soldiers
                If linkedGenerals(j, 12) = provRulerIdx Then genCnt = genCnt + 1
                If linkedGenerals(j, 12) = 255 Then freeCnt = freeCnt + 1
            End If
        Next j

        Dim k As Integer
        For k = 1 To UBound(linkedProvinces, 2)
            summaryRows(i, k) = linkedProvinces(i, k)
        Next k

        summaryRows(i, UBound(linkedProvinces, 2) + 1) = soldiersSum
        summaryRows(i, UBound(linkedProvinces, 2) + 2) = genCnt
        summaryRows(i, UBound(linkedProvinces, 2) + 3) = freeCnt
    Next i

    SummarizeProvinceWithGenerals = summaryRows

End Function


' Summarizes ruler data: province/general statistics
' @param rulers: 2D array of ruler data
' @param summarizedProvinces: 2D array of province summary
' @param linkedGenerals: 2D array of linked generals
' @return: 2D array of ruler summary
Function SummarizeRulerWithProvincesAndGenerals(rulers As Variant, summarizedProvinces As Variant, linkedGenerals As Variant) As Variant

    Dim summaryRows() As Variant
    Dim i As Integer, j As Integer, rowCount As Integer
    Dim rulerCount As Integer: rulerCount = UBound(rulers, 1)
    ReDim summaryRows(1 To rulerCount, 1 To UBound(rulers, 2) + 7) ' +7 for prov_cnt, gold_sum, food_sum, pop_sum, soldiers_sum, gen_cnt, free_cnt

    For i = 1 To rulerCount
        Dim provCnt As Long: provCnt = 0
        Dim goldSum As Long: goldSum = 0
        Dim foodSum As Long: foodSum = 0
        Dim popSum As Long: popSum = 0
        Dim soldiersSum As Long: soldiersSum = 0
        Dim genCnt As Long: genCnt = 0
        Dim freeCnt As Long: freeCnt = 0
        Dim rulerIdx As Integer: rulerIdx = rulers(i, 1)

        For j = 1 To UBound(summarizedProvinces, 1)
            If summarizedProvinces(j, 13) = rulerIdx Then
                provCnt = provCnt + 1
                goldSum = goldSum + summarizedProvinces(j, 9)
                foodSum = foodSum + summarizedProvinces(j, 10)
                popSum = popSum + summarizedProvinces(j, 12)
                soldiersSum = soldiersSum + summarizedProvinces(j, 26)
                genCnt = genCnt + summarizedProvinces(j, 27)
                freeCnt = freeCnt + summarizedProvinces(j, 28)
            End If
        Next j

        For j = 1 To UBound(linkedGenerals, 1)
            If linkedGenerals(j, UBound(linkedGenerals, 2)) = rulerIdx Then
                soldiersSum = soldiersSum + linkedGenerals(j, 17)
            End If
        Next j

        Dim k As Integer
        For k = 1 To UBound(rulers, 2)
            summaryRows(i, k) = rulers(i, k)
        Next k

        summaryRows(i, UBound(rulers, 2) + 1) = provCnt
        summaryRows(i, UBound(rulers, 2) + 2) = goldSum
        summaryRows(i, UBound(rulers, 2) + 3) = foodSum
        summaryRows(i, UBound(rulers, 2) + 4) = popSum
        summaryRows(i, UBound(rulers, 2) + 5) = soldiersSum
        summaryRows(i, UBound(rulers, 2) + 6) = genCnt
        summaryRows(i, UBound(rulers, 2) + 7) = freeCnt
    Next i

    SummarizeRulerWithProvincesAndGenerals = summaryRows

End Function


' Main routine: extract, link, summarize and output arrays to sheets
' Reads the save file, extracts and processes all data, and outputs to Excel sheets
Sub OutputArraysToSheets()

    Dim file_path As String
    file_path = PATH & FILENAME
    dataBytes = ReadBinaryFile(file_path)
    yyy_mm = ExtractYearMonth(dataBytes)

    Dim generals As Variant, provinces As Variant, rulers As Variant
    generals = ExtractGenerals(dataBytes)
    provinces = ExtractProvinces(dataBytes, generals)
    rulers = ExtractRulers(dataBytes, generals)

    ' 1. Link provinces by ruler (linked list order)
    Dim linkedProvinces As Variant
    linkedProvinces = LinkProvincesByRuler(rulers, provinces)

    ' 2. Link generals by province (linked list order)
    Dim linkedGenerals As Variant
    linkedGenerals = LinkGeneralsByProvince(linkedProvinces, generals)

    Dim wsLinkedGen As Worksheet
    Set wsLinkedGen = ThisWorkbook.Sheets(WS_NAME_GENERAL)
    wsLinkedGen.Range(DATA_START_CELL).Resize(UBound(linkedGenerals, 1), UBound(linkedGenerals, 2)).ClearContents
    wsLinkedGen.Range(DATA_START_CELL).Resize(UBound(linkedGenerals, 1), UBound(linkedGenerals, 2)).Value = linkedGenerals

    ' 3. Province summary (soldiers_sum, gen_cnt, free_cnt)
    summarizedProvinces = SummarizeProvinceWithGenerals(linkedProvinces, linkedGenerals)
    Dim wsSumProv As Worksheet
    Set wsSumProv = ThisWorkbook.Sheets(WS_NAME_PROVINCE)
    wsSumProv.Range(DATA_START_CELL).Resize(UBound(summarizedProvinces, 1), UBound(summarizedProvinces, 2)).ClearContents
    wsSumProv.Range(DATA_START_CELL).Resize(UBound(summarizedProvinces, 1), UBound(summarizedProvinces, 2)).Value = summarizedProvinces

    ' 4. Ruler summary
    summarizedRulers = SummarizeRulerWithProvincesAndGenerals(rulers, summarizedProvinces, linkedGenerals)
    Dim wsSumRul As Worksheet
    Set wsSumRul = ThisWorkbook.Sheets(WS_NAME_RULER)
    wsSumRul.Range(DATA_START_CELL).Resize(UBound(summarizedRulers, 1), UBound(summarizedRulers, 2)).ClearContents
    wsSumRul.Range(DATA_START_CELL).Resize(UBound(summarizedRulers, 1), UBound(summarizedRulers, 2)).Value = summarizedRulers

End Sub
