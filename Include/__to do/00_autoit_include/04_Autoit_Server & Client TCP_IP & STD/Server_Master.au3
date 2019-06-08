#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <GuiConstantsEx.au3>
#include <Constants.au3>


GUICreate("Server Master Test")
Global $cInput1 = GUICtrlCreateInput("Test Input",20,30,200,150)

GUISetState()

Global $pServer = Run("Server_multiple_test.exe",@WorkingDir,"",BitOR($STDIN_CHILD,$STDOUT_CHILD,$STDERR_CHILD))

While 1
   $msg = GUIGetMsg()
   If $msg = $GUI_EVENT_CLOSE Then Exit
;~    Sleep(100)
   $con = StdoutRead($pServer)
   If $con = "get1" Then
	  $s = GUICtrlRead($cInput1)
	  StdinWrite($pServer,"get1:" & $s)
   EndIf
   $con = ""
WEnd






