

Func _Gui_Create_JobList_Main()
   
   Opt("GUICoordMode",0)
   Global Const $hGui1 = GuiCreate("Job Control",500,400)
;~    Global Const $c1Button1 = GUICtrlCreateButton("Exit",340,330,120,40)

   ; Menu Items
   Global Const $cMenu1 = GUICtrlCreateMenu("Datei")
   Global Const $cMenu1Sub1 = GUICtrlCreateMenuItem("Speichere Jobliste....",$cMenu1)
   Global Const $cMenu1Sub2 = GUICtrlCreateMenuItem("Entferne Jobliste....",$cMenu1)
   Global Const $cMenu1Sub3 = GUICtrlCreateMenuItem("Lade Jobliste....",$cMenu1)
   GUICtrlCreateMenuItem("",$cMenu1)
   Global Const $cMenu1Sub4 = GUICtrlCreateMenuItem("Beenden....",$cMenu1)
   Global Const $cMenu2 = GUICtrlCreateMenu("Job")
   Global Const $cMenu2Sub1 = GUICtrlCreateMenuItem("Füge Job Hinzu....",$cMenu2)
   Global Const $cMenu2Sub2 = GUICtrlCreateMenuItem("Entferne Job....",$cMenu2)
   GUICtrlCreateMenuItem("",$cMenu2)
   Global Const $cMenu2Sub3 = GUICtrlCreateMenuItem("Lade Job....",$cMenu2)
   Global Const $cMenu2Sub4 = GUICtrlCreateMenuItem("Speichere Job....",$cMenu2)
   
   
   ; Job List Items
   
   GUISetCoord(15,15)
   Global $c1List1 = GUICtrlCreateListView("Job #|Ersteller|Titel|Beschreibung|Datum|Est.Time|Data1|Data2",0,0,450,200,BitOR($LVS_NOSORTHEADER,$LVS_SINGLESEL),BitOR($LVS_EX_CHECKBOXES,$LVS_EX_FULLROWSELECT))
   
EndFunc


Func _Gui_SetOnEvent_JobList_Main()
   GUISwitch($hGui1)
   GUISetOnEvent($GUI_EVENT_CLOSE,"_Gui_Close")
   
   GUICtrlSetOnEvent($cMenu1Sub1,"_Job_List_Save_Button_All")
   GUICtrlSetOnEvent($cMenu1Sub2,"_Job_List_Delete_Button_All")
   GUICtrlSetOnEvent($cMenu1Sub3,"_Job_List_Load_Button_All")
   GUICtrlSetOnEvent($cMenu1Sub4,"_Gui_Close")
   
   GUICtrlSetOnEvent($cMenu2Sub1,"_Job_List_Add")
   GUICtrlSetOnEvent($cMenu2Sub2,"_Job_List_Delete_Button_Single")
   GUICtrlSetOnEvent($cMenu2Sub3,"_Job_List_Load_Button_Single")
   GUICtrlSetOnEvent($cMenu2Sub4,"_Job_List_Save_Button_Single")
   
   
EndFunc


Func _Gui_Create_JobList_AddJob()
   Opt("GUICoordMode",0)
   Global $hGui2 = GuiCreate("Job Parameter",500,400,Default,Default,BitOR($WS_POPUPWINDOW,$WS_CAPTION),-1,$hGui1)
   
   GUISetCoord(15,20)
   Global $c2Edit1 = GUICtrlCreateEdit("Ersteller....",0,0,120,40,$ES_AUTOHSCROLL)
   Global $c2Edit2 = GUICtrlCreateEdit("Titel....",140,0,0,0,$ES_AUTOHSCROLL)
   Global $c2Edit3 = GUICtrlCreateEdit("Beschreibung....",140,0,0,0,$ES_AUTOHSCROLL)
   GUISetCoord(15,60)
   Global $c2Date1 = GUICtrlCreateDate("",0,0,200,40)
   
   GUISetCoord(15,110)
   Global $c2Box1 = GUICtrlCreateCheckbox("Add Parameter 1",0,0,350,40)
   Global $c2Box2 = GUICtrlCreateCheckbox("Add Parameter 2",0,50,0,00)
   
   GUISetCoord(15,340)
   Global $c2Button1 = GUICtrlCreateButton("Setze Job",0,0,120,40)
   Global $c2Button2 = GUICtrlCreateButton("Abbrechen",160,0,0,00)
   
   
EndFunc


Func _Gui_SetOnEvent_JobList_AddJob()
   GUISwitch($hGui2)
   GUISetOnEvent($GUI_EVENT_CLOSE,"_Gui_Close")
   
   GUICtrlSetOnEvent($c2Button1,"_Job_List_Add_Button_Save")
   GUICtrlSetOnEvent($c2Button2,"_Job_List_Add_Button_Cancel")
EndFunc








