;_CompileLang.au3

Func _Compile_Lang_Init()
	
	Global $asCompileLangFiles[1] = ["addon_english.txt"]
	Global Const $asFileHeader[UBound($asCompileLangFiles)] = ['"addon"' ]
	
	For $i =  0 TO UBOund($asCompileLangFiles) -1 Step 1
		$asCompileLangFiles[$i] = $sCompileLangFolderTarget & $asCompileLangFiles[$i]
	Next 
	
	Global $aCompileLangSettings[1][2]

	$aCompileLangSettings[0][0] = "addon_english\"
	$aCompileLangSettings[0][1] = $asCompileLangFiles[0]

EndFunc 

Func _Compile_Lang()
	#Region Init Files
		Local $file
		For $i = 0 TO UBound($asCompileLangFiles) -1 Step 1
;~ 			$file = @ScriptDir &  "\" &  $asFiles[$i]
			$file = $asCompileLangFiles[$i]
			FileDelete($file)
			FileWrite($file, $asFileHeader[$i]  &  @LF & "{" &  @LF & @LF )
		Next
	#EndRegion
	
	#Region Merge Files
		Local $s, $a, $h
		For $i = 0 TO UBound($aCompileLangSettings) -1 Step 1
;~ 			$aFileList = _FileListToArrayRec(@ScriptDir & "\" & $aSettings[$i][0], "*.cpp", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH )
			$aFileList = _FileListToArrayRec($sCompileLangFolderSource & "\" & $aCompileLangSettings[$i][0], "*.cpp", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH )
			If Not IsArray($aFileList) Then ContinueLoop
	;~ 		_ArrayDisplay($aFileList)
			$h =  FileOpen($aCompileLangSettings[$i][1], $FO_APPEND )
			; Completely read File to VAR, then add leading @TAB to each line. 
			For $j = 1 TO $aFileList[0] Step 1
	;~ 			$s =  FileRead($aFileList[$j]) ; Get File Text
	;~ 			FileWrite($h, $s); Append File
				
				_FileReadToArray($aFileList[$j], $a, $FRTA_NOCOUNT )
				For $k = 0 TO UBound($a) -1 Step 1
					$a[$k] =  @TAB & $a[$k]
					FileWrite($h, $a[$k] &  @LF)
				Next
			Next
			FileWrite($h, @LF)
			FileClose( $h )
		Next 
	#EndRegion
	
	#Region Finish Files
		Local $file
		For $i = 0 TO UBound($asCompileLangFiles) -1 Step 1
			$file = $asCompileLangFiles[$i]
			
			FileWrite($file, @LF & "}" &  @LF & @LF )
		Next
	#EndRegion
EndFunc 