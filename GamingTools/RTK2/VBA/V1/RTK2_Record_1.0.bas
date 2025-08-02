Option Explicit


Sub RecordGameData()

    'Call the target file's path that user entered
    Dim path As String
    path = "C:\Game\Koei\RTK2\" & Range("B1")

    'Check if the file exists
    Dim fileChk As Boolean                                  'default : False
    If (Len(Dir(path)) > 0) Then fileChk = True
    Range("B2") = fileChk

    Dim fn As Integer                                       'fn : file number
    fn = FreeFile

    'Call the file's date (YYY-MM)
    Dim yyy As Byte, mm As Byte, ym As String

        'Read the file
        Open path For Binary Access Read As #fn
            Get #fn, 13, yyy
            Get #fn, 15, mm
        Close #fn

    Range("B3") = yyy

    mm = mm + 1                                             'add 1 because Jan : 0, Feb : 1
    If mm + 1 < 10 Then
        Range("B4") = 0 & mm
        ym = CStr(yyy) & "-0" & CStr(mm)
    Else
        Range("B4") = mm
        ym = CStr(yyy) & "-" & CStr(mm)
    End If
    Debug.Print "yyy-mm : " & ym                            'test : ok

    'Get the Zero Point
    Dim zero As Range
    Set zero = Range("A8")                                  'don't forget 'Set'!

    'Get the Starting Row Number for New Data
    Dim row As Integer
    row = Sheet8.UsedRange.Rows.Count - zero.row + 1        'do not add any format in the data area (it causes there to be recognized as used range)
    Debug.Print "new data starts from row " & row

    'Get the New Data
    Range("C8:BG23").Offset(row, 0) = Sheet7.Range("B9:BF24").Value

    'Fill Filename and YYY-MM
    Dim i As Integer, n As Integer
    n = 16                                                  'if the ruler doesn't exist?
    Debug.Print "new data's row : " & n                     'test : ok
    Debug.Print zero.Offset(row, 0).row                     'test : ok
    For i = 1 To n
        zero.Offset(row + i - 1, 0) = Range("b1").Value
        zero.Offset(row + i - 1, 1) = ym

        'when the ruler's slot is empty
        If zero.Offset(row + i - 1, 3) = 0 Then
            zero.Offset(row + i - 1, 2) = 99
        End If
    Next i

End Sub


Sub btnRecordGameData_Click()

    'Unify the save file name among all the sheets
    Sheet5.Range("B1").Value = Range("B1")
    Sheet6.Range("B1").Value = Range("B1")
    Sheet7.Range("B1").Value = Range("B1")

    'Skip excel formula calculation temporarily
    Application.Calculation = xlManual
        Call Sheet5.ReadGeneralData
        Call Sheet6.ReadProvinceData
        Call Sheet7.ReadRulerData
        Call Sheet8.RecordGameData
    Application.Calculation = xlAutomatic

    ' Refresh the Pivot Table and Chart
    Sheet9.PivotTables("PivotTable").PivotCache.Refresh

End Sub