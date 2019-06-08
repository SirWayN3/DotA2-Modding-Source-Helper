



Func _Job_List_Add()
   _Gui_Create_JobList_AddJob()
   _Gui_SetOnEvent_JobList_AddJob()
   GuiSetState(@SW_SHOW,$hGui2)
   GUISetState(@SW_DISABLE,$hGui1)
EndFunc


Func _Job_List_Add_Button_Cancel(); Fenster wird geschlossen
   ; Einstellungen brauchen nicht zurück gesetzt werden, da Fenster gelöscht wird.
   GUISetState(@SW_ENABLE,$hGui1)
   GUIDelete($hGui2)
EndFunc


Func _Job_List_Add_Button_Save(); Paramter sind gesetzt
   ; Parameter überprüfen
   ; dann speichern des Jobs einleiten
   _Job_List_Check()
   _Job_List_Add_Save()
   _Job_List_Add_Button_Cancel()
EndFunc


Func _Job_List_Add_Save(); Parameter sind i.O.
   ; Job Speichern
   $iJobListCount += 1
   
   $aJobListInf[0][1] = GuiCtrlRead($c2Edit1)
   $aJobListInf[1][1] = GuiCtrlRead($c2Edit2)
   $aJobListInf[2][1] = GuiCtrlRead($c2Edit3)
   $aJobListInf[3][1] = GuiCtrlRead($c2Date1)
   $aJobListInf[5][1] = _GuiGetBox($c2Box1)
   $aJobListInf[6][1] = _GuiGetBox($c2Box2)
   
   Local $str = $iJobListCount & "|"
   For $i=0 To UBound($aJobListInf)-1 Step 1
	  $str &= $aJobListInf[$i][1] & "|"
   Next
   _GuiSetBox(GUICtrlCreateListViewItem($str,$c1List1),1)
EndFunc






