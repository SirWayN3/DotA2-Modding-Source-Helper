#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#Include "GUIConstants.au3"
#include <EditConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayIconHide",1)

Global $i1 = 1
Global $i2 = 35
Global $i3 = 100
GUICreate("test",500,400)
Global $cEdit1 = GUICtrlCreateEdit($i1,40,50,-1,20,$ES_READONLY)
Global $cEdit2 = GUICtrlCreateEdit($i2,40,80,-1,-1,$ES_READONLY)
Global $cEdit3 = GUICtrlCreateEdit($i3,40,120,-1,-1,$ES_READONLY)
Global $cLabel1 = GUICtrlCreateLabel("Test Label To Read",15,15)
Global $t = TimerInit()
GUISetState()

Do
   $msg = GUIGetMsg()
   If (TimerDiff($t) / 500) >= $i1 Then
	  GuiCtrlSetData($cEdit1,$i1)
	  GuiCtrlSetData($cEdit2,$i2)
	  GuiCtrlSetData($cEdit3,$i3)
	  $i1 += 1
	  $i2 += 1
	  $i3 += 1
	  If $i1 = 1001 Then $i1 = 1
	  If $i2 = 1001 Then $i2 = 1
	  If $i3 = 1001 Then $i3 = 1
   EndIf
Until $msg = $GUI_EVENT_CLOSE