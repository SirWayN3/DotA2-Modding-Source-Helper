
#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.8.1
	Author:         myName
	
	Script Function:
	Template AutoIt script.
	
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin

#include <_Zip.au3>
#include <File.au3>

Global $bZipDone = 0
Global $sPath = ""
Global $sZipPath = ""

OnAutoItExitRegister("_ExitScript")

If UBound($CmdLine) <> 3 Then Exit -1

If StringLeft($CmdLine[1], 1) = "\" Then
	$sPath = _PathFull(StringTrimLeft($CmdLine[1], 1), @WorkingDir)
Else
	
	$sPath = _PathFull($CmdLine[1], @WorkingDir)
EndIf

If StringLeft($CmdLine[2], 1) = "\" Then
	$sZipPath = _PathFull(StringTrimLeft($CmdLine[2], 1), @WorkingDir)
Else
	$sZipPath = _PathFull($CmdLine[2], @WorkingDir)
EndIf


_Zip_Create($sZipPath, 1)
If @error Then Exit -4


_Zip_AddItem($sZipPath, $sPath)
If @error Then Exit -5

$bZipDone = 1
Exit

Func _ExitScript()
	If $bZipDone = 0 Then
		MsgBox(64, "Proper Usage", "Use .exe with Parameters:" & @LF & _
				"First Parameter: Full Path or relative (same directory as exe) to create Zip File." & _
				@LF & "Second Parameter: Full Path to Zip File")
	EndIf
EndFunc   ;==>_ExitScript








