# [Sudoku](../README.md#sudoku)

Let's make a **Sudoku** game in VBA!


## List

0. [Initialization (2022.12.22)](#0-initialization-20221222)
1. Generate a Sudoku puzzle
2. Masking the puzzle  
  2.1 Difficulty Control
3. Compare with the Answer
4. Hint
5. Auto-solver


## [0. Initialization (2022.12.22)](#list)

  - Base codes are helped by [ChatGPT](https://github.com/kimpro82/MyGame/issues/56#issuecomment-1363135037)
  - Fill the cells just temporarily for test, not for the real game

  ![Initialization](./Images/VBA_Sudoku_Init.gif)

  <details>
    <summary>Codes : Sudoku.bas</summary>

  ```vba
  Option Explicit
  ```
  ```vba
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
  ```
  ```vba
  Private Sub GetZeroPoint(ByRef zeroPoint As Range)

      Set zeroPoint = Range("C5")

  End Sub
  ```
  ```vba
  Private Sub GeneratePuzzle(ByRef puzzle As Variant)

      ' Temporary; to be advanced
      Dim i As Integer, j As Integer
      For i = 1 To 9
          For j = 1 To 9
              puzzle(i, j) = Int(Rnd * 9) + 1
          Next j
      Next i

  End Sub
  ```
  ```vba
  Private Sub PrintPuzzle(ByRef puzzle As Variant, ByRef zeroPoint As Range)

      ' Print the puzzle to the sheet
      Dim i As Integer, j As Integer
      For i = 1 To 9
          For j = 1 To 9
              zeroPoint.Offset(i - 1, j - 1).Value = puzzle(i, j)
          Next j
      Next i

  End Sub
  ```
  ```vba
  Private Sub Hint()

      Debug.Print "Hint function is not completed yet"
      ' Debug.Print Me.Name & "() is not completed yet"                           ' Me.Name : "Soduku"

  End Sub
  ```
  ```vba
  Private Sub AutoSolve()

      Debug.Print "Auto Solve function is not completed yet"

  End Sub
  ```
  ```vba
  Private Sub Clear()

      Dim zeroPoint As Range
      Call GetZeroPoint(zeroPoint)

      Dim Rng As Range
      Set Rng = zeroPoint.Resize(9, 9)

      With Rng
          .ClearContents
      End With

  End Sub
  ```
  ```vba
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
  ```
  </details>