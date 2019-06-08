#include-once
#include <Array.au3>

#cs defs to add to au3.api

_GuiGetBoxBool($ID) Reads Checkbox if $GUI_CHECKED Return 1 else Returns 0 (Requires: #include <_AdvGui.au3>)
_GuiGetListChar($ID,$n=1) Returns $n Chars of Control (Requires: #include <_AdvGui.au3>)
_GuiListView_SortHeader() Sorts the Header as requested directly from the Listview. Works only with GuiCtrlSetOnEvent. (Requires: #include <_AdvGui.au3>)
_GUICtrlListView_CreateArray($hListView, $sDelimeter = '|') Creates a 2-dimensional array from a listview. (Requires: #include <_AdvGui.au3>)

#ce
;===============================================================================
;Global variables

;===============================================================================

;UDF functions

Func _GuiGetBoxBool($ID)
	Local $i = GUICtrlRead($ID)
	If $i = $GUI_CHECKED Then Return 1
	Return 0
EndFunc   ;==>_GetBox


Func _GuiGetListChar($ID,$n=1)
	Local $s = StringLeft(GUICtrlRead($ID), $n)
	Return $s
EndFunc   ;==>_GetList



Func _GuiListView_SortHeader()
	_GUICtrlListView_SortItems(@GUI_CtrlId,GUICtrlGetState(@GUI_CtrlId))
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlListView_CreateArray
; Description ...: Creates a 2-dimensional array from a listview.
; Syntax ........: _GUICtrlListView_CreateArray($hListView[, $sDelimeter = '|'])
; Parameters ....: $hListView           - Control ID/Handle to the control
;                  $sDelimeter          - [optional] One or more characters to use as delimiters (case sensitive). Default is '|'.
; Return values .: Success - The array returned is two-dimensional and is made up of the following:
;                                $aArray[0][0] = Number of rows
;                                $aArray[0][1] = Number of columns
;                                $aArray[0][2] = Delimited string of the column name(s) e.g. Column 1|Column 2|Column 3|Column nth

;                                $aArray[1][0] = 1st row, 1st column
;                                $aArray[1][1] = 1st row, 2nd column
;                                $aArray[1][2] = 1st row, 3rd column
;                                $aArray[n][0] = nth row, 1st column
;                                $aArray[n][1] = nth row, 2nd column
;                                $aArray[n][2] = nth row, 3rd column
; Author ........: guinness
; Remarks .......: GUICtrlListView.au3 should be included.
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_CreateArray($hListView, $sDelimeter = '|')
    Local $iColumnCount = _GUICtrlListView_GetColumnCount($hListView), $iDim = 0, $iItemCount = _GUICtrlListView_GetItemCount($hListView)
    If $iColumnCount < 3 Then
        $iDim = 3 - $iColumnCount
    EndIf
    If $sDelimeter = Default Then
        $sDelimeter = '|'
    EndIf

    Local $aColumns = 0, $aReturn[$iItemCount + 1][$iColumnCount + $iDim] = [[$iItemCount, $iColumnCount, '']]
    For $i = 0 To $iColumnCount - 1
        $aColumns = _GUICtrlListView_GetColumn($hListView, $i)
        $aReturn[0][2] &= $aColumns[5] & $sDelimeter
    Next
    $aReturn[0][2] = StringTrimRight($aReturn[0][2], StringLen($sDelimeter))

    For $i = 0 To $iItemCount - 1
        For $j = 0 To $iColumnCount - 1
            $aReturn[$i + 1][$j] = _GUICtrlListView_GetItemText($hListView, $i, $j)
        Next
    Next
    Return SetError(Number($aReturn[0][0] = 0), 0, $aReturn)
EndFunc   ;==>_GUICtrlListView_CreateArray