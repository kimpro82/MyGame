Option Explicit


Sub ReadGeneral()

    'Call the target file's path that user entered
    Dim path As String
    path = ThisWorkbook.path & Application.PathSeparator & Range("B1")

    'Check if the file exists
    Dim fileChk As Boolean                              'default : False
    If (Len(Dir(path)) > 0) Then fileChk = True
    Range("B2") = fileChk

    Dim fn As Integer                                   'fn : file number
    fn = FreeFile

    'Read the file
    Open path For Binary Access Read As #fn

        'call parameters the user entered on the sheet
        Dim pos, posEnd, interval As Integer
        pos = Range("B3").Value
        interval = Range("B4").Value
        posEnd = Range("B5").Value
        
        'initialize criteria
        Dim row, col, colEnd As Integer
        row = 1
        col = 1
        colEnd = pos + interval

        'set offset location for output
        Dim output As Range
        Set output = Range("B8")

        'declare name variable for gathering byte data
        Dim data As Byte, name As String
        name = ""

        'loop for each row
        While pos <= posEnd
            
            'loop for shifting a cell to the right
            While col <= interval
                Get #fn, pos, data                      'read data one by one
                If col >= 27 Then
                    name = name & Chr(data)             'assemble name from each byte
                output.Offset(row, col).Value = data    'print each byte
                
                pos = pos + 1
                col = col + 1
            Wend

            'print the general's name of the recent row
            output.Offset(row, 0).Value = name
            name = ""

            'set parameters for the next loop
            row = row + 1
            col = 1
            colEnd = colEnd + interval                  'set the end of the next row

        Wend

    Close #fn

End Sub