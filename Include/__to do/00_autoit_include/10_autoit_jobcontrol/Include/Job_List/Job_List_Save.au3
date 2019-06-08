




Func _Job_List_Save_Button_Single(); Launched by GuiEvent
   If $iJobListCount = 0 Then; es sind keine Jobs zum speichern vorhanden
	  _ShowBox(1)
	  Return
   EndIf
   
   Local $index = _GUICtrlListView_GetSelectionMark($c1List1); selektierter Job
   
   If $index = -1 Then; es ist kein job selektiert
	  _ShowBox(2)
	  Return
   EndIf
   
   Local $path = FileSaveDialog("Speichere Jobliste....","","Job List (*.job)",2+16,"Job " & ($index+1) & ".job",@GUI_WinHandle)
   If @error Then Return
   _Job_List_Save($index,$path)
   If @error Then Return _ShowBox(3)
   _ShowBox(4)
EndFunc


Func _Job_List_Save_Button_All(); Launched by GuiEvent
   If $iJobListCount = 0 Then; es sind keine Jobs zum speichern vorhanden
	  _ShowBox(1)
	  Return
   EndIf
   
   Local $path = FileSaveDialog("Speichere Jobliste....","","Job List (*.job)",2+16,"Job Liste Komplett.job",@GUI_WinHandle)
   If @error Then Return
   _Job_List_Save_All($path)
   If @error Then Return _ShowBox(3)
   _ShowBox(5)
EndFunc




Func _Job_List_Save($index,$path)
   Local $str = _GUICtrlListView_GetItemTextString($c1List1,$index)
   $a = StringSplit($str,"|",2)
   
   If FileExists($path) = 0 Then FileClose(FileOpen($path,1+8))
   Local $i
   For $i=0 To 1000 Step 1
	  IniReadSection($path,"Job" & $i)
	  If @error Then ExitLoop
   Next
   
   For $i2=1 To UBound($aJobListInf)-1 Step 1
	  IniWrite($path,"Job" & $i,$aJobListInf[$i2][0],$a[$i2])
	  If @error Then Return SetError(1,0,0)
   Next
EndFunc



Func _Job_List_Save_All($path)
   ; $iJobListCount für Anzahl verwenden
   
   Local $count = _GUICtrlListView_GetItemCount($c1List1)
   ConsoleWrite($count & @CRLF)
   
   For $i=0 To $count-1 Step 1
	  _Job_List_Save($i,$path)
	  If @error Then Return SetError(1,0,0)
   Next
EndFunc

