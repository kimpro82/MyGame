' RTK2 ERP / Play Sheet
' Version : 2.0
'
' Author:  kimpro82
' Date: 2025.08.02.
'
' This module provides routines for displaying player summary data on the Play sheet.


Option Explicit


' Sheet and cell location constants
Private Const THIS_SHEET_NAME As String = "Play"
Private Const RULER_IDX_LOC As String = "C2"        ' Cell containing the current ruler index
Private Const YYY_MM_LOC As String = "C5"           ' Cell for year-month display
Private Const DATA_COLUMN_LENGTH As Integer = 15    ' Number of columns in summary data
Private Const DATA_START_CELL As String = "B9"      ' Top-left cell for output data


' Returns a summary array of the current player's provinces
' @param summarizedProvinces: Province summary array (from SaveDataExtractor)
' @return: 2D array of player summary data
Private Function GetPlayerSummaryData(ByRef summarizedProvinces As Variant) As Variant

    Dim rulerIdx As Integer
    rulerIdx = Range(RULER_IDX_LOC).Value

    Dim playerSummaryData(1 To 41, 1 To DATA_COLUMN_LENGTH) As Variant
    Dim i As Integer, k As Integer
    k = 0
    For i = 1 To 41
        If summarizedProvinces(i, 13) = rulerIdx Then
            k = k + 1
            playerSummaryData(k, 1) = k                                         ' Command Order
            playerSummaryData(k, 2) = summarizedProvinces(i, 1)                 ' Province Index
            playerSummaryData(k, 3) = summarizedProvinces(i, 4)                 ' Governor Name
            playerSummaryData(k, 4) = summarizedProvinces(i, 12)                ' Population
            playerSummaryData(k, 5) = Int(playerSummaryData(k, 4) / 300000) + 1 ' Population Level
            playerSummaryData(k, 6) = summarizedProvinces(i, 26)                ' Soldiers
            playerSummaryData(k, 7) = summarizedProvinces(i, 27)                ' Generals
            playerSummaryData(k, 8) = summarizedProvinces(i, 9)                 ' Gold
            playerSummaryData(k, 9) = summarizedProvinces(i, 10)                ' Food
            playerSummaryData(k, 10) = summarizedProvinces(i, 16)               ' Rate
            playerSummaryData(k, 11) = summarizedProvinces(i, 17)               ' Merchant
            playerSummaryData(k, 12) = summarizedProvinces(i, 18)               ' Loyalty
            playerSummaryData(k, 13) = summarizedProvinces(i, 19)               ' Land
            playerSummaryData(k, 14) = summarizedProvinces(i, 20)               ' Flood
            playerSummaryData(k, 15) = summarizedProvinces(i, 21)               ' Horses
        End If
    Next i

    GetPlayerSummaryData = playerSummaryData

End Function


' Prints the player summary data array to the Play sheet
' @param playerSummaryData: 2D array of player summary data
Private Sub PrintPlayerSummaryData(ByRef playerSummaryData As Variant)

    Dim wsPlay As Worksheet
    Set wsPlay = ThisWorkbook.Sheets(THIS_SHEET_NAME)

    wsPlay.Range(DATA_START_CELL).Resize(UBound(playerSummaryData, 1), UBound(playerSummaryData, 2)).ClearContents
    wsPlay.Range(DATA_START_CELL).Resize(UBound(playerSummaryData, 1), UBound(playerSummaryData, 2)).Value = playerSummaryData

End Sub


' Button click event: updates all summary data and prints to sheet
Private Sub btnUpdate_Click()

    Application.Calculation = xlManual

    Call OutputArraysToSheets
    Range(YYY_MM_LOC) = yyy_mm

    Dim playerSummaryData As Variant
    playerSummaryData = GetPlayerSummaryData(summarizedProvinces)
    Call PrintPlayerSummaryData(playerSummaryData)

    Application.Calculation = xlAutomatic

End Sub
