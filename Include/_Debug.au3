;_Debug.au3
#include-once
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

Global $dbgFile = "Debug.txt"
Global $dbgToCon = False
Global $dbgToFile = False
Global $dbgToCtrl = False

Global $dbgHCtrl = 0; Control Handle for Debug
Global $dbgHWin = 0; Window Handle for Debug Window
Global $dbgHButton = 0; Control Handle for Clear Log Button
Global $dbgHBox1 = 0; Control Handle for Checkbox Enable Logging

;===============================================================================
; Debug Functions for Debug in File
;
;===============================================================================
#cs defs to add to au3.api

_DbgW($String,$file = $dbgFile) Write String to File. Requires: #include <_Debug.au3>)
_DbgSetOption($i = $dbgToCon,$j = $dbgToFile) Set Debug Options. Requires: #include <_Debug.au3>)
_DbgSetFile($file = $dbgFile) Set new File to write in case $dbgToFile. Requires: #include <_Debug.au3>)
_DbgCreateWin() Requires: #include <_Debug.au3>)
_DbgShowWin() Requires: #include <_Debug.au3>)
_DbgWinHide() Requires: #include <_Debug.au3>)
_DbgWToCtrl() Requires: #include <_Debug.au3>)
_DbgClearLog() Requires: #include <_Debug.au3>)
#ce
;===============================================================================

Func _DbgSetFile($file = $dbgFile)
	$dbgFile = $file
EndFunc

Func _DbgSetOption($i = $dbgToCon,$j = $dbgToFile,$n = $dbgToCtrl)
;~ 	Switch $i
;~ 		Case 0
;~ 			$i = False
;~ 		Case 1
;~ 			$i = True
;~ 	EndSwitch
;~ 	Switch $j
;~ 		Case 0
;~ 			$j = False
;~ 		Case 1
;~ 			$j = True
;~ 	EndSwitch
	
	$dbgToCon = $i
	$dbgToFile = $j
	$dbgToCtrl = $n 
	
	If $dbgToCtrl = 1 Then GuiCtrlSetState($dbgHBox1,$GUI_CHECKED)
	If $dbgToCtrl = 0 Then GuiCtrlSetState($dbgHBox1,$GUI_UNCHECKED)
		
	; ConsoleWrite("_DbgSetOption: BdgToCon: " & $i & @LF)
EndFunc

Func _DbgW($s = "",$file = $dbgFile)
	If $dbgToFile Then FileWriteLine($file,$s)
	If $dbgToCon Then ConsoleWrite($s & @LF)
	If $dbgToCtrl Then _DbgWToCtrl($s)
EndFunc

Func _DbgCreateWin()
	$dbgHWin = GuiCreate("Debug Window",500,500,Default,Default,Default,Default,0)
	GUISetOnEvent($GUI_EVENT_CLOSE,"_DbgWinHide")
	$dbgHButton = GUICtrlCreateButton("Clear Log",15,15,120,30)
	GUICtrlSetOnEvent($dbgHButton,"_DbgClearLog")
	$dbgHBox1 = GUICtrlCreateCheckbox("Enable Show Log",170,15,120,30)
	GUICtrlSetOnEvent(-1,"_DbgEnableLog")
	; $dbgHCtrl = GUICtrlCreateEdit("Debug Log.",15,50,470,435,$ES_READONLY + $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL)
	$dbgHCtrl = GUICtrlCreateEdit("Debug Log.",15,50,470,435,$ES_READONLY + $ES_WANTRETURN + $WS_VSCROLL + $WS_HSCROLL + $ES_AUTOVSCROLL + $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1,"Debug Log")
EndFunc

Func _DbgWinShow()
	If Not IsHWnd($dbgHWin) Then Return
	GUISetState(@SW_SHOW,$dbgHWin)
EndFunc

Func _DbgWinHide()
	If Not IsHWnd($dbgHWin) Then Return
	GUISetState(@SW_HIDE,$dbgHWin)
EndFunc

Func _DbgWToCtrl($s)
	If Not IsHWnd($dbgHWin) Then Return
	Local $n = GUICtrlRead($dbgHCtrl)
	$n = $s & @CRLF & $n
	GUICtrlSetData($dbgHCtrl,$n)
EndFunc
Func _DbgClearLog()
	If GUICtrlGetState($dbgHCtrl) =-1 Then Return
	GUICtrlSetData($dbgHCtrl,"")
EndFunc
Func _DbgEnableLog()
	If GUICtrlGetState($dbgHBox1) = $GUI_CHECKED Then $dbgToCtrl = 1
	If GUICtrlGetState($dbgHBox1) = $GUI_UNCHECKED Then $dbgToCtrl = 0
EndFunc