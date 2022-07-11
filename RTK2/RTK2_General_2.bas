Option Explicit


Sub ReadGeneralData()

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
                If col >= 26 Then
                    name = name & Chr(data)             'assemble name from each byte
                End If
                output.Offset(row, col).Value = data    'print each byte

                pos = pos + 1
                col = col + 1
            Wend

            'print the general name
            output.Offset(row, -1).Value = name
            name = ""

            'print the soldiers' quality : (men / 10000) * (weapon + trainning * 100) / 20000
            output.Offset(row, 43).Value = _
                (output.Offset(row, 16).Value + output.Offset(row, 17).Value * 256) / 10000 _
                * (output.Offset(row, 18).Value + output.Offset(row, 19).Value * 256 _
                   + output.Offset(row, 20).Value * 100) _
                / 20000

            'set parameters for the next loop
            row = row + 1
            col = 0
            colEnd = colEnd + interval                  'set the end for the next row

        Wend

    Close #fn

End Sub


Private Sub btnReadGeneralData_Click()

    ' Skip excel formula calculation temporarily
    Application.Calculation = xlManual
        Call ReadGeneralData
    Application.Calculation = xlAutomatic

End Sub