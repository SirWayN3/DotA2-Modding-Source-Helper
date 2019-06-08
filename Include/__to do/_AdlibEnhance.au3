#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7 ; Uncomment this line to Au3Check!
#include-once
; #INDEX# =======================================================================================================================
; Title .........: _AdlibEnhance
; Version .......: 0.16.1212.2600b
; AutoIt Version.: 3.3.8.1
; Language.......: English
; Description ...: Enhanced Adlib function!
; Author ........: JScript (João Carlos)
; Remarks .......: You can register a function using parameters!!!
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Adlib_Register
; _Adlib_UnRegister
; _Adlib_SetParams
; _Adlib_Pause
; _Adlib_Resume
; _Adlib_SetTimer
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __ADB_ENHANCED
; __ADB_CreateTimer
; __ADB_KillTimer
; __ADB_SetTimer
; __ADB_ShutDown
; ===============================================================================================================================

; #Obfuscator ===================================================================================================================
#Obfuscator_Ignore_Funcs= __ADB_ENHANCED, __ADB_CreateTimer, __ADB_KillTimer, __ADB_SetTimer
#Obfuscator_Ignore_Variables= $avADB_CALLS, $pADB_CALLBACK, $pADB_CALLTIMER
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $avADB_CALLS[1][10]
Global $pADB_CALLTIMER = 10

; Open DLLs to acelerate execution!
Global Const $hGRP_USER32 = DllOpen("user32.dll")
;==============================================================================================================================

; #EXIT_REGISTER# ===============================================================================================================
OnAutoItExitRegister("__ADB_ShutDown")
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_Register
; Description ...: Enables Enhanced Adlib functionality for defined function.
; Syntax.........: _Adlib_Register( "Function" [, "Params" [, Time [, RepeatCount ]]] )
; Parameters ....: Function 	- The name of the adlib function to call.
;                  Params 		- [optional] Any parameters you want to pass to the function seperated by "|".
;                  Time			- [optional] How often in milliseconds to call the function. Default is 250 ms.
;				   RepeatCount 	- [optional] Number of times to repeat the call for "Function". Default is -1 (infinite).
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: JScript
; Modified.......:
; Remarks .......: Now you can register native functions!
;				Every 250 ms (or time ms) the specified "function" is called--typically to check for unforeseen errors.
;				For example, you could use adlib in a script which causes an error window to pop up unpredictably.
;				The adlib function should be kept simple as it is executed often and during this time the main script is paused.
;				Also, the time parameter should be used carefully to avoid CPU load.
; Related .......: _Adlib_UnRegister, _Adlib_Pause, _Adlib_SetTimer
; Link ..........;
; Example .......; _Adlib_Register( "MyFunction", "", 100 )
; ===============================================================================================================================
Func _Adlib_Register($sFuncName, $sParams = "", $iTime = 250, $iRepeatCount = -1)
	Local $iIndex, $hWnd

	If Not IsString($sFuncName) Or $sFuncName = "" Or Not IsInt($iTime) Then Return 0

	If $iTime < 10 Then $iTime = 10

	$iIndex = __ADB_GetIndex($sFuncName)
	If $iIndex Then Return 0

	$hWnd = WinGetHandle(AutoItWinGetTitle())

	;----> Fills array with the control data!
	$iIndex = $avADB_CALLS[0][0] + 1
	ReDim $avADB_CALLS[$iIndex + 1][10]
	$avADB_CALLS[0][0] = $iIndex
	$avADB_CALLS[$avADB_CALLS[0][0]][0] = $sFuncName
	$avADB_CALLS[$avADB_CALLS[0][0]][1] = $sParams
	$avADB_CALLS[$avADB_CALLS[0][0]][2] = $iTime
	$avADB_CALLS[$avADB_CALLS[0][0]][3] = $iRepeatCount
	$avADB_CALLS[$avADB_CALLS[0][0]][4] = $hWnd
	$avADB_CALLS[$avADB_CALLS[0][0]][5] = 0 ; Callback identifier, need this for the Kill Timer.
	$avADB_CALLS[$avADB_CALLS[0][0]][6] = 0 ; Pointer to a callback identifier, need this for the __ADB_SetTimer.

	__ADB_CreateTimer($hWnd, $iTime, $iIndex)

	Return 1
EndFunc   ;==>_Adlib_Register

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_SetParams
; Description ...: Sets run-time Adlib parameters!
; Syntax.........: _Adlib_SetParams( "Function", "Params" )
; Parameters ....: sFuncName           - The name of the adlib function.
;                  sParams             - The new parameter(s).
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: darthWhatever
; Modified.......: JScript
; Remarks .......:
; Related .......: _Adlib_Resume, _Adlib_Register, _Adlib_UnRegister, _Adlib_SetTimer
; Link ..........;
; Example .......; _Adlib_SetParams( "MyFunction", "NewParam1|NewParam2" )
; ===============================================================================================================================
Func _Adlib_SetParams($sFuncName, $sParams)
	Local $iIndex = __ADB_GetIndex($sFuncName)
	If Not $iIndex Then Return 0

	$avADB_CALLS[$iIndex][1] = $sParams

	Return 1
EndFunc   ;==>_Adlib_SetParams

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_Pause
; Description ...: Pauses the Enhanced Adlib functionality for defined function.
; Syntax.........: _Adlib_Pause( "Function" )
; Parameters ....: Function - The name of the adlib function to pause.
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: JScript
; Modified.......:
; Remarks .......:
; Related .......: _Adlib_Resume, _Adlib_Register, _Adlib_UnRegister, _Adlib_SetTimer
; Link ..........;
; Example .......; _Adlib_Pause( "MyFunction" )
; ===============================================================================================================================
Func _Adlib_Pause($sFuncName)
	Local $iIndex

	$iIndex = __ADB_GetIndex($sFuncName)
	If Not $iIndex Then Return 0

	__ADB_KillTimer($avADB_CALLS[$iIndex][4], $iIndex)

	Return 0
EndFunc   ;==>_Adlib_Pause

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_Resume
; Description ...: Resumes the Enhanced Adlib functionality for defined function.
; Syntax.........: _Adlib_Resume( "Function" )
; Parameters ....: Function - The name of the adlib function to resume.
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: JScript
; Modified.......:
; Remarks .......:
; Related .......: _Adlib_Register, _Adlib_UnRegister, _Adlib_SetTimer
; Link ..........;
; Example .......; _Adlib_Resume( "MyFunction" )
; ===============================================================================================================================
Func _Adlib_Resume($sFuncName)
	Local $iIndex

	$iIndex = __ADB_GetIndex($sFuncName)
	If Not $iIndex Then Return 0

	__ADB_CreateTimer($avADB_CALLS[$iIndex][4], $avADB_CALLS[$iIndex][2], $iIndex)

	Return 1
EndFunc   ;==>_Adlib_Resume

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_SetTimer
; Description ...: Sets the Enhanced Adlib "Timer" for defined function.
; Syntax.........: _Adlib_SetTimer( "Function" [, Time ] )
; Parameters ....: Function - The name of the adlib function to pause.
;				   Time		- [optional] How often in milliseconds to call the function. Default is 250 ms.
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: JScript
; Modified.......:
; Remarks .......:
; Related .......: _Adlib_Register, _Adlib_UnRegister, _Adlib_Pause
; Link ..........;
; Example .......; _Adlib_SetTimer( "MyFunction", 250 )
; ===============================================================================================================================
Func _Adlib_SetTimer($sFuncName, $iTime = 250)
	Local $iIndex

	$iIndex = __ADB_GetIndex($sFuncName)
	If Not $iIndex Or Not IsInt($iTime) Then Return 0

	__ADB_SetTimer($avADB_CALLS[$iIndex][4], $iTime, $iIndex)

	$avADB_CALLS[$iIndex][2] = $iTime

	Return 1
EndFunc   ;==>_Adlib_SetTimer

; #FUNCTION# ====================================================================================================================
; Name...........: _Adlib_UnRegister
; Description ...: Removes the Enhanced Adlib functionality for defined function.
; Syntax.........: _Adlib_UnRegister( "Function" )
; Parameters ....: Function - The name of the adlib function to disable.
; Return values .: Success 	- Return 1
;				   Failure 	- Return 0
; Author ........: JScript
; Modified.......:
; Remarks .......:
; Related .......: _Adlib_Register, _Adlib_Pause, _Adlib_SetTimer
; Link ..........;
; Example .......; _Adlib_UnRegister( "MyFunction" )
; ===============================================================================================================================
Func _Adlib_UnRegister($sFuncName = "")
	Local $iIndex

	$iIndex = __ADB_GetIndex($sFuncName)
	If Not $iIndex Then Return 0

	For $i = $iIndex To UBound($avADB_CALLS) - 2
		For $j = 0 To 9
			$avADB_CALLS[$i][$j] = $avADB_CALLS[$i + 1][$j]
		Next
	Next
	ReDim $avADB_CALLS[$avADB_CALLS[0][0]][10]
	$avADB_CALLS[0][0] -= 1

	Return 0
EndFunc   ;==>_Adlib_UnRegister

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __ADB_ENHANCED
; Description ...: Check functions, timers and provides Adlib functionality to the program.
; Syntax.........: __ADB_ENHANCED()
; Parameters ....: $hWnd, $Msg, $iIDTimer, $dwTime
; Return values .:
; Author ........: JScript
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......; __ADB_ENHANCED($hWnd, $Msg, $iIndex, $dwTime)
; ===============================================================================================================================
Func __ADB_ENHANCED($hWnd, $Msg, $iIndex, $dwTime)
	#forceref $hWnd, $Msg, $iIndex, $dwTime
	;------------------------------
	; Note: $iIndex = $iIDTimer !!!
	;------------------------------

	;----> CALLS array sample.
	#cs
		$avADB_CALLS[$avADB_CALLS[0][0]][0] = $sFuncName
		$avADB_CALLS[$avADB_CALLS[0][0]][1] = $sParams
		$avADB_CALLS[$avADB_CALLS[0][0]][2] = $iTime
		$avADB_CALLS[$avADB_CALLS[0][0]][3] = $iRepeatCount
		$avADB_CALLS[$avADB_CALLS[0][0]][4] = $hWnd
		$avADB_CALLS[$avADB_CALLS[0][0]][5] = 0 ; Callback identifier, need this for the Kill Timer.
		$avADB_CALLS[$avADB_CALLS[0][0]][6] = 0 ; Pointer to a callback identifier, need this for the __ADB_SetTimer.
	#ce
	;<----

	; Repeat count.
	If $avADB_CALLS[$iIndex][3] Then
		$avADB_CALLS[$iIndex][3] -= 1
		If Not $avADB_CALLS[$iIndex][3] Then
			__ADB_KillTimer($hWnd, $iIndex)
		EndIf
	EndIf

	Switch $avADB_CALLS[$iIndex][1]
		Case ""
			Execute($avADB_CALLS[$iIndex][0] & "()")
		Case Else
			Local $vParam

			$vParam = StringSplit($avADB_CALLS[$iIndex][1], "|")
			If Not @error Then
				Local $sEval, $sExec = $avADB_CALLS[$iIndex][0] & "("

				For $i = 1 To $vParam[0]
					$sEval = StringLower($vParam[$i])
					Switch $sEval
						Case "true"
							$vParam[$i] = True
						Case "false"
							$vParam[$i] = False
						Case Else
							If $sEval = "0" Then
								$vParam[$i] = Number($vParam[$i])
							ElseIf ($sEval <> "0") And (Number($sEval) <> 0) Then
								$vParam[$i] = Number($vParam[$i])
							EndIf
					EndSwitch
					$sExec &= "$vParam[" & $i & "],"
				Next
				$sExec = StringTrimRight($sExec, 1) & ")"
				Execute($sExec)
			Else
				Execute($avADB_CALLS[$iIndex][0] & "(" & $avADB_CALLS[$iIndex][1] & ")")
			EndIf
	EndSwitch

	Return 0
EndFunc   ;==>__ADB_ENHANCED

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADB_GetIndex
; Description ...: Return array index based on $sFuncName.
; Syntax ........: __ADB_GetIndex($sFuncName)
; Parameters ....: $sFuncName             - Fuction name.
; Return values .: None
; Author ........: JScript
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADB_GetIndex($sFuncName)
	If $avADB_CALLS[0][0] Then
		For $iIndex = 1 To $avADB_CALLS[0][0]
			If $avADB_CALLS[$iIndex][0] = $sFuncName Then
				Return $iIndex
			EndIf
		Next
	EndIf
	Return 0
EndFunc   ;==>__ADB_GetIndex

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADB_CreateTimer
; Description ...: Creates a timer with the specified time-out value.
; Syntax ........: __ADB_CreateTimer($hWnd, $iElapse, $iIndex)
; Parameters ....: $hWnd                - Handle to the window to be associated with the timer.
;                  $iElapse             - Specifies the time-out value, in milliseconds.
;                  $iIndex              - An integer value.
; Return values .: Success - Integer identifying the new timer
;                  Failure - 0
; Author ........: JScript
; Modified.......:
; Remarks .......: Based on _Timer_SetTimer() by Gary Frost
; Related .......: __ADB_KillTimer(
; Link ..........; @@MsdnLink@@ SetTimer
; Example .......: No
; ===============================================================================================================================
Func __ADB_CreateTimer($hWnd, $iElapse, $iIndex)
	Local $hCallBack = 0, $pTimerFunc = 0, $aResult[1] = [0]

	$hCallBack = DllCallbackRegister("__ADB_ENHANCED", "none", "hwnd;int;uint_ptr;dword")
	$pTimerFunc = DllCallbackGetPtr($hCallBack)

	$aResult = DllCall($hGRP_USER32, "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iIndex, "uint", $iElapse, "ptr", $pTimerFunc)
	If @error Or $aResult[0] = 0 Then
		DllCallbackFree($hCallBack)
		Return SetError(@error, @extended, 0)
	EndIf
	$avADB_CALLS[$iIndex][5] = $hCallBack ; Callback identifier, need this for the Kill Timer.
	$avADB_CALLS[$iIndex][6] = $pTimerFunc ; Pointer to a callback identifier, need this for the __ADB_SetTimer.

	Return $aResult[0]
EndFunc   ;==>__ADB_CreateTimer

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADB_KillTimer
; Description ...: Destroys the specified adlib timer.
; Syntax ........: __ADB_KillTimer($hWnd, $iIndex)
; Parameters ....: $hWnd                - Handle to the window associated with the specified timer.
;										This value must be the same as the hWnd value passed to the __ADB_CreateTimer function.
;                  $iIndex              - An integer value.
; Return values .: Success - True
;                  Failure - False
; Author ........: JScript
; Modified.......:
; Remarks .......: The __ADB_KillTimer( function does not remove WM_TIMER messages already posted to the message queue
;				   Based on _Timer_KillTimer() by Gary Frost
; Related .......: _Timer_SetTimerEx
; Link ..........: @@MsdnLink@@ KillTimer
; Example .......: No
; ===============================================================================================================================
Func __ADB_KillTimer($hWnd, $iIndex)
	Local $aResult[1] = [0], $hCallBack = 0

	$aResult = DllCall($hGRP_USER32, "bool", "KillTimer", "hwnd", $hWnd, "uint_ptr", $iIndex) ;-> = $iIDTimer
	;If @error Or $aResult[0] = 0 Then Return SetError(@error, @extended, False)
	$hCallBack = $avADB_CALLS[$iIndex][5]
	If $hCallBack <> 0 Then DllCallbackFree($hCallBack)
	; Reset identifiers.
	$avADB_CALLS[$iIndex][5] = 0
	$avADB_CALLS[$iIndex][6] = 0

	Return $aResult[0] <> 0
EndFunc   ;==>__ADB_KillTimer

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADB_SetTimer
; Description ...: Replace a new time-out value.
; Syntax ........: __ADB_SetTimer($hWnd, $iElapse, $iIndex)
; Parameters ....: $hWnd                - Handle to the window to be associated with the timer.
;                  $iElapse             - Specifies the time-out value, in milliseconds.
;                  $iIndex              - An integer value.
; Return values .: Success 				- 1
;                  Failure 				- 0
; Author ........: JScript
; Modified.......:
; Remarks .......: Based on _Timer_SetTimer() by Gary Frost
; Related .......: __ADB_KillTimer(
; Link ..........; @@MsdnLink@@ SetTimer
; Example .......: No
; ===============================================================================================================================
Func __ADB_SetTimer($hWnd, $iElapse, $iIndex)
	DllCall($hGRP_USER32, "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iIndex, _ ;-> = $iIDTimer
			"int", $iElapse, "ptr", $avADB_CALLS[$iIndex][6]) ;-> =$pTimerFunc

	;If @error Or $aResult[0] = 0 Then Return SetError(@error, @extended, 0)
	Return 1
EndFunc   ;==>__ADB_SetTimer

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADB_ShutDown
; Description ...: Function to be called when AutoIt exits.
; Syntax ........: __ADB_ShutDown()
; Parameters ....:
; Return values .: None
; Author ........: JScript
; Modified ......:
; Remarks .......: Frees handle created with DllCallbackRegister.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADB_ShutDown()
	If $avADB_CALLS[0][0] Then
		For $iIndex = 1 To $avADB_CALLS[0][0]
			__ADB_KillTimer($avADB_CALLS[$iIndex][4], $iIndex)
		Next
	EndIf
	DllClose($hGRP_USER32)
EndFunc   ;==>__ADB_ShutDown