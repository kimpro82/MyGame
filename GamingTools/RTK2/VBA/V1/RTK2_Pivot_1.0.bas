Option Explicit


' Refresh all the Pivot Table and Chart
Sub RefreshPivotTables()

        PivotTables("PivotTable1").PivotCache.Refresh
        PivotTables("PivotTable2").PivotCache.Refresh

End Sub


Private Sub BtnRefresh_Click()

    Application.Calculation = xlManual                                          'Skip excel formula calculation temporarily
        Call RefreshPivotTables
    Application.Calculation = xlAutomatic

End Sub