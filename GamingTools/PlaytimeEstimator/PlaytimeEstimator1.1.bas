' Playtime Estimator based on Capture Images / Version 1.1 (Refactoring)
'
' Date   : 2025.7.19.
' Author : kimpro82
'
' This VBA module scans directories, collects file information, prints the data to the worksheet, and calculates playtime statistics.


Option Explicit


' Structure to hold file information
Private Type FileInfo

    fileName                As String   ' Name of the file
    fileType                As String   ' File type description
    fileSize                As Integer  ' File size in bytes
    fileDateLastModified    As Date     ' Last modified date

End Type


' Constants
Const MAX_PATH  As Integer = 5  ' Maximum number of paths to scan
Const MAX_ROW   As Long = 10000 ' Maximum number of rows and columns for output area
Const MAX_COL   As Long = 12

Private Const PLAYTIME_TERM_COUNT As Integer = 4
Private PLAYTIME_TERMS(1 To PLAYTIME_TERM_COUNT) As Double
Private Sub InitPlaytimeTerms() ' Initialize playtime terms

    PLAYTIME_TERMS(1) = 0.5
    PLAYTIME_TERMS(2) = 1
    PLAYTIME_TERMS(3) = 1.5
    PLAYTIME_TERMS(4) = 2

End Sub


' Entry point for the button click event
Private Sub btnRun_Click()

    ' Temporarily set calculation to manual for performance, then run main logic
    Application.Calculation = xlManual
    Call Main
    Application.Calculation = xlAutomatic

End Sub


' Main workflow: collects file info, sorts, calculates playtime, and prints results
Sub Main()

    ' Set reference cells for input, output, and calculation
    Dim readZero    As Range
    Dim printZero   As Range
    Dim calZero     As Range
    Call SetZero(readZero, printZero, calZero)

    ' Clear the output area for new data
    Dim usingArea   As Range
    Call SetUsingArea(printZero, usingArea)

    ' Read folder paths from worksheet
    Dim path(1 To MAX_PATH) As String
    Dim pathLen             As Integer
    Call GetPath(readZero, path, pathLen)

    ' Collect file information from folders
    Dim data(1 To MAX_ROW)  As FileInfo
    Dim numFiles            As Integer
    Call CollectFileInfos(path, pathLen, data, numFiles)
    Call SortData(data, numFiles)

    ' Initialize playtime terms
    Call InitPlaytimeTerms
    ' Declare arrays for playtime and frequency
    Dim playTime() As Double
    Dim playFreq() As Integer
    ReDim playTime(1 To numFiles, 1 To 4) As Double
    ReDim playFreq(1 To numFiles, 1 To 4) As Integer
    ' Calculate playtime and frequency (based on sorted data)
    Call GetPlayTime(data, printZero, calZero, numFiles, playTime, playFreq)

    ' Print summary and playtime results
    Call PrintAllResults(printZero, calZero, data, numFiles, playTime, playFreq, pathLen)

End Sub


' Set reference cells for reading input, printing output, and calculation area
Private Sub SetZero(ByRef readZero As Range, printZero As Range, calZero As Range)

    Set readZero = Range("B2")      ' Path list input starts here
    Set printZero = Range("A11")    ' Output data starts here
    Set calZero = Range("F3")       ' Calculation area starts here

End Sub


' Clear the output area for new data
Private Sub SetUsingArea(ByRef printZero As Range, ByRef usingArea As Range)

    Set usingArea = Range(printZero, printZero.Offset(MAX_ROW, MAX_COL))
    usingArea.ClearContents
    ' usingArea.VerticalAlignment = xlCenter  ' (Doesn't work, instead, manual alignment on the sheet)

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


' Collect folder objects and PNG file information
Private Sub CollectFileInfos(path As Variant, pathLen As Integer, ByRef data() As FileInfo, ByRef numFiles As Integer)

    Dim oFolder(1 To MAX_PATH) As Object
    Call CollectFolders(path, pathLen, oFolder)
    Call CollectPngFileInfos(oFolder, pathLen, data, numFiles)

End Sub


' Get folder objects from path array, handle missing folders
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


' Extract info for "알씨 PNG 파일" from folders into data array
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


' Sorts the data array by fileDateLastModified (ascending)
Private Sub SortData(ByRef data() As FileInfo, ByVal numFiles As Integer)

    Dim i As Integer, j As Integer
    Dim temp As FileInfo
    For i = 1 To numFiles - 1
        For j = i + 1 To numFiles
            If data(i).fileDateLastModified > data(j).fileDateLastModified Then
                temp = data(i)
                data(i) = data(j)
                data(j) = temp
            End If
        Next j
    Next i

End Sub


' Calculates playtime statistics and prints the results
Private Sub GetPlayTime(ByRef data() As FileInfo, ByRef printZero As Range, ByRef calZero As Range, ByRef numFiles As Integer, ByRef playTime() As Double, ByRef playFreq() As Integer)

    Dim terms(1 To 4) As Single

    ' Set playtime calculation terms (in hours)
    Call SetTerms(printZero, calZero, terms)
    ' Calculate playtime and frequency
    Call CalPlayTime(data, printZero, numFiles, terms, playTime, playFreq)

End Sub


' Sets the playtime calculation terms and prints headers
Private Sub SetTerms(ByRef printZero As Range, ByRef calZero As Range, ByRef terms As Variant)

    Dim i As Integer
    For i = 1 To PLAYTIME_TERM_COUNT
        terms(i) = PLAYTIME_TERMS(i)
        calZero.Offset(i - 1, 1).Value = terms(i) & "h"
        printZero.Offset(-1, 5 + 2 * (i - 1)).Value = terms(i) & "h"
        printZero.Offset(-1, 6 + 2 * (i - 1)).Value = "Freq" & terms(i) & "h"
    Next i

End Sub


' Calculates playtime and frequency arrays based on file modification times (using data array)
Private Sub CalPlayTime(ByRef data() As FileInfo, ByRef printZero As Range, ByVal numFiles As Integer, ByRef terms As Variant, ByRef playTime As Variant, ByRef playFreq As Variant)

    Dim diff        As Double
    Dim i           As Integer
    Dim j           As Integer
    Dim continuous  As Integer

    For i = 1 To numFiles
        If i = 1 Then
            For j = 1 To 4
                playTime(i, j) = 0
                playFreq(i, j) = 1
            Next j
            diff = 0
        Else
            diff = (data(i).fileDateLastModified - data(i - 1).fileDateLastModified) * 24   ' hour
        
            continuous = 99
    
            For j = 1 To 4
                If diff < terms(j) Then
                    continuous = j
                    Exit For  ' break
                End If
            Next j
    
            For j = 1 To 4
                ' Debug.Print i, j, playTime(i - 1, j), playFreq(i - 1, j)                  ' For Test
                If continuous <= j Then
                    playTime(i, j) = playTime(i - 1, j) + diff
                    playFreq(i, j) = playFreq(i - 1, j)
                Else
                    playFreq(i, j) = playFreq(i - 1, j) + 1
                    playTime(i, j) = playTime(i - 1, j)
                End If
            Next j
        End If
    Next i

End Sub


' Print file information to the worksheet
Private Sub PrintFileInfos(printZero As Range, data() As FileInfo, numFiles As Integer, Optional playTime As Variant, Optional playFreq As Variant)

    Dim i As Integer, j As Integer
    For i = 1 To numFiles
        printZero.Offset(i - 1, 0) = i
        printZero.Offset(i - 1, 1) = data(i).fileName
        printZero.Offset(i - 1, 2) = data(i).fileType
        printZero.Offset(i - 1, 3) = data(i).fileSize
        printZero.Offset(i - 1, 4) = data(i).fileDateLastModified
        If Not IsMissing(playTime) And Not IsMissing(playFreq) Then
            For j = 1 To 4
                printZero.Offset(i - 1, 5 + 2 * (j - 1)).Value = playTime(i, j)
                printZero.Offset(i - 1, 6 + 2 * (j - 1)).Value = playFreq(i, j)
            Next j
        End If
    Next i

End Sub


' Print summary information to the worksheet
Private Sub PrintSummary(calZero As Range, pathLen As Integer, numFiles As Integer)

    calZero.Offset(0, 0).Value = pathLen
    calZero.Offset(2, 0).Value = numFiles

End Sub


' Prints the final playtime statistics to the worksheet
Private Sub PrintPlayTime(ByRef calZero As Range, numFiles As Integer, playTime As Variant, playFreq As Variant)

    Dim i As Integer
    For i = 1 To 4
        calZero.Offset(i - 1, 2).Value = playTime(numFiles, i)
        calZero.Offset(i - 1, 3).Value = playFreq(numFiles, i)
        If playFreq(numFiles, i) <> 0 Then
            calZero.Offset(i - 1, 4).Value = playTime(numFiles, i) / playFreq(numFiles, i)
        Else
            calZero.Offset(i - 1, 4).Value = 0
        End If
    Next i

End Sub


' Print all outputs (file info, summary, playtime)
Private Sub PrintAllResults(printZero As Range, calZero As Range, data() As FileInfo, numFiles As Integer, playTime As Variant, playFreq As Variant, pathLen As Integer)

    Call PrintFileInfos(printZero, data, numFiles, playTime, playFreq)
    Call PrintSummary(calZero, pathLen, numFiles)
    Call PrintPlayTime(calZero, numFiles, playTime, playFreq)

End Sub
