#include <GUIConstantsEx.au3>
#include <Array.au3>
#include <_TCP_UDF.au3>
#include <EditConstants.au3>

;==============================================
;==============================================
;SERVER!! Start Me First !!!!!!!!!!!!!!!
;==============================================
;==============================================
TCPStartup()

Global Const $szIPADDRESS = @IPAddress1
Global Const $nPORT = 33891
Global Const $iConnMax = 2
Global Const $aIP_Allowed[10] = ["127.0.0.1",@IPAddress1]
Global Const $MainSocket = TCPListen($szIPADDRESS, $nPORT)
If @error Then Exit @error


Global $aSocket[$iConnMax+1][4] = [[1,-1,0,""]]
Global $iConnCurr = 0; Current Connections
Global $sRead,$aRead,$sSend,$sCon

For $i=0 To UBound($aSocket)-1 Step 1
   $aSocket[$i][0] = -1; connect socket
   $aSocket[$i][1] = -1; ip Adress
   $aSocket[$i][2] = -1; Status Bit
   $aSocket[$i][3] = -1; user Name
Next

_Env_Gui_Create()


While 1
   ; Check Gui messages
   $msg = GUIGetMsg()
   Switch $msg
   Case $GUI_EVENT_CLOSE
	  ExitLoop
   EndSwitch
   
   ; Check Open Connections
   For $i=0 To $iConnMax Step 1
	  If $aSocket[$i][0] = -1 Then ContinueLoop
	  _TCP_SocketCheck($aSocket[$i][0])
	  If @error Then _TCP_SocketClose($aSocket,$i)
   Next
   
   ; Check inc Connections
   For $i=0 To $iConnMax Step 1
	  If $iConnCurr = $iConnMax Then ExitLoop
	  If $aSocket[$i][0] = -1 Then; Kein Socket vorhanden
		 $aSocket[$i][0] = TCPAccept($MainSocket)
		 If $aSocket[$i][0] = -1 Then ContinueLoop
		 $aSocket[$i][1] = SocketToIP($aSocket[$i][0])
		 If _TCP_CheckAllowedIP($aIP_Allowed,$aSocket[$i][1]) = 0 Then 
			_Env_Gui_SetLog($cEdit1,"Not Allowed Ip Adress > " & $aSocket[$i][1])
			_TCP_SendError($aSocket[$i][1],4)
			_TCP_SocketClose($aSocket,$i)
			ContinueLoop
		 EndIf
		 _Env_Gui_SetLog($cEdit1,"Connected Client > " & $aSocket[$i][1])
		 $iConnCurr += 1
	  EndIf
   Next
   
   ; Anzahl der Sockets überprüfen; Welcome Msg senden; User Setting up
   For $i=0 To $iConnMax Step 1
	  If $aSocket[$i][0] = -1 Then ContinueLoop
	  If $aSocket[$i][2] = -1 Then; Init User
		 _TCP_WaitText($aSocket[$i][0],"Hello.")
		 If @error Then 
			_TCP_SocketClose($aSocket,$i)
			ContinueLoop
		 EndIf
		 $aSocket[$i][2] = 1 
		 _TCP_SendText($aSocket[$i][0],"Welcome.")
		 Sleep(10)
		 _TCP_SendError($aSocket[$i][0],0)
	  Else; User Name recv and Check
		 If $aSocket[$i][3] <> -1 Then ContinueLoop
		 $sRead = _TCP_ReadText($aSocket[$i][0])
		 If @error Then ContinueLoop
		 $aRead = StringSplit($sRead,":",2)
		 If @error Then
			_TCP_SendError($aSocket[$i][0],0)
			ContinueLoop
		 EndIf
		 If $aRead[0] = "user" Then
			If StringStripWS($aRead[1],3) = "" Then
			   _TCP_SendError($aSocket[$i][0],1)
			   ContinueLoop
			EndIf
			$aSocket[$i][3] = $aRead[1]
			_Env_Gui_SetLog($cEdit1,"Connected User:" & $aSocket[$i][1] & " > " & $aRead[1])
			_TCP_SendText($aSocket[$i][0],"User succesfully registered: " & $aRead[1])
		 Else
			_TCP_SendError($aSocket[$i][0],0)
		 EndIf
	  EndIf
   Next
   
   ; Server Accepted Commands
   For $i=0 To $iConnMax Step 1
	  If $aSocket[$i][0] = -1 Then ContinueLoop
	  If $aSocket[$i][2] = -1 Then ContinueLoop
	  If $aSocket[$i][3] = -1 Then ContinueLoop
	  $sRead = _TCP_ReadText($aSocket[$i][0])
	  If @error OR $sRead = "" Then ContinueLoop
	  _Env_Gui_SetLog($cEdit1,$aSocket[$i][3] & " > " & $sRead)
	  Switch $sRead
		 Case "help"
			_TCP_SendText($aSocket[$i][0],"supported Commands are: 'list'")
		 Case "list"
			$sSend = ""
			For $i2=0 To UBound($aSocket)-1 Step 1
			   If $aSocket[$i2][1] = -1 Then ContinueLoop
			   $sSend &= $aSocket[$i2][3] & @CRLF
			Next
			_TCP_SendText($aSocket[$i][0],"Connected Clients:" & @CRLF & $sSend)
		 Case "get"
;~ 			$sSend = GUICtrlRead($cInput1)
			$sSend = ConsoleWrite("get1")
			$sSend = _Std_WaitText("get1")
			If @error Then
			   $sSend = "Cant Connect to App."
			   _TCP_SendError($aSocket[$i][0],5)
			   _Env_Gui_SetLog($cEdit1,$sSend)
			   ContinueLoop
			Else
			   _TCP_SendText($aSocket[$i][0],"Current Input Value: " & $sSend)
			EndIf
		 Case "exit"
			_TCP_SendText($aSocket[$i][0],"Exiting Server")
			Sleep(500)
			Exit
		 Case "logoff"
			_TCP_SocketClose($aSocket,$i)
		 Case Else
			_TCP_SendText($aSocket[$i][0],"please use 'help'")
	  EndSwitch
   Next
   
   ; Clear Variables
   $sRead = ""
   $sSend = ""
   Dim $aRead[2]
WEnd


Func _Env_Gui_Create()   
   GUICreate("My Server (IP: " & $szIPADDRESS & ")", 300, 400)
   Global $cEdit1 = GUICtrlCreateEdit("", 10, 10, 280, 180,$ES_READONLY)
   Global $cInput1 = GUICtrlCreateInput(100,10,210,280,30)
   GUISetState()
EndFunc


Func _Env_Gui_SetLog($edit,$text)
   If $text = "" Then Return
   GUICtrlSetData($edit,$text & @CRLF & GuiCtrlRead($edit))
EndFunc


Func SocketToIP($SHOCKET)
   Local $sockaddr, $aRet
   $sockaddr = DllStructCreate("short;ushort;uint;char[8]")
   $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $SHOCKET, _
		 "ptr", DllStructGetPtr($sockaddr), "int*", DllStructGetSize($sockaddr))
   If Not @error And $aRet[0] = 0 Then
	  $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sockaddr, 3))
	  If Not @error Then $aRet = $aRet[0]
   Else
	  $aRet = 0
   EndIf
   Return $aRet
 EndFunc   ;==>SocketToIP
 
 
 
 
