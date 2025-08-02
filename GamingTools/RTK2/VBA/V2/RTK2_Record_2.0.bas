' RTK2 ERP / Record Sheet
' Version : 2.0
'
' Author:  kimpro82
' Date: 2025.08.02.
' 
' This module provides routines for recording annual ruler statistics to the Record sheet.


Option Explicit


' Sheet and data output constants
Private Const THIS_SHEET_NAME As String = "Record"         ' Sheet name for record output
Private Const DATA_START_CELL As String = "B5"             ' Top-left cell for output data
Private Const DATA_COLUMN_LENGTH As Integer = 12           ' Number of columns in record data

' Stores the annual record data for output
Private AnnualRecordData() As Variant


' Returns a summary array of annual record data for all rulers
' @param summarizedRulers: Ruler summary array (from SaveDataExtractor)
' @return: 2D array of annual record data
Private Function GetAnnualRecordData(ByRef summarizedRulers As Variant) As Variant

    Dim AnnualRecordData(1 To 16, 1 To DATA_COLUMN_LENGTH) As Variant
    Dim i As Integer
    For i = 1 To 16
        AnnualRecordData(i, 1) = FILENAME                   ' Filename
        AnnualRecordData(i, 2) = yyy_mm                     ' Year-Month
        AnnualRecordData(i, 3) = summarizedRulers(i, 1)     ' Ruler Index
        AnnualRecordData(i, 4) = summarizedRulers(i, 2)     ' Ruler Name
        AnnualRecordData(i, 5) = summarizedRulers(i, 3)     ' Capital Index
        AnnualRecordData(i, 6) = summarizedRulers(i, 4)     ' Advisor Name
        AnnualRecordData(i, 7) = summarizedRulers(i, 5)     ' Trust
        AnnualRecordData(i, 8) = summarizedRulers(i, 41)    ' Gold
        AnnualRecordData(i, 9) = summarizedRulers(i, 42)    ' Food
        AnnualRecordData(i, 10) = summarizedRulers(i, 43)   ' Population
        AnnualRecordData(i, 11) = summarizedRulers(i, 44)   ' Soldiers
        AnnualRecordData(i, 12) = summarizedRulers(i, 45)   ' Generals
    Next i

    GetAnnualRecordData = AnnualRecordData

End Function


' Prints the annual record data array to the Record sheet
' @param AnnualRecordData: 2D array of annual record data
Private Sub PrintAnnualRecordData(ByRef AnnualRecordData As Variant)

    Dim wsRecord As Worksheet
    Set wsRecord = ThisWorkbook.Sheets(THIS_SHEET_NAME)
    ' Get the starting row number for new data
    Dim rowNum As Integer
    rowNum = wsRecord.UsedRange.Rows.Count - 1          ' Avoid formatting in data area to keep UsedRange accurate
    wsRecord.Range(DATA_START_CELL).offset(rowNum, 0).Resize(UBound(AnnualRecordData, 1), UBound(AnnualRecordData, 2)).Value = AnnualRecordData

End Sub


' Button click event: updates all record data and prints to sheet
Private Sub btnUpdate_Click()

    Application.Calculation = xlManual

    Call OutputArraysToSheets
    Dim AnnualRecordData As Variant
    AnnualRecordData = GetAnnualRecordData(summarizedRulers)
    Call PrintAnnualRecordData(AnnualRecordData)

    Application.Calculation = xlAutomatic

End Sub
