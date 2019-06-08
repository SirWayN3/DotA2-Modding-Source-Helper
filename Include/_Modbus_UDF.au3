#include-Once
; #INDEX# =======================================================================================================================
; Title .........: libmodbus
; AutoIt Version : 3.2.10++
; Language ......: English/German
; Description ...: Functions for Handling the http://libmodbus.org/ dll
;					the "_nativ" Funktions Handels the ModbusTCP ONLY VIA AutoIT !!  -> you need no modbus.dll for those Funktions
; Author(s) .....: vivus ( Marc Neininger ), funkey,
;					The libmodbus documentation was written by Stéphane Raimbault <stephane.raimbault@gmail.com>
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;>"_native" ( dll not needed )
;_native_ModbusTCP_ReadImputRegister($mainsocket,  $iStart, $iNum, $sType)
;_native_ModbusTCP_ReadCoils($mainsocket, $iStartAddress, $iNumOfCoils)
;_native_ModbusTCP_WriteCoils($mainsocket, $Port_adress , $Hi_Lo)
;_native_ModbusTCP_WriteSingleRegister($mainsocket, $iStartAddress, $iNumOfCoils)

;----------------------------------------------------
;>"_Madbus" ( libmodbus.dll from libmodbus.org needed )
;_Modbus_SetDllPath($sFullPath)
;_Modbus_DllOpen()
;_Modbus_New_TCP($sIP, $iPort = 502)
;_Modbus_Connect($tModbus)
;_Modbus_Close($tModbus)
;_Modbus_Free($tModbus)
;_Modbus_StrError($iError)
;_Modbus_Read_Registers($tModbus, $iAddr, $iNum)
;_Modbus_Read_Input_Registers($tModbus, $iAddr, $iNum)
;_Modbus_Read_Input_Bits($tModbus, $iAddr, $iNum = 1)
;_Modbus_Read_Bits($tModbus, $iAddr, $iNum = 1 ) ( offiziell Read Coil )
;_Modbus_Write_Bit($tModbus, $iAddr, $status )
;_Modbus_Write_Register($tModbus, $iAddr, $Value)
;_Modbus_Set_Debug($tModbus, $boolean)
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;>"_native" ( dll not needed )
;__Convert_To_Binary($iNumber)
;__WinAPI_Int64ToDouble($iInt64)
;__ModbusTCP_Recv($mainsocket, $maxlen = 256, $flag = 0)
;__ModbusTCP_Send($mainsocket, $data)
;----------------------------------------------------
;
; ===============================================================================================================================
;===============================================================================
; Help Functions for Struct
;
;===============================================================================
#cs defs to add to au3.api

_Modbus_SetDllPath($sFullPath) Set Dll Path for internal Functions. Requires: #include <_Modbus_UDF.au3>)
_Modbus_DllOpen() Create Handle to the supported Dll. Required: _Modbus_SetDllPath. Requires: #include <_Modbus_UDF.au3>)
_Modbus_New_TCP($sIP, $iPort = 502) Create new TCP Socket. Requires: #include <_Modbus_UDF.au3>)
_Modbus_Connect($tModbus) Connect to Modbus Server. Requires: #include <_Modbus_UDF.au3>)
_Modbus_Close($tModbus) Close Connection to Modbus Server Requires: #include <_Modbus_UDF.au3>)
_Modbus_Free($tModbus) Free Resources for Modbus. Requires: #include <_Modbus_UDF.au3>)
_Modbus_StrError($iError) Get Error Codes out of libmodbus.dll Requires: #include <_Modbus_UDF.au3>)
_Modbus_Read_Registers($tModbus, $iAddr, $iNum) Read Multiple Registers. [Function: 0x03] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Read_Input_Registers($tModbus, $iAddr, $iNum) Read Multiple Input Registers. [Function: 0x04] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Read_Input_Bits($tModbus, $iAddr, $iNum = 1) Read Multiple Input Bits. [Function: 0x02] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Read_Bits($tModbus, $iAddr, $iNum = 1 ) Read Multiple Bits (offiziell Read Coil). [Function: 0x01] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Write_Bit($tModbus, $iAddr, $status ) Write Single Bit. [Function: 0x05] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Write_Register($tModbus, $iAddr, $Value) Write Single Register. [Function: 0x06] Requires: #include <_Modbus_UDF.au3>)
_Modbus_Set_Debug($tModbus, $boolean) Set Debug function. CAUTION: Causes multiple verbose Messages! Requires: #include <_Modbus_UDF.au3>)


#ce
;===============================================================================

#include <Array.au3>
#include <WinAPI.au3>

Const $_sUDFVersion = 'V1.0'
;Global $_mgdebug = False

;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;>"_nativ" ( dll not needed )
Global $_native_ModbusTCP_Debug_Send = 0 ; if = 1 you can see the modbus send-Protokoll on CMD-line ( only _native )
Global $_native_ModbusTCP_Debug_Recv = 0 ; if = 1 you can see the modbus recv-Protokoll on CMD-line ( only _native )
Global $__TID=0 	; ONLY INTERNAL USE !! contains the transmission ID of the last _native_Modbus CALL !!

; #Simple-Sample# for >"_nativ" ModbusTCP( dll not needed ) ========================================================================
#cs

Func _example_nativ()
	MsgBox(0, "_example_native()", "Example modbusTCP only via Autoit")
	TCPStartup()

	$_native_ModbusTCP_Debug_Send = 1
	$_native_ModbusTCP_Debug_Recv = 1

	Global $iSock = TCPConnect("172.18.65.159", 502)

	If $iSock = -1 Then
		ConsoleWrite("Fehler Verbindungsaufbau" & @LF)
		Exit
	EndIf


	$repeat = 5

	While $repeat >= 1

		ConsoleWrite("write" & @CRLF)
		$retval = _native_ModbusTCP_WriteCoils($iSock, 1, 1) ;
		ConsoleWrite("$retval =" & $retval & @CRLF)

		Sleep(100)
		ConsoleWrite("clear" & @CRLF)
		$retval = _native_ModbusTCP_WriteCoils($iSock, 1, 0)
		ConsoleWrite("$retval =" & $retval & @CRLF)

		; oder
		$retval = _native_ModbusTCP_WriteSingleRegister($iSock, 0, 0)
		ConsoleWrite("$retval =" & $retval & @CRLF)


		$aTest = _native_ModbusTCP_ReadImputRegister($iSock, 0, 4, "float") ;Functioncode 4, Register 1, Länge 4 Resiter lesen, als float zurückgeben
		ConsoleWrite("float = " & $aTest[0] & @CRLF)
		$aTest = _native_ModbusTCP_ReadImputRegister($iSock, 0, 1, "word") ;Functioncode 4, Register 1, Länge 4 Resiter lesen, als float zurückgeben
		ConsoleWrite("word = " & $aTest[0] & @CRLF)
		_ArrayDisplay($aTest)

		Global $iRet = _native_ModbusTCP_ReadCoils($iSock, 0, 8);16)
		ConsoleWrite("Bits = " & $iRet & @CRLF)


		$repeat = $repeat - 1

	WEnd

	TCPCloseSocket($iSock)
	TCPShutdown()

EndFunc   ;==>_example_nativ
#ce
; ===============================================================================================================================

Func _native_ModbusTCP_ReadImputRegister($mainsocket, $iStart, $iNum, $sType)

    $__TID += 1

    Local $iBytesToSend = 6
	Local $FC = "04"

    __ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & Hex($FC, 2) & Hex($iStart, 4) & Hex($iNum, 4))
    If @error Then Return SetError(1, 0, 0)

    Local $sRecv

    Do
        $sRecv = __ModbusTCP_Recv($mainsocket, 512)

	Until @error Or $sRecv <> ""
    If @error Then Return SetError(2, 0, 0)

    If Int(String(BinaryMid($sRecv, 1, 2))) <> $__TID Then Return SetError(3, 0, 0)

	;ConsoleWrite("$sRecv"&$sRecv&@CRLF)

    Local $iSize = 4 ; default

    Switch $sType
        Case "word"
            $iSize = 2
        Case "float"
            $iSize = 4
        Case "double"
            $iSize = 8
    EndSwitch

    Local $aRet[$iNum / ($iSize / 2)], $iTemp

    For $i = 0 To UBound($aRet) - 1
        $iTemp = BinaryMid($sRecv, 10 + $i * $iSize, $iSize)
        Switch $sType
            Case "word"
                $aRet[$i] = Int(String($iTemp))
            Case "float"
                $aRet[$i] = _WinAPI_IntToFloat(Int(String($iTemp)))
            Case "double"
                $aRet[$i] = __WinAPI_Int64ToDouble(Int(String($iTemp)))
        EndSwitch
    Next
    Return $aRet
EndFunc   ;==>_ModbusTCP_ReadValues


Func _native_ModbusTCP_ReadCoils($mainsocket, $iStartAddress, $iNumOfCoils)

    $__TID += 1

    Local $iBytesToSend = 6, $iFunctionCode = "02"

    If $iNumOfCoils < 1 Then Return SetError(1, 0, 0)

    __ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & $iFunctionCode & Hex($iStartAddress, 4) & Hex($iNumOfCoils, 4))
    If @error Then Return SetError(2, 0, 0)

    Local $sRecv

    Do
        $sRecv = __ModbusTCP_Recv($mainsocket, 512)
    Until @error Or $sRecv <> ""
    If @error Then Return SetError(3, 0, 0)

    If Int(String(BinaryMid($sRecv, 1, 2))) <> $__TID Then Return SetError(4, 0, 0)

    Local $iAnzahlBytes = Int(String(BinaryMid($sRecv, 9, 1)))

    ;ConsoleWrite("Anzahl der erhaltenen Daten: " & $iAnzahlBytes & " Byte(s), max " & $iAnzahlBytes * 8 & " Bits." & @CRLF)

    Return __Convert_To_Binary(Int(String(BinaryMid($sRecv, 10, $iAnzahlBytes))))
EndFunc   ;==>_ModbusTCP_ReadCoils

;--------------------------------------------------------------------------------------------------------------------------------------------------------------

Func _native_ModbusTCP_WriteCoils($mainsocket, $Port_adress , $Hi_Lo)

    $__TID += 1

    Local $iBytesToSend = 6, $iFunctionCode = "05"

	If $Port_adress < 1 Then Return SetError(1, 0, 0)

	If $Hi_Lo = 1 then
		 __ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & $iFunctionCode & Hex($Port_adress-1, 4) & "FF00"); 65280 = FF00

	ElseIf $Hi_Lo = 0 then
		__ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & $iFunctionCode & Hex($Port_adress-1, 4) & "0000")

	Else
		;If $iNumOfCoils < 1 Then Return SetError(1, 0, 0)
		Return SetError(1, 0, 0)
		;_ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & $iFunctionCode & Hex($iStartAddress, 4) & Hex($iNumOfCoils, 4))

	EndIf
	If @error Then Return SetError(2, 0, 0)

    Local $sRecv

    Do
        $sRecv = __ModbusTCP_Recv($mainsocket, 512)
    Until @error Or $sRecv <> ""
    If @error Then Return SetError(3, 0, 0)

    If Int(String(BinaryMid($sRecv, 1, 2))) <> $__TID Then Return SetError(4, 0, 0)

    ;Local $iAnzahlBytes = Int(String(BinaryMid($sRecv, 9, 1)))

    ;ConsoleWrite("Anzahl der erhaltenen Daten: " & $iAnzahlBytes & " Byte(s), max " & $iAnzahlBytes * 8 & " Bits." & @CRLF)

    Return 1 ;_Convert_To_Binary(Int(String(BinaryMid($sRecv, 10, $iAnzahlBytes))))

EndFunc   ;==>_ModbusTCP_ReadCoils

;--------------------------------------------------------------------------------------------------------------------------------------------------

Func _native_ModbusTCP_WriteSingleRegister($mainsocket, $iStartAddress, $iNumOfCoils)

    $__TID += 1

    Local $iBytesToSend = 6, $iFunctionCode = "06"

    If $iNumOfCoils < 0 Then
		Return SetError(1, 0, 0)
	EndIf

    __ModbusTCP_Send($mainsocket, "0x" & Hex($__TID, 4) & "0000" & Hex($iBytesToSend, 4) & "01" & $iFunctionCode & Hex($iStartAddress, 4) & Hex($iNumOfCoils, 4))
    If @error Then Return SetError(2, 0, 0)

    Local $sRecv

    Do
        $sRecv = __ModbusTCP_Recv($mainsocket, 512)
    Until @error Or $sRecv <> ""
    If @error Then Return SetError(3, 0, 0)

    If Int(String(BinaryMid($sRecv, 1, 2))) <> $__TID Then Return SetError(4, 0, 0)

    ;Local $iAnzahlBytes = Int(String(BinaryMid($sRecv, 9, 1)))

    ;ConsoleWrite("Anzahl der erhaltenen Daten: " & $iAnzahlBytes & " Byte(s), max " & $iAnzahlBytes * 8 & " Bits." & @CRLF)

    Return 1;_Convert_To_Binary(Int(String(BinaryMid($sRecv, 10, $iAnzahlBytes))))
EndFunc   ;==>_ModbusTCP_ReadCoils

Func __ModbusTCP_Send($mainsocket, $data)
    If $_native_ModbusTCP_Debug_Send Then ConsoleWrite("_native_ModbusTCP_Send(" & $mainsocket & ", """ & $data & """)" & @CRLF)
    Local $Send = TCPSend($mainsocket, $data)
    Return SetError(@error, 0, $Send)
EndFunc   ;==>_ModbusTCP_Send

Func __ModbusTCP_Recv($mainsocket, $maxlen = 256, $flag = 0)
    Local $sRecv = TCPRecv($mainsocket, $maxlen, $flag)
    Local $error = @error
    If $sRecv <> "" And $_native_ModbusTCP_Debug_Recv Then ConsoleWrite("_native_ModbusTCP_Recv: " & $sRecv & @CRLF)
    Return SetError($error, 0, $sRecv)
EndFunc   ;==>_ModbusTCP_Recv

; #FUNCTION# ====================================================================================================================
; Name...........: __WinAPI_Int64ToDouble
; Description ...: Returns a 8 byte integer as a double value
; Syntax.........: __WinAPI_IntToFloat($iInt64)
; Parameters ....: $iInt64    - 8 byte Integer value (64 bit)
; Return values .: Success    - 8 byte integer value as a double
; Author ........: funkey
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __WinAPI_Int64ToDouble($iInt64)
    Local $__TIDnt64 = DllStructCreate("INT64")
    Local $tDouble = DllStructCreate("double", DllStructGetPtr($__TIDnt64))
    DllStructSetData($__TIDnt64, 1, $iInt64)
    Return DllStructGetData($tDouble, 1)
EndFunc   ;==>_WinAPI_Int64ToDouble

Func __Convert_To_Binary($iNumber)
    Local $sBinString = ""
    Do
        $sBinString = BitAND($iNumber, 1) & $sBinString
        $iNumber = BitShift($iNumber, 1)
    Until $iNumber <= 0
    If $iNumber < 0 Then SetError(1, 0, 0)
    Return $sBinString
EndFunc   ;==>_Convert_To_Binary

; END -> ;>"_nativ" ( dll not needed )

;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;###################################################################################################################################
;>"_Madbus" ( libmodbus.dll from libmodbus.org needed )

Global $hDLL_Modbus = 0
Global $__DLLNAME = 'libModbus.dll'

; #Simple-Sample# for libmodbus.dll ================================================================================================
#cs
Func _example_libDll()
	MsgBox(0, "_example_libDll()", "Example with the libmodbus.dll")

	_Modbus_DllOpen()

	Global $tModbus = _Modbus_New_TCP("172.18.65.159")
	If _Modbus_Connect($tModbus) = -1 Then
		ConsoleWrite("! Fehler: Es konnte keine Verbindung aufgebaut werden." & @CRLF)
		_Modbus_Free($tModbus)
		Exit
	EndIf
	Global $aVal

	$aVal = _Modbus_Set_Debug($tModbus, 1)

	;Global $aVal = _Modbus_Read_Registers($tModbus, 0, 1)
	;Global $aVal = _Modbus_Read_Input_Registers($tModbus, 0, 1)
	;Global $aVal = _Modbus_Read_Input_Bits($tModbus, 5)
	;Global $aVal = _Modbus_Read_Bits($tModbus, 5)
	;Global $aVal = _Modbus_Write_Bit($tModbus, 0, 1 )
	;Global $aVal = _Modbus_Write_Register($tModbus, 0, 8 )


	$repeat = 5

	While $repeat >= 1

		$aVal = _Modbus_Write_Register($tModbus, 0, 1)
		;_ArrayDisplay($aVal)
		;MsgBox(0,"",$aVal)

		Sleep(100)
		$aVal = _Modbus_Write_Register($tModbus, 0, 0)
		;_ArrayDisplay($aVal)
		;MsgBox(0,"",$aVal)

		$aVal = _Modbus_Read_Registers($tModbus, 0, 1)
		_ArrayDisplay($aVal)
		;MsgBox(0,"",$aVal)

		$repeat = $repeat - 1

	WEnd


	_Modbus_Close($tModbus)
	_Modbus_Free($tModbus)

EndFunc   ;==>_example_libDll
#ce
; ===============================================================================================================================

;===============================================================================
; Function Name:  _Modbus_SetDllPath($sFullPath)
; Description:    Sets full path to th extdll so that it can be in any location.
; Parameters:     $sFullPath -  Full path to the libmodbus.dll e.g. "C:\libmodbus\libmodbus.dll"
; Returns;  on success 1
;           on error -1 if full path does not exist
;===============================================================================
Func _Modbus_SetDllPath($sFullPath)
    If Not FileExists($sFullPath) Then Return -1

    $__DLLNAME = $sFullPath
    Return 1

EndFunc   ;==>_CommSetDllPath

;===============================================================================
; Function Name:  _Modbus_DllOpen()
; Description:    Start the Connection to the libmodbus dll
; Parameters:
; Returns;  on success 1
;           on error -1
;===============================================================================
Func _Modbus_DllOpen()
	$hDLL_Modbus = DllOpen($__DLLNAME)
        If $hDLL_Modbus = -1 Then
            SetError(1)
            $sErr = 'Failed to open DLL'
            Return 0;failed
        EndIf

	return 1
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_New_TCP
; Description ...: The modbus_new_tcp() function shall allocate and initialize a modbus_t structure to communicate with a Modbus TCP/IPv4 server.
; Syntax.........: _Modbus_New_TCP($sIP, $iPort = 502)
; Parameters ....: The ip argument specifies the IP address of the server to which the client wants etablish a connection.
;                  The port argument is the TCP port to use. Set the port to MODBUS_TCP_DEFAULT_PORT to use the default one (502). It’s convenient to use a port number greater than or equal to 1024 because it’s not necessary to have administrator privileges.
; Return values .: The modbus_new_tcp() function shall return a pointer to a modbus_t structure if successful. Otherwise it shall return NULL and set errno to one of the values defined below.
;                  Failure EINVAL An invalid IP address was given.
; C-Syntax.......: modbus_t *modbus_new_tcp(const char *ip, int port);
; ===============================================================================================================================
Func _Modbus_New_TCP($sIP, $iPort = 502)
	Local $aRet = DllCall($hDLL_Modbus, "ptr:cdecl", "modbus_new_tcp", "str", $sIP, "int", $iPort)
	Return $aRet[0]
EndFunc   ;==>_Modbus_New_TCP

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Connect
; Description ...: The modbus_connect() function shall etablish a connection to a Modbus server, a network or a bus using the context information of libmodbus context given in argument.
; Syntax.........: _Modbus_Connect($tModbus)
; Parameters ....: The $tModbus handle
; Return values .: The modbus_connect() function shall return 0 if successful. Otherwise it shall return -1 and set errno to one of the values defined by the system calls of the underlying platform.
; C-Syntax.......: int modbus_connect(modbus_t *ctx);
; ===============================================================================================================================
Func _Modbus_Connect($tModbus)
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_connect", "ptr", $tModbus)
	Return $aRet[0]
EndFunc   ;==>_Modbus_Connect

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Close
; Description ...: The modbus_close() function shall close the connection established with the backend set in the context.
; Syntax.........: _Modbus_Close($tModbus)
; Parameters ....: The $tModbus handle
; Return values .: There is no return value.
; C-Syntax.......: void modbus_close(modbus_t *ctx);
; ===============================================================================================================================
Func _Modbus_Close($tModbus)
	DllCall($hDLL_Modbus, "none:cdecl", "modbus_close", "ptr", $tModbus)
EndFunc   ;==>_Modbus_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Free
; Description ...: The modbus_free() function shall free an allocated modbus_t structure.
; Syntax.........: _Modbus_Free($tModbus)
; Parameters ....: The $tModbus handle
; Return values .: There is no return value.
; C-Syntax.......: void modbus_free(modbus_t *ctx);
; ===============================================================================================================================
Func _Modbus_Free($tModbus)
	DllCall($hDLL_Modbus, "none:cdecl", "modbus_free", "ptr", $tModbus)
EndFunc   ;==>_Modbus_Free

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_StrError
; Description ...: The modbus_strerror() function shall return a pointer to an error message string corresponding to the error number specified by the errnum argument. As libmodbus defines additional error numbers over and above those defined by the
;					operating system, applications should use modbus_strerror() in preference to the standard strerror() function.
; Syntax.........: _Modbus_StrError($iError)
; Parameters ....: the Error number
; Return values .: The modbus_strerror() function shall return a pointer to an error message string.
; C-Syntax.......: const char *modbus_strerror(*int errnum);
; ===============================================================================================================================
Func _Modbus_StrError($iError)
	Local $aRet = DllCall($hDLL_Modbus, "str:cdecl", "modbus_strerror", "int", $iError)
	Return $aRet[0]
EndFunc   ;==>_Modbus_StrError

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Read_Registers
; Description ...: The modbus_read_registers() function shall read the content of the nb holding registers to the address addr of the remote device. The result of reading is stored in dest array as word values (16 bits).
;					You must take care to allocate enough memory to store the results in dest [tBuffer] (at least nb * sizeof(uint16_t)).
;					The function uses the Modbus function code 0x03 (read holding registers).
; Syntax.........: _Modbus_Read_Registers($tModbus, $iAddr, $iNum)
; Parameters ....: nb holding registers
;				   addr of the remote device
; Return values .: The modbus_read_registers() function shall return the number of read registers if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_read_registers(modbus_t *ctx, int addr, int nb, uint16_t *dest);
; ===============================================================================================================================
Func _Modbus_Read_Registers($tModbus, $iAddr, $iNum)
	Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_read_registers", "ptr", $tModbus, "int", $iAddr, "int", $iNum, "struct*", $tBuffer)
	
	Local $aRes[$iNum]
	For $i = 0 To $iNum - 1
		$aRes[$i] = DllStructGetData($tBuffer, 1, $i + 1)
	Next
	Return $aRes
EndFunc   ;==>_Modbus_Read_Registers

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Read_Input_Registers
; Description ...: The modbus_read_input_registers() function shall read the content of the nb input registers to address addr of the remote device. The result of the reading is stored in dest array as word values (16 bits).
;					You must take care to allocate enough memory to store the results in dest [tBuffer] (at least nb * sizeof(uint16_t)).
;					The function uses the Modbus function code 0x04 (read input registers). The holding registers and input registers have different historical meaning, but nowadays it’s more common to use holding registers only.
; Syntax.........: _Modbus_Read_Input_Registers($tModbus, $iAddr, $iNum)
; Parameters ....: nb holding registers
;				   addr of the remote device
; Return values .: The modbus_read_input_registers() function shall return the number of read input registers if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_read_input_registers(modbus_t *ctx, int addr, int nb, uint16_t *dest);
; ===============================================================================================================================
Func _Modbus_Read_Input_Registers($tModbus, $iAddr, $iNum)
	Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_read_input_registers", "ptr", $tModbus, "int", $iAddr, "int", $iNum, "struct*", $tBuffer)

	Local $aRes[$iNum]
	For $i = 0 To $iNum - 1
		$aRes[$i] = DllStructGetData($tBuffer, 1, $i + 1)
	Next
	Return $aRes
EndFunc   ;==>_Modbus_Read_Input_Registers

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Read_Input_Bits
; Description ...: The modbus_read_input_bits() function shall read the content of the nb input bits to the address addr of the remote device. The result of reading is stored in dest array as unsigned bytes (8 bits) set to TRUE or FALSE.
;					You must take care to allocate enough memory to store the results in dest [tBuffer] (at least nb * sizeof(uint8_t)).
;					The function uses the Modbus function code 0x02 (read input status).
; Syntax.........: _Modbus_Read_Input_Bits($tModbus, $iAddr, $iNum)
; Parameters ....: nb holding registers
;				   addr of the remote device
; Return values .: The modbus_read_input_status() function shall return the number of read input status if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_read_input_bits(modbus_t *ctx, int addr, int nb, uint8_t *dest);
; ===============================================================================================================================
Func _Modbus_Read_Input_Bits($tModbus, $iAddr, $iNum = 1)
	Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_read_input_bits", "ptr", $tModbus, "int", $iAddr, "int", $iNum, "struct*", $tBuffer)
	
	Local $aRes[$iNum]
	For $i = 0 To $iNum - 1
		$aRes[$i] = DllStructGetData($tBuffer, 1, $i + 1)
	Next
	
	If $iNum = 1 Then
		Return $aRes[0]
	Else
		Return $aRes
	EndIf
EndFunc   ;==>_Modbus_Read_Input_Bits

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Read_Bits  ( offiziell Read Coil )
; Description ...: The modbus_read_bits() function shall read the status of the nb bits (coils) to the address addr of the remote device. The result of reading is stored in dest array as unsigned bytes (8 bits) set to TRUE or FALSE.
;					You must take care to allocate enough memory to store the results in dest [tBuffer] (at least nb * sizeof(uint8_t)).
;					The function uses the Modbus function code 0x01 (read coil status).
; Syntax.........: _Modbus_Read_Bits($tModbus, $iAddr, $iNum = 1 )
; Parameters ....: nb holding registers
;				   addr of the remote device
; Return values .: The modbus_read_bits() function shall return the number of read bits if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_read_bits(modbus_t *ctx, int addr, int nb, uint8_t *dest);
; ===============================================================================================================================
Func _Modbus_Read_Bits($tModbus, $iAddr, $iNum = 1)
	Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_read_bits", "ptr", $tModbus, "int", $iAddr, "int", $iNum, "struct*", $tBuffer)

	Local $aRes[$iNum]
	For $i = 0 To $iNum - 1
		$aRes[$i] = DllStructGetData($tBuffer, 1, $i + 1)
	Next

	If $iNum = 1 Then
		Return $aRes[0]
	Else
		Return $aRes
	EndIf
EndFunc   ;==>_Modbus_Read_Bits

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Write_Bit  ( write a single bit )
; Description ...: The modbus_write_bit() function shall write the status of status at the address addr of the remote device. The value must be set to TRUE or FALSE.
;					The function uses the Modbus function code 0x05 (force single coil).
; Syntax.........: _Modbus_Write_Bit($tModbus, $iAddr, $status )
; Parameters ....: addr of the remote device
;				   $status - True False
; Return values .: The modbus_write_bit() function shall return 1 if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_write_bit(modbus_t *ctx, int addr, int status);
; ===============================================================================================================================
Func _Modbus_Write_Bit($tModbus, $iAddr, $status)
	;Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_write_bit", "ptr", $tModbus, "int", $iAddr, "int", $status);, "struct*", $tBuffer)

	If (UBound($aRet)) >= 4 Then
		If $aRet[3] = $status Then
			Return 1
		Else
			Return -1
		EndIf
	EndIf
	Return -1

EndFunc   ;==>_Modbus_Write_Bit

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Write_Register  ( write a single register )
; Description ...: The modbus_write_register() function shall write the value of value holding registers at the address addr of the remote device.
;					The function uses the Modbus function code 0x06 (preset single register).
; Syntax.........: _Modbus_Write_Register($tModbus, $iAddr, $Value)
; Parameters ....: addr of the remote device
;				   $status - True False
; Return values .: The modbus_write_register() function shall return 1 if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_write_register(modbus_t *ctx, int addr, int value);
; ===============================================================================================================================
Func _Modbus_Write_Register($tModbus, $iAddr, $Value)

	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_write_register", "ptr", $tModbus, "int", $iAddr, "int", $Value)

	If (UBound($aRet)) >= 4 Then
		If $aRet[3] = $Value Then
			Return 1
		Else
			Return -1
		EndIf
	EndIf

	Return -1

EndFunc   ;==>_Modbus_Write_Register

; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Set_Debug  ( set debug flag of the context)
; Description ...: The modbus_set_debug() function shall set the debug flag of the modbus_t context by using the argument boolean. When the boolean value is set to TRUE, many verbose messages are displayed on stdout and stderr. For example, this
;					flag is useful to display the bytes of the Modbus messages.
;					[00][14][00][00][00][06][12][03][00][6B][00][03]
;					Waiting for a confirmation…
;					<00><14><00><00><00><09><12><03><06><02><2B><00><00><00><00>
; Syntax.........: _Modbus_Set_Debug($tModbus, $boolean)
; Parameters ....: When the boolean value is set to TRUE many verbose messages are displayed on stdout and stderr
;
; Return values .: There is no return values.
; C-Syntax.......: void modbus_set_debug(modbus_t *ctx, int boolean);
; ===============================================================================================================================
Func _Modbus_Set_Debug($tModbus, $boolean)

	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_set_debug", "ptr", $tModbus, "int", $boolean)

	Return $aRet

EndFunc   ;==>_Modbus_Write_Register




#cs
; #FUNCTION# ====================================================================================================================
; Name...........: _Modbus_Write_Bits ( write many bits / Multible Coil )
; Description ...: The modbus_write_bits() function shall write the status of the nb bits (coils) from src at the address addr of the remote device. The src array must contains bytes set to TRUE or FALSE.
;					The function uses the Modbus function code 0x0F (force multiple coils).
; Syntax.........: _Modbus_Write_Bits($tModbus, $iAddr, $iNum)
; Parameters ....: addr of the remote device
;				    status of the nb bits (coils)
;					 src - quelle
; Return values .: The modbus_write_bits() function shall return the number of written bits if successful. Otherwise it shall return -1 and set errno.
; C-Syntax.......: int modbus_write_bits(modbus_t *ctx, int addr, int nb, const uint8_t *src);
; ===============================================================================================================================
Func _Modbus_Write_Bits($tModbus, $iAddr, $iNum)
	Local $tBuffer = DllStructCreate("WORD[" & $iNum & "]")
	Local $aRet = DllCall($hDLL_Modbus, "int:cdecl", "modbus_read_registers", "ptr", $tModbus, "int", $iAddr, "int", $iNum, "struct*", $tBuffer)

	Local $aRes[$iNum]
	For $i = 0 To $iNum - 1
		$aRes[$i] = DllStructGetData($tBuffer, 1, $i + 1)
	Next
	Return $aRes
EndFunc   ;==>_Modbus_Write_Bits
#ce