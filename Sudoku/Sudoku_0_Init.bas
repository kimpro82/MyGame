' Sudoku
' 2022.12.22

' Thank you ChatGPT!


Option Explicit


Private Sub GenerateSudoku()

    ' Set zeroPiont to start 9x9 matrix
    Dim zeroPoint As Range
    Call GetZeroPoint(zeroPoint)

    Dim sudoku(1 To 9, 1 To 9) As Integer

    ' Initialize the Sudoku array with zeros
    Dim i As Integer, j As Integer
    For i = 1 To 9
        For j = 1 To 9
            sudoku(i, j) = 0
        Next j
    Next i

    ' Generate the Sudoku puzzle
    Call GeneratePuzzle(sudoku)

    ' Print the Sudoku puzzle to the sheet
    Call PrintPuzzle(sudoku, zeroPoint)

End Sub


Private Sub GetZeroPoint(ByRef zeroPoint As Range)

    Set zeroPoint = Range("C5")

End Sub


Private Sub GeneratePuzzle(ByRef puzzle As Variant)

    ' Temporary; to be advanced
    Dim i As Integer, j As Integer
    For i = 1 To 9
        For j = 1 To 9
            puzzle(i, j) = Int(Rnd * 9) + 1
        Next j
    Next i

End Sub


Private Sub PrintPuzzle(ByRef puzzle As Variant, ByRef zeroPoint As Range)

    ' Print the puzzle to the sheet
    Dim i As Integer, j As Integer
    For i = 1 To 9
        For j = 1 To 9
            zeroPoint.Offset(i - 1, j - 1).Value = puzzle(i, j)
        Next j
    Next i

End Sub


Private Sub Hint()

    Debug.Print "Hint function is not completed yet"
    ' Debug.Print Me.Name & "() is not completed yet"                           ' Me.Name : "Soduku"

End Sub


Private Sub AutoSolve()

    Debug.Print "Auto Solve function is not completed yet"

End Sub


Private Sub Clear()

    Dim zeroPoint As Range
    Call GetZeroPoint(zeroPoint)

    Dim Rng As Range
    Set Rng = zeroPoint.Resize(9, 9)

    With Rng
        .ClearContents
    End With

End Sub



' Buttons

Private Sub btnGenerate_Click()

    Call GenerateSudoku

End Sub


Private Sub btnHint_Click()

    Call Hint

End Sub


Private Sub btnAutoSolve_Click()

    Call AutoSolve

End Sub


Private Sub btnClear_Click()

    Call Clear

End Sub