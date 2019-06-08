;_CompileSource.au3

;~ Path will be set with @ScriptDir and trailing \
;~ [x][0] : Folder, [x][1] : Target File

	Global $asCompileSourceFiles[4] = ["npc_abilities_custom.txt", "npc_heroes_custom.txt", "npc_items_custom.txt", "npc_units_custom.txt"]
	Global Const $asCompileSourceFileHeader[UBound($asCompileSourceFiles)] = ['"DOTAAbilities"', '"DOTAHeroes"', '"DOTAAbilities"', '"DOTAUnits"' ]
	Global Const $sStructDelim =  "§"
	Global Const $sStructLangPrefix = "Lang_"

Func _Compile_Source_Init()
	
	For $i =  0 TO UBOund($asCompileSourceFiles) -1 Step 1
		$asCompileSourceFiles[$i] = $sCompileSourceFolderTarget & $asCompileSourceFiles[$i]
	Next 
	Global $aCompileSourceSettings[5][2]
;~ 	_ArrayDisplay($asCompileSourceFiles)
	Global $aStructCollection[2] = [0]
	$aCompileSourceSettings[0][0] = "builders\"
	$aCompileSourceSettings[0][1] = $asCompileSourceFiles[1]

	$aCompileSourceSettings[1][0] = "buildings\"
	$aCompileSourceSettings[1][1] = $asCompileSourceFiles[3]

	$aCompileSourceSettings[2][0] = "creeps\"
	$aCompileSourceSettings[2][1] = $asCompileSourceFiles[3]

	$aCompileSourceSettings[3][0] = "abilities\"
	$aCompileSourceSettings[3][1] = $asCompileSourceFiles[0]

	$aCompileSourceSettings[4][0] = "items\"
	$aCompileSourceSettings[4][1] = $asCompileSourceFiles[2]
EndFunc

Func _Compile_Source()
	_DbgW("Compile Source.")
	#Region Init Vars
		For $i = 1 To UBound($aStructCollection) -1 Step 1
			Assign($aStructCollection[$i], "", $ASSIGN_FORCEGLOBAL )
			$aStructCollection[$i] = ""
		Next
		$aStructCollection[0] = 0
		local $file, $ini_sections, $ini_values, $id, $path, $key,  $a, $b, $text, $path
		Local $s, $a, $target, $ID, $str, $struct, $b, $c, $length, $t, $val, $m, $start, $s2, $index
	#EndRegion

	#Region Init Files
		For $i = 0 TO UBound($asCompileSourceFiles) -1 Step 1
	;~ 		$file = @ScriptDir &  "\" &  $asCompileSourceFiles[$i]
			$file = $asCompileSourceFiles[$i]
			FileDelete($file)
			FileWrite($file, $asCompileSourceFileHeader[$i]  &  @LF & "{" &  @LF & @LF )
		Next
	#EndRegion
	
	#Region Merge Files
		
		For $i = 0 TO UBound($aCompileSourceSettings) -1 Step 1
			$path = $sCompileSourceFolderSource & $aCompileSourceSettings[$i][0]
			_DbgW(@TAB & "Search Folder:" & $path & @LF)
			$aFileList = _FileListToArrayRec($path, "*.cpp", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH )
			If Not IsArray($aFileList) Then ContinueLoop
	;~ 		_ArrayDisplay($aFileList)
			$target =  FileOpen($aCompileSourceSettings[$i][1], $FO_APPEND )
			_DbgW("Target File: " & $aCompileSourceSettings[$i][1])
			; Completely read File to VAR, then add leading @TAB to each line. 
			For $j = 1 To $aFileList[0] Step 1
;~ 				_DbgW($aFileList[$j] & @TAB & _Extract_GetID($aFileList[0]))
;~ 				_DbgW($ID)
				$struct = ""
				_DbgW("Read File: "& $aFIleList[$j])
				_Compile_Source__ReadKeyValues($aFileList[$j], $target, $struct)
				
				_Compile_Source__ReadIni($aFileList[$j], $struct)
				
				_Compile_Source__CreateStruct($struct)
				
				; Read Next File
			Next
			FileWrite($target, @LF)
			FileClose( $target )
		Next 
	#EndRegion
	
	
	#Region FinishFiles
		Local $file
		For $i = 0 TO UBound($asCompileSourceFiles) -1 Step 1
			$file = $asCompileSourceFiles[$i]
			
			FileWrite($file, @LF & "}" &  @LF & @LF )
		Next
	#EndRegion
;~ 	_ArrayDisplay($aStructCollection)
	_DbgW("Finished Writing to Files.")
EndFunc 
	
	
Func _Compile_Source__ReadKeyValues($file, $target, ByRef $struct)
	_DbgW("Read KeyValues")
	Local $a, $ID, $s2, $bCommentBlock, $iKeyValuesEnd, $bCommentBlock = false, $iKeyValuesEnd = 0
	
	$ID = _Extract_GetID($file)
	_FileReadToArray($file, $a, $FRTA_NOCOUNT )
	For $k = 0 TO UBound($a) -1 Step 1
		$s2 =  StringStripWS($a[$k], $STR_STRIPALL)
		; Remove Comment Blocks due to Failure with Ini Phrases in there. Engine cant handle this.
		If StringLeft($s2, 2) =  "/*" Then
			$bCommentBlock = TRUE
			ContinueLoop
		EndIf 
		If StringLeft($s2, 2) =  "*/" Then
			$bCommentBlock = FALSE
			ContinueLoop
		EndIf 
		IF StringLeft($s2, 2) = "//" Then
			ContinueLoop
		EndIf 
		If $bCommentBlock then ContinueLoop 
		
		If StringLen($s2) = 0 then ContinueLoop
		
		; Save for Struct
		; Check for Entries in Struct
		If StringLeft($s2, 1) = "{" Then
			$iKeyValuesEnd += 1
;~ 						_DbgW($iKeyValuesEnd &  @LF)
		EndIf 
		If StringLeft($s2, 1) = "}" Then
			$iKeyValuesEnd -= 1
		EndIf
		
		If $iKeyValuesEnd < 2 Then
;~ 						_DbgW(@TAB & @TAB & $s2)
			$str = $s2
			$str = StringStripWS($str, $STR_STRIPALL)
			$struct = $struct & $sStructDelim & $str
		EndIf
		
		; Write to File
		$a[$k] =  @TAB & $a[$k]
		FileWrite($target, $a[$k] &  @LF)
	Next
	_DbgW()
EndFunc

Func _Compile_Source__ReadIni($file, ByRef $struct)
	_DbgW("ReadIni...")
	local $ini_sections, $ID, $targetname, $path, $ini_values, $default = "01_NO_TARGET_APPLIED", $s, $str
	; Read Ini for More Data for Struct
	$ini_sections = IniReadSectionNames($file)
;~ 	_ArrayDisplay($ini_sections, "Ini_Sections")
	If @error = 0 Then
;~ 		_DbgW($file)
;~ 		Entry has been Found
;~ 		_ArrayDisplay($ini_sections)
		$ID = _Extract_GetID($file)
;~ 			_DbgW($id &  @LF)
		For $j = 1 To $ini_sections[0] Step 1
			
			_DbgW(@TAB& "Path: " & $path)
			_DbgW(@TAB&  "Create Struct Data for: " & $ini_sections[$j])
			
			$str = ""
			$ini_values = IniReadSection( $file, $ini_sections[$j])
			If @error = 0 Then
;~ 					_DbgW(_ArrayToString($ini_values, "|", Default, Default, @LF &  @TAB) &  @LF)
;~ 				_ArrayDisplay($ini_values)
				For $k = 1 To $ini_values[0][0] Step 1
					; If Entries to check for Struct Vars are Found they will be replaced.
					
					_DbgW(@TAB & @TAB & "Ini Values: " & $ini_values[$k][0] & @TAB & $ini_values[$k][1])
;~ 					$struct = $struct & $sStructDelim & $key 
					$s = '"' & $sStructLangPrefix & $ini_values[$k][0] & '""' & $ini_values[$k][1] & '"'
					_DbgW(@TAB & @TAB & @TAB & "String to save to Struct: " & $s)
					$str = $str & $sStructDelim & $s
				Next
;~ 				MsgBox(0, 0, $ini_sections[$j])
				If $ini_sections[$j] = "self" Then
					$struct =  $struct & $str
				Else ; Key is not self, so use an own struct for the data
					; Leading Entry for ID is missing in Struct. First Part has to be ID; else pass ID as optional Param
					_Compile_Source__CreateStruct($str, $ini_sections[$j] )
;~ 					MsgBox(0, 0, 0)
				EndIf 
			EndIf
		Next 
	EndIf
	
	_DbgW()
EndFunc

Func _Compile_Source__CreateStruct($struct, $ID = "")
	Local $b, $start, $index, $c, $length, $val, $t
	_DbgW("Create Struct...")
	; Create Struct, Merge Data
	_DbgW(@TAB & $struct)
	$b = StringSplit($struct, $sStructDelim)
;~ 	_ArrayDisplay($b, "Struct")
	If $ID = "" Then $ID = StringReplace($b[2], '"', "")

	; Create Struct
	$struct = ""
	$start = 3
	Dim $val[$b[0]]
	
	$index = 0
	
	For $n = $start To $b[0] Step 1
		$c = StringSplit($b[$n], '"')
		
		; Use Index 2 Key & 4 Value
;~ 					_DbgW(@TAB & _ArrayToString($c))
		If UBound($c) < 5 Then 
;~ 						If UBound($c) > 2 Then _ArrayDisplay($c)
			ContinueLoop
		EndIf
		$index += 1
		$length = StringLen($c[4])
		If $length = 0 Then $length = 1
		$struct &= "char " & $c[2] & "[" & $length & "]"
		$struct &=  ";"
		$val[$index] = $c[4]
;~ 					_DbgW(@TAB & @TAB & @TAB & "ID=" & $index & @TAB & "L=" & $length & @TAB & $c[2])
	Next
	$val[0] = $index
	; Read ini Data from File into Struct
	
	
	; Struct Finished Reading
	$struct = StringTrimRight($struct, 1)
	
	_DbgW(@TAB & "Created Struct for: " & $ID & @LF & @TAB & @TAB & $struct)
	$t = Assign($ID, _StrCreate($struct), $ASSIGN_FORCEGLOBAL)
	_DbgW(@TAB & @TAB & "Return Value from Create Struct: " & $t)
	$aStructCollection[0] += 1
	If UBound($aStructCollection) -1 = $aStructCollection[0] Then 
		ReDim $aStructCollection[UBound($aStructCollection) + 10]
		
	EndIf
	$aStructCollection[ $aStructCollection[0] ] =  $ID
	
	; Assign Values to Struct
;~ 	_ArrayDisplay($val)
	For $m = 1 To $val[0] Step 1
;~ 		_DbgW(@TAB & "ID=" & $m & @TAB & $val[$m])
		_StrSet($m , $val[$m], Eval($ID) )
	Next 
	_DbgW()
EndFunc