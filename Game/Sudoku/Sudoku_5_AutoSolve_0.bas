' Sudoku for My Sister

' 0. Initialization (2022.12.22) : Thank you ChatGPT!
' 1. Generate a Sudoku puzzle (2022.12.28)
' 2. Masking the puzzle by level (2022.12.29)
' 3. Evaluate the Answer (2022.12.30)
' 4. Hint (2022.12.31)
' 5. Auto Solve (2023.01.02)


Option Explicit


' Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)       ' for Sleep()


' Update (2022.12.30) : Move the Declaration locations out of Main()
Private sudoku(1 To 9, 1 To 9)      As Integer
Private sudokuMask(1 To 9, 1 To 9)  As Integer
Private sudokuAnswer()              As Integer                                  ' The new array should not be fixed

Private zeroPoint                   As Range                                    ' zeroPiont     : to start 9x9 matrix
Private level                       As Integer                                  ' level         : determine how much masking
Private hintNum                     As Integer                                  ' hintNum       : the number how much hints are given
Private hintFlag                    As Boolean                                  ' hintFlag      : print other message when True
Private onGameFlag                  As Boolean                                  ' onGameFlag    : do not run intersect() when False


' Update (2022.12.30) : Rename GenerateSudoku() to Main()
Private Sub Main()

    ' Set parameters
    Call SetParameters(zeroPoint, level, hintNum, hintFlag)

    ' Initialize the Sudoku array before shuffle
    Call GenerateInitialPuzzle(sudoku)

    ' Shuffle the puzzle
    Call ShufflePuzzle(sudoku)

    ' Masking the puzzle by the level
    Call MaskingPuzzle(sudoku, sudokuMask, level)

    ' Evaluate the answer
    sudokuAnswer = sudokuMask
    ' EvaluatePuzzle() runs through Worksheet_Change()

    ' Print the Sudoku puzzle to the sheet
    onGameFlag = False
        Call PrintPuzzle(sudokuAnswer, zeroPoint)
    onGameFlag = True

End Sub


' Update (2022.12.30) : Merge 3 procedures for each parameter
Private Sub SetParameters(ByRef zeroPoint As Range, ByRef level As Integer, ByRef hintNum As Integer, ByRef hintFlag As Boolean)

    Set zeroPoint = Range("C5")
    level = Range("R2")
    Range("V2") = 5
    hintNum = Range("V2")
    hintFlag = False

End Sub


Private Sub GenerateInitialPuzzle(ByRef puzzle As Variant)

    zeroPoint.Offset(-1, 0).Value = ""
    
    Dim i As Integer, j As Integer, starting As Integer
    For i = 1 To 9
        ' Update (2022.12.30) : More compact code
        starting = ((i - 1) * 3 + Int((i - 1) / 3)) Mod 9

'       ' Old Ver. (2022.12.28) : it seems not minimized but anyway works
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
    Dim a As Integer, b As Integer, temp As Integer
    For i = 1 To n
        a = Int(Rnd * 9) + 1
        b = Int((a - 1) / 3) * 3 + Int(Rnd * 3) + 1                             ' quite proud code …… !

        If i Mod 2 = 0 Then
            For j = 1 To 9
                temp = puzzle(a, j)
                puzzle(a, j) = puzzle(b, j)
                puzzle(b, j) = temp
            Next j
        Else
            For j = 1 To 9
                temp = puzzle(j, a)
                puzzle(j, a) = puzzle(j, b)
                puzzle(j, b) = temp
            Next j
        End If
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


' Update (2022.12.31)
Private Sub Hint(ByRef puzzle As Variant, ByRef puzzleAnswer As Variant, ByRef zeroPoint As Range)

    If hintNum > 0 Then
        Dim i As Integer, j As Integer
        Do
            i = Int(Rnd * 9) + 1
            j = Int(Rnd * 9) + 1
            If puzzleAnswer(i, j) = 0 Then
                hintFlag = True
                hintNum = hintNum - 1
                Range("V2").Value = hintNum                                     ' seems not the best way ……
                ' Debug.Print i & j & puzzle(i, j)
                zeroPoint.Offset(i - 1, j - 1).Value = puzzle(i, j)
                Exit Do
            End If
        Loop
    End If

End Sub


' Update (2023.01.02)
Private Sub AutoSolve(ByRef puzzle As Variant, ByRef puzzleAnswer As Variant, ByRef zeroPoint As Range)

    Dim i As Integer, j As Integer, k As Integer, l As Integer
    Dim completeFlag As Boolean, solve1 As Boolean, unique As Integer, answer As Integer
    ' Dim cntNum(0 To 9) As Integer                                             ' 0 should be included (but not to be used)

    Do                                                                          ' ★ escape with <Ctrl + Pause Break> when infinite loop!
        ' Sleep (100)
        completeFlag = True
        solve1 = False
        For i = 1 To 9
            For j = 1 To 9
                If puzzleAnswer(i, j) = 0 Then
                    ' Erase cntNum                                              ' foxed error
                    Dim cntNum(0 To 9) As Integer                               ' temporary alternative
                    completeFlag = False
                    Debug.Print "A loop for (" & i & ", " & j & ")"

                    ' 1) Check the row
                    For k = 1 To 9
                        ' Debug.Print i & k
                        cntNum(puzzleAnswer(i, k)) = 1
                    Next k
                    ' 2) Check the column
                    For k = 1 To 9
                        ' Debug.Print k & j
                        cntNum(puzzleAnswer(k, j)) = 1
                    Next k
                    ' 3) Check the 3x3 box
                    For k = 1 To 3
                        For l = 1 To 3
                            ' Debug.Print Int((i - 1) / 3) * 3 + k & Int((j - 1) / 3) * 3 + l
                            cntNum(puzzleAnswer(Int((i - 1) / 3) * 3 + k, Int((j - 1) / 3) * 3 + l)) = 1
                        Next l
                    Next k
                    ' 4) Find the unique answer
                    unique = 0
                    For k = 1 To 9
                        If cntNum(k) = 0 Then
                            Debug.Print "(" & i & ", " & j & ") : " & k
                            answer = k
                            unique = unique + 1
                        End If
                    Next k
                    ' 5) Answer if unique
                    If unique = 1 Then
                        zeroPoint.Offset(i - 1, j - 1).Value = answer
                        solve1 = True
                    End If
                End If
            Next j
        Next i

        ' 6) Hint if solve1 = 0
        If solve1 = False And hintNum > 0 Then
            Call Hint(puzzle, puzzleAnswer, zeroPoint)
            solve1 = True
        End If

        ' 7) Evaluate the auto-sovaltion for a loop
        Debug.Print completeFlag & " " & solve1 & " " & hintNum
        If completeFlag = True Then
            zeroPoint.Offset(-1, 0).Value = "Auto-Solvation completed!"
            Exit Do
        ElseIf solve1 = False And hintNum = 0 Then
            zeroPoint.Offset(-1, 0).Value = "Auto-Solvation Failed!"
            Exit Do
        End If
    Loop

'    ' Temporary : Exactly not solving, but just cheating ……
'    Dim i As Integer, j As Integer
'    For i = 1 To 9
'        For j = 1 To 9
'            If puzzleAnswer(i, j) = 0 Then
'                puzzleAnswer(i, j) = puzzle(i, j)
'                zeroPoint.Offset(i - 1, j - 1).Value = puzzle(i, j)
'            End If
'        Next j
'    Next i

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
        Call EvaluatePuzzle(Target.Address, hintFlag)
        Call PrintPuzzle(sudokuAnswer, zeroPoint)
    End If

End Sub


' Update (2022.12.30)
Private Sub EvaluatePuzzle(ByRef ChangedCell As String, ByRef hintFalg As Boolean)

    ' Debug.Print ChangedCell                                                   ' ok
    Dim i As Integer, j As Integer, ans As Integer
    i = Range(ChangedCell).Row - zeroPoint.Row + 1
    j = Range(ChangedCell).Column - zeroPoint.Column + 1
    ans = Range(ChangedCell).Value
    ' Debug.Print i & j & ans                                                   ' ok

    If sudoku(i, j) = Range(ChangedCell).Value Then
        ' Update (2022.12.31) : Differ the message when hint
        If hintFlag = False Then
            zeroPoint.Offset(-1, 0).Value = "Correct!"
        Else
            zeroPoint.Offset(-1, 0).Value = "(" & i & ", " & j & ") is " & ans & "!"
            hintFalg = False
        End If
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
        Call Hint(sudoku, sudokuAnswer, zeroPoint)
    Application.Calculation = xlAutomatic

End Sub


Private Sub btnAutoSolve_Click()

    Application.Calculation = xlManual
        Call AutoSolve(sudoku, sudokuAnswer, zeroPoint)
    Application.Calculation = xlAutomatic

End Sub


Private Sub btnClear_Click()

    Application.Calculation = xlManual
        Call Clear
    Application.Calculation = xlAutomatic

End Sub