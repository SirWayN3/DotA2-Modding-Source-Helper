

#cs HeaderIndex	Language
0				ID_V0.1
1				German
2				English
#ce

#cs Index Gliederung

#ce


Global $aScriptLanguageFile;		Array für die Language Datei
Global $aScriptLanguage[1] = ["None, No Language File"];			Array für LanguageDatei ausgelesen

Func _CheckLanguageInitXLSX()
   Local $hScriptLanguageFile
;~    Fileinstall("0-Include\Language.xlsx",$sScriptLanguageFile,1)
   If Not FileExists($sScriptLanguageFile) Then Return SetError(1,0,1)
   $aScriptLanguageFile = _XLSXReadToArray($sScriptLanguageFile)
   _ArrayDelete($aScriptLanguageFile,0)
   If IsArray($aScriptLanguageFile) = 0 Then Return SetError(2,0,1)
EndFunc


;~ Func _CheckLanguageInitTXT()
;~    ; Funktion mit einer bestimmten Language Datei schreiben
;~    ; Language Datei enthält nur eine Sprache
;~    ; Mehrere Language Dateien sollen zur Auswahl stehen
;~    If $iScriptLanguageIndex = 1 Then FileInstall("0-Include\Language_German.txt",$sScriptLanguageFile,1)
;~    If $iScriptLanguageIndex = 2 Then FileInstall("0-Include\Language_English.txt",$sScriptLanguageFile,1)
;~    _FileReadToArray($sScriptLanguageFile,$aScriptLanguage)
;~    If @error Then Return SetError(2,0,1)
;~    _ArrayDelete($aScriptLanguage,0)
;~    If $aScriptLanguage[0] <> $aScriptLanguageIndex[$iScriptLanguageIndex] Then Return SetError(1,0,1)
;~    _LogAdd(_LanguageGet(1213) & $aScriptLanguageIndex[$iScriptLanguageIndex])
;~    _LogAdd(_LanguageGet(1210))
;~ EndFunc


;~ Func _CheckLanguageInitXLS()
;~    Local $hScriptLanguageFile
;~    FileInstall("Language.xls","Language.xls",1)
;~    If Not FileExists($sScriptLanguageFile) Then Return SetError(1,0,1)
;~    $hScriptLanguageFile = _ExcelBookOpen($sScriptLanguageFile,0,1)
;~    If @error Then Return SetError(2,0,1)
;~    ; CheckHeader
;~    $aScriptLanguage = _ExcelReadArray($hScriptLanguageFile,1,1,4,0); Header einlesen
;~    If $aScriptLanguage[$iScriptLanguageIndex] <> $aScriptLanguageIndex[$iScriptLanguageIndex] Then Return SetError(2,0,1)
;~    ; Header richtig, richtige Sprache
;~    ; eine Spalte auslesen, 100 Zeilen
;~    $aScriptLanguage = _ExcelReadArray($hScriptLanguageFile,2,$iScriptLanguageIndex+1,100,1)
;~    ; Gesamtes Dokument auslesen
;~    $aScriptLanguage = _ExcelReadSheetToArray($hScriptLanguageFile,2,2,0,0)
;~    _ArrayDelete($aScriptLanguage,0)
;~    _ExcelBookClose($hScriptLanguageFile)
;~    Return 0
;~ EndFunc


Func _LanguageSet()
   Switch @GUI_CtrlId
   Case $cSubMenu53; Deutsch -> 1
	  If $iScriptLanguageIndex = 1 Then Return
	  $iScriptLanguageIndex = 1
   Case $cSubMenu54; English -> 2
	  If $iScriptLanguageIndex = 2 Then Return
	  $iScriptLanguageIndex = 2
   EndSwitch
   _ShowBox32()
   _LanguageRestart()
EndFunc


Func _LanguageGet($key,$mode=0)
   ;$mode = 1 -> silent CARE
;~    MsgBox("","",$key)
;~    _ArrayDisplay($aScriptLanguageFile)
;~    #cs - XLSX Version
   Local $s = $aScriptLanguageFile[$key][$iScriptLanguageIndex]
   Local $error = 0
   
;~    #ce

   #cs - TXT Version
   Local $s = $aScriptLanguage[$key]
   #ce
   
   If StringInStr($s,"@") Then 
	  $s = Execute($s)
	  If @error Then $error = 1
   Else
	  If StringInStr($s,'"') Then $s = Execute($s)
	  If @error Then $error = 2
   EndIf
   If $mode = 0 AND $s = "" Then _LogAdd(_LanguageGet(1246) & $error & _LanguageGet(1247) & $key); -> Debug
   Return $s
EndFunc


Func _LanguageSetFirst()
   $bFirstRun = __IniCheckBool("$bFirstRun")
   If $bFirstRun = 1 Then
	 ; Fenster für Sprache auswählen
	  ; << Gui8 Sprache auswählen >>
	  Local $h = GuiCreate("Select Language",200,75,-1,-1,BITOR($WS_POPUPWINDOW,$WS_CAPTION))
	  GuiSetFont(10,700)
	  Local $c1 = GuiCtrlCreateCombo("",10,20,180,50,$CBS_DROPDOWN)
	  GuiCtrlSetData($c1,"Deutsch|English")
	  GuiSetOnEvent($GUI_EVENT_CLOSE,"_LanguageExit",$h)
	  GuiCtrlSetOnEvent($c1,"_LanguageGetFirst")
	  GuiSetState()
	  While WinExists("Select Language")
		 Sleep(100)
	  WEnd
   Else
	  $iScriptLanguageIndex  = __IniCheckInt("$iScriptLanguageIndex")
   EndIf
EndFunc

Func _LanguageExit()
   Exit
EndFunc

Func _LanguageGetFirst()
   Switch GuiCtrlRead(@Gui_CtrlID)
   Case $aScriptLanguageIndex[1]
	  $iScriptLanguageIndex = 1
   Case $aScriptLanguageIndex[2]
	  $iScriptLanguageIndex = 2
   EndSwitch
   GUIDelete()
EndFunc


Func _LanguageRestart()
   If @compiled = 0 Then Return
;~    FileInstall("0-Include/Restart/Restart.exe","Restart.exe",1)
   Local $s = 'Restart.exe "' & $sScriptName & '" "' & $sGuiName1 & '" "' & _
			   @AutoItExe & '" "' & @AutoItPID & '" 1'
   Run($s)
   _ScriptExit()
EndFunc


