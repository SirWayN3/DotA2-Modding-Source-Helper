

#cs ShowBox Version 2
   ShowBox verwendet ID's zum Auswählen der Nachricht
   Flags werden bei der ID ausgewählt
   Title werden bei der ID ausgewählt
   

#ce

Func _ShowBox($ID)
   Local $msg,$flag,$title
   Local $aFlag[4] = [0,48]
   Local $aTitle[4] = ["Info....","Fehler...."]
   
   
   Switch $ID
   Case 1
	  $msg = "Es sind keine Jobs zum Speichern vorhanden."
	  $title = $aTitle[0]
	  $flag = $aFlag[0]
	  $timeout = 0
	  $win = @GUI_WinHandle
   Case 2
	  $msg = "Bitte den Job zum Speichern selektieren."
	  $title = $aTitle[0]
	  $flag = $aFlag[0]
	  $timeout = 0
	  $win = @GUI_WinHandle
   Case 3
	  $msg = "Es gab einen Fehler bei dem Schreiben der Datei."
	  $title = $aTitle[1]
	  $flag = $aFlag[1]
	  $timeout = 0
	  $win = @GUI_WinHandle
   Case 4
	  $msg = "Der Job wurde erfolgreich abgespeichert."
	  $title = $aTitle[0]
	  $flag = $aFlag[0]
	  $timeout = 0
	  $win = @GUI_WinHandle
   Case 5
	  $msg = "Die Jobs wurden erfolgreich abgespeichert."
	  $title = $aTitle[0]
	  $flag = $aFlag[0]
	  $timeout = 0
	  $win = @GUI_WinHandle
;~    Case 
;~ 	  $msg = ""
;~ 	  $title = $aTitle[]
;~ 	  $flag = $aFlag[]
;~ 	  $timeout = 0
;~ 	  $win = @GUI_WinHandle
   EndSwitch
   
   MsgBox($flag,$title,$msg,$timeout,$win)
EndFunc
