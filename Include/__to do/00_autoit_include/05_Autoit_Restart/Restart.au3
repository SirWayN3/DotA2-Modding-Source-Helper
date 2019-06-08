
#RequireAdmin
#include <Array.au3>



#cs
$CmdLine[0] = Number of Parameters
$CmdLine[1] = ScriptName (Display)
$CmdLine[2] = MainWindowName (Exit)
$CmdLine[3] = Path to Program to Restart
$CmdLine[4] = Name to Process to Restart
$CmdLine[5] = Param to Pass to Program after Restart


#ce

If $CmdLine[0] = 0 Then _ScriptExit(-1)
If $CmdLine[1] = "" Then _ScriptExit(1)
If WinExists($CmdLine[2]) = 0 Then _ScriptExit(2)
If FileExists($CmdLine[3]) = 0 Then _ScriptExit(3)
If ProcessWaitClose($CmdLine[4]) = 0 Then _ScriptExit(4)
   
WinWaitClose($CmdLine[2])
Sleep(500)
Run($CmdLine[3] & ' "' & $CmdLine[5] & '"' )
Exit


Func _ScriptExit($i)
   Local $s
   Switch $i
	  Case -1; Keine Parameter angegeben
		 $s = "This Program needs proper Parameters."
	  Case 1; Keinen Namen für das Script angegeben
		 $s = "Parameter 1 is invalid."
	  Case 2; Fenster zum schließen existiert nicht
		 $s = "Parameter 2 is invalid, Window doesnt exist." 
	  Case 3; Programm Pfad existiert nicht
		 $s = "Parameter 3 is invalid, Path to Program doesnt exist."
	  Case 4; Prozess ist invalid
		 $s = "Parameter 4 is invalid, Prozess doesnt close."
   EndSwitch
   $s &= @CRLF & "Error Code: " & $i
   MsgBox("48","Error....",$s)
   Exit
EndFunc
