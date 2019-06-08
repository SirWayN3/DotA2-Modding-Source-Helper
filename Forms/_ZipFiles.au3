;_ZipFiles.au3

Func _cf_ZipFiles()
	local $hZip, $filename
	DirCreate($sZipTargetFolder)
	#Region Content Data
		$hZip = _Zip_Create($sZipTargetFolder & StringReplace(_NowCalcDate(), "/", "_") & ".CastleFightReforged.Content.zip", 1)
		if @error then
			ConsoleWrite(@error &  @LF)
			
		EndIf
		_Zip_AddItem($hZip, $sZipSourceContent)
		if @error then
			ConsoleWrite("AddItems Error: " &  @error &  @LF)
		EndIf
	#EndRegion

	#Region Game Data
		$hZip = _Zip_Create($sZipTargetFolder & StringReplace(_NowCalcDate(), "/", "_") & ".CastleFightReforged.Game.zip", 1)

		if @error then
			ConsoleWrite(@error &  @LF)
;~ 			exit
		EndIf
		
		_Zip_AddItem($hZip, $sZipSourceGame)
		if @error then
			ConsoleWrite("AddItems Error: " &  @error &  @LF)
		EndIf
	#EndRegion
	
;~ 	exit
EndFunc