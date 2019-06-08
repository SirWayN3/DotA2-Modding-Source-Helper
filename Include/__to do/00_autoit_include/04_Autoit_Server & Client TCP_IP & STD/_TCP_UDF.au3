#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


Func _TCP_SendText($socket,$text)
   Local $ret = TCPSend($socket,StringToBinary($text,4))
   Return SetError(@error,@extended,$ret)
EndFunc

Func _TCP_ReadText($socket)
   Local $s = TCPRecv($socket, 2048)
   If @error Then Return SetError(1,0,"")
   If $s = "" Then Return SetError(2,0,"")
   $s = BinaryToString($s,4)
   Return $s
EndFunc

Func _TCP_WaitText($socket,$text,$timeout=1000)
   Local $recv
   Local $t = TimerInit()
   While 1
	  $recv = _TCP_ReadText($socket)
	  If $recv = $text Then ExitLoop
	  If $recv <> "" Then Return SetError(2,0,$recv)
	  If TimerDiff($t) > $timeout Then Return SetError(1,0,"")
   WEnd
   Return $recv
EndFunc

Func _TCP_SendError($socket,$mode)
   Local $text
   Switch $mode
	  Case 0
		 $text = "Please send your Username. Syntax: 'user:_____'"
	  Case 1
		 $text = "No supported Username."
	  Case 2
		 $text = "No supported Command."
	  Case 3
		 $text = "Closing Connection."
	  Case 4
		 $text = "Closing Connection. Not allowed IP Adress."
	  Case 5
		 $text = "Cant Connect to App."
   EndSwitch
   Local $ret = TCPSend($socket,StringToBinary($text,4))
   Return SetError(@error,@extended,$ret)
EndFunc

Func _TCP_SocketClose(ByRef $array,$index)
   _TCP_SendError($array[$index][0],3)
   TCPCloseSocket($array[$index][0])
   _Env_Gui_SetLog($cEdit1,"Connection Closed > " & $aSocket[$i][1])
   $iConnCurr -= 1
   For $i=0 To 3 Step 1
	  $array[$index][$i] = -1
   Next
EndFunc


Func _TCP_SocketCheck($socket)
   TCPSend($socket,"")
   If @error Then Return SetError(1,0,"")
EndFunc



Func _TCP_CheckAllowedIP(ByRef Const $array,ByRef Const $ip)
   For $i=0 To UBound($array)-1 Step 1
	  If $array[$i] = $ip Then Return 1
   Next
   Return 0
EndFunc



Func _Std_WaitText($text,$timeout=1000)
   Local $recv
   Local $t = TimerInit()
   While 1
	  $recv = ConsoleRead()
	  If StringInStr($recv,$text) Then ExitLoop
	  If $recv <> "" Then Return SetError(2,0,$recv)
	  If TimerDiff($t) > $timeout Then Return SetError(1,0,"")
   WEnd
   Return $recv
EndFunc


