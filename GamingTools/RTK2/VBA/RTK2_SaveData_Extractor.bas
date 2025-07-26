' RTK2 ERP / Extract and Arrange the Ruler, Province, and General Data from the Save File
'
' Author:  kimpro82
' Date: 2025.07.26


Option Explicit

Const FILENAME As String = "SC5TEST"
Const WS_NAME_GENERAL As String = "General"
Const WS_NAME_PROVINCE As String = "Province"
Const WS_NAME_RULER As String = "Ruler"
Const START_CELL As String = "A2"


' 바이너리 파일을 읽어 바이트 배열로 반환
Function ReadBinaryFile(FILENAME As String) As Byte()
    Dim fileNum As Integer
    Dim fileLen As Long
    Dim bytes() As Byte

    fileNum = FreeFile
    Open FILENAME For Binary Access Read As #fileNum
    fileLen = LOF(fileNum)
    ReDim bytes(1 To fileLen)
    Get #fileNum, , bytes
    Close #fileNum

    ReadBinaryFile = bytes
End Function

' General 데이터 추출
Function ExtractGenerals(dataBytes() As Byte) As Variant
    Dim generals(1 To 255, 1 To 26) As Variant
    Dim i As Integer, offset As Long
    Dim nameBytes() As Byte, nameStr As String
    For i = 1 To 255
        offset = 32 + (i - 1) * 43
        nameBytes = MidB(dataBytes, offset + 28, 15)
        nameStr = ""
        Dim j As Integer
        For j = 1 To 15
            If nameBytes(j) = 0 Then Exit For
            nameStr = nameStr & ChrW(nameBytes(j))
        Next j
        generals(i, 1) = i ' general_idx
        generals(i, 2) = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ 43 + 1 ' next_gen_idx
        generals(i, 3) = nameStr ' name
        generals(i, 4) = dataBytes(offset + 3) ' act
        generals(i, 5) = dataBytes(offset + 4) ' state
        generals(i, 6) = dataBytes(offset + 5) ' int
        generals(i, 7) = dataBytes(offset + 6) ' war
        generals(i, 8) = dataBytes(offset + 7) ' cha
        generals(i, 9) = dataBytes(offset + 8) ' fai
        generals(i, 10) = dataBytes(offset + 9) ' vir
        generals(i, 11) = dataBytes(offset + 10) ' amb
        generals(i, 12) = dataBytes(offset + 11) ' ruler_idx
        generals(i, 13) = dataBytes(offset + 12) ' loy
        generals(i, 14) = dataBytes(offset + 13) ' exp
        generals(i, 15) = dataBytes(offset + 14) ' spy_idx
        generals(i, 16) = dataBytes(offset + 15) ' spy_exp
        generals(i, 17) = dataBytes(offset + 16) ' syn
        generals(i, 18) = dataBytes(offset + 17) ' blood
        generals(i, 19) = dataBytes(offset + 18) ' blood
        generals(i, 20) = dataBytes(offset + 19) + dataBytes(offset + 20) * 256 ' soldiers
        generals(i, 21) = dataBytes(offset + 21) + dataBytes(offset + 22) * 256 ' weapons
        generals(i, 22) = dataBytes(offset + 23) ' trainning
        generals(i, 23) = dataBytes(offset + 24) ' ?
        generals(i, 24) = dataBytes(offset + 25) ' ?
        generals(i, 25) = dataBytes(offset + 26) ' birth
        generals(i, 26) = dataBytes(offset + 27) + CLng(dataBytes(offset + 28)) * 256 ' face
    Next i
    ExtractGenerals = generals
End Function

' Province 데이터 추출
Function ExtractProvinces(dataBytes() As Byte, generals As Variant) As Variant
    Dim provinces(1 To 41, 1 To 24) As Variant
    Dim i As Integer, offset As Long, govIdx As Integer, rulerIdx As Integer
    For i = 1 To 41
        offset = 11660 + (i - 1) * 35
        govIdx = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 88) \ 43 + 1
        rulerIdx = dataBytes(offset + 17)
        provinces(i, 1) = i ' prov_idx
        provinces(i, 2) = WorksheetFunction.Max((dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 21 - 11660) \ 35, -1)
        provinces(i, 3) = govIdx ' governor_idx
        If rulerIdx >= 0 And govIdx > 0 And govIdx <= 255 Then
            provinces(i, 4) = generals(govIdx, 3) ' governor name
        Else
            provinces(i, 4) = ""
        End If
        provinces(i, 5) = dataBytes(offset + 5) ' ?
        provinces(i, 6) = dataBytes(offset + 6) ' ?
        provinces(i, 7) = dataBytes(offset + 7) ' ?
        provinces(i, 8) = dataBytes(offset + 8) ' ?
        provinces(i, 9) = dataBytes(offset + 9) + dataBytes(offset + 10) * 256 ' gold
        provinces(i, 10) = dataBytes(offset + 11) + CLng(dataBytes(offset + 12)) * 256 + CLng(dataBytes(offset + 13)) * 65536 ' food
        provinces(i, 11) = dataBytes(offset + 14) ' ?
        provinces(i, 12) = (dataBytes(offset + 15) + CLng(dataBytes(offset + 16) * 256)) * 100 ' pop
        provinces(i, 13) = rulerIdx ' ruler_idx
        provinces(i, 14) = dataBytes(offset + 18) ' ?
        provinces(i, 15) = dataBytes(offset + 19) ' ?
        provinces(i, 16) = dataBytes(offset + 20) ' ?
        provinces(i, 17) = (dataBytes(offset + 20) Mod 4) > 0 ' merch
        provinces(i, 18) = dataBytes(offset + 24) ' loy
        provinces(i, 19) = dataBytes(offset + 23) ' land
        provinces(i, 20) = dataBytes(offset + 25) ' flood
        provinces(i, 21) = dataBytes(offset + 26) ' horses
        provinces(i, 22) = dataBytes(offset + 27) ' forts
        provinces(i, 23) = dataBytes(offset + 28) ' rate
        provinces(i, 24) = dataBytes(offset + 35) ' state
        ' Debug.Print provinces(i, 1), provinces(i, 2), provinces(i, 3), provinces(i, 4), provinces(i, 9), provinces(i, 10), provinces(i, 12)  ' Ok
    Next i
    ExtractProvinces = provinces
End Function

' Ruler 데이터 추출
Function ExtractRulers(dataBytes() As Byte, generals As Variant) As Variant
    Dim rulers(1 To 16, 1 To 39) As Variant
    Dim i As Integer, j As Integer, offset As Long, rulerIdx As Integer, advisorIdx As Integer, capitalIdx As Integer
    For i = 1 To 16
        offset = 11004 + (i - 1) * 41
        rulerIdx = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ 43 + 1
        advisorIdx = (dataBytes(offset + 5) + dataBytes(offset + 6) * 256 - 88) \ 43 + 1
        rulers(i, 1) = i
        If rulerIdx >= 0 And rulerIdx <= 255 Then
            rulers(i, 2) = generals(rulerIdx, 3) ' ruler_name
        Else
            rulers(i, 2) = ""
        End If
        rulers(i, 3) = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 21 - 11660) \ 35
        If advisorIdx >= 0 And advisorIdx <= 255 Then
            rulers(i, 4) = generals(advisorIdx, 3) ' advisor_name
        Else
            rulers(i, 4) = ""
        End If
        rulers(i, 5) = dataBytes(offset + 7) ' trust
        ' Debug.Print i, advisorIdx, capitalIdx, rulers(i, 2), rulers(i, 5), rulers(i, 6)  ' Ok
        rulers(i, 6) = dataBytes(offset + 8) ' ?
        rulers(i, 7) = dataBytes(offset + 9) ' ?
        rulers(i, 8) = dataBytes(offset + 10) ' ?
        rulers(i, 9) = dataBytes(offset + 11) ' ?
        rulers(i, 10) = dataBytes(offset + 12) ' ?
        rulers(i, 11) = dataBytes(offset + 13) ' ?
        rulers(i, 12) = dataBytes(offset + 14) ' ?
        For j = 15 To 30
            rulers(i, j - 2) = dataBytes(offset + j) ' hostility
        Next j
        rulers(i, 29) = dataBytes(offset + 31) ' ?
        rulers(i, 30) = dataBytes(offset + 32) ' ?
        rulers(i, 31) = dataBytes(offset + 33) ' ?
        rulers(i, 32) = dataBytes(offset + 34) ' ?
        rulers(i, 33) = dataBytes(offset + 35) ' ?
        rulers(i, 34) = dataBytes(offset + 36) ' ?
        rulers(i, 35) = dataBytes(offset + 37) ' ?
        rulers(i, 36) = dataBytes(offset + 38) ' ?
        rulers(i, 37) = dataBytes(offset + 39) ' ?
        rulers(i, 38) = dataBytes(offset + 40) ' ?
        rulers(i, 39) = dataBytes(offset + 41) ' ?
    Next i
    ExtractRulers = rulers
End Function

' Ruler의 capital_idx부터 province를 연결 리스트 순서대로 정렬
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
    ' Unowned provinces 추가
    For i = 1 To provCount
        If provinces(i, 13) = 255 And Not visited(i) Then
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

' Province의 governor_idx부터 general을 연결 리스트 순서대로 정렬
Function LinkGeneralsByProvince(linkedProvinces As Variant, generals As Variant) As Variant
    Dim linkedRows() As Variant
    Dim rowCount As Integer: rowCount = 0
    Dim genCount As Integer: genCount = UBound(generals, 1)
    Dim i As Integer, currentGenIdx As Integer, nextGenIdx As Integer
    ReDim linkedRows(1 To genCount * 2, 1 To UBound(generals, 2) + 3) ' +3 for prov_idx, prov_governor, prov_ruler

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
                linkedRows(rowCount, UBound(generals, 2) + 2) = linkedProvinces(i, 5) ' prov_governor
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

' Province별로 soldiers_sum, gen_cnt, free_cnt 집계
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
        Dim provRulerIdx As Integer: provRulerIdx = linkedProvinces(i, 8)
        For j = 1 To UBound(linkedGenerals, 1)
            If linkedGenerals(j, UBound(linkedGenerals, 2) - 2) = provIdx Then
                soldiersSum = soldiersSum + linkedGenerals(j, 17) ' soldiers
                If linkedGenerals(j, 11) = provRulerIdx Then genCnt = genCnt + 1
                If linkedGenerals(j, 11) = 255 Then freeCnt = freeCnt + 1
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

' Ruler별로 province/general 집계
Function SummarizeRulerWithProvincesAndGenerals(rulers As Variant, summarizedProvinces As Variant, linkedGenerals As Variant) As Variant
    Dim summaryRows() As Variant
    Dim i As Integer, j As Integer, rowCount As Integer
    Dim rulerCount As Integer: rulerCount = UBound(rulers, 1)
    ReDim summaryRows(1 To rulerCount, 1 To UBound(rulers, 2) + 7) ' +6 for prov_cnt, gold_sum, food_sum, pop_sum, soldiers_sum, gen_cnt, free_cnt

    For i = 1 To rulerCount
        Dim provCnt As Long: provCnt = 0
        Dim goldSum As Long: goldSum = 0
        Dim foodSum As Long: foodSum = 0
        Dim popSum As Long: popSum = 0
        Dim soldiersSum As Long: soldiersSum = 0
        Dim genCnt As Long: genCnt = 0
        Dim freeCnt As Long: freeCnt = 0
        Dim rulerIdx As Integer: rulerIdx = rulers(i, 1)
        Dim rulerName As String: rulerName = rulers(i, 2)
        For j = 1 To UBound(summarizedProvinces, 1)
            If summarizedProvinces(j, 8) = rulerIdx Then
                provCnt = provCnt + 1
                goldSum = goldSum + summarizedProvinces(j, 6)
                foodSum = foodSum + summarizedProvinces(j, 7)
                popSum = popSum + summarizedProvinces(j, 8)
                genCnt = genCnt + summarizedProvinces(j, UBound(summarizedProvinces, 2) - 1)
                freeCnt = freeCnt + summarizedProvinces(j, UBound(summarizedProvinces, 2))
            End If
        Next j
        For j = 1 To UBound(linkedGenerals, 1)
            If linkedGenerals(j, UBound(linkedGenerals, 2)) = rulerName Then
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

' 시트에 배열 출력 예시
Sub OutputArraysToSheets()
    Dim dataBytes() As Byte
    dataBytes = ReadBinaryFile(FILENAME)

    Dim generals As Variant, provinces As Variant, rulers As Variant
    generals = ExtractGenerals(dataBytes)
    provinces = ExtractProvinces(dataBytes, generals)
    rulers = ExtractRulers(dataBytes, generals)

    ' 1. Ruler별 Province 연결 리스트 순서대로 정렬
    Dim linkedProvinces As Variant
    linkedProvinces = LinkProvincesByRuler(rulers, provinces)
    
    ' 2. Province별 General 연결 리스트 순서대로 정렬
    Dim linkedGenerals As Variant
    linkedGenerals = LinkGeneralsByProvince(linkedProvinces, generals)

    Dim wsLinkedGen As Worksheet
    Set wsLinkedGen = ThisWorkbook.Sheets(WS_NAME_GENERAL)
    wsLinkedGen.Cells.Clear
    wsLinkedGen.Range(START_CELL).Resize(UBound(linkedGenerals, 1), UBound(linkedGenerals, 2)).Value = linkedGenerals

    ' 3. Province별 집계(soldiers_sum, gen_cnt, free_cnt)
    Dim summarizedProvinces As Variant
    summarizedProvinces = SummarizeProvinceWithGenerals(linkedProvinces, linkedGenerals)
    Dim wsSumProv As Worksheet
    Set wsSumProv = ThisWorkbook.Sheets(WS_NAME_PROVINCE)
    wsSumProv.Cells.Clear
    wsSumProv.Range(START_CELL).Resize(UBound(summarizedProvinces, 1), UBound(summarizedProvinces, 2)).Value = summarizedProvinces

    ' 4. Ruler별 집계
    Dim summarizedRulers As Variant
    summarizedRulers = SummarizeRulerWithProvincesAndGenerals(rulers, summarizedProvinces, linkedGenerals)
    Dim wsSumRul As Worksheet
    Set wsSumRul = ThisWorkbook.Sheets(WS_NAME_RULER)
    wsSumRul.Cells.Clear
    wsSumRul.Range(START_CELL).Resize(UBound(summarizedRulers, 1), UBound(summarizedRulers, 2)).Value = summarizedRulers
End Sub
