

;~ Log Parameters
Global $sLogDir = @ScriptDir & "\"
Global $sLogZipFile = $sLogDir & "Log.zip"
Global $iLogIndex = 1
Global $aLog[2] = [1,"Logfile - " & $sScriptName];				Array für die Log Anzeige
Global $hLogFile;					Handle für das logFile
Global $sLogHeader = @MDAY & "-" & @MON & "-" & @YEAR & " - Logfile - " & $sScriptName; Header für das LogFile
Global $sLogFile;					String für das aktuelle logFile
Global $sLogFileAudio;				String für das aktuelle logFile AudioGenie
Global $sLogFileShort;
Global $sLogFileAudioShort;
Global $sLogZipTempDir = @TempDir & "\AudioParser.tmp\"



Func _LogInit()
   Opt("GUICoordMode",0)
   Global Const $hGui8 = GuiCreate("Log File",450,300,-1,-1,BITOR($WS_POPUPWINDOW,$WS_CAPTION),-1); -> vorläufiger name, wird in LogInit angepasst
   ; Name auch in Gui_Create8 anpassen
   GUISetCoord(15,10)
   GuiSetFont(8.5,400)
   Global Const $c8List = GUICtrlCreateEdit($sLogHeader,0,0,420,230,$WS_VSCROLL + $ES_READONLY + $ES_MULTILINE)
   Global Const $c8Button1 = GuiCtrlCreateButton("Export Log(.txt)",50,240,125,30); -> vorläufiger name, wird in LogInit angepasst
   Global Const $c8Button2 = GuiCtrlCreateButton("Delete Log",200,0,125,30); -> vorläufiger name, wird in LogInit angepasst
   
   
   Opt("GUICoordMode",0)
EndFunc


Func _LogHeader()
   If $bScriptStart = 1 Then $bLogSave = __IniCheckBool("$bLogSave")
   If $bLogSave = 0 Then Return
   $sLogFileShort = "Log - " & $sScriptName & " - " & $iLogIndex & ".txt"
   $sLogFile = $sLogDir & $sLogFileShort
   $sLogFileAudioShort = "Log - AudioGenie - " & $sScriptName & " - " & $iLogIndex & ".txt"
   $sLogFileAudio = $sLogDir & $sLogFileAudioShort
   $hLogFile = FileOpen($sLogFile,1+8)
   DllCall($hScriptAudioGenie,"none","SetLogFileW","wstr",$sLogFileAudio)
   _LogAdd($sLogHeader)
   If FileExists($sLogZipFile) = 0 Then
	  _Zip_Create($sLogZipFile)
   EndIf
EndFunc


Func _LogAdd($string)
   Local $time = @HOUR & ":" & @MIN & ":" & @SEC
   If $bLogSave = 1 Then _FileWriteLog($hLogFile,$string,-1)
   $string = $time & " - " & $string
   ConsoleWrite("LOG: " & $string & @CRLF)
;~    _GuiCtrlRichEdit_AppendText($c8List,@CR & $string)
   GuiCtrlSetData($c8List,GuiCtrlRead($c8List) & @CRLF & $string)
   Local $i = _ArrayAdd($aLog,$string)
   $aLog[0] = $i
   If IsDeclared("c3Tab7Label1") <> 0 Then
	  GuiCtrlSetData($c3Tab7Label1,_LanguageGet(202) & Floor(FileGetSize($sLogZipFile)/1024) & " KB")
   EndIf
;~    Sleep(1000)
EndFunc

Func _LogExport()
   If $aLog[0] = 0 Then Return
   Local $f = FileSaveDialog(_LanguageGet(707),"",_LanguageGet(708),18,"",$hGui8)
   If @error Then Return
   If StringRight($f,4) <> ".txt" Then $f &= ".txt"
   _FileWriteFromArray($f,$aLog,1)
EndFunc


Func _LogDelete()
   If $aLog[0] = 0 Then Return
   If _ShowBox38() = 2 Then Return
   Redim $aLog[2]
   $aLog[0] = 0
;~    GuiCtrlSetData($c8List,"|")
;~    _GUICtrlRichEdit_SetText($c8List,$sLogHeader)
   GuiCtrlSetData($c8List,$sLogHeader)
;~    _LogAdd("Logfile - " & $sScriptName)
EndFunc


Func _LogGetLine()
   If $aLog[0] = 0 Then Return
   ClipPut(GuiCtrlRead($c8List))
EndFunc


Func _LogFileClose()
   If $bLogsave = 0 Then Return
;~    _GUICtrlRichEdit_Destroy(ByRef $c8List)
   _LogAdd(_LanguageGet(1245))
   DirRemove($sLogZipTempDir,1)
   _Zip_UnzipAll($sLogZipFile,$sLogZipTempDir)
   FileDelete($sLogZipFile)
   FileCopy($sLogFile,$sLogZipTempDir & $sLogFileShort,9)
   FileCopy($sLogFileAudio,$sLogZipTempDir & $sLogFileAudioShort,9)
;~    Sleep(200)
   _Zip_Create($sLogZipFile)
;~    ConsoleWrite("LogFileClose_ZipCreate" & @CRLF)
   _Zip_AddFolderContents($sLogZipFile,$sLogZipTempDir)
;~    ConsoleWrite("LogFileClose_ZipAddFolderContents" & @CRLF)
;~    Sleep(200)
   FileClose($hLogFile)
   FileDelete($sLogFile)
   FileDelete($sLogFileAudio)
   DirRemove($sLogZipTempDir,1)
   $iLogIndex += 1
EndFunc





