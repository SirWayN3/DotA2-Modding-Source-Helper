

#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>


#cs
$CmdLine[0] = Number of Parameters passed
$CmdLine[1] = 
$CmdLine[2] = 
$CmdLine[3] = 
$CmdLine[4] = 
$CmdLine[5] = 
$CmdLine[6] = 
$CmdLine[7] = 


#ce

;~ _ArrayDisplay($CmdLine); -> Debug


Global Const $iSleepTime = 750
Global $sURL[2]; Array für die Dateien, die herunter zu laden sind
Global $iSize = 0; Int für die Dateigröße
Global $hInet = 0; Handle für das Runterladen der Internet Datei

; CmdLine überprüfen
$CmdLine[0] = 0 Then _ScriptExit(-1)

; Gui Erstellen
_GuiCreate()


; Programm abfolge
For $i=0 To UBound($sURL)-1 Step 1
   $iSize = InetGetSize($sURL[$i],3)
   ConsoleWrite("Size File: " & $i & @TAB & $iSize & @CRLF)
Next

_ScriptExit(0)


Func _ScriptExit($i)
   Local $s
   Switch $i
	  Case -1; Keine Parameter angegeben
		 $s = "This Program needs proper Parameters."
	  Case 0;
		 InetClose($hInet)
		 Exit
   EndSwitch
   $s &= @CRLF & "Error Code: " & $i
   MsgBox("48","Error....",$s)
   InetClose($hInet)
   Exit $i
EndFunc


Func _GuiCreate()
   Global $hMainWindow = GuiCreate($CmdLine[1] & " - Updater",400,250)
   GuiCtrlCreateLabel("Das Programm '" & $CmdLine[1] & "' wird geupdatet.",20,20,360,20)
   GuiCtrlCreateLabel("Dateigröße beträgt:",20,40,100,20)
   Global $cLabel2 = GuiCtrlCreateLabel("0 KB",130,40,100,20,$SS_LEFT)
   Global $cLabel1 = GuiCtrlCreateLabel("Der Download neuer Dateien beginnt...",20,80,360,20)
   Global $cProgress1 = GUICtrlCreateProgress(20,110,360,40,$PBS_SMOOTH)
   Global $cButton1 = GuiCtrlCreateButton("Abbrechen",150,200,100,40)

   GuiCtrlSetOnEvent($cButton1,"_ExitApp")
   GuiSetState()
EndFunc




