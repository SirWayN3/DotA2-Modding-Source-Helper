;*****************************************
;CastleFight_Compile_Backup.au3 by Hammig
;Erstellt mit ISN AutoIt Studio v. 1.08
;*****************************************
#include <Date.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Inet.au3>
#include <Misc.au3>

#include "Include\_Debug.au3"
#include "Include\_Struct.au3"
#include "Include\_Zip.au3"

If _Singleton(@ScriptName, 1) = 0 Then 
	MsgBox($MB_SYSTEMMODAL, "Fehler...", "Das Programm wurde bereits gestartet.")
	Exit
EndIf
#cs To Do List
	_COmpileSource:
		Muss zukünftig auch das einlesen der INI's enthalten.
		-> INI Format neu aufbauen
			-> neuer Eintrag: TYPE [ability;modifier;unit;building;hero;builder]
		-> Andere Daten einkürzen (name_ab -> name etc.)
	_ExtractLang anpassen, dass dort nur noch die Daten aus dem Struct abgefragt werden.
#ce

_DbgSetOption(not @compiled, 0,  @compiled)
_DbgCreateWin()
_StrSetDebug(true)
if @compiled then _DbgWinShow()

#include "Forms\_Variables.au3"
#include "Forms\_Config.au3"
#include "Forms\_ZipFiles.au3"


#include "Forms\_MainGui.isf"
#include "Forms\_CompileSource.au3"
#include "Forms\_CompileLang.au3"
#include "Forms\_Extract_Lang.au3"


_Ini_ReadAll()


_Compile_Source_Init()
_Compile_Lang_Init()
GUISetState(@SW_SHOW)


While true
	Switch GuiGetMsg()
		Case $GUI_EVENT_CLOSE;
			Exit
		Case $cButtonZipFiles
			ProgressOn("", "Working...",Default,Default,Default,$DLG_MOVEABLE )
			_cf_ZipFiles()
			ProgressOff()
			
		Case $cButtonCompileSource
			$iRunCount += 1
			ProgressOn("", "Working...",Default,Default,Default,$DLG_MOVEABLE )
			_Compile_Source()
			ProgressSet(33)
;~ 			MsgBox(0, 0, _StrGet("Lang_name", Eval("cf_01_ab_human_cr06_01")))
;~ 			MsgBox(0, 0, _StrGet("Lang_type", Eval("cf_01_ab_human_cr06_01")))

			_Extract_Lang_From_Struct()
			ProgressSet(66)
			
			
			_Compile_Lang()
			
			ProgressOff()
		Case $cButtonCompileLang
			ProgressOn("", "Working...",Default,Default,Default,$DLG_MOVEABLE )
			_Compile_Lang()
			ProgressOff()
			
		Case $cButtonStartCommand
			ClipPut($sLaunchCommand)
;~ 			MsgBox(0, "Hint", "Text has been copied to Clipboard." & @LF & @LF & $sLaunchCommand, 0, $hGuiMain)
		Case $cButtonTargetFolder_Extract
			ShellExecute($sExtractSourceFolderTarget)
			
		Case $cButtonTargetFolder_CompileSource
			ShellExecute($sCompileSourceFolderTarget)
			
		Case $cButtonTargetFolder_CompileLang
			ShellExecute($sCompileLangFolderTarget)
			
		Case $cButtonTargetFolder_CompileZip
			ShellExecute($sZipTargetFolder)
			
		Case $cButtonStartDotA2
			ShellExecute($sStartDotA2Path, $sStartDotA2Params)
		Case $cBoxIniModeTesting
			If GuiCtrlRead($cBoxIniModeTesting) = $GUI_CHECKED Then
				_Ini_ReadAll("_Testing")
			Else 
				_Ini_ReadAll()
			EndIf
			_Compile_Source_Init()
		Case Else 
			;
	EndSwitch
WEnd