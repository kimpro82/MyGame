' Sudoku

' 0. Initialization (2022.12.22) : Thank you ChatGPT!
' 1. Generate a Sudoku puzzle (2022.12.28)


Option Explicit


Private Sub GenerateSudoku()

    ' Set zeroPiont to start 9x9 matrix
    Dim zeroPoint As Range
    Call GetZeroPoint(zeroPoint)

    ' Initialize the Sudoku array before shuffle
    Dim sudoku(1 To 9, 1 To 9) As Integer
    Call GenerateInitialPuzzle(sudoku)

    ' Shuffle the puzzle
    Call ShufflePuzzle(sudoku)

    ' Print the Sudoku puzzle to the sheet
    Call PrintPuzzle(sudoku, zeroPoint)

End Sub


Private Sub GetZeroPoint(ByRef zeroPoint As Range)

    Set zeroPoint = Range("C5")

End Sub


Private Sub GenerateInitialPuzzle(ByRef puzzle As Variant)

    ' Update (2022.12.28); it seems not minimized but anyway works
    Dim i As Integer, j As Integer, starting As Integer
    For i = 1 To 9
        If i < 4 Then
            starting = (i - 1) * 3 Mod 9
        ElseIf i < 7 Then
            starting = ((i - 1) * 3 + 1) Mod 9
        Else
            starting = ((i - 1) * 3 + 2) Mod 9
        End If

        For j = 1 To 9
            puzzle(i, j) = (starting + j - 1) Mod 9 + 1
        Next j
    Next i

'    ' Temporary (2022.12.22); to be advanced
'    Dim i As Integer, j As Integer
'    For i = 1 To 9
'        For j = 1 To 9
'            puzzle(i, j) = Int(Rnd * 9) + 1
'        Next j
'    Next i

End Sub


Private Sub ShufflePuzzle(ByRef puzzle As Variant)

    Dim n As Integer
    n = 100

    Dim i As Integer, j As Integer
    Dim a As Integer, b As Integer, temp(1 To 9) As Integer
    For i = 1 To n
        a = Int(Rnd * 9) + 1
        b = Int(Rnd * 9) + 1

        For j = 1 To 9
            If i Mod 2 = 0 Then
                temp(j) = puzzle(a, j)
                puzzle(a, j) = puzzle(b, j)
                puzzle(b, j) = temp(j)
            Else
                temp(j) = puzzle(j, a)
                puzzle(j, a) = puzzle(j, b)
                puzzle(j, b) = temp(j)
            End If
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