' RTK2 ERP / Pivot Sheet
' Version : 2.0
'
' Author:  kimpro82
' Date: 2025.08.02.
'
' This module provides routines for refreshing pivot tables and charts on the Pivot sheet.


Option Explicit


' Refreshes all pivot tables and charts on the active sheet
' Currently refreshes only "PivotTable1"; extend as needed for more tables/charts
Sub RefreshPivotTables()

    PivotTables("PivotTable1").PivotCache.Refresh

End Sub


' Button click event: refreshes all pivot tables and charts
Private Sub BtnRefresh_Click()

    Application.Calculation = xlManual

    Call RefreshPivotTables

    Application.Calculation = xlAutomatic

End Sub
