;_Extract_Lang.au3

Global $aFileHandlesExtract[2]
Global $sFileHandlePreFix = "FileHandle_"

Func _Extract_Lang_From_Struct()
	_DbgW()
	_DbgW("Extract from Struct to Lang File")
	Local $target, $ID
	DirRemove($sExtractSourceFolderTarget, $DIR_REMOVE )
	DirCreate($sExtractSourceFolderTarget)
	FileWrite($sExtractSourceFolderTarget & "00_ReadMe.txt", "Automatically Created Files. Any Changes will be overwritten!")
	
	$aFileHandlesExtract[1] = FileOpen($sExtractSourceFolderTarget & "NO_TARGET_APPLIED.txt", $FO_CREATEPATH + $FO_APPEND )
	$aFileHandlesExtract[0] = 1
	
	For $i = 1 To $aStructCollection[0] -1 Step 1
		$ID = $aStructCollection[$i]
		
		_DbgW(@TAB & $ID)
		$target = _StrGet($sStructLangPrefix & "target", Eval($ID), true)
;~ 		MsgBox(0, IsInt($target), $target)
		if $target = "" Then
			$target = $aFileHandlesExtract[1]
		Else
			
			If IsDeclared($sFileHandlePreFix & $target) Then
				$target = Eval($sFileHandlePreFix & $target)
			Else
				$aFileHandlesExtract[0] += 1
				If UBound($aFileHandlesExtract) <= $aFileHandlesExtract[0] Then 
					ReDim $aFileHandlesExtract[$aFileHandlesExtract[0] + 10]
				EndIf
				Assign($sFileHandlePreFix & $target, FileOpen($sExtractSourceFolderTarget & $target & ".cpp", $FO_CREATEPATH + $FO_APPEND ), $ASSIGN_FORCEGLOBAL)
				$aFileHandlesExtract[$aFileHandlesExtract[0]] = Eval($sFileHandlePreFix & $target)
				$target = $aFileHandlesExtract[$aFileHandlesExtract[0]]
			EndIf
		EndIf
		

		$ID = $ID
		
		
		Switch StringLower(_Extract_GetType($ID))
			Case "ability", "item"
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID, _Extract_GetName($ID))
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID & "_Description", _Extract_GetDescr($ID))
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID & "_Lore", _Extract_GetLore($ID))
				
			Case "hero", "unit", "building"
				_Extract_WriteLine($target, $ID, _Extract_GetName($ID))
				
			Case "modifier"
				_Extract_WriteLine($target, "DOTA_Tooltip_" & $ID, _Extract_GetName($ID))
				_Extract_WriteLine($target, "DOTA_Tooltip_" & $ID & "_Description", _Extract_GetDescr($ID))
				
			
			Case Else 
				
;~ 				_Extract_WriteLine($target, $id, name)
;~ 				_Extract_WriteLine($target, $id, descr)
		EndSwitch 
		FileWriteLine($target, "")
		FileWriteLine($target, "")
		_DbgW()
	Next 
	
	For $i = 1 To $aFileHandlesExtract[0] Step 1
		_DbgW("Closing File Handles... " & $aFileHandlesExtract[$i])
		FileClose($aFileHandlesExtract[$i])
	Next 
	_DbgW("LanguageFromFile Extract Done.")
EndFunc

Func _Extract_GetName($struct)
	Return _Extract_GetFromStruct($struct, $sStructLangPrefix & "name")
EndFunc 
Func _Extract_GetType($struct)
	Return _Extract_GetFromStruct($struct, $sStructLangPrefix & "type")
EndFunc
Func _Extract_GetDescr($struct)
	Return _Extract_GetFromStruct($struct, $sStructLangPrefix & "descr")
EndFunc
Func _Extract_GetLore($struct)
	Return _Extract_GetFromStruct($struct, $sStructLangPrefix & "lore")
EndFunc
Func _Extract_GetFromStruct($struct, $ID)
	Local $s, $a, $b, $text, $ret, $target
	$s = _StrGet($ID, Eval($struct), true)
	$a = StringSplit($s, "$")
	$target = $struct
	If $a[0] > 1 Then
;~ 		_ArrayDisplay($a)
		For $i = 1 To $a[0] Step 1
			If Mod($i, 2) = 0 Then
				_DbgW("Extract_GetFromStruct: "& $i)
				$b = StringSplit($a[$i], ".")
				For $j = 1 To $b[0] Step 1
					_DbgW(@TAB & "Extract_GetFromStruct: " & $b[$j])
					Switch $b[$j]
						Case "self"
							$target = $struct
						Case "this"
							$text = _StrGet($sStructLangPrefix & "name", Eval($target))
						Case Else
							$text = _StrGet($b[$j], Eval($target))
							$target = $text
					EndSwitch
					_DbgW(@TAB & @TAB& "Target Struct for next: " & $target)
				Next
				$ret &= $text
			Else
				$ret &= $a[$i]
			EndIf
		Next
		_DbgW(@TAB & @TAB & "Resulting Text:" & $ret)
;~ 		MsgBox(0, 0, $ret)
		$s = $ret
	EndIf 
	Return $s
EndFunc 
Func _Extract_GetID($s)
	Local $h =  FileOpen($s)
	local $t =  ""
;~ 	_DbgW($s)
	For $i = 1 To 10 Step 1
		$t = FileReadLine($h, $i)
		$t = StringStripWS($t,  $STR_STRIPALL )
		If StringLeft($t, 1) = '"' And StringRight($t, 1) = '"' Then
			$t = StringTrimLeft(StringTrimRight($t, 1), 1)
			ExitLoop
		EndIf 
;~ 		If FileReadLine($s, $i)
	Next 
	FileClose($h)
	return $t
EndFunc


Func _Extract_WriteLine($h, $text1, $text2)
	local $t = @TAB & '"' & $text1 & '"' & @TAB & @TAB & @TAB & '"' & $text2 & '"'
	
	FileWriteLine($h, $t)
EndFunc 