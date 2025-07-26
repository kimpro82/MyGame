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
    Dim rulers(1 To 16, 1 To 40) As Variant
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
        rulers(i, 3) = capitalIdx
        rulers(i, 4) = advisorIdx
        If advisorIdx >= 0 And advisorIdx <= 255 Then
            rulers(i, 5) = generals(advisorIdx, 3) ' advisor_name
        Else
            rulers(i, 5) = ""
        End If
        rulers(i, 6) = dataBytes(offset + 7) ' trust
        ' Debug.Print i, advisorIdx, capitalIdx, rulers(i, 2), rulers(i, 5), rulers(i, 6)  ' Ok
        rulers(i, 7) = dataBytes(offset + 8) ' ?
        rulers(i, 8) = dataBytes(offset + 9) ' ?
        rulers(i, 9) = dataBytes(offset + 10) ' ?
        rulers(i, 10) = dataBytes(offset + 11) ' ?
        rulers(i, 11) = dataBytes(offset + 12) ' ?
        rulers(i, 12) = dataBytes(offset + 13) ' ?
        rulers(i, 13) = dataBytes(offset + 14) ' ?
        For j = 15 To 30
            rulers(i, j - 1) = dataBytes(offset + j) ' hostility
        Next j
        rulers(i, 30) = dataBytes(offset + 31) ' ?
        rulers(i, 31) = dataBytes(offset + 32) ' ?
        rulers(i, 32) = dataBytes(offset + 33) ' ?
        rulers(i, 33) = dataBytes(offset + 34) ' ?
        rulers(i, 34) = dataBytes(offset + 35) ' ?
        rulers(i, 35) = dataBytes(offset + 36) ' ?
        rulers(i, 36) = dataBytes(offset + 37) ' ?
        rulers(i, 37) = dataBytes(offset + 38) ' ?
        rulers(i, 38) = dataBytes(offset + 39) ' ?
        rulers(i, 39) = dataBytes(offset + 40) ' ?
        rulers(i, 40) = dataBytes(offset + 41) ' ?
    Next i
    ExtractRulers = rulers
End Function

' 시트에 배열 출력 예시
Sub OutputArraysToSheets()
    Dim dataBytes() As Byte
    dataBytes = ReadBinaryFile(FILENAME)

    Dim generals As Variant, provinces As Variant, rulers As Variant
    generals = ExtractGenerals(dataBytes)
    provinces = ExtractProvinces(dataBytes, generals)
    rulers = ExtractRulers(dataBytes, generals)

    ' General 데이터 출력
    Dim wsGen As Worksheet
    Set wsGen = ThisWorkbook.Sheets(WS_NAME_GENERAL)
    wsGen.Cells.Clear
    wsGen.Range(START_CELL).Resize(UBound(generals, 1), UBound(generals, 2)).Value = generals

    ' Province 데이터 출력
    Dim wsProv As Worksheet
    Set wsProv = ThisWorkbook.Sheets(WS_NAME_PROVINCE)
    wsProv.Cells.Clear
    wsProv.Range(START_CELL).Resize(UBound(provinces, 1), UBound(provinces, 2)).Value = provinces

    ' Ruler 데이터 출력
    Dim wsRul As Worksheet
    Set wsRul = ThisWorkbook.Sheets(WS_NAME_RULER)
    wsRul.Cells.Clear
    wsRul.Range(START_CELL).Resize(UBound(rulers, 1), UBound(rulers, 2)).Value = rulers
End Sub
