;==============================================
;==============================================
;CLIENT! Start Me after starting the SERVER!!!!!!!!!!!!!!!
;==============================================
;==============================================
#include <EditConstants.au3>
#include <GuiConstants.au3>
#include <ButtonConstants.au3>
#include <_TCP_UDF.au3>

;~ Global Const $szIPserver = @IPAddress1
Global $szIPserver = @IPAddress1
Global Const $nPORT = 33891

Global $msg,$recv,$resp
Global $hSocket = -1

TCPStartup()
;~ If @Compiled AND ProcessWait(Run("Server.exe"),3) = 0 Then Exit -1



_Env_CreateGui()

;~ _TCP_Connect()

If @error Then Exit MsgBox(4112, "Error", "TCPConnect failed with WSA error: " & _
		 @error,0,$hGui1)

While 1
   $msg = GUIGetMsg()
   Switch $msg
   Case $GUI_EVENT_CLOSE
	  ExitLoop
   Case $cButton1
	  GUICtrlSetState($cInput1,$GUI_FOCUS)
	  $recv = _Env_Gui_ReadComm($cInput1)
	  If @error Then ContinueLoop
	  _TCP_SendText($hSocket,$recv)
	  If @error Then _Env_Gui_SetLog($cEdit1,"Error: No Connection to the Server")
	  GUICtrlSetData($cInput1,"")
   Case $cButton2
	  GUICtrlSetData($cEdit1,"")
   Case $cButton3
	  $recv = GUICtrlRead($cInput2)
	  $szIPserver = $recv
	  _TCP_Connect()
	  If @error Then _Env_Gui_SetLog($cEdit1,"Error: No Connection to the Server")
   EndSwitch
   Sleep(50)
   _Env_Gui_SetLog($cEdit1,_TCP_ReadText($hSocket))
   $recv = ""
WEnd



Func _TCP_Connect()

   Local $szData,$recv,$t
   _Env_Gui_SetLog($cEdit1,"Trying to connect to: " & $szIPserver & ":" & $nPort)
   $hSocket = TCPConnect($szIPserver, $nPORT)
   If @error Then Return SetError(1,0,"")
   ; Test Connection
   _TCP_SendText($hSocket,"Hello.")
;~    If @error Then SetError(1,0,"")
   $recv = _TCP_WaitText($hSocket,"Welcome.")
   Switch @error
	  Case 1
		 _Env_Gui_SetLog($cEdit1,"Connection Closed > " & $szIPserver)
		 _Env_Gui_SetLog($cEdit1,"Timed Out.")
		 TCPCloseSocket($hSocket)
		 Return SetError(1)
	  Case 2
		 _Env_Gui_SetLog($cEdit1,"Connection Closed > " & $szIPserver)
		 _Env_Gui_SetLog($cEdit1,"Server message: " & $recv)
		 TCPCloseSocket($hSocket)
		 Return SetError(2)
	  Case Else
		 _Env_Gui_SetLog($cEdit1,"Succesfully connected to: " & $szIPserver & ":" & $nPort)
		 _Env_Gui_SetLog($cEdit1,$recv)
   EndSwitch
   
EndFunc   ;==>Example

 
Func _Env_Gui_SetLog($edit,$text)
   If $text = "" Then Return
   GUICtrlSetData($edit,$text & @CRLF & GuiCtrlRead($edit))
EndFunc


Func _Env_Gui_ReadComm($control)
   Local $s = GuiCtrlRead($control)
   If $s = "" Then Return SetError(1,0,"")
   Return $s
EndFunc


Func _Env_CreateGui()
  Global $hGui1 = GuiCreate("Client Software",550,500)
  Global $cInput1 = GUICtrlCreateEdit("",30,15,400,30,$GUI_SS_DEFAULT_INPUT)
  Global $cButton1 = GUICtrlCreateButton("Befehl senden",30,70,100,40,$BS_DEFPUSHBUTTON)
  Global $cButton2 = GUICtrlCreateButton("Log Leeren",150,70,100,40)
  Global $cButton3 = GUICtrlCreateButton("Connect to IP",290,70,100,40)
  Global $cInput2 = GUICtrlCreateInput($szIPserver,430,70,100,40)
  Global $cEdit1 = GUICtrlCreateEdit("",30,140,400,340,$ES_READONLY)
  GUISetState()
  WinWait($hGui1)
EndFunc





