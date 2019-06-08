

; #FUNCTION# ====================================================================================================================
; Name...........: _DoubleClick
; Description ...: Checks Double Click on a Control
; Requirements...: Use WM_COMMAND and GuiRegisterMsg($WM_COMMAND,"YOUR_FUNCTION") to use it fast
;					Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
;   					If BitAND($wParam, 0x0000FFFF) = "YOUR_ID" Then _DoubleClick("YOUR_ID")
;   					Return $GUI_RUNDEFMSG
;					EndFunc   ;==>_WM_COMMAND
; Syntax.........: _DoubleClick($CtrlID)
; Parameters ....: $CtrlID - ID of the Control
; Return values .: Success - 1
;                  Failure - 0
; Author ........: SirWayNe
; Modified.......: 
; Remarks .......:
; Related .......: 
; Link ..........:
; Example .......: 
; ===============================================================================================================================


; DoubleClick über TimerDiff zum letzten aufrufen realisieren
Global $aDoubleClick[3]; [0] CtrlID,[1] Timer,[2] ClickSpeed
$aDoubleClick[2] = RegRead("HKEY_CURRENT_USER\Control Panel\Mouse", "DoubleClickSpeed")


Func _DoubleClick($ID)
   ; Return 1 = DoubleClick = True
   ; Return 0 = DoubleClick = False
   If $aDoubleClick[0] = $ID Then ; wurde bereits angeklickt
	  If TimerDiff($aDoubleClick[1]) < $aDoubleClick[2] Then; Zeit ist noch in Toleranz
		 Return 1
	  EndIf
   EndIf
   $aDoubleClick[0] = $ID
   $aDoubleClick[1] = TimerInit()
   Return 0
EndFunc



