#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

; CmdLine auslesen und einstellen
Global $bScriptCmdLineNoSplash = 0;	Bool für das Starten des Programms mit Splash
Global $sScriptCmdLineLanguage = ""; String für das Language 
_CmdLineRead()



Func _CmdLineRead()
   ; nosplash=1
   Local $a[2]
   For $i=1 To $CmdLine[0] Step 1
	  $a = StringSplit($CmdLine[$i],"=",2)
	  If UBound($a) > 2 Then ContinueLoop
	  Switch $a[0]
	  Case "nosplash"
		 $bScriptCmdlineNoSplash = $a[1]
	  Case "language"
		 $sScriptCmdLineLanguage = $a[1]
	  EndSwitch
   Next
EndFunc