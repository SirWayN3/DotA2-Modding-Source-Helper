#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>


#cs To Do Liste
	Überprüfung ob fehlerhafte Parameter vorhanden sind
	-> nicht starten, wenn nicht alle Param gesetzt sind
	Abfrage Window Closed nicht erfolgt
	Prozess ID besser als Window Closed
	Before Loop loslözuft kontrollieren ob datei existiert, wenn nicht, skippen
#ce


Global Const $sVersion = 0.01
Global Const $sUpdateIni = @ScriptDir & "\Update.ini"
Global Const $iSleepTime = 750

Global $sCmdLineLeftOver = ""
Global $sFileSize = ""
Global $iTotalFiles = 0
Global $sFileUrl = ""
Global $sFileLocal = ""
Global $hFileUrl

Global $aParam[4][2] = [["name"],["win"],["path1"],["param1"]]
Global $aFiles[2][2] = [["filelocal", "fileonline"]]



If _Variant_CmdLine() = 0 Then
	If _Variant_Ini() = 0 Then
		If _Variant_Com() = 0 Then _ScriptExit(-2)
	EndIf
EndIf

_GuiCreate()

$iTotalFiles = UBound($aFiles) - 1
For $i = 1 To $iTotalFiles Step 1
	GUICtrlSetData($cLabel6, "Der Download neuer Dateien beginnt...")
	GUICtrlSetData($cProgress1, 0)
	
	$sFileUrl = $aFiles[$i][1]
	$sFileLocal = $aFiles[$i][0]
	GUICtrlSetData($cLabel5, $i & " / " & $iTotalFiles)
	$sFileSize = Floor(InetGetSize($sFileUrl, 1) / 1024) & " KB"
	GUICtrlSetData($cLabel3, $sFileSize)
	
	$hFileUrl = InetGet($sFileUrl, @TempDir & $sFileLocal, 1, 1)
	While 1
		GUICtrlSetData($cLabel3, Floor(InetGetInfo($hFileUrl, 0) / 1024) & " / " & $sFileSize)
		If InetGetInfo($hFileUrl, 2) = 1 Then
			InetClose($hFileUrl)
			ExitLoop
		EndIf
		Sleep(100)
	WEnd
	GUICtrlSetData($cProgress1, 33)
	GUICtrlSetData($cLabel6, "Lösche alte Dateien....")
	
	Sleep($iSleepTime)
	
	
	FileDelete($sFileLocal)
	
	GUICtrlSetData($cLabel6, "Kopiere neue Datei....")
	GUICtrlSetData($cProgress1, 66)
	
	Sleep($iSleepTime)
	
	If FileMove(@TempDir & $sFileLocal, $sFileLocal, 1 + 8) = 0 Then _ScriptExit(9)
	
	Sleep($iSleepTime)
	
	
	GUICtrlSetData($cLabel6, "Update erfolgreich!")
	GUICtrlSetData($cProgress1, 100)
	Sleep($iSleepTime * 2)
Next

MsgBox(64, "Erfolg....", "Das Update war erfolgreich." & @CRLF & "Das Programm " & $aParam[0][1] & _
		" wird neu gestartet.", 10, $hMainWindow)

Run($aParam[2][1] & " " & $aParam[3][1])



Sleep(2000)
Exit




Func _ScriptExit($i)
	Local $s
	Switch $i
		Case -2
			$s = "This Program needs proper Parameters. Check the Help File."
		Case -1; Keine Parameter angegeben
			$s = "The Update was canceled."
		Case 1; Keinen Namen für das Script angegeben
			$s = "Parameter 1 is invalid."
		Case 2; Fenster zum schließen existiert nicht
			$s = "Parameter 2 is invalid, Window doesnt exist."
		Case 3; Programm Pfad existiert nicht
			$s = "Parameter 3 is invalid, Path to Program doesnt exist."
		Case 4; Prozess ist invalid
			$s = "Parameter 4 is invalid, Prozess doesnt close."
		Case 6; Download fehlgeschlagen
			$s = "Parameter 6 is invalid, Download is not possible."
		Case 7; Lokale Datei hat ein falsches Format (leer, keine exe)
			$s = "Parameter 7 is invalid."
		Case 8; Löschen fehlerhaft
			$s = "Can't delete the original File...."
		Case 9; Kopieren fehlerhaft
			$s = "Can't copy the new File...."
	EndSwitch
	$s &= @CRLF & "Error Code: " & $i
	MsgBox("48", "Error....", $s)
	Exit
EndFunc   ;==>_ScriptExit


Func _GuiCreate()
	Global $hMainWindow = GUICreate($aParam[0][1] & " - Updater", 400, 250)
	GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")
	Global $cLabel1 = GUICtrlCreateLabel("Das Programm '" & $aParam[0][1] & "' wird geupdatet.", 20, 20, 360, 20)
	Global $cLabel2 = GUICtrlCreateLabel("Dateigröße beträgt:", 20, 40, 100, 20)
	Global $cLabel3 = GUICtrlCreateLabel("0 KB", 130, 40, 100, 20, $SS_LEFT)
	Global $cLabel4 = GUICtrlCreateLabel("Datei: ", 290, 40, 40, 0)
	Global $cLabel5 = GUICtrlCreateLabel("0 / 0", 350, 40, 40, 0)
	Global $cLabel6 = GUICtrlCreateLabel("Der Download neuer Dateien beginnt...", 20, 80, 360, 20)
	Global $cProgress1 = GUICtrlCreateProgress(20, 110, 360, 40, $PBS_SMOOTH)
	Global $cButton1 = GUICtrlCreateButton("Abbrechen", 150, 200, 100, 40)

	GUICtrlSetOnEvent($cButton1, "_ExitApp")
	GUISetState()
EndFunc   ;==>_GuiCreate


Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	If BitAND($wParam, 0x0000FFFF) = $cButton1 Then _ScriptExit(-1)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_COMMAND







#cs
	Name=[ScriptName (Display)]
	Win=[MainWindowName (Exit)]
	Path1=[Path to Program to Restart]
	Param1=[Param to Pass to Program after Restart]
	FileOnline1=[UpdateFileOnline (Complete URL)]
	FileLocal1=[UpdateFileLocal (Name + Ext)]
	
	
#ce


Func _CheckParam($str)
	Local $i = _ArraySearch($aParam, $str)
	Return $i
EndFunc   ;==>_CheckParam


Func _CheckFile($str)
	Local $i = -1
	Select
		Case StringInStr($str, "fileonline")
			$i = StringTrimLeft($str, 10)
			SetExtended(1)
		Case StringInStr($str, "filelocal")
			$i = StringTrimLeft($str, 9)
			SetExtended(0)
	EndSelect
	Return $i
EndFunc   ;==>_CheckFile




Func _Variant_CmdLine()
	If UBound($CmdLine) = 1 Then Return 0

	Local $s, $index, $ext
	For $i = 1 To UBound($CmdLine) - 1 Step 1
		$s = StringSplit($CmdLine[$i], "=", 2)
		If UBound($s) <> 2 Then ContinueLoop
		$index = _CheckParam($s[0])
		If $index >= 0 Then
			$aParam[$index][1] = $s[1]
			ContinueLoop
		EndIf
		
		$index = _CheckFile($s[0])
		$ext = @extended
		If $index >= 0 Then
			ReDim $aFiles[$index + 1][2]
			$aFiles[$index][$ext] = $s[1]
			ContinueLoop
		EndIf
		
		$sCmdLineLeftOver &= $CmdLine[$i] & " "
	Next
	Return 1
EndFunc   ;==>_Variant_CmdLine






Func _Variant_Ini()
	If FileExists($sUpdateIni) = 0 Then Return 0

	$aParam[0][1] = IniRead($sUpdateIni, "Update", "name", "")
	$aParam[1][1] = IniRead($sUpdateIni, "Update", "win", "")
	$aParam[2][1] = IniRead($sUpdateIni, "Update", "path1", "")
	$aParam[3][1] = IniRead($sUpdateIni, "Update", "param1", "")

	For $i = 1 To 1000 Step 1
		ReDim $aFiles[$i + 1][2]
		$aFiles[$i][0] = IniRead($sUpdateIni, "Files", "filelocal" & $i, "")
		$aFiles[$i][1] = IniRead($sUpdateIni, "Files", "fileonline" & $i, "")
		If $aFiles[$i][0] = "" Or $aFiles[$i][1] = "" Then ExitLoop
	Next
	_ArrayDelete($aFiles, UBound($aFiles) - 1)
	Return 1
EndFunc   ;==>_Variant_Ini



Func _Variant_Com()

EndFunc   ;==>_Variant_Com



