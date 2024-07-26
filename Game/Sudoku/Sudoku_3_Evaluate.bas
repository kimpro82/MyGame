' Sudoku for My Sister

' 0. Initialization (2022.12.22) : Thank you ChatGPT!
' 1. Generate a Sudoku puzzle (2022.12.28)
' 2. Masking the puzzle by level (2022.12.29)
' 3. Evaluate the Answer (2022.12.30)


Option Explicit


' Update (2022.12.30) : Move the Declaration locations out of Main()
Private Sudoku(1 To 9, 1 To 9)      As Integer
Private sudokuMask(1 To 9, 1 To 9)  As Integer
Private sudokuAnswer()              As Integer                                  ' The new array should not be fixed

Private zeroPoint                   As Range                                    ' zeroPiont     : to start 9x9 matrix
Private level                       As Integer                                  ' level         : determine how much masking
Private hintNum                     As Integer                                  ' hintNum       : the number how much hints are given
Private onGameFlag                  As Boolean                                  ' onGameFlag    : do not run intersect() when False


' Update (2022.12.30) : Rename GenerateSudoku() to Main()
Private Sub Main()

    ' Set parameters
    Call SetParameters(zeroPoint, level, hintNum)

    ' Initialize the Sudoku array before shuffle
    Call GenerateInitialPuzzle(Sudoku)

    ' Shuffle the puzzle
    Call ShufflePuzzle(Sudoku)

    ' Masking the puzzle by the level
    Call MaskingPuzzle(Sudoku, sudokuMask, level)

    ' Evaluate the answer
    sudokuAnswer = sudokuMask
    ' EvaluatePuzzle() runs through Worksheet_Change()

    ' Print the Sudoku puzzle to the sheet
    onGameFlag = False
        Call PrintPuzzle(sudokuAnswer, zeroPoint)
    onGameFlag = True

End Sub


' Update (2022.12.30) : Merge 3 procedures for each parameter
Private Sub SetParameters(ByRef zeroPoint As Range, ByRef level As Integer, ByRef hintNum As Integer)

    Set zeroPoint = Range("C5")
    level = Range("R2")
    hintNum = Range("V2")

End Sub


Private Sub GenerateInitialPuzzle(ByRef puzzle As Variant)

    zeroPoint.Offset(-1, 0).Value = ""

    
    Dim i As Integer, j As Integer, starting As Integer
    For i = 1 To 9
        ' Update (2022.12.30) : More compact code
        starting = (i - 1) * 3 Mod 9 + (i - 1) / 3

'        Old Ver. (2022.12.28) : it seems not minimized but anyway works
'        If i < 4 Then
'            starting = (i - 1) * 3 Mod 9
'        ElseIf i < 7 Then
'            starting = ((i - 1) * 3 + 1) Mod 9
'        Else
'            starting = ((i - 1) * 3 + 2) Mod 9
'        End If

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


' Update (2022.12.28)
Private Sub ShufflePuzzle(ByRef puzzle As Variant)

    Dim n As Integer
    n = 100

    Dim i As Integer, j As Integer
    Dim a As Integer, b As Integer, temp(1 To 9) As Integer
    For i = 1 To n
        a = Int(Rnd * 9) + 1
        b = Int((a - 1) / 3) * 3 + Int(Rnd * 3) + 1                             ' quite proud code …… !

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


' Update (2022.12.29)
Private Sub MaskingPuzzle(ByRef puzzle As Variant, ByRef puzzleMask As Variant, ByRef level As Integer)

    Dim i As Integer, j As Integer
    For i = 1 To 9
        For j = 1 To 9
            If Int(Rnd * 10) >= level Then
                puzzleMask(i, j) = puzzle(i, j)
            Else
                puzzleMask(i, j) = 0
            End If
        Next j
    Next i

End Sub


' Update (2022.12.30) : Update the SudokuAnswer at once
Private Sub PrintPuzzle(ByRef puzzle As Variant, ByRef zeroPoint As Range)

    ' Print the puzzle to the sheet
    onGameFlag = False
        zeroPoint.Resize(9, 9).Value = puzzle
    onGameFlag = True

'    ' Old Ver.
'    Dim i As Integer, j As Integer
'    For i = 1 To 9
'        For j = 1 To 9
'            If puzzle(i, j) <> 0 Then
'                zeroPoint.Offset(i - 1, j - 1).Value = puzzle(i, j)
'            Else
'                zeroPoint.Offset(i - 1, j - 1).Value = ""
'            End If
'        Next j
'    Next i

End Sub


Private Sub Hint()

    Debug.Print "Hint function is not completed yet"
    ' Debug.Print Me.Name & "() is not completed yet"                           ' Me.Name : "Soduku"

End Sub


Private Sub AutoSolve()

    Debug.Print "Auto Solve function is not completed yet"

End Sub


' Update (2022.12.30)
Private Sub Clear()

    Dim Rng As Range
    Set Rng = zeroPoint.Resize(9, 9)
    ' Debug.Print Rng.Address                                                   ' ok

    onGameFlag = False
        Rng.ClearContents
        zeroPoint.Offset(-1, 0).Value = ""
    onGameFlag = True

End Sub


' Update (2022.12.30)
Private Sub Worksheet_Change(ByVal Target As Range)

    If (onGameFlag = True) And (Not Intersect(zeroPoint.Resize(9, 9), Target) Is Nothing) Then
        ' Debug.Print Target.Address                                            ' ok
        Call EvaluatePuzzle(Target.Address)
        Call PrintPuzzle(sudokuAnswer, zeroPoint)
    End If

End Sub


' Update (2022.12.30)
Private Sub EvaluatePuzzle(ByRef ChangedCell As String)

    ' Debug.Print ChangedCell                                                   ' ok
    Dim i As Integer, j As Integer, ans As Integer
    i = Range(ChangedCell).Row - zeroPoint.Row + 1
    j = Range(ChangedCell).Column - zeroPoint.Column + 1
    ans = Range(ChangedCell).Value
    ' Debug.Print i & j & ans                                                   ' ok

    If Sudoku(i, j) = Range(ChangedCell).Value Then
        zeroPoint.Offset(-1, 0).Value = "Correct!"
        sudokuAnswer(i, j) = Range(ChangedCell).Value
    Else
        zeroPoint.Offset(-1, 0).Value = "(" & i & ", " & j & ") is not " & ans & "!"
    End If

End Sub


' Buttons

Private Sub btnGenerate_Click()
    
    Application.Calculation = xlManual
       Call Main
    Application.Calculation = xlAutomatic

End Sub


Private Sub btnHint_Click()

    Application.Calculation = xlManual
        Call Hint
    Application.Calculation = xlAutomatic

End Sub


Private Sub btnAutoSolve_Click()

    Application.Calculation = xlManual
        Call AutoSolve
    Application.Calculation = xlAutomatic

End Sub


Private Sub btnClear_Click()

    Application.Calculation = xlManual
        Call Clear
    Application.Calculation = xlAutomatic

End Sub