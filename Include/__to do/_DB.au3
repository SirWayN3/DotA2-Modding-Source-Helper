;_DB.au3

#include <SQLite.au3>
#cs INFO
	Allgemeine Funktionen zu einer Datenbank
	_DB_Dll_StartUp		-> Setup Dll
	_DB_Close			-> Datenbank schließen (Handle)
	_DB_Open			-> Datenbank öffnen (Handle)
	
#ce

Func _DB_Dll_Startup($path)
	_SQLite_Startup($path, False, 1)
	If @error Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_DB_Dll_Startup

Func _DB_Dll_Close()
	_SQLite_Shutdown()
EndFunc   ;==>_DB_Dll_Close

Func _DB_Close($handle = -1)
	_SQLite_Close($handle)
EndFunc   ;==>_DB_Close

Func _DB_Open($path, ByRef $handle, $mode = 1)
	#cs verschiedene Varianten des öffnens
		_SQLite_Open($sScriptSQLiteDBPath); siehe $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE
		_SQLite_Open($sScriptSQLiteDBPath,$SQLITE_OPEN_READONLY)
		_SQLite_Open($sScriptSQLiteDBPath,$SQLITE_OPEN_READWRITE)
		_SQLite_Open($sScriptSQLiteDBPath,$SQLITE_OPEN_CREATE)
		_SQLite_Open($sScriptSQLiteDBPath,$SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE)
	#ce
	Switch $mode
		Case 1
			$handle = _SQLite_Open($path, $SQLITE_OPEN_READONLY)
		Case 2
			$handle = _SQLite_Open($path, $SQLITE_OPEN_READWRITE)
		Case 3
			$handle = _SQLite_Open($path, $SQLITE_OPEN_CREATE)
		Case 4
			$handle = _SQLite_Open($path, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE)
		Case Else
			MsgBox(48, "Error - DB_OPEN", "mode does not match the Setting. Allowed: 1-4, mode: " & $mode)
			Return 0
	EndSwitch
	Return 1
EndFunc   ;==>_DB_Open

Func _DB_Read_ByIDRange(Const $handle, Const $table, $startID, $endID)
	Local $amount = 0, $query, $result
	_SQLite_Query($handle, "SELECT * FROM " & $table & " WHERE rowid BETWEEN " & $startID & " AND " & $endID & ";", $query)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
		$amount += 1
		GUICtrlCreateListViewItem($amount & "|" & _ArrayToString($result), $cList1)
	WEnd
	_SQLite_QueryFinalize($query)
EndFunc   ;==>_DB_Read_ByID

Func _DB_Read_ToString_ByID(Const $handle, Const $table, Const $ID)
	Local $amount = 0, $query, $result, $array[2]
	_SQLite_Query($handle, "SELECT * FROM " & $table & " WHERE rowid=" & $ID & ";", $query)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
		If UBound($array)-1 < $amount Then ReDim $array[UBound($array)+100]
;~ 		_ArrayDisplay($result,"_DB_Read_ByID")
		$array[$amount] = _ArrayToString($result)
		$amount += 1
	WEnd
;~ 		_ArrayDisplay($array,"_DB_Read_ByID")
	_SQLite_QueryFinalize($query)
	Return $array[0]
EndFunc   ;==>_DB_Read_ByID

Func _DB_read_ToString_ByIDSingle(Const $handle, Const $table, Const $ID, Const $column)
	Local $amount = 0, $query,$result,$array
	_SQLite_Query($handle, "SELECT " & $column & " FROM " & $table & " WHERE rowid=" & $ID & ";", $query)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
;~ 		If UBound($array)-1 < $amount Then ReDim $array[UBound($array)+100]
;~ 		_ArrayDisplay($result,"_DB_Read_ByID")
		$array = $result
		$amount += 1
	WEnd
	_SQLite_QueryFinalize($query)
	_ArrayDisplay($array,"_DB_READ_TOSTRING_BYSINGLEID")
	Return $result
EndFunc

Func _DB_Read_ByContentHeader(Const $handle, Const $table, $header, $content)
	Local $amount = 0, $query, $result
	_SQLite_Query($handle, "SELECT * FROM " & $table & " WHERE " & $header & " MATCH '" & $content & "';", $query)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
		$amount += 1
		GUICtrlCreateListViewItem($amount & "|" & _ArrayToString($result), $cList1)
	WEnd
	_SQLite_QueryFinalize($query)
EndFunc   ;==>_DB_Read_ByContentHeader

Func _DB_Read_ToArray_ByHeader(Const $handle, Const $table, Const $header, ByRef $array)
	Local $amount = 0, $query, $result
;~ 	_SQLite_Query($handle, "SELECT * FROM " & $table & " WHERE " & $header & ";", $query)
	_SQLite_Query($handle, "SELECT " & $header & " FROM " & $table & ";", $query)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
		If UBound($array)-1 < $amount Then ReDim $array[UBound($array)+100]
		$array[$amount] = $result[0]
		$amount += 1
	WEnd
	_SQLite_QueryFinalize($query)
EndFunc

Func _DB_Read_ToArray_ByTextLike(Const $handle, Const $table, Const $header, Const $text, ByRef $array)
	Local $amount = 0, $query, $result
;~ 	Local $i = _SQLite_Query($handle, "SELECT " & $header & " FROM " & $table & " WHERE " & $header & " LIKE '" & $text & "';", $query)
;~ 	Local $i = _SQLite_Query($handle, "SELECT rowid FROM " & $table & " WHERE " & $header & " LIKE '" & $text & "';", $query)
	Local $i = _SQLite_Query($handle, "SELECT DISTINCT rowid FROM " & $table & " WHERE " & $header & " LIKE '" & $text & "';", $query)
;~ 	ConsoleWrite("Error DB_MAIN: " & @error & @LF)
;~ 	ConsoleWrite("Error DB_MAIN; Return: " & $i & @LF)
	While _SQLite_FetchData($query, $result) = $SQLITE_OK
		If UBound($array)-1 < $amount Then ReDim $array[UBound($array)+100]
		$array[$amount] = $result[0]
		$amount += 1
	WEnd
	_SQLite_QueryFinalize($query)
EndFunc

Func _DB_Table_Create(Const $handle, $table, $columndefault)
;~ 	If _DB_Table_CheckExists($handle, $table) = 1 Then Return SetError(1, 0, 0)
	_SQLite_Exec($handle, "CREATE VIRTUAL TABLE IF NOT EXISTS " & $table & " USING fts3 (" & $columndefault & ");")
	Return 1
EndFunc   ;==>_DB_Table_Create

Func _DB_Write_ByEntry(Const $handle, ByRef Const $table, ByRef Const $entry)
	
EndFunc   ;==>_DB_Write_ByEntry

Func _DB_Write_ByArray(Const $handle, ByRef Const $table, ByRef Const $a)
	Local $array = _DB_Replace_ByArray($a)
	Local $s = "INSERT INTO " & $table & " VALUES ("
	For $i = 0 To UBound($array) - 1 Step 1
		$s &= "'" & $array[$i] & "',"
	Next
	$s = StringTrimRight($s, 1); Komma entfernen
	$s &= ");"
	If _SQLite_Exec($handle, $s) <> $SQLITE_OK Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_DB_Write_ByArray


Func _DB_Replace_ByArray(ByRef Const $array)
	Local $a[UBound($array)]
	Switch UBound($array,0)
	Case 2
		For $i = 0 To UBound($array) -1 Step 1
				$a[$i] = StringReplace($array[$i][1], "'", "''")
		Next
		Return $a
	Case 1
		For $i = 0 To UBound($array) -1 Step 1
				$a[$i] = StringReplace($array[$i], "'", "''")
		Next
		Return $a
	EndSwitch
EndFunc   ;==>_DB_Check_ByArray

