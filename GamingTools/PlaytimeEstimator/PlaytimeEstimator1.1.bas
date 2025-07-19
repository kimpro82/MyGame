Option Explicit


Const MAX_PATH As Integer = 5
Const MAX_ROW As Long = 10000
Const MAX_COL As Long = 12


Private Type FileInfo

    fileName                As String
    fileType                As String
    fileSize                As Integer
    fileDateLastModified    As Date

End Type


Private Sub btnRun_Click()

    Application.Calculation = xlManual
        Call Main
    Application.Calculation = xlAutomatic

End Sub


Sub Main()

    ' Set zero points
    Dim readZero    As Range
    Dim printZero   As Range
    Dim calZero     As Range
    Call SetZero(readZero, printZero, calZero)

    ' Set area to print
    Dim usingArea   As Range
    Call SetUsingArea(printZero, usingArea)

    ' Get path
    Dim path(1 To MAX_PATH) As String
    Dim pathLen     As Integer
    Call GetPath(readZero, path, pathLen)

    ' Get oFile collection's informations to 'data' array
    Dim numFiles    As Integer
    Call GetFileList(printZero, calZero, path, pathLen, numFiles)

    ' Sort data on the sheet by DateCreated
    Call SortData(printZero)

    ' Get play time
    Call GetPlayTime(printZero, calZero, numFiles)

End Sub


Sub SetZero(ByRef readZero As Range, printZero As Range, calZero As Range)

    Set readZero = Range("B2")
    Set printZero = Range("A11")
    Set calZero = Range("F3")

End Sub


Sub SetUsingArea(ByRef printZero As Range, ByRef usingArea As Range)

    Set usingArea = Range(printZero, printZero.Offset(MAX_ROW, MAX_COL))

    usingArea.ClearContents
    ' usingArea.VerticalAlignment = xlCenter                                            ' why doesn't it work? aligned manually on the sheet

End Sub


Sub GetPath(ByRef readZero As Range, ByRef path As Variant, ByRef pathLen As Integer)   ' array should be passed as Variant

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


Sub GetFileList(ByRef printZero As Range, ByRef calZero As Range, ByRef path As Variant, ByRef pathLen As Integer, ByRef numFiles As Integer)

    Dim oFSO        As Object
    Dim oFolder(1 To MAX_PATH)  As Object
    Dim oFile       As Object
    Dim i           As Integer
    Dim idx         As Integer

    On Error GoTo FolderErr
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    numFiles = 0
    ' Get the length of the struct array
    For i = 1 To pathLen
        On Error Resume Next
        Set oFolder(i) = oFSO.GetFolder(path(i))
        If Err.Number <> 0 Then
            Debug.Print "폴더를 찾을 수 없습니다: " & path(i)
            Err.Clear
            Set oFolder(i) = Nothing
        End If
        On Error GoTo 0
        numFiles = numFiles + oFolder(i).Files.Count
    Next i

    ' Save data into the struct array
    Dim data()      As FileInfo
    If numFiles > 0 Then
        ReDim data(1 To numFiles)
    End If
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
                Else
                    numFiles = numFiles - 1
                End If
            Next oFile
        End If
    Next i
    Debug.Print "numFiles : " & numFiles

    ' Print pathLen and numFiles
    calZero.Offset(0, 0).Value = pathLen
    calZero.Offset(2, 0).Value = numFiles

    ' Print data on the sheet
    For i = 1 To numFiles
        printZero.Offset(i - 1, 0) = i
        printZero.Offset(i - 1, 1) = data(i).fileName
        printZero.Offset(i - 1, 2) = data(i).fileType
        printZero.Offset(i - 1, 3) = data(i).fileSize
        printZero.Offset(i - 1, 4) = data(i).fileDateLastModified
    Next i

    Exit Sub

FolderErr:
    Debug.Print "FSO 오류 발생: " & Err.Description
    On Error GoTo 0

End Sub


Sub SortData(ByRef printZero As Range)

    ' Debug.Print printZero.End(xlDown).Address                                         ' ok : $A$1416
    Range(printZero, printZero.End(xlDown).Offset(0, 4)).Sort _
        Key1:=printZero.Offset(0, 4), _
        Order1:=xlAscending

End Sub


Sub GetPlayTime(ByRef printZero As Range, ByRef calZero As Range, ByRef numFiles As Integer)

    Dim playTime(1 To 4) As Double
    Dim playFreq(1 To 4) As Integer
    Dim terms(1 To 4) As Single

    ' Set playFreq() start from 1
    Dim i           As Integer
    For i = 1 To 4
        playFreq(i) = 1
    Next i

    ' Set terms for calculating playTime
    Call SetTerms(printZero, calZero, terms)

    ' Calculate
    Call CalPlayTime(printZero, numFiles, terms, playTime, playFreq)

    ' Print calculation results
    Call PrintPlayTime(calZero, numFiles, playTime, playFreq)

End Sub


Sub SetTerms(ByRef printZero As Range, ByRef calZero As Range, ByRef terms As Variant)

    ' Set terms for calculating playTime
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


Sub CalPlayTime(ByRef printZero As Range, ByRef numFiles As Integer, ByRef terms As Variant, ByRef playTime As Variant, ByRef playFreq As Variant)

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
                Exit For                                                                ' break
            End If
        Next j

        For j = 1 To 4
            If continuous <= j Then
                playTime(j) = playTime(j) + diff
            Else
                playFreq(j) = playFreq(j) + 1
            End If
        Next j

        For j = 1 To 4
            printZero.Offset(i, 5 + 2 * (j - 1)).Value = playTime(j)
            printZero.Offset(i, 6 + 2 * (j - 1)).Value = playFreq(j)
        Next j
    Next i

End Sub


Sub PrintPlayTime(ByRef calZero As Range, numFiles As Integer, playTime As Variant, playFreq As Variant)

    ' Print calculation results
    Dim i As Integer
    For i = 1 To 4
        calZero.Offset(i - 1, 2).Value = playTime(i)
        calZero.Offset(i - 1, 3).Value = playFreq(i)
        calZero.Offset(i - 1, 4).Value = playTime(i) / playFreq(i)
    Next i

End Sub
