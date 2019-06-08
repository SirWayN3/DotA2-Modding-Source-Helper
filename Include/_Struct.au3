#include-once
;===============================================================================
; Help Functions for Struct
;
;===============================================================================
#cs defs to add to au3.api

_StrGet($ID,$Struct = $strStruct_Target) Get Data out of Struct(Requires: (Requires: #include <_Help_Struct.au3>)
_StrSet($ID, $Val, $Struct = $strStruct_Target) Set Data to Struct. (Requires: #include <_Help_Struct.au3>)
_StrSetDebug($debug_flag = True) Set Debug Mode on. Debug will be written to Console (Requires: #include <_Help_Struct.au3>)
_StrSetStruct($Struct) Set $strStruct_Target to use Functions more easily. (Requires: #include <_Help_Struct.au3>)
_StrSetStructValFromArraySearch(ByRef Const $Array,$ArraySearch,$StructID, $ArrayDimSearch,$ArrayDimValue,$Struct = $strStruct_Target) Set Value for $StructID from Array with ArraySearchString. Pass the right Dimensions to Search for String and take Value. (Requires: #include <_Help_Struct.au3>)
_StrCreate($String) Create Struct by using the String supported. (Requires: #include <_Help_Struct.au3>)
#ce
;===============================================================================
Global $strStruct_Target
Global $sStr_error;Error message variable for str errors
Global $strdebugging;flag for debug messages


Func _StrCreate(Const $s)
	Local $str = DllStructCreate($s)
	If @error Then
		MsgBox(16,"Error _StrCreate", "Error with Creating Structure. Check DllStructCreate for Information." & @LF & "Error: " & @error)
		Return SetError(1,0,_StrDebugWrite("Internal Error, creating Struct didnt work!" & @LF))
	EndIf
	Return $str
EndFunc


Func _StrSetStruct(ByRef Const $Struct)
	If IsDllStruct($Struct) = 0 Then Return SetError(1,0,_StrDebugWrite("Internal Error, passed Struct isnt a Struct!" & @LF))
	$strStruct_Target = $Struct
EndFunc


Func _StrGet($ID,$Struct = $strStruct_Target, $silent = false)
	If IsDllStruct($Struct) = 0 Then
		If Not $silent Then MsgBox(16, "Error", "Passed Structure is not a Struct! " & @TAB & $Struct & @LF &  "Value " & $ID & " cant be retrieved." & @TAB & "Error: " & @error)
		Return SetError(1,_StrDebugWrite("Internal Error, passed 2nd Param is not a Structure!" & @LF & $ID), "")
	EndIf
	Local $i = DllStructGetData($Struct, $ID)
	Local $err = @error
	If $err Then
		If Not $silent Then MsgBox(16, "Error", "Value " & $ID & " cant be retrieved." & @TAB & "Error: " & $err & @LF & "Struct Name:" & $Struct)
		Return SetError(1, _StrDebugWrite("Internal Error, cant get Data of Struct! Error Number: " & $err & @TAB & $ID), "")
	EndIf
;~ 	_StrDebugWrite("_StrGet: ID: " & $ID & " Return Val: " & $i)
	Return $i
EndFunc   ;==>_Data_Get


Func _StrSet($ID, $Val, $Struct = $strStruct_Target)
	Local $i = DllStructSetData($Struct, $ID, $Val)
;~ 	If @error Then MsgBox(64, "Error....", "Internal Error, cant set Data to Struct! Error Number: " & @error & @LF & $ID)
	local $err =  @error
	Switch $err
		Case 0;
			;
		Case 1; Scruct is not valid
			MsgBox(16, "Error", "Passed Struct is not a Struct." & @LF & @LF & $Struct)
			Return 0
		
		Case Else
			MsgBox(16, "Error", "Value " & $Val & " cant be set. ID: " & $ID & @LF & "Error: " & $err)
			Return SetError(1,0,_StrDebugWrite("Internal Error, cant set Data to Struct! Error Number: " & $err & @TAB & $ID))
	
	EndSwitch
	_StrDebugWrite("_StrSet: ID: " & $ID & " Return Val: " & $i)
	Return $i
EndFunc   ;==>_Data_Set

;===============================================================================
; Function Name:	- 	_strSetDebug($flag =False)
; Description:		-  Writes a message to console with a crlf on the end
; Parameters:		- $message   the message to display
; Syntax:			- _strDebugWrite($message)
; Author(s):		-
; Returns:			-
;===============================================================================
Func _StrSetDebug($debug_flag = True)
	Switch $debug_flag
		Case 0
			$debug_flag = False
		Case 1
			$debug_flag = True
	EndSwitch
	$strdebugging = $debug_flag
EndFunc   ;==>_strSetDebug
;===============================================================================
; Function Name:	- 	_strDebugWrite($message)
; Description:		-  Writes a message to console with a crlf on the end
; Parameters:		- $message   the message to display
; Syntax:			- _strDebugWrite($message)
; Author(s):		-
; Returns:			-
;===============================================================================
Func _StrDebugWrite($message, $flag =@LF)
    If $strdebugging Then
        If $flag <> "" Then
            ConsoleWrite($message & $flag )
        Else
            ConsoleWrite($message)
        EndIf
    EndIf
EndFunc   ;==>_strDebugWrite


Func _StrSetStructValFromArraySearch(ByRef Const $Array,$value,$StructID, $ArrayDimSearch,$ArrayDimTarget,$Struct = $strStruct_Target)
	Local $i,$s
	If IsArray($Array) = 0 Then Return SetError(1,0,_StrDebugWrite("_StrSetStructValFromArraySearch: Passed Array is not an Array"))
	If UBound($Array,0) < $ArrayDimSearch Then Return SetError(2,0,_StrDebugWrite("_StrSetStructValFromArraySearch: Passed Dimension for ArrayDimSearch is greater then DIM."))
	If UBound($Array,0) < $ArrayDimTarget Then Return SetError(3,0,_StrDebugWrite("_StrSetStructValFromArraySearch: Passed Dimension for ArrayDimTarget is greater then DIM."))
	
	$i = _ArraySearch($Array,$value,0,0,0,0,1,$ArrayDimSearch)
	If @error Then Return SetError(4,0,_strDebugWrite("_StrSetStructValFromArraySearch: Value not Found in Array" & @TAB & $value))
;~ 	_StrDebugWrite("_StrSetStructValFromArraySearch: Return Array Row: " & $i)
	$s = $Array[$i][$ArrayDimTarget]
	_StrSet($StructID,$s,$Struct)
EndFunc






