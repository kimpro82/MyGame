Option Explicit


Sub ReadRulerData()

    'Call the target file's path that user entered
    Dim path As String
    path = "C:\Game\Koei\RTK2\" & Range("B1")

    'Check if the file exists
    Dim fileChk As Boolean                              'default : False
    If (Len(Dir(path)) > 0) Then fileChk = True
    Range("B2") = fileChk

    Dim fn As Integer                                   'fn : file number
    fn = FreeFile

    'Read the file
    Open path For Binary Access Read As #fn

        'call parameters that user entered on the sheet
        Dim pos, posEnd, interval As Integer
        pos = Range("B3").Value
        interval = Range("B4").Value
        posEnd = Range("B5").Value

        'initialize criteria
        Dim row, col, colEnd As Integer
        row = 0
        col = 0
        colEnd = pos + interval

        'set offset location for output
        Dim output As Range
        Set output = Range("C9")

        'declare name variable for gathering byte data
        Dim data As Byte, name As String
        name = ""

        'loop for each row
        While pos < posEnd

            'print the index number
            output.Offset(row, -2).Value = pos

            'loop for shifting cell to the right
            While col < interval
                Get #fn, pos, data                      'read data one by one
                output.Offset(row, col).Value = data    'print each byte

                pos = pos + 1
                col = col + 1
            Wend

            'print the ruler's number
            output.Offset(row, -1).Value = row

            'print the ruler's name
            output.Offset(row, 41).Value = Application.WorksheetFunction.IfError( _
                Application.VLookup( _
                    output.Offset(row, 0).Value + output.Offset(row, 1).Value * 256 - 53, _
                    Sheet5.Range("A:B"), _
                    2, _
                    False _
                ), _
                "" _
            )

            'print the advisor's name
            output.Offset(row, 42).Value = Application.WorksheetFunction.IfError( _
                Application.VLookup( _
                    output.Offset(row, 4).Value + output.Offset(row, 5).Value * 256 - 53, _
                    Sheet5.Range("A:B"), _
                    2, _
                    False _
                ), _
                "" _
            )

            'print the number of the provinces
            output.Offset(row, 43).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.CountIf( _
                    Sheet6.Range("S:S"), _
                    row _
                ), _
                "" _
            )

            'print the total population (1 = 10,000 people)
            output.Offset(row, 44).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AL:AL") _
                ), _
                "" _
            )

            'print the total gold (1 = 100 gold)
            output.Offset(row, 45).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AM:AM") _
                ), _
                "" _
            )

            'print the total food (1 = 10,000 food)
            output.Offset(row, 46).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AN:AN") _
                ), _
                "" _
            )

            'print the total horses
            output.Offset(row, 47).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AB:AB") _
                ), _
                "" _
            )

            'print the average loyalty (weighted)
            'caution : exiled rulers cause an error : divide by zero → infinity → stack overflow
            output.Offset(row, 48).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AO:AO") _
                ) / Application.WorksheetFunction.Max(1, output.Offset(row, 44).Value), _
                "" _
            )

'            'print the average loyalty (simple)
'            output.Offset(row, 48).Value = Application.WorksheetFunction.IfError( _
'                Application.WorksheetFunction.SumIf( _
'                    Sheet6.Range("S:S"), _
'                    row, _
'                    Sheet6.Range("Z:Z") _
'                ) / output.Offset(row, 44).Value, _
'                "" _
'            )

            'print the total productivity (to find better measures)
            output.Offset(row, 49).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet6.Range("S:S"), _
                    row, _
                    Sheet6.Range("AP:AP") _
                ), _
                "" _
            )

            'print the number of the generals
            output.Offset(row, 50).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.CountIfs( _
                    Sheet5.Range("K:K"), _
                    row, _
                    Sheet5.Range("Z:Z"), _
                    ">0" _
                ), _
                "" _
            )

            'print the total soldiers
            output.Offset(row, 51).Value = Application.WorksheetFunction.IfError( _
                ( _
                    Application.WorksheetFunction.SumIf( _
                        Sheet5.Range("K:K"), _
                        row, _
                        Sheet5.Range("T:T") _
                    ) * 256 _
                    + _
                    Application.WorksheetFunction.SumIf( _
                        Sheet5.Range("K:K"), _
                        row, _
                        Sheet5.Range("S:S") _
                    ) _
                ) / 10000, _
                "" _
            )

            'print the sum of the soldiers' quality
            output.Offset(row, 52).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.SumIf( _
                    Sheet5.Range("K:K"), _
                    row, _
                    Sheet5.Range("AT:AT") _
                ), _
                "" _
            )

            'print the manpower (Int)
            output.Offset(row, 53).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.CountIfs( _
                    Sheet5.Range("K:K"), _
                    row, _
                    Sheet5.Range("Z:Z"), _
                    ">0", _
                    Sheet5.Range("E:E"), _
                    ">=80" _
                ), _
                "" _
            )

            'print the manpower (War)
            output.Offset(row, 54).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.CountIfs( _
                    Sheet5.Range("K:K"), _
                    row, _
                    Sheet5.Range("Z:Z"), _
                    ">0", _
                    Sheet5.Range("F:F"), _
                    ">=80" _
                ), _
                "" _
            )
            
            'print the manpower (Cham)
            output.Offset(row, 55).Value = Application.WorksheetFunction.IfError( _
                Application.WorksheetFunction.CountIfs( _
                    Sheet5.Range("K:K"), _
                    row, _
                    Sheet5.Range("Z:Z"), _
                    ">0", _
                    Sheet5.Range("G:G"), _
                    ">=80" _
                ), _
                "" _
            )

            'print the manpower (Total)
            output.Offset(row, 56).Value = Application.WorksheetFunction.IfError( _
                output.Offset(row, 53).Value _
                + output.Offset(row, 54).Value _
                + output.Offset(row, 55).Value _
                , _
                "" _
            )

            'print total measurement (old)
            'weight : Province * Productivuty 2.5  / Gold & Food 2.5 / Generals 2.5 (Manpower +2.5) / Arms 2.5
            output.Offset(row, 57).Value = Application.WorksheetFunction.IfError( _
                (output.Offset(row, 49).Value / 50) * 2.5 _
                + (output.Offset(row, 45).Value + output.Offset(row, 46).Value) / 2 / 300 * 2.5 _
                + (output.Offset(row, 50).Value + output.Offset(row, 56).Value) / (255 / 41) * 2.5 _
                + output.Offset(row, 51).Value / (255 / 41) * 2.5 _
                , _
                "" _
            )

            'print total measurement (new)
            'weight : Province 0.125 (+ Productivuty 0.125) / Gold & Food 0.25 / Generals 0.125 (Manpower +0.125) / Arms 0.125 (+ Quality 0.125)
            output.Offset(row, 57).Value = Application.WorksheetFunction.IfError( _
                (output.Offset(row, 43).Value + output.Offset(row, 49).Value / 50) * 0.125 _
                + (output.Offset(row, 45).Value + output.Offset(row, 46).Value) / 2 / 300 * 0.25 _
                + (output.Offset(row, 50).Value + output.Offset(row, 56).Value * 2) / (255 / 41) * 0.125 _
                + (output.Offset(row, 51).Value + output.Offset(row, 52).Value) / (255 / 41) * 0.125 _
                , _
                "" _
            )

            'set parameters for the next loop
            row = row + 1
            col = 0
            colEnd = colEnd + interval                  'set the end for the next row

        Wend

    Close #fn

End Sub


Private Sub btnReadRulerData_Click()

    ' Skip excel formula calculation temporarily
    Application.Calculation = xlManual
        Call ReadRulerData
    Application.Calculation = xlAutomatic

End Sub