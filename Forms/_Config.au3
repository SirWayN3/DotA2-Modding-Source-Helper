;_Config.au3

;~ Global Const $sPathConfig =  @ScriptDir & "\Config.ini"
Global Const $sPathConfig =  @ScriptDir & "\Config\Config.ini"

Global $sLaunchCommand = ""
Global $sStartDotA2Path = ""
Global $sStartDotA2Params = ""


Func _Ini_ReadAll($param = "")
	
	_Ini_Zip_ReadAll($sPathConfig, $param)
	_Ini_Compile_Source_ReadAll($sPathConfig, $param)
	_Ini_Compile_Lang_ReadAll($sPathConfig, $param)
	_Ini_Extract_Lang_ReadAll($sPathConfig, $param)
	
	$sLaunchCommand = IniRead($sPathConfig, "launch_command", "command", "")
	$sStartDotA2Path = IniRead($sPathConfig, "launch_command", "start", "")
	$sStartDotA2Params =  IniRead($sPathConfig, "launch_command", "params", "")

EndFunc 



Func _Ini_Zip_ReadAll($s, $param = "")
	Global $sZipTargetFolder = _PathFull(IniRead($s, "Zip", "targetfolder" & $param, "")) &  "\"
	
	Global $sZipSourceGame = _PathFull(IniRead($s, "Zip", "source_game" & $param, "")) &  "\"
	
	Global $sZipSourceContent = _PathFull(IniRead($s, "Zip", "source_content" & $param, "")) &  "\"
EndFunc


Func _Ini_Compile_Source_ReadAll($s, $param = "")
	Global $sCompileSourceFolderSource =  _PathFull(IniRead($s, "Compile_Source", "Folder_Source" & $param, "")) &  "\"
	Global $sCompileSourceFolderTarget =  _PathFull(IniRead($s, "Compile_Source", "Folder_Target" & $param, "")) &  "\"
	
;~ 	ConsoleWrite($sCompileSourceFolderSource & @LF & $sCompileSourceFolderTarget & @LF)
EndFunc

Func _Ini_Compile_Lang_ReadAll($s, $param = "")
	Global $sCompileLangFolderSource = _PathFull(IniRead($s, "Compile_Language", "Folder_Source" & $param, "")) & "\"
	Global $sCompileLangFolderTarget = _PathFull(IniRead($s, "Compile_Language", "Folder_Target" & $param, "")) & "\"
EndFunc 
	
Func _Ini_Extract_Lang_ReadAll($s, $param = "")
	Global $sExtractSourceFolderTarget =  _PathFull(IniRead($s, "Extract_Language", "Folder_Target" & $param, "")) & "\"
	
	DirCreate($sExtractSourceFolderTarget)
EndFunc 