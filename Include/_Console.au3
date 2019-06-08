;_Console_Functions.au3

#pragma compile(Console,True)

Global Const $iConMaxCharPerLineCmd = 80; Maximum is supported by CMD
Global Const $iConMaxCharPerLine = 76; Adding 2 Spaces to the Lines and Minimum of 2 # Equals 76
Global Const $sConHotkeyUserNext = "{Enter}"
Global Const $sConHotkeyUserNextText = "Enter"
Global Const $sConHotkeyUserQuit = "{Esc}"
Global Const $sConHotkeyUserQuitText = "Escape"


Global $bUserHotkeyEnter = 0
Global $sConHeader = ""


Func _Con_W($mode,$s = 1)
	Local $j = "", $k,$n,$i
	If IsNumber($mode) = 0 Then Exit MsgBox(16,"Internal Error","No Number specified for mode: " & @LF & $mode)
	Switch $mode
		Case -1; Simple Write $s
			$j = $s
		Case 0; Linefeed Count with $s
			For $i = 2 To $s Step 1
				$j &= @LF
			Next
		Case 1; Single line of #
			$s = "#"
			For $i=0 To $iConMaxCharPerLineCmd Step 1
				$j &= $s
			Next
		Case 2; Fill with # to match Lines
			If StringLen($s) > $iConMaxCharPerLine Then ; Split String and put them into multiple Lines
				$i = $iConMaxCharPerLine
				Do
					$k = StringLeft($s,$i)					; Hard Split of String, TEMP
					$j = StringInStr($k," ",0,-1)			; Search for nearest Space from right
					If $j = 0 Then $j = $i					; When no Space is found in Partial String take Hard Split Val
					$n = StringLeft($s,$j)					; Take string on Pos of nearest Space
					_Con_W(2,$n)							; Write String to Console
					$s = StringTrimLeft($s,$j)				; Trim String to Selected Space
				Until StringLen($s) < $iConMaxCharPerLine +1
				_Con_W(2,$s)								; Write Remaining String to Console
				Return
			Else
				$k = ($iConMaxCharPerLineCmd - StringLen($s)-2) / 2; Substracting 2 Spaces
				For $i = 1 To Floor($k) Step 1
					$j &= "#"
				Next
				$j &= " " & $s & " "
				For $i = 1 To Ceiling($k) Step 1
					$j &= "#"
				Next
			EndIf
	EndSwitch
	ConsoleWrite($j & @LF)
EndFunc
Func _Con_W_Header($s = -1)
	If $s = -1 Then
		$s = $sConHeader
	Else
		$sConHeader = $s
	EndIf
	_Con_W(1)
	_Con_W(2,$s)
	_Con_W(1)
	_Con_W(0)
EndFunc
Func __Con_UserNext(); Internal Function!
	$bUserHotkeyEnter = 1
EndFunc
Func __Con_UserQuit(); Internal Function
	$bUserHotkeyEnter = 2
EndFunc
Func _Con_Wait()
	Local $ext = 0
	_Con_W(1)
	_Con_W(0,1)
	_Con_W(0)
	_Con_W(-1,"Press " & $sConHotkeyUserNextText & " to continue or press " & $sConHotkeyUserQuitText & " to quit....")
	_Con_W(0)
	HotKeySet($sConHotkeyUserNext,"__Con_UserNext")
	HotKeySet($sConHotkeyUserQuit,"__Con_UserQuit")
	While $bUserHotkeyEnter = 0
		Sleep(100)
	WEnd
	$ext = $bUserHotkeyEnter
	$bUserHotkeyEnter = 0
	HotkeySet($sConHotkeyUserNext)
	HotkeySet($sConHotkeyUserQuit)
	Return SetExtended($ext)
EndFunc
Func _Con_Wait_Quit()
	Local $ext = 0
	_Con_W(1)
	_Con_W(0,1)
	_Con_W(0)
	_Con_W(-1,"Press " & $sConHotkeyUserQuitText & " to quit....")
	_Con_W(0)
	HotKeySet($sConHotkeyUserQuit,"__Con_UserQuit")
	While $bUserHotkeyEnter = 0
		Sleep(100)
	WEnd
	$ext = $bUserHotkeyEnter
	$bUserHotkeyEnter = 0
	HotkeySet($sConHotkeyUserQuit)
	Return SetExtended($ext)
EndFunc
Func _Con_Clear($mode=1)
	_Con_W(2,"CONSOLE GETS CLEARED IN COMPILED")
	_WinAPI_ClearConsole()
	If $mode = 1 Then _Con_W_Header()
EndFunc

; #FUNCTION# =======================================================
; Name...........: _WinAPI_ClearConsole
; Description ...: Clears console screen buffer
; Syntax.........: _WinAPI_WriteConsole()
; Parameters ....: $hConsole    - (Optional) Handle to the console screen buffer
;
; Return values .: Success      - True
;                         Failure        - False
; Author ........: rover
; Modified.......:
; Remarks .......: with code from Screen_Scrape.au3 - Author: Valik
;                        http://www.autoitscript.com/forum/index.php?s=&showtopic=71023&view=findpost&p=527810
; Related .......:   How To Performing [sic] Clear Screen (CLS) in a Console Application
;                        Article ID: 99261 - Last Review: November 21, 2006 - Revision: 3.3
;                        http://support.microsoft.com/kb/99261
;                        Clearing the Screen (Windows) - Win32 & COM (same code as above)
;                        http://msdn.microsoft.com/en-us/library/ms682022.aspx (Build date: 3/12/2009)  
; Link ..........; @@MsdnLink@@ FillConsoleOutputCharacter            
; Example .......; Yes
; ==================================================================
Func _WinAPI_ClearConsole($hConsole = -1)
    If @Compiled = 0 Then Return 0
    Local $coordBufferCoord = BitOR(0 * 0x10000, BitAND(0, 0xFFFF)), $bChar = 0x20
    Local Const $STD_OUTPUT_HANDLE = -11
    Local Const $INVALID_HANDLE_VALUE = -1
    Local Const $_CONSOLE_SCREEN_BUFFER_INFO = "short dwSizeX; short dwSizeY;short dwCursorPositionX;" & _
    "short dwCursorPositionY; short wAttributes;short Left; short Top; short Right; short Bottom;" & _
    "short dwMaximumWindowSizeX; short dwMaximumWindowSizeY"

    Local $hDLLK32 = DllOpen("Kernel32.dll"), $aRet
    If $hConsole = -1 Then
        $aRet = DllCall($hDLLK32, "hwnd", "GetStdHandle", "dword", $STD_OUTPUT_HANDLE)
        If @error Then Return SetError(@error, 1, $INVALID_HANDLE_VALUE)
        $hConsole = $aRet[0]
    EndIf
    
    Local $tCONSOLE_SCREEN_BUFFER_INFO = DllStructCreate($_CONSOLE_SCREEN_BUFFER_INFO)
    Local $pConsoleScreenBufferInfo = DllStructGetPtr($tCONSOLE_SCREEN_BUFFER_INFO)
    If @error Then $pConsoleScreenBufferInfo = $tCONSOLE_SCREEN_BUFFER_INFO
    
    $aRet = DllCall($hDLLK32, "int", "GetConsoleScreenBufferInfo", "hwnd", _
    $hConsole, "ptr", $pConsoleScreenBufferInfo)
    If @error Then Return SetError(@error, 2, False)
    
    Local $dwSizeX  = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "dwSizeX")
    Local $dwSizeY  = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "dwSizeY")
    Local $dwConSize = $dwSizeX * $dwSizeY
    
    $aRet = DllCall($hDLLK32, "int", "FillConsoleOutputCharacter", "hwnd", $hConsole, _
    "byte", $bChar, "dword", $dwConSize, "dword", $coordBufferCoord, "int*", 0)
    If @error Or UBound($aRet) <> 6 Or $aRet[5] <> $dwConSize Then Return SetError(@error, 3, False)

    $aRet = DllCall($hDLLK32, "int", "GetConsoleScreenBufferInfo", "hwnd", _
    $hConsole, "dword", $pConsoleScreenBufferInfo)
    If @error Then Return SetError(@error, 4, False)
    Local $wAttribute  = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "wAttributes")

    $aRet = DllCall($hDLLK32, "int", "FillConsoleOutputAttribute", "hwnd", $hConsole, _
    "short", $wAttribute, "dword", $dwConSize,  "dword", $coordBufferCoord, "int*", 0)
    If @error Or UBound($aRet) <> 6 Or $aRet[5] <> $dwConSize Then Return SetError(@error, 5, False)

    $aRet = DllCall($hDLLK32, "int", "SetConsoleCursorPosition", "hwnd", _
    $hConsole, "dword", $coordBufferCoord)
    If @error Then Return SetError(@error, 6, False)
    DllClose($hDLLK32)
    Return SetError(@error, 0, True)
EndFunc


