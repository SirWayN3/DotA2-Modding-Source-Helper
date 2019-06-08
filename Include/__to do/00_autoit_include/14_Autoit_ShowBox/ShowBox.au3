#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
Opt("GuiOnEventMode",1)

Global Const $aShowBox_Flag[5] = [ _
				  32, _ ; Hinweiﬂ
				  64, _ ; Hilfe
				  16, _ ; Fehler
				  48 _ ; Warnung
				  ]
Global Const $aShowBox_Title[5] = [ _
				  "Hinweiﬂ", _ 
				  "Hilfe", _ 
				  "Fehler", _
				  "Warnung" _
				  ]
   


_ShowBox(1)
_ShowBox(2,1)
_ShowBox(3,0,10)


Func _ShowBox($ID,$ext=0,$timeout=0)
   Local $flag,$title,$handle
   Local $i=-1;
   #cs $i
	  0=Hinweiﬂ
	  1=Hilfe
	  2=Fehler
	  3=Warnung
   #ce
   If IsDeclared("@Gui_Winhandle") Then $handle = @GUI_WinHandle
   Switch $ID
   Case 3; timeout
	  $i = 0
	  $text = "Timeout 10 Secs"
   Case 2; ext
	  $flag = 2
	  $title = "titel"
	  $text = "irgendein text"
	  Switch $ext
	  Case 1
		 $text &= " Zusatz1"
	  Case 2
		 $text &= " Zusatz2"
	  EndSwitch
   Case 1; Standard
	  $i=0
	  $text = "irgendwas"
   Case Else
	  Return SetError(1,0,0)
   EndSwitch
   
   If $i <> -1 Then 
	  $flag = $aShowBox_Flag[$i]
	  $title = $aShowBox_Title[$i]
   EndIf
   $i = MsgBox($flag,$title,$text,$timeout,$handle)
   Return $i
EndFunc
