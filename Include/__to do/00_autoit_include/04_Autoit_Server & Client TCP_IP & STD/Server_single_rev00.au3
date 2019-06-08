#include <GUIConstantsEx.au3>
#include <Array.au3>

;==============================================
;==============================================
;SERVER!! Start Me First !!!!!!!!!!!!!!!
;==============================================
;==============================================
TCPStartup()

Global $szIPADDRESS = @IPAddress1
Global $nPORT = 33891
Global Const $aIP_Allowed[10] = ["127.0.0.1"]
Global $MainSocket = TCPListen($szIPADDRESS, $nPORT)
If @error Then Exit @error



Example()

Func Example()
   Local $msg,$sRecv,$aRecv
    ; Set Some reusable info
    ; Set your Public IP address (@IPAddress1) here.
    ;   Local $szServerPC = @ComputerName
    ;   Local $szIPADDRESS = TCPNameToIP($szServerPC)
;~     Local $MainSocket, $edit, $ConnectedSocket, $szIP_Accepted

    ; Start The TCP Services
    ;==============================================
    TCPStartup()

    ; Create a Listening "SOCKET".
    ;   Using your IP Address and Port 33891.
    ;==============================================
;~     $MainSocket = TCPListen($szIPADDRESS, $nPORT)

    ; If the Socket creation fails, exit.


    ; Create a GUI for messages
    ;==============================================
    GUICreate("My Server (IP: " & $szIPADDRESS & ")", 300, 200)
    $edit = GUICtrlCreateEdit("", 10, 10, 280, 180)
    GUISetState()


    ; Initialize a variable to represent a connection
    ;==============================================
    $ConnectedSocket = -1


    ;Wait for and Accept a connection
    ;==============================================
   Do
	  $ConnectedSocket = TCPAccept($MainSocket)
	  $msg = GUIGetMsg()
	  If $msg = $GUI_EVENT_CLOSE Then Exit
   Until $ConnectedSocket <> -1
   _Client_SendTCP($ConnectedSocket,"Welcome.")

    ; Get IP of client connecting
   $szIP_Accepted = SocketToIP($ConnectedSocket)
   If _ArraySearch($aIP_Allowed,$szIP_Accepted) = 0 Then TCPCloseSocket($ConnectedSocket)
   GUICtrlSetData($edit,"Connected Client > " & $szIP_Accepted & @CRLF & GUICtrlRead($edit))
   ; GUI Message Loop
    ;==============================================
    While 1
	  $msg = GUIGetMsg()

	  ; GUI Closed
	  ;--------------------
	  If $msg = $GUI_EVENT_CLOSE Then ExitLoop

	  $sRecv = TCPRecv($ConnectedSocket, 2048)
	  If @error Then ExitLoop

	  ; convert from UTF-8 to AutoIt native UTF-16
	  $sRecv = BinaryToString($sRecv, 4)
	  $aRecv = StringSplit($sRecv,":",2)
	  Switch $aRecv[0]
	  Case ""; no message
		 If $sRecv <> "" Then ConsoleWrite($sRecv & @CRLF)
		 ContinueLoop
	  Case "help"; help needed
		 _Client_SendTCP($ConnectedSocket,"Syntax: 'run: %file%'")
	  Case "run"; special message: Run Notepad
		 Run("notepad.exe")
		 _Client_SendTCP($ConnectedSocket,"Running: '" & $aRecv[1] & "' with error: " & @error)
	  Case "text"
	  Case Else; Ignore all other messages; Send no Such Command
		 _Client_SendTCP($ConnectedSocket,"Error > No Such Command: " & $sRecv)
		 ContinueLoop
	  EndSwitch
	  GUICtrlSetData($edit,$szIP_Accepted & " > " & $sRecv & @CRLF & GUICtrlRead($edit))
   WEnd
   
   If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)

   TCPShutdown()
EndFunc   ;==>Example

Func _Client_SendTCP($socket,$text)
   Local $ret = TCPSend($socket,StringToBinary($text,4))
   Return SetError(@error,@extended,$ret)
EndFunc


; Function to return IP Address from a connected socket.
;----------------------------------------------------------------------
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

    $sockaddr = 0

    Return $aRet
EndFunc   ;==>SocketToIP
