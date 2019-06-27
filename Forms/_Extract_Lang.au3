;_Extract_Lang.au3

Global $aFileHandlesExtract[2]
	$aFileHandlesExtract[0] = 1
Global $sFileHandlePreFix = "FileHandle_"

Func _Extract_Lang_From_Struct()
	_DbgW()
	_DbgW("Extract from Struct to Lang File")
	#Region Init Vars
	
		Local $target, $ID, $snippet_name, $struct
	#EndRegion
	DirRemove($sExtractSourceFolderTarget, $DIR_REMOVE )
	DirCreate($sExtractSourceFolderTarget)
	FileWrite($sExtractSourceFolderTarget & "00_ReadMe.txt", "Automatically Created Files. Any Changes will be overwritten!")
;~ 	$aFileHandlesExtract[1] = FileOpen($sExtractSourceFolderTarget & "NO_TARGET_APPLIED.txt", $FO_CREATEPATH + $FO_APPEND )
	
;~ 	_ArrayDisplay($aStructCollection)
	For $i = 1 To $aStructCollection[0] Step 1
		$ID = $aStructCollection[$i]
		$struct = $ID
;~ 		MsgBox(0, 0, $ID)
		_DbgW("Extract from ID: " & $ID)
		$target = _StrGet($sStructLangPrefix & "target", Eval($ID), true)
;~ 		MsgBox(0, IsInt($target), $target)
		If $target = "" Then
			$target = "NO_TARGET_APPLIED.cpp"
		EndIf
		$target = $sExtractSourceFolderTarget & $target & ".cpp"
		#cs
		if $target = "" Then
			$target = $aFileHandlesExtract[1]
		Else
			If IsDeclared($sFileHandlePreFix & $target) Then
				
				$target = Eval($sFileHandlePreFix & $target)
				
				_DbgW(@TAB& @TAB& "Target File: "& $target)
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
		#ce
		$snippet_name =  _Extract_GetSnippet($ID)
		_DbgW(@TAB& "Snippet Name: " & $snippet_name)
		If StringLen($snippet_name) <= 1 Then
			; No Snippet has been found
		Else
			; Snippet has been found
;~ 			$ID = $snippet_name
			$struct = $snippet_name
			_Dbgw("IsDllStruct:" & IsDllStruct(Eval("Critical_Strike"))) ; -> TRUE
			_DbgW(_StrGet($sStructLangPrefix & "type", Eval("Critical_Strike"))) ; -> TRUE
			MsgBox(0, "TEST", _Extract_GetType($struct) &  @LF & $struct)
		EndIf
		; Get Data and Write
		Switch StringLower(_Extract_GetType($struct))
			Case "ability", "item"
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID, _Extract_GetName($struct))
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID & "_Description", _Extract_GetDescr($struct))
				_Extract_WriteLine($target, "DOTA_Tooltip_Ability_" & $ID & "_Lore", _Extract_GetLore($struct))
				
			Case "hero", "unit", "building"
				_Extract_WriteLine($target, $ID, _Extract_GetName($struct))
				
			Case "modifier"
				_Extract_WriteLine($target, "DOTA_Tooltip_" & $ID, _Extract_GetName($struct))
				_Extract_WriteLine($target, "DOTA_Tooltip_" & $ID & "_Description", _Extract_GetDescr($struct))
				
			Case Else 
				
		EndSwitch 
		_DbgW(@TAB & "Target File: " & $target & @TAB & $aFileHandlesExtract[0])
		
		FileWriteLine($target, "")
;~ 		FileWriteLine($target, "")
		_DbgW()
	Next 
;~ 	MsgBox(0, 0, 0)
	#cs
	For $i = 1 To $aFileHandlesExtract[0] Step 1
		_DbgW("Closing File Handles... " & $aFileHandlesExtract[$i])
		FileClose($aFileHandlesExtract[$i])
;~ 		$aFileHandlesExtract[$i] = ""
	Next 
	#ce
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
Func _Extract_GetSnippet($struct)
	Return _Extract_GetFromStruct($struct, $sStructLangPrefix &  "snippet")
EndFunc
Func _Extract_GetFromStruct($struct, $ID)
	Local $s, $a, $b, $text, $ret, $target
	If IsDllStruct(Eval($struct)) = 0 Then
		MsgBox(64, "Error", "_Extract_GetFromStruct: Passed $struct is not a struct." & @LF & $struct)
		Return
	EndIf
	$s = _StrGet($ID, Eval($struct), true)
	_Dbgw(@TAB& @TAB& "Struct passed Name: " & $struct &  @TAB & "IsStruct:" &  IsDllStruct($struct))
	$a = StringSplit($s, "$")
	$target = $struct
	If $a[0] > 1 Then
;~ 		_ArrayDisplay($a)
		For $i = 1 To $a[0] Step 1
			If Mod($i, 2) = 0 Then
				$b = StringSplit($a[$i], ".")
				For $j = 1 To $b[0] Step 1
					_DbgW(@TAB & "StructName: " & $target & @TAB & @TAB & "ID: " & $b[$j])
					Switch $b[$j]
						Case "self"
							$target = $struct
						Case "this"
							$text = _StrGet($sStructLangPrefix & "name", Eval($target))
						Case Else
							If $j = 1 Then
								$text = $b[$j]
							else
								_DbgW(@TAB & @TAB & "IsStruct: " & IsDllStruct(Eval($target)))
								If IsDllStruct(Eval($target)) Then 
									$text = _StrGet($b[$j], Eval($target))
								Else
									$text = _StrGet($b[$j], $target)
								EndIf
							EndIf
							$target = $text
					EndSwitch
					_DbgW(@TAB & @TAB& "Target Struct for next: " & $target)
				Next
				$ret &= $text
				_DbgW()
			Else
				$ret &= $a[$i]
			EndIf
		Next
		_DbgW(@TAB & @TAB & @TAB & "Resulting Text: " & $ret)
;~ 		MsgBox(0, 0, $ret)
		$s = $ret
	EndIf 
	_DbgW()
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