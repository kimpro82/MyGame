' Roguelike Game
' 2022.11.30


Option Explicit


' ★ Manage parameters by user directly
Private Sub SetSize(ByRef MapData As RndMap)

    MapData.rSize = 30
    MapData.cSize = 50

    With Range("A1").Resize(MapData.rSize, MapData.cSize)
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .RowHeight = 15
        .ColumnWidth = 2
    End With

End Sub


Private Sub Main()

    Dim MapData As RndMap

    ' Set map size
    Call SetSize(MapData)

    ' Set starting and ending location
    Call SetLocation(MapData)

    ' Find n ways

    ' Build walls

    ' Arrange items

    ' Arrage monsters

    ' Arrage NPCs

End Sub


Private Sub SetLocation(ByRef MapData As RndMap)

    Dim rTemp, cTemp As Integer

    ' Set Starting Cell
    Randomize
    rTemp = Int(Rnd * MapData.rSize)
    cTemp = Int(Rnd * MapData.cSize)
    ' Debug.Print rTemp, cTemp
    Set MapData.Start = Range(Cells(rTemp, cTemp), Cells(rTemp, cTemp))         ' Range(Cells(rTemp, cTemp)) causes an error

    ' Mark Starting Cell
    MapData.Start.Interior.Color = vbBlack
    MapData.Start.Font.Color = vbWhite
    MapData.Start.FormulaR1C1 = "S"

    ' Set Ending Cell
    Randomize
    rTemp = Int(Rnd * MapData.rSize)
    cTemp = Int(Rnd * MapData.cSize)
    Set MapData.End = Range(Cells(rTemp, cTemp), Cells(rTemp, cTemp))

    ' Mark Ending Cell
    MapData.End.Interior.Color = vbRed
    MapData.End.Font.Color = vbWhite
    MapData.End.FormulaR1C1 = "E"

End Sub


Private Sub BtnMapGeneration_Click()

    Call Main

End Sub


' To-Be : Call MapData
Private Sub Clear()

    Dim Rng As Range
    Set Rng = Range("A1").Resize(100, 100)

    With Rng
        .ClearContents
        .Interior.ColorIndex = 0
    End With

End Sub


Private Sub BtnClear_Click()

    Call Clear

End Sub