Option Explicit


Sub ReadProvinceData()

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

        Dim data As Byte

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

            'print #province
            output.Offset(row, -1).Value = row + 1

            'print population (1 = 10,000 people)
            output.Offset(row, 35).Value = ( _
                output.Offset(row, 15).Value * 256 _
                + output.Offset(row, 14).Value _
            ) / 100

            'print gold
            output.Offset(row, 36).Value = ( _
                output.Offset(row, 9).Value * 256 _
                + output.Offset(row, 8).Value _
            ) / 100

            'print food
            output.Offset(row, 37).Value = ( _
                output.Offset(row, 12).Value * 256 * 256 _
                + output.Offset(row, 11).Value * 256 _
                + output.Offset(row, 10).Value _
            ) / 10000

            'print #population * loyalty
            output.Offset(row, 38).Value = ( _
                output.Offset(row, 35).Value _
                * output.Offset(row, 23).Value _
            )

            'print productivity : pop * (land + flood + loyalty) / 300
            output.Offset(row, 39).Value = ( _
                output.Offset(row, 35).Value _
                * _
                ( _
                    output.Offset(row, 22).Value _
                    + output.Offset(row, 23).Value _
                    + output.Offset(row, 24).Value _
                ) / 300 _
            )

            'set parameters for the next loop
            row = row + 1
            col = 0
            colEnd = colEnd + interval                  'set the end for the next row

        Wend

    Close #fn

End Sub


Private Sub btnReadProvinceData_Click()

    ' Skip excel formula calculation temporarily
    Application.Calculation = xlManual
        Call ReadProvinceData
    Application.Calculation = xlAutomatic

End Sub