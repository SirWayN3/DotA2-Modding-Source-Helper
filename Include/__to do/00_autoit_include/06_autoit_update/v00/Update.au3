

#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>


#cs
$CmdLine[0] = Number of Parameters passed
$CmdLine[1] = ScriptName (Display)
$CmdLine[2] = MainWindowName (Exit)
$CmdLine[3] = Path to Program to Restart
$CmdLine[4] = Name to Process to Restart
$CmdLine[5] = Param to Pass to Program after Restart
$CmdLine[6] = UpdateFileOnline (Complete URL)
$CmdLine[7] = UpdateFileLocal (Name + Ext)


#ce
;~ _ArrayDisplay($CmdLine)
Global $sFileSize
Global $iSleepTime = 750

If $CmdLine[0] = 0 Then _ScriptExit(-1)
If $CmdLine[1] = "" Then _ScriptExit(1)
;~ If WinExists($CmdLine[2]) = 0 Then _ScriptExit(2)
If $CmdLine[2] = "" Then _ScriptExit(2)
If FileExists($CmdLine[3]) = 0 Then _ScriptExit(3)
If ProcessWaitClose($CmdLine[4]) = 0 Then _ScriptExit(4)
; CmdLine[5] enthält Parameter, die nicht überprüft werden können
   $sFileSize = InetGetSize($CmdLine[6],1)
If @error Then _ScriptExit(6)
If $CmdLine[7] = "" OR StringRight($CmdLine[7],4) <> ".exe" Then _ScriptExit(7)

   
   
   
;~ Global $sHomeUrl = "http://home.arcor.de/meisterj43ger/AudioParser/"
;~ Global $sUpdateFileOnline = "Audio Parser.exe"
;~ Global $CmdLine[8] = "Audio Parser.exe"
;~ Global $CmdLine[1] = "Audio Parser"


_GuiCreate()



;~ Global $sFileSize = InetGetSize($CmdLine[6],1)
;~ If @error Then
;~    MsgBox(64,"Fehler....","Der Download ist fehlgeschlagen, das Update wird abgebrochen.","",$hMainWindow)
;~    Exit
;~ EndIf
$sFileSize = Floor($sFileSize / 1024)
$sFileSize &= " KB"
GuiCtrlSetData($cLabel2,$sFileSize)

InetGet($CmdLine[6],@TempDir & $CmdLine[7],1)

GuiCtrlSetData($cLabel1,"Lösche alte Dateien....")
GuiCtrlSetData($cProgress1,33)

Sleep($iSleepTime)

If FileDelete($CmdLine[7]) = 0 Then _ScriptExit(8)
   
GuiCtrlSetData($cLabel1,"Kopieren neue Dateien....")
GuiCtrlSetData($cProgress1,66)

Sleep($iSleepTime)

If FileMove(@TempDir & $CmdLine[7], $CmdLine[7],1) = 0 Then _ScriptExit(9)

GuiCtrlSetData($cLabel1,"Update erfolgreich!")
GuiCtrlSetData($cProgress1,100)
MsgBox(64,"Erfolg....","Das Update war erfolgreich. '" & $CmdLine[1] & "' wird gestartet.",10,$hMainWindow)
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
	  Case 6; Download fehlgeschlagen
		 $s = "Parameter 6 is invalid, Download is not possible."
	  Case 7; Lokale Datei hat ein falsches Format (leer, keine exe)
		 $s = "Parameter 7 is invalid."
	  Case 8; Löschen fehlerhaft
		 $s = "Can't delete the original File...."
	  Case 9; Kopieren fehlerhaft
		 $s = "Can't copy the new File...."
   EndSwitch
   $s &= @CRLF & "Error Code: " & $i
   MsgBox("48","Error....",$s)
   Exit
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


