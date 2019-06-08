#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#cs To Do Liste
   Setze Namen in die JobFiles damit erkannt wird, wann eine .job Datei zu dem Programm gehört.
   Checksum?
   
#ce
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <ListviewConstants.au3>
#include <GuiListView.au3>

#include <Include/Gui_Create.au3>
#include <Include/Job_List.au3>
#include <Include/ShowBox.au3>



Opt("GUIOnEventMode",1)


_Gui_Create_JobList_Main()
_Gui_SetOnEvent_JobList_Main()


GuiSetState(@SW_SHOW,$hGui1)


While 1
   Sleep(1000)
WEnd





Func _Main_Exit()
   Exit
EndFunc



Func _GuiGetBox($h)
   Local $i = GuiCtrlRead($h)
   If $i = 1 Then Return 1; Box is checked
   If $i = 4 Then Return 0; Box is not checked
EndFunc


Func _GuiSetBox($h,$v)
   If $v = 1 Then GuiCtrlSetState($h,$GUI_CHECKED)
   If $v = 0 Then GuiCtrlSetState($h,$GUI_UNCHECKED)
  EndFunc





Func _Gui_Close(); Launched by GuiEvent
   Switch @GUI_CtrlId
   Case $GUI_EVENT_CLOSE; Fenster wurde über rotes Kreuz geschlossen
	  Switch @GUI_WinHandle
	  Case $hGui1
		 _Main_Exit()
	  Case $hGui2
		 _Job_List_Add_Button_Cancel()
	  EndSwitch
   Case $cMenu1Sub4
	  _Main_Exit()
   EndSwitch
EndFunc

