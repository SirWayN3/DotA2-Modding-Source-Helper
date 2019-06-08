;_Func_Mouse-Hover.au3

Global Const $iTimeMouseHoverToolTipUpdateRate = 150 ; Time in ms to Update the Tooltip when Mouse Hover is active
Global Const $iCountMaxCharsDisplayControlText = 2048 ; Maximum of Displayed Chars to prevent overflow

Global $bMouseHoverInformation = 0 ; Bool to get Information from mouse Hovering
Global $bMouseHoverPossible = 1 ; Bool to indicate wether mouse hovering is possible
Global $bMouseHoverSaved = 0 ; Bool to indicate wether mouse hovering was saved


Global $aMouseHoverPos1 = MouseGetPos() ; must be initialized
Global $aMouseHoverPos2 = MouseGetPos() ; must be initialized

Global $cMouseHoverHandle = 0 ; Handle, that the mouse currently is hovered over
Global $sMouseHoverHandleText = "" ; Text of the Currently hovered Handle of Mouse
Global $cMouseHoverHandleParent = 0 ; Parent Handle, that the mouse currently is hovered over
Global $sMouseHoverHandleParentText = 0 ; Parent Handle, that the mouse currently is hovered over

Global $tTimerMouseHover = 0 ; Handle for Timer to update ToolTip delayed

Global $hMouseHoverAppHandle
Global $hMouseHoverMainGui = 0; Handle to GUI not beeing able to select. Prevent Recursion

Func _Mouse_Hover_Information_Get()
	If $bMouseHoverInformation = 0 Then Return
	If _Mouse_Hover_Information_Check_Time() = 1 Then Return; time not yet ready to update
	Local $s
	$aMouseHoverPos1 = MouseGetPos()
	If $aMouseHoverPos1[0] = $aMouseHoverPos2[0] And $aMouseHoverPos1[1] = $aMouseHoverPos2[1] Then ; has the mouse moved?
		Return
	EndIf
	Local $a_info = _Mouse_Control_GetInfo()
	Local $aDLL = DllCall('User32.dll', 'int', 'GetDlgCtrlID', 'hwnd', $a_info[0]) ; get the ID of the control
	If @error Then Return
	
	$cMouseHoverHandle = $a_info[0]
	$sMouseHoverHandleText = ControlGetText("", "", $cMouseHoverHandle)
	$cMouseHoverHandleParent = _WinAPI_GetAncestor($hMouseHoverAppHandle, $GA_ROOT)
	$sMouseHoverHandleParentText = WinGetTitle($cMouseHoverHandleParent)
	
	$aMouseHoverPos2 = MouseGetPos()
	
	
	; Check for Control, should NOT be the in the Program itself
	If $cMouseHoverHandleParent <> $hMouseHoverMainGui Then
		$s = "X = "
		$s &= $aMouseHoverPos2[0]
		$s &= "   |   Y = "
		$s &= $aMouseHoverPos2[1]
		$s &= @CRLF
		$s &= "Control Text: "
		$s &= StringLeft($sMouseHoverHandleText, 25)
		$s &= @CRLF
		$s &= "Control HWND: "
		$s &= $cMouseHoverHandle
		$s &= @CRLF
		$s &= "Parent ID: "
		$s &= $cMouseHoverHandleParent
		$s &= @CRLF
		$s &= "Parent Title: "
		$s &= $sMouseHoverHandleParentText
		$s &= @CRLF
		ToolTip($s, Default, Default, "STR+S zum speichern", $TIP_INFOICON)
	Else
		$s = "Bitte ein anderes Programm wählen."
		ToolTip($s, Default, Default, "Fehler....", $TIP_ERRORICON)
	EndIf

;~ 	ConsoleWrite($s)
;~ 	ConsoleWrite(@CRLF)
EndFunc   ;==>_Mouse_Hover_Information_Get

Func _Mouse_Hover_SetMainGui($h)
	$hMouseHoverMainGui = $h
EndFunc
Func _Mouse_Hover_Information_Start()
	$bMouseHoverInformation = 1
	_Mouse_Hover_Hotkey_Start()
EndFunc   ;==>_Mouse_Hover_Information_Start

Func _Mouse_Hover_Information_Stop()
	ToolTip("")
	$bMouseHoverInformation = 0
	$tTimerMouseHover = 0
	_Mouse_Hover_Hotkey_Stop()
EndFunc   ;==>_Mouse_Hover_Information_Stop

Func _Mouse_Hover_Information_Check_Time()
	Local $t
	If $tTimerMouseHover = 0 Then $tTimerMouseHover = TimerInit() ; First Init or Reset
	$t = TimerDiff($tTimerMouseHover)
	If $t > $iTimeMouseHoverToolTipUpdateRate Then
		$tTimerMouseHover = TimerInit()
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_Mouse_Hover_Information_Check_Time

Func _Mouse_Hover_Hotkey_Start()
	HotKeySet("^s", "_Mouse_Hover_Hotkey_Save")
	ConsoleWrite("Hotkey Return Value: " & @error & @LF)
EndFunc
Func _Mouse_Hover_Hotkey_Stop()
	HotKeySet("^s")
EndFunc

Func _Mouse_Hover_Hotkey_Save()
	If $cMouseHoverHandleParent = $hMouseHoverMainGui Then Return ; Not valid
	$bMouseHoverSaved = 1
	; cMouseHoverHandle
	; cMouseHoverHandleParent
	_Mouse_Hover_Information_Stop()
EndFunc
; ===============================================================================
; Retrieves the Handle of GUI/Application the mouse is over.
; Similar to WinGetHandle except it used the current mouse position
; Taken from http://www.autoitscript.com/forum/index.php?showtopic=444962
; Changed to take params to allow only one set of coords to be used.
; Params
;~  $i_xpos - x position of the mouse - usually from MouseGetPos(0)
;~  $i_ypos - x position of the mouse - usually from MouseGetPos(1)
; ===============================================================================
Func _GetHoveredHwnd($i_xpos, $i_ypos)
	Local $iRet = DllCall("user32.dll", "int", "WindowFromPoint", "long", $i_xpos, "long", $i_ypos)
	Local $hMouseHoverAppHandle
	If IsArray($iRet) Then
		$hMouseHoverAppHandle = $iRet[0]
		Return HWnd($iRet[0])
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_GetHoveredHwnd

; ===============================================================================
;~ Retrieves the information of a Control located under the mouse.
;~ Uses Windows functions WindowFromPoint and GetClassName to retrieve the information.
;~ Functions used
;~  _GetHoveredHwnd()
;~  _ControlGetClassnameNN()
;~ Returns
;~   [0] = Control Handle of the control
;~   [1] = The Class Name of the control
;~   [2] = Mouse X Pos (converted to Screen Coord)
;~   [3] = Mouse Y Pos (converted to Screen Coord)
;~   [4] = ClassNN
; ===============================================================================
Func _Mouse_Control_GetInfo()
	Local $client_mpos = $aMouseHoverPos1 ; gets client coords because of "MouseCoordMode" = 2
	Local $a_mpos
;~  Call to removed due to offset issue $a_mpos = _ClientToScreen($hMouseHoverAppHandle, $client_mpos[0], $client_mpos[1]) ; $a_mpos now screen coords
	$a_mpos = $client_mpos
	$hMouseHoverAppHandle = _GetHoveredHwnd($client_mpos[0], $client_mpos[1]) ; Uses the mouse to do the equivalent of WinGetHandle()

	If @error Then Return SetError(1, 0, 0)
	Local $a_wfp = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $a_mpos[0], "long", $a_mpos[1]) ; gets the control handle
	If @error Then Return SetError(2, 0, 0)

	Local $t_class = DllStructCreate("char[260]")
	DllCall("User32.dll", "int", "GetClassName", "hwnd", $a_wfp[0], "ptr", DllStructGetPtr($t_class), "int", 260)
	Local $a_ret[5] = [$a_wfp[0], DllStructGetData($t_class, 1), $a_mpos[0], $a_mpos[1], "none"]
;~     Local $sClassNN = _ControlGetClassnameNN($a_ret[0]) ; optional, will run faster without it
;~     $a_ret[4] = $sClassNN

	Return $a_ret
EndFunc   ;==>_Mouse_Control_GetInfo

