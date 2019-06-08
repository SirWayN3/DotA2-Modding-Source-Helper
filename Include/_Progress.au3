#include-once
;===============================================================================
; Help Functions for Struct
;
;===============================================================================
#cs defs to add to au3.api

_PGShow($s = $pgTitle,$n = $pgMain,$j = $pgSub,$i = $pgOpt,$k = $pgHwnd) Show Progress (Requires: #include <_Help_Progress.au3>)
_PGSet($i = $pgPercent,$s = $pgSub,$n = $pgMain) Update Progress. Requires _PGShow() to Show Progress. (Requires: #include <_Help_Progress.au3>)
_PGSetMain($s = "") Set Main Text of Progress. Requires _PGSet() to update Progress. (Requires: #include <_Help_Progress.au3>)
_PGSetSub($s = "") Set Sub Text of Progress. Requires _PGSet() to update Progress. (Requires: #include <_Help_Progress.au3>)
_PGSetPerc($i = 0) Set Percentage of Progress. Range between 0 and 100. Requires _PGSet() to update Progress. (Requires: #include <_Help_Progress.au3>)
_PGSetOpt($i = 0) Set Option of Next Progress. Requires _PGSet() to update Progress. 1=Borderless, titleless. 2=Without "Always on top" attribute. 16=Window can be moved (Requires: #include <_Help_Progress.au3>)
_PGSetHwnd($i = 0) Set Parent Window Handle. (Requires: #include <_Help_Progress.au3>)
_PGHide($mode = 0) Hide Current Progress. Mode0: Delete every Setting. Mode1: Preserve last Settings (Requires: #include <_Help_Progress.au3>)

#ce
;===============================================================================

Global $pgHwnd = 0			; Gui Handle to be parent
Global $pgVis = 0			; Progress Visible
Global $pgPercent = 0		; Current Percentage
Global $pgTitle = ""		; Current Title
Global $pgMain = ""			; Current Main Text
Global $pgSub = ""			; Current Sub Text
Global $pgOpt = 0			; Current Option

Func _PGSet($i = $pgPercent,$s = $pgSub,$n = $pgMain)
	If $pgVis = 0 Then Return
	ProgressSet($i,$s,$n)
EndFunc
Func _PGShow($s = $pgTitle,$n = $pgMain,$j = $pgSub,$i = $pgOpt,$k = $pgHwnd)
	If $pgVis = 1 Then Return
	ProgressOn($s,$n,$j,Default,Default,$i)
	GUISetState(@SW_DISABLE,$k)
	$pgVis = 1
Endfunc
Func _PGSetMain($s = "")
	$pgMain = $s
EndFunc
Func _PGSetHwnd($i = 0)
	$pgHwnd = $i
EndFunc
Func _PGSetSub($s = "")
	$pgSub = $s
EndFunc
Func _PGSetPerc($i = 0)
	If $i < 0 OR $i > 100 Then Return MsgBox(48,"Intern _PGSetPerc","Internal Error. Dont use Numbers < 0 or > 100")
	$pgPercent = $i
	ProgressSet($i)
EndFunc
Func _PGSetOpt($i = 0)
	If $i < 0 OR $i > 19 Then Return MsgBox(48,"Intern _PGSetOpt","Internal Error. Dont use Numbers < 0 or > 16")
	$pgOpt = $i
EndFunc
Func _PGHide($mode = 0)
	GUISetState(@SW_ENABLE,$pgHwnd)
	ProgressOff()
	$pgVis = 0
	If $mode = 0 Then
		$pgPercent = 0
		$pgTitle = ""
		$pgMain = ""
		$pgSub = ""
		$pgOpt = 0
		$pgHwnd = 0
	EndIf
EndFunc
