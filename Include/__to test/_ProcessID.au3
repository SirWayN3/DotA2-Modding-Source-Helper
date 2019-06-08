;ProcessID.au3
#cs defs to add to au3.api

_PrcCheck($s = $prcFile) Check if Process File is present and Running. Requires: #include <_Process.au3>)
_PrcSave($s = $prcFile) Save Process File. Requires: #include <_Process.au3>)
_PrcDel($s = $prcFile) Delete Process File. Requires: #include <_Process.au3>)
_PrcSetFile($s = "") Set intern Variable $prcFile. Requires: #include <_Process.au3>)

#ce

Global $prcFile = ""

Func _PrcSetFile($s = "")
	$prcFile = $s
EndFunc
Func _PrcCheck($s = $prcFile)
	If FileExists($s) = 1 Then
		Local $s = FileReadLine($s,1)
		Select
			Case $s = @AutoItPID; nicht möglich
				Return SetError(2,0,0)
			Case $s <> @AutoItPID
				If ProcessExists($s) = 1 Then Return 0; everythign is OK
				Return SetError(3,0,0)
		EndSelect
	Else
		Return SetError(1,0,0)
	EndIf
	Return 1
EndFunc
Func _PrcSave($s = $prcFile)
	If _PrcCheck() = 1 Then
		FileDelete($s); In case File Exists
		Local $ID = @AutoItPID
		FileWriteLine($s,$ID)
	EndIf
EndFunc
Func _PrcDel($s = $prcFile)
	FileDelete($s)
EndFunc

#cs Old Functions
Func _Process_CheckID()
	If FileExists($sScriptProcessFilePath) = 1 Then
		Local $h = FileOpen($sScriptProcessFilePath)
		Local $ID = FileReadLine($h, 1)
		FileClose($h)
		
		Select
			Case $ID = @AutoItPID; nicht möglich
				Return 1
			Case $ID <> @AutoItPID; ID ist nicht die gleiche
				If ProcessExists($ID) = 1 Then Return 0; überprüfe ob es bereits läuft
				Return 1
		EndSelect
	Else
		Return 1
	EndIf
EndFunc   ;==>_Process_CheckID

Func _Process_SaveID()
	FileDelete($sScriptProcessFilePath); In case File Exists
	Local $ID = @AutoItPID
	Local $h = FileOpen($sScriptProcessFilePath, 1)
	FileWrite($h, $ID)
	FileClose($h)
	_LogAdd(_LanguageGet(1262) & $ID)
EndFunc   ;==>_Process_SaveID

Func _Process_DeleteID()
	FileDelete($sScriptProcessFilePath)
EndFunc   ;==>_Process_DeleteID
#ce


