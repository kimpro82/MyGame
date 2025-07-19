' Playtime Estimator Main Module / Version 1.1
'
' Date   : 2025.7.19.
' Author : kimpro82
'
' This VBA module scans directories, collects file information, prints the data to the worksheet, and calculates playtime statistics.


Option Explicit

' Constants
Const MAX_PATH  As Integer = 5  ' Maximum number of paths to scan
Const MAX_ROW   As Long = 10000 ' Maximum number of rows and columns for output area
Const MAX_COL   As Long = 12

' Structure to hold file information
Private Type FileInfo
    fileName                As String   ' Name of the file
    fileType                As String   ' File type description
    fileSize                As Integer  ' File size in bytes
    fileDateLastModified    As Date     ' Last modified date
End Type

' Entry point for the button click event
Private Sub btnRun_Click()
    Application.Calculation = xlManual
    Call Main
    Application.Calculation = xlAutomatic
End Sub

' Main workflow: collects file info, prints to sheet, sorts, and calculates playtime
Sub Main()
    ' Set reference points for reading, printing, and calculation
    Dim readZero    As Range
    Dim printZero   As Range
    Dim calZero     As Range
    Call SetZero(readZero, printZero, calZero)

    ' Define and clear the output area
    Dim usingArea   As Range
    Call SetUsingArea(printZero, usingArea)

    ' Get list of paths to scan
    Dim path(1 To MAX_PATH) As String
    Dim pathLen     As Integer
    Call GetPath(readZero, path, pathLen)

    ' Collect file information
    Dim data(1 To MAX_ROW) As FileInfo
    Dim numFiles As Integer
    Call CollectFileInfos(path, pathLen, data, numFiles)

    ' Print file info to worksheet
    Call PrintFileInfos(printZero, data, numFiles)

    ' Print summary info
    Call PrintSummary(calZero, pathLen, numFiles)

    ' Sort the printed data by last modified date
    Call SortData(printZero)

    ' Calculate and print playtime statistics
    Call GetPlayTime(printZero, calZero, numFiles)
End Sub

' Set reference cells for reading input, printing output, and calculation area
Private Sub SetZero(ByRef readZero As Range, printZero As Range, calZero As Range)
    Set readZero = Range("B2")      ' Input path list starts here
    Set printZero = Range("A11")    ' Output data starts here
    Set calZero = Range("F3")       ' Calculation area starts here
End Sub

' Clear the output area for fresh data
Private Sub SetUsingArea(ByRef printZero As Range, ByRef usingArea As Range)
    Set usingArea = Range(printZero, printZero.Offset(MAX_ROW, MAX_COL))
    usingArea.ClearContents
    ' usingArea.VerticalAlignment = xlCenter  ' (Manual alignment on the sheet)
End Sub

' Read the list of folder paths from the worksheet
Private Sub GetPath(ByRef readZero As Range, ByRef path As Variant, ByRef pathLen As Integer)
    pathLen = Range(readZero, readZero.End(xlDown)).Count
    Debug.Print "pathLen : " & pathLen
    If pathLen > 0 And readZero <> "" Then
        Dim i As Integer
        For i = 1 To pathLen
            path(i) = readZero.Offset(i - 1, 0).Value
            Debug.Print path(i)
        Next i
    Else
        path(1) = ThisWorkbook.path
        pathLen = 1
        Debug.Print path(1)
    End If
End Sub


' Collect file information from the specified paths into the data array

' CollectFileInfos: Orchestrates folder collection and file info extraction
Private Sub CollectFileInfos(path As Variant, pathLen As Integer, ByRef data() As FileInfo, ByRef numFiles As Integer)
    Dim oFolder(1 To MAX_PATH) As Object
    Call CollectFolders(path, pathLen, oFolder)
    Call CollectPngFileInfos(oFolder, pathLen, data, numFiles)
End Sub

' CollectFolders: Get folder objects from path array, handle missing folders
Private Sub CollectFolders(path As Variant, pathLen As Integer, ByRef oFolder() As Object)
    Dim oFSO As Object
    Dim i As Integer
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    For i = 1 To pathLen
        On Error Resume Next
        Set oFolder(i) = oFSO.GetFolder(path(i))
        If Err.Number <> 0 Then
            Debug.Print "Folder not found: " & path(i)
            Err.Clear
            Set oFolder(i) = Nothing
        End If
        On Error GoTo 0
    Next i
End Sub

' CollectPngFileInfos: Extract info for "알씨 PNG 파일" from folders into data array
Private Sub CollectPngFileInfos(oFolder() As Object, pathLen As Integer, ByRef data() As FileInfo, ByRef numFiles As Integer)
    Dim oFile As Object
    Dim i As Integer
    Dim idx As Integer
    idx = 1
    For i = 1 To pathLen
        If Not oFolder(i) Is Nothing Then
            For Each oFile In oFolder(i).Files
                If oFile.Type = "알씨 PNG 파일" Then
                    data(idx).fileName = oFile.Name
                    data(idx).fileType = oFile.Type
                    data(idx).fileSize = oFile.Size
                    data(idx).fileDateLastModified = oFile.DateLastModified
                    idx = idx + 1
                End If
            Next oFile
        End If
    Next i
    numFiles = idx - 1
    Debug.Print "numFiles : " & numFiles
End Sub

' Print file information to the worksheet
Private Sub PrintFileInfos(printZero As Range, data() As FileInfo, numFiles As Integer)
    Dim i As Integer
    For i = 1 To numFiles
        printZero.Offset(i - 1, 0) = i
        printZero.Offset(i - 1, 1) = data(i).fileName
        printZero.Offset(i - 1, 2) = data(i).fileType
        printZero.Offset(i - 1, 3) = data(i).fileSize
        printZero.Offset(i - 1, 4) = data(i).fileDateLastModified
    Next i
End Sub

' Print summary information to the worksheet
Private Sub PrintSummary(calZero As Range, pathLen As Integer, numFiles As Integer)
    calZero.Offset(0, 0).Value = pathLen
    calZero.Offset(2, 0).Value = numFiles
End Sub

' Sorts the printed file data by last modified date (ascending)
Private Sub SortData(ByRef printZero As Range)
    ' Debug.Print printZero.End(xlDown).Address  ' e.g. $A$1416
    Range(printZero, printZero.End(xlDown).Offset(0, 4)).Sort _
        Key1:=printZero.Offset(0, 4), _
        Order1:=xlAscending
End Sub

' Calculates playtime statistics and prints the results
Private Sub GetPlayTime(ByRef printZero As Range, ByRef calZero As Range, ByRef numFiles As Integer)
    Dim playTime(1 To 4) As Double
    Dim playFreq(1 To 4) As Integer
    Dim terms(1 To 4) As Single
    ' Initialize playFreq array
    Dim i           As Integer
    For i = 1 To 4
        playFreq(i) = 1
    Next i
    ' Set playtime calculation terms (in hours)
    Call SetTerms(printZero, calZero, terms)
    ' Calculate playtime and frequency
    Call CalPlayTime(printZero, numFiles, terms, playTime, playFreq)
    ' Print playtime calculation results
    Call PrintPlayTime(calZero, numFiles, playTime, playFreq)
End Sub

' Sets the playtime calculation terms and prints headers
Private Sub SetTerms(ByRef printZero As Range, ByRef calZero As Range, ByRef terms As Variant)
    ' Set terms for calculating playTime (in hours)
    terms(1) = 0.5
    terms(2) = 1
    terms(3) = 1.5
    terms(4) = 2
    Dim i As Integer
    For i = 1 To 4
        calZero.Offset(i - 1, 1).Value = terms(i) & "h"
        printZero.Offset(-1, 5 + 2 * (i - 1)).Value = terms(i) & "h"
        printZero.Offset(-1, 6 + 2 * (i - 1)).Value = "Freq" & terms(i) & "h"
    Next i
End Sub

' Calculates playtime and frequency arrays based on file modification times
Private Sub CalPlayTime(ByRef printZero As Range, ByRef numFiles As Integer, ByRef terms As Variant, ByRef playTime As Variant, ByRef playFreq As Variant)
    Dim diff        As Double
    Dim i           As Integer
    Dim j           As Integer
    Dim continuous  As Integer
    ' Calculate playTime() and playFreq()
    For i = 1 To numFiles - 1
        diff = (printZero.Offset(i, 4).Value - printZero.Offset(i - 1, 4).Value) * 24   ' hour
        continuous = 99
        For j = 1 To 4
            If diff < terms(j) Then
                continuous = j
                Exit For  ' break
            End If
        Next j
        For j = 1 To 4
            If continuous <= j Then
                playTime(j) = playTime(j) + diff
            Else
                playFreq(j) = playFreq(j) + 1
            End If
        Next j
        ' Print intermediate results to worksheet
        For j = 1 To 4
            printZero.Offset(i, 5 + 2 * (j - 1)).Value = playTime(j)
            printZero.Offset(i, 6 + 2 * (j - 1)).Value = playFreq(j)
        Next j
    Next i
End Sub

' Prints the final playtime statistics to the worksheet
Private Sub PrintPlayTime(ByRef calZero As Range, numFiles As Integer, playTime As Variant, playFreq As Variant)
    Dim i As Integer
    For i = 1 To 4
        calZero.Offset(i - 1, 2).Value = playTime(i)
        calZero.Offset(i - 1, 3).Value = playFreq(i)
        If playFreq(i) <> 0 Then
            calZero.Offset(i - 1, 4).Value = playTime(i) / playFreq(i)
        Else
            calZero.Offset(i - 1, 4).Value = 0
        End If
    Next i
End Sub
