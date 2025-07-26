' RTK2 ERP / Extract and Arrange the Ruler, Province, and General Data from the Save File
'
' Author:  kimpro82
' Date: 2025.07.26


Option Explicit

Const FILENAME As String = "SC5TEST"
Const WS_NAME_GENERAL As String = "General"
Const WS_NAME_PROVINCE As String = "Province"
Const WS_NAME_RULER As String = "Ruler"


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
    Dim generals(1 To 255, 1 To 20) As Variant
    Dim i As Integer, offset As Long
    Dim nameBytes() As Byte, nameStr As String
    For i = 0 To 254
        offset = 32 + i * 43
        nameBytes = MidB(dataBytes, offset + 28, 15)
        nameStr = ""
        Dim j As Integer
        For j = 1 To 15
            If nameBytes(j) = 0 Then Exit For
            nameStr = nameStr & ChrW(nameBytes(j))
        Next j
        generals(i + 1, 1) = i + 1 ' general_idx
        generals(i + 1, 2) = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ 43 ' next_gen_idx
        generals(i + 1, 3) = nameStr ' name
        generals(i + 1, 4) = dataBytes(offset + 5) ' int
        generals(i + 1, 5) = dataBytes(offset + 6) ' war
        generals(i + 1, 6) = dataBytes(offset + 7) ' cha
        generals(i + 1, 7) = dataBytes(offset + 8) ' fai
        generals(i + 1, 8) = dataBytes(offset + 9) ' vir
        generals(i + 1, 9) = dataBytes(offset + 10) ' amb
        generals(i + 1, 10) = dataBytes(offset + 11) ' ruler_idx
        generals(i + 1, 11) = dataBytes(offset + 12) ' loy
        generals(i + 1, 12) = dataBytes(offset + 13) ' exp
        generals(i + 1, 13) = dataBytes(offset + 14) ' spy_idx
        generals(i + 1, 14) = dataBytes(offset + 15) ' spy_exp
        generals(i + 1, 15) = dataBytes(offset + 16) ' syn
        generals(i + 1, 16) = dataBytes(offset + 19) + dataBytes(offset + 20) * 256 ' soldiers
        generals(i + 1, 17) = dataBytes(offset + 21) + dataBytes(offset + 22) * 256 ' weapons
        generals(i + 1, 18) = dataBytes(offset + 23) ' trainning
        generals(i + 1, 19) = dataBytes(offset + 26) ' birth
        generals(i + 1, 20) = dataBytes(offset + 27) + CLng(dataBytes(offset + 28)) * 256 ' face
    Next i
    ExtractGenerals = generals
End Function

' Province 데이터 추출
Function ExtractProvinces(dataBytes() As Byte, generals As Variant) As Variant
    Dim provinces(1 To 41, 1 To 18) As Variant
    Dim i As Integer, offset As Long, govIdx As Integer, rulerIdx As Integer
    For i = 0 To 40
        offset = 11660 + i * 35
        rulerIdx = dataBytes(offset + 17)
        govIdx = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 88) \ 43 + 1
        provinces(i + 1, 1) = i + 1 ' prov_idx
        provinces(i + 1, 2) = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 21 - 11660) \ 35 ' next_prov_idx
        provinces(i + 1, 3) = govIdx ' governor_idx
        If rulerIdx >= 0 And govIdx > 0 And govIdx <= 255 Then
            provinces(i + 1, 4) = generals(govIdx, 3) ' governor name
        Else
            provinces(i + 1, 4) = ""
        End If
        provinces(i + 1, 5) = dataBytes(offset + 9) + dataBytes(offset + 10) * 256 ' gold
        provinces(i + 1, 6) = dataBytes(offset + 11) + CLng(dataBytes(offset + 12)) * 256 + CLng(dataBytes(offset + 13)) * 65536 ' food
        provinces(i + 1, 7) = (dataBytes(offset + 15) + CLng(dataBytes(offset + 16) * 256)) * 100 ' pop
        provinces(i + 1, 8) = rulerIdx ' ruler_idx
        provinces(i + 1, 9) = dataBytes(offset + 24) ' loy
        provinces(i + 1, 10) = dataBytes(offset + 23) ' land
        provinces(i + 1, 11) = dataBytes(offset + 25) ' flood
        provinces(i + 1, 12) = dataBytes(offset + 26) ' horses
        provinces(i + 1, 13) = dataBytes(offset + 27) ' forts
        provinces(i + 1, 14) = dataBytes(offset + 28) ' rate
        provinces(i + 1, 15) = (dataBytes(offset + 20) Mod 4) > 0 ' merch
        provinces(i + 1, 16) = dataBytes(offset + 35) ' state
        ' Debug.Print provinces(i + 1, 1), provinces(i + 1, 4), provinces(i + 1, 5), provinces(i + 1, 6), provinces(i + 1, 7), provinces(i + 1, 8)  ' Ok
    Next i
    ExtractProvinces = provinces
End Function

' Ruler 데이터 추출
Function ExtractRulers(dataBytes() As Byte, generals As Variant) As Variant
    Dim rulers(1 To 16, 1 To 6) As Variant
    Dim i As Integer, offset As Long, rulerIdx As Integer, advisorIdx As Integer, capitalIdx As Integer
    For i = 0 To 15
        offset = 11004 + i * 41
        rulerIdx = (dataBytes(offset + 1) + dataBytes(offset + 2) * 256 - 88) \ 43 + 1
        advisorIdx = (dataBytes(offset + 5) + dataBytes(offset + 6) * 256 - 88) \ 43 + 1
        capitalIdx = (dataBytes(offset + 3) + dataBytes(offset + 4) * 256 - 21 - 11660) \ 35
        rulers(i + 1, 1) = rulerIdx
        If rulerIdx >= 0 And rulerIdx <= 255 Then
            rulers(i + 1, 2) = generals(rulerIdx, 3) ' ruler_name
        Else
            rulers(i + 1, 2) = ""
        End If
        rulers(i + 1, 3) = capitalIdx
        rulers(i + 1, 4) = advisorIdx
        If advisorIdx >= 0 And advisorIdx <= 255 Then
            rulers(i + 1, 5) = generals(advisorIdx, 3) ' advisor_name
        Else
            rulers(i + 1, 5) = ""
        End If
        rulers(i + 1, 6) = dataBytes(offset + 7) ' trust
        ' Debug.Print rulerIdx, advisorIdx, capitalIdx, rulers(i + 1, 2), rulers(i + 1, 5)  ' Ok
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
    wsGen.Range("A2").Resize(UBound(generals, 1), UBound(generals, 2)).Value = generals

    ' Province 데이터 출력
    Dim wsProv As Worksheet
    Set wsProv = ThisWorkbook.Sheets(WS_NAME_PROVINCE)
    wsProv.Cells.Clear
    wsProv.Range("A2").Resize(UBound(provinces, 1), UBound(provinces, 2)).Value = provinces

    ' Ruler 데이터 출력
    Dim wsRul As Worksheet
    Set wsRul = ThisWorkbook.Sheets(WS_NAME_RULER)
    wsRul.Cells.Clear
    wsRul.Range("A2").Resize(UBound(rulers, 1), UBound(rulers, 2)).Value = rulers
End Sub
