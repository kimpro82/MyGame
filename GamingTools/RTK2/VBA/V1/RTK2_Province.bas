Option Explicit


Sub ReadProvinceData()

    'Call the target file's path that user entered
    Dim path As String
    path = "C:\Game\Koei\RTK2" & Application.PathSeparator & Sheets("VBA1").Range("B1")

    'Check if the file exists
    Dim fileChk As Boolean                              'default : False
    If (Len(Dir(path)) > 0) Then fileChk = True
    Sheets("VBA1").Range("B2") = fileChk

    Dim fn As Integer                                   'fn : file number
    fn = FreeFile

    'Read the file
    Open path For Binary Access Read As #fn

        'call parameters that user entered on the sheet
        Dim pos, posEnd, interval As Integer
        pos = Sheets("VBA1").Range("B3").Value
        interval = Sheets("VBA1").Range("B4").Value
        posEnd = Sheets("VBA1").Range("B5").Value

        'initialize criteria
        Dim row, col, colEnd As Integer
        row = 1
        col = 1
        colEnd = pos + interval

        'set offset location for output
        Dim output As Range
        Set output = Sheets("VBA1").Range("B8")

        Dim data As Byte

        'loop for each row
        While pos <= posEnd
            
            'loop for shifting cell to the right
            While col <= interval
                Get #fn, pos, data                      'read data one by one
                output.Offset(row, col).Value = data    'print each byte

                pos = pos + 1
                col = col + 1
            Wend
            
            'print #province
            output.Offset(row, 0).Value = row

            'set parameters for the next loop
            row = row + 1
            col = 1
            colEnd = colEnd + interval                  'set the end for the next row

        Wend

    Close #fn

End Sub