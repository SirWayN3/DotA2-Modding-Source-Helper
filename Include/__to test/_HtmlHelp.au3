#include-Once

; #INDEX# ========================================================================================
; Title..........: HtmlHelp (ANSI version)
; Version........: 1.0 (Apr 4/11)
; AutoIt Version : 3.3.6.1
; Language.......: English
; Description....: HtmlHelp functions for context-sensitive help, etc. in projects
; Author(s)......: Allen Titley (aka Geodetic)
; Remarks........: This UDF provides basic HTML Help functionality for programmers who want to
;                  include a proper CHM (compiled HTML) help file with their project.  Functions
;                  allow basic file opening (_HHDispTOC), opening using context-sensitive IDs
;                  (_HHOpenTopicByID), and opening using a URL to an HTML file in the CHM
;                  (_HHOpenTopicByURL).  The UDF is 'self contained' and requires no other
;                  #include files.
;                  You might also want the HTML Help Workshop documentation package, available at:
;                  http://go.microsoft.com/fwlink/?LinkId=14581
; Dll(s) ........: hhctrl.ocx


; #CURRENT# ======================================================================================
;_HHOpen
;_HHClose
;_HHCloseAll
;_HHOpenTopicByID
;_HHOpenTopicByURL
;_DecodeHELPINFO
;_HHDispTOC
;_HHDispIndex
;_HH_DispSearch
;_PopupSetFont
;_PopupSetWindow
;_HHPopupText
;_HHPopupResource
;_HHPopupID


; #NOT_IMPLEMENTED# ==============================================================================
; HH_ALINK_LOOKUP - not practical for most help files, manual full-text search takes priority
; HH_GET_LAST_ERROR - 'flakey', not reliable information in returns, according to API docs
; HH_GET_WIN_HANDLE - programmer must know window type, AutoIt's WinGetHandle() is easier
; HH_GET_WIN_TYPE - too much information provided, too complex/esoteric
; HH_KEYWORD_LOOKUP - not practical for most help files, manual full-text search takes priority
; HH_PRETRANSLATEMESSAGE - not required for AutoIt (single-thread), see discussion in _HHOpen()
; HH_SET_WIN_TYPE - paired with HH_GET_WIN_TYPE - too complex/esoteric
; HH_SYNC - not needed - during help file compilation, auto-sync can be enabled instead
; HH_TP_HELP_CONTEXTMENU - see HH_TP_HELP_WM_HELP, following
; HH_TP_HELP_WM_HELP - not as versatile as _HHPopupID implemented here.  Both HH_TP_ functions
;	require the handle to the control desired, and pass a structure to the API (__HHocx)
;	containing a table of control IDs paired with help topicIDs - essentially, just a dispatch
;	routine.  The HH_TP_HELP_WM_HELP command uses the "What's this" 'menu', but this should be
;	used in conjunction with the "?" button ($WS_EX_CONTEXTHELP extended window style) which can
;	only be enabled with dialog-type windows.  A better approach might be to use AutoIt's
;	GUIGetCursorInfo function which provides ID of the control under the mouse, then use your
;	own method to pair this with a topicID, and call _HHPopupID.


; #INTERNAL_USE_ONLY# ============================================================================
;$tagHHCookie
;$tagHELPINFO
;__HHocx
;_Int64toInt32
;_Coord2Abs
;_WinAPI_LoadLibraryEx, by Paul Campbell (PaulIA)
;_WinAPI_FreeLibrary, by Paul Campbell (PaulIA)


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........: $tagHHCookie
; Description....: Used to fetch 'cookie' by _HHOpen.  'Cookie' is used by _HHClose.
; Fields.........: dwCookie		- 'double word' (ie. Int32), usage is unknown
; Author ........: Allen Titley (aka Geodetic)
; Remarks........: only used by _HHOpen, but declared Globally for conformity.
;                  DllStructGetData returns Int64, use _Int64toInt32 before passing to _HHClose.
; ================================================================================================
Global Const $tagHHCookie = "DWORD dwCookie"


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........: $tagHELPINFO
; Description....: Passed to parent window from a $lParam pointer in a WM_HELP message
; Fields.........: cbSize			- 1: struct size (always 28 or 0x1C)
;                  |iContextType	- 2: 1=ctrl/window  2=menu item
;                  |iCtrlId			- 3: control/window/menu ID
;                  |hItemHandle		- 4: handle to sending control/window/menu
;                  |dwContextId		- 5: Help contextID, set by 'others' (application/programmer)
;                  |X				- 6: mouse X
;                  |Y				- 7: mouse Y
; Author ........: Allen Titley (aka Geodetic)
; Remarks........: DllStructGetData returns Int64 on integers, use _Int64toInt32, as needed
; ================================================================================================
Global Const $tagHELPINFO = _
		"UINT cbSize;int iContextType;int iCtrlId;HANDLE hItemHandle;" & _
		"DWORD dwContextId;long X;long Y"


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........: $tagHH_POPUP
; Description....: Passed to a __HHocx call ($HH_DISPLAY_TEXT_POPUP).  Specifies popup info.
; Fields.........: cbStruct			- 1: struct size (always 52 or 0x34)
;                  |hinst			- 2: Instance handle of program or DLL, for resource strings
;                  |idString		- 3: Specifies 0, a resource ID, or a topic # in a text file
;                  |pszText			- 4: Pointer: specifies text to display if idString is zero
;                  |X				- 5: In pixels - top/center of popup window, X co-ordinate
;                  |Y				- 6: In pixels - top/center of popup window, Y co-ordinate
;                  |clrForeground	- 7: 'RGB' (0x00bbggrr) foreground, -1 = sys_color (0x00EEFFFF)
;                  |clrBackground	- 8: 'RGB' (0x00bbggrr) background, -1 = sys_color (0x00000000)
;                  |margin_lt		- 9: left margin (pixels), -1 = default (5 pixels)
;                  |margin_top		- 10: top margin (pixels), -1 = default (5 pixels)
;                  |margin_rt		- 11: right margin (pixels), -1 = default (5 pixels)
;                  |margin_bot		- 12: bottom margin (pixels), -1 = default (5 pixels)
;                  |pszFont			- 13: Pointer: font attributes string
; Author ........: Allen Titley (aka Geodetic)
; Remarks........: Default colors and margins may vary with you system and configuration.
; ================================================================================================
Global Const $tagHH_POPUP = _
		"int cbStruct;HANDLE hinst;UINT idString;ptr pszText;UINT X;UINT Y;" & _
		"DWORD clrForeground;DWORD clrBackground;" & _
		"long margin_lt;long margin_top;long margin_rt;long margin_bot;ptr pszFont"


; #CONSTANTS# ====================================================================================
; Uncommented constants are documented in HTML Help API reference.
; Commented constants are not in common usage(?) - unverified - see htmlhelp.h in HTML Help Workshop
Global Const $HH_DISPLAY_TOPIC = 0x0000
Global Const $HH_DISPLAY_TOC = 0x0001
Global Const $HH_DISPLAY_INDEX = 0x0002
Global Const $HH_DISPLAY_SEARCH = 0x0003
Global Const $HH_SET_WIN_TYPE = 0x0004
Global Const $HH_GET_WIN_TYPE = 0x0005
Global Const $HH_GET_WIN_HANDLE = 0x0006
;Global Const $HH_ENUM_INFO_TYPE		=0x0007
;Global Const $HH_SET_INFO_TYPE			=0x0008
Global Const $HH_SYNC = 0x0009
;Global Const $HH_RESERVED1				=0x000A		; HH_ADD_NAV_UI
;Global Const $HH_RESERVED2				=0x000B		; HH_ADD_BUTTON
;Global Const $HH_RESERVED3				=0x000C		; HH_GETBROWSER_APP
Global Const $HH_KEYWORD_LOOKUP = 0x000D
Global Const $HH_DISPLAY_TEXT_POPUP = 0x000E
Global Const $HH_HELP_CONTEXT = 0x000F
Global Const $HH_TP_HELP_CONTEXTMENU = 0x0010
Global Const $HH_TP_HELP_WM_HELP = 0x0011
Global Const $HH_CLOSE_ALL = 0x0012
Global Const $HH_ALINK_LOOKUP = 0x0013
;Global Const $HH_GET_LAST_ERROR			=0x0014		; not currently implemented(1999 - now?)
;Global Const $HH_ENUM_CATEGORY			=0x0015
;Global Const $HH_ENUM_CATEGORY_IT		=0x0016
;Global Const $HH_RESET_IT_FILTER		=0x0017
;Global Const $HH_SET_INCLUSIVE_FILTER	=0x0018
;Global Const $HH_SET_EXCLUSIVE_FILTER	=0x0019
;Global Const $HH_SET_GUID				=0x001A
;Global Const $HH_SET_BACKUP_GUID		=0x001B
Global Const $HH_INITIALIZE = 0x001C
Global Const $HH_UNINITIALIZE = 0x001D
;Global Const $HH_PRETRANSLATEMESSAGE	=0x00FD		; Not needed, since AutoIt is single threaded
;Global Const $HH_SET_GLOBAL_PROPERTY	=0x00FC

Global Const $pNULL = Ptr(0) ; used in calls to __HHocx, etc.
Global Const $sNULL = "" ; used in calls to __HHocx

; The following constants can be used in functions with some numeric parameters, in order to
; select the preset values, or to skip any change to that parameter.  The numbers have been
; chosen to be 'unusual' - almost never entered as parameters.
; Accepted in:
; 	_HH_DispSearch($iFlags)	- $nochange, $preset=1
Global Const $preset = 0xEE000000 ; preset (built-in) value
Global Const $skip = 0xFF000000 ; skip (no change)


; #VARIABLES# ====================================================================================
Global $tHHcookie ; *IMPORTANT* storage - see _HHOpen, _HHClose
Global $hOCXhandle ; *IMPORTANT* handle to hhctrl.ocx - required by _HHClose

Global $HHWinWhdl = 0 ; handle to currently open Html Help window, can be accessed by application
; NOTE: This handle is ONLY valid after using a routine which returns a window handle, currently:
;	- _HHOpenTopicByID
;	- _HHOpenTopicByURL
;	- _HHDispTOC
;	- _HHDispIndex
;	- _HH_DispSearch
; Users should test for zero (0) and for existence of actual window (user may have close it) using
; WinExists prior to using it, or use WinGetHandle() instead.  If this handle is needed prior to
; using one of the above routines, WinGetHandle() might be the only option.

; Calls using a _HHPopup.. function require an HH_POPUP structure and 2 string structures
; They are created by _HHopen() and 'destroyed' by _HHClose().
Global $tHH_POPUP ; control structure
Global $pHH_POPUP ; pointer to $tHH_POPUP
Global $tszText ; structure - explicit text string
Global $tszFont ; structure - font style string


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........:  __HHocx
; Description....: Executes a 'dll' call to hhctrl.ocx, using "HtmlHelpA"
; Syntax.........: __HHocx($hCaller,$psFile,$iCommand,$iData)
; Parameters.....: $hCaller		- handle to the calling window, or $pNULL
;                  $psFile		- one of:
;                  |	o  a null pointer ($pNULL), where there is no string to pass, or
;                  |	o  a string (ie. path to CHM, topic URL, etc.)
;                  |If $psFile is passed as a string, it MUST be put into a structure, then the
;                  |POINTER to the string passed directly to the DllCall.  The HTML Help API
;                  |reference states that this may also be: "A window type name ... preceded
;                  |with a greater-than (>) character." (rarely used)
;                  $iCommand	- command to perform, use a $HH_ constant, eg. $HH_INITIALIZE
;                  $iData		- data required for $iCommand.  Note that the internal declaration
;                  |of this parameter is "DWORD_PTR dwData", previously defined as an integer.
;                  |Some commands will accept a pointer here, pointing to a variety of data types.
; Return values..: Success:		- value from "HtmlHelpA" call
;                  |HTML Help API reference says: "Depending on the specified uCommand and the
;                  |result, HtmlHelp() returns one or both of the following:
;                  |	o  The handle (hwnd) of the help window.
;                  |	o  NULL. In some cases, NULL indicates failure; in other cases, NULL
;                  |       indicates that the help window has not yet been created.
;                  Failure:		- one of the following:
;                  |-1, unable to use the DLL file
;                  |-2, unknown "return type"
;                  |-3, "function" not found in the DLL file
;                  |-4, bad number of parameters
;                  |application crash - it's fussy! (not exactly a return)
;                  |eg.     "AutoIt3.exe has encountered a problem and needs to close.
;                  |         We are sorry for the inconvenience."
;                  |The nature of the "HtmlHelp" native call is such that return values
;                  |are generally not meaningful, and faulty parameters usually yield an
;                  |application crash rather than returning an error value.  For this
;                  |reason it is difficult to accurately determine a successful call,
;                  |so routines which call "__HHocx()" (ie. native Html Help API function)
;                  |will not, in most cases, test results.  If call returns, you should
;                  |assume it was successful.
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Internal function - this function provides the ONLY access to "hhctrl.ocx",
;                  ie. the API.  Uses "HtmlHelpA" (ANSI) call; changing to "HtmlHelpW" for Unicode
;                  is 'possible', but requires some rework for string structures, etc. - avoid
;                  if possible.
;                  See "Return values:" for additional comments re: function returns.
; Related........:
; Link ..........: http://msdn.microsoft.com/en-us/library/ms670172(v=vs.85).aspx
; Example........: No
; ================================================================================================
Func __HHocx($hCaller, $psFile, $iCommand, $iData) ; default format for HtmlHelp call
	Local $result, $err
	Local $tpszFile = DllStructCreate("CHAR[256]") ; holds pszFile string
	If VarGetType($psFile) = "String" Then ; just pass null pointer, if set to $pNULL already
		If $psFile = "" Then
			$psFile = $pNULL ; just in case a caller passes "" instead of $pNULL
		Else
			DllStructSetData($tpszFile, 1, $psFile) ; load string into structure
			$psFile = DllStructGetPtr($tpszFile) ; get pointer to pass to DllCall
		EndIf
	EndIf
	$result = DllCall("hhctrl.ocx", "HWND", "HtmlHelpA", _
			"HWND", $hCaller, _	; handle to calling window
			"ptr", $psFile, _	; pointer to path to .chm file, or topic page, etc.
			"UINT", $iCommand, _	; HH_ command constant
			"DWORD", $iData) ; data required by some commands
	$tpszFile = 0
	$err = @error
	If $err Then
		SetError(-$err)
		Return -$err ; return error code as negative (-1..-4).
		; Returns from "HtmlHelpA" call are 'all over the map', but should never be negative(?).
	Else
		Return $result[0] ; DllCall return value
	EndIf
EndFunc   ;==>__HHocx


; #FUNCTION# =====================================================================================
; Name...........: _HHOpen
; Description....: Initializes the HtmlHelp system.
; Syntax.........: _HHOpen()
; Parameters.....: none
; Return values..: Success:		- 1, 'cookie' stored in $tHHcookie for life of application
;                  Failure:		- 0, sets @error=1 ("hhctrl.ocx" not found), or crash?
;                  |Missing hhctrl.ocx generates a MsgBox alert - serious!
;                  |(see __HHocx return values)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: The HtmlHelp system MUST be initialized prior to use; failing to do so will
;                  render the Help system inoperative.  _HHOpen checks for the existence of
;                  Windows\system32\hhctrl.ocx, the ActiveX component for implementing HtmlHelp.
;                  _HHOpen should only be called once during the application's lifetime.
;                  _HHopen() also creates some 'permanent' structures for other functions, which
;                  are 'destroyed' by _HHClose.
; Related........: _HHClose
; Link...........: http://msdn.microsoft.com/en-us/library/ms670090(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHopen() ; initialize HTMLHelp, returns 32-bit "cookie" required for HH_uninit
	$tHHcookie = DllStructCreate($tagHHCookie) ; 'alive' until _HHclose()
	Local $pCookie = DllStructGetPtr($tHHcookie, "dwCookie")
	If FileExists(@SystemDir & "\hhctrl.ocx") Then ; is ocx file there?
		$hOCXhandle = DllOpen(@SystemDir & "\hhctrl.ocx") ; yes, open it - for duration of app
		__HHocx($pNULL, $pNULL, $HH_INITIALIZE, $pCookie) ; initialize help system

		; Calls using the _HHPopup.. functions require an HH_POPUP structure and 2 string structures
		$tHH_POPUP = DllStructCreate($tagHH_POPUP)
		$pHH_POPUP = DllStructGetPtr($tHH_POPUP) ; get pointer
		$tszText = DllStructCreate("CHAR[256]") ; probably more than we need!
		$tszFont = DllStructCreate("CHAR[128]")
		DllStructSetData($tHH_POPUP, "cbStruct", 52) ; set size
		DllStructSetData($tHH_POPUP, "hinst", $pNULL) ; set dummy instance handle
		DllStructSetData($tHH_POPUP, "pszText", DllStructGetPtr($tszText)) ; ptr to popup text
		DllStructSetData($tHH_POPUP, "pszFont", DllStructGetPtr($tszFont)) ; ptr to font attributes

		DllStructSetData($tHH_POPUP, "clrForeground", -1) ; system color
		DllStructSetData($tHH_POPUP, "clrBackground", -1) ; system color
		DllStructSetData($tHH_POPUP, "margin_lt", -1) ; set default margins
		DllStructSetData($tHH_POPUP, "margin_top", -1)
		DllStructSetData($tHH_POPUP, "margin_rt", -1)
		DllStructSetData($tHH_POPUP, "margin_bot", -1)
		DllStructSetData($tszFont, 1, "Tahoma,8.5,,") ; set default font (system defaults)
		; Except for using resource strings, only "idString", "X" and "Y" are missing from $tHH_POPUP.
		; Prior to call, $szText may also need to be set in conjunction with "idString".  If resource
		; strings are to be used, "hinst" and "idString" are involved.  Programmers may change any of
		; the parameters to suit their own application, such as colors, font, margins, etc.
		Return 1
	Else
		MsgBox(16, "Html Help System", "'hhctrl.ocx' not found - Help System inoperative")
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHopen


; #FUNCTION# =====================================================================================
; Name...........: _HHClose
; Description....: Properly shuts down (ie. un-initializes) the HTML Help system.
; Syntax.........: _HHClose()
; Parameters.....: none - uses global variable $tHHcookie
; Return values..: none - see __HHocx for comments
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: This function should be the last help command the application calls.
;                  _HHClose should only be called once during the application's lifetime
;                  - at app termination.  WARNING: your application MUST have called _HHOpen
;                  at entry!
; Related........: _HHOpen
; Link...........: http://msdn.microsoft.com/en-us/library/ms670097(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHClose() ; shutdown Html Help system
	Local $iCookie = _Int64toInt32(DllStructGetData($tHHcookie, "dwCookie")) ; make sure it's Int32
	_HHCloseAll() ; close all open (child) help windows - must be performed to avoid crash!
	__HHocx($pNULL, $pNULL, $HH_UNINITIALIZE, $iCookie) ; clean up
	DllClose($hOCXhandle) ; and close 'dll'
	$tHHcookie = 0
	$tHH_POPUP = 0 ; release memory from structures
	$tszText = 0
	$tszFont = 0
EndFunc   ;==>_HHClose


; #FUNCTION# =====================================================================================
; Name...........: _HHCloseAll
; Description....: Closes all windows opened directly or indirectly by the calling program.
; Syntax.........: _HHCloseAll()
; Parameters.....: none
; Return values..: none - see __HHocx for comments
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Because help windows opened from the application (using this UDF) are
;                  essentially child windows, they MUST be closd before the Help system can be
;                  shut down and the 'dll' (hhctrl.ocx) closed.  This function is part of _HHClose
;                  and closes all 'child' help windows at Help system shutdown, however, you
;                  may use it at any time when it is desirable to close all help windows.
; Related........: _HHOpen, HHClose
; Link...........: http://msdn.microsoft.com/en-us/library/ms670079(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHCloseAll() ; close all Help windows opened by AutoIt application
	__HHocx($pNULL, $pNULL, $HH_CLOSE_ALL, 0)
EndFunc   ;==>_HHCloseAll


; #FUNCTION# =====================================================================================
; Name...........: _HHOpenTopicByID
; Description....: Opens a topic in a CHM file using a topicID (integer).
; Syntax.........: _HHOpenTopicByID($sChmFile,$iIDNum[,$hParent])
; Parameters.....: $sChmFile	- the name of the CHM file (with path, if needed).
;                  $iIDNum		- an integer (topicID) which identifies the topic.  TopicIDs are
;                  |pre-compiled into the CHM file using the [ALIAS] and [MAP] sections of the
;                  |.HHP project file (HTML Help Workshop).
;                  $hParent		- (optional) hWnd (handle) to calling window, usually current
;                  |AutoIt app.  If absent, Help window will have no specific parent; if handle
;                  |to your app is used, Help window is "on top" (maybe not what you want).
;                  |"On top" (child) property only works when opening Help windows for first
;                  |time.
; Return values..: Success:		- 1
;                  Failure:		- 0, @error=1 ($sChmFile not found)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: If the topicID has not been assigned in the Chm file, this function does
;                  nothing.  That is, if the Help file is not yet open, a bad ID will not open
;                  it; if it IS already open, a bad ID will not change the topic.  It is the
;                  programmer's responsibility to ensure the topicID is correct.
; Related........: _HHOpenTopicByURL
; Link...........: http://msdn.microsoft.com/en-us/library/ms670088(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHOpenTopicByID($sChmFile, $iIDNum, $hParent = $pNULL) ; open topic in $sChmFile using $iIDNum (int)
	If FileExists($sChmFile) Then
		$HHWinWhdl = __HHocx($hParent, $sChmFile, $HH_HELP_CONTEXT, $iIDNum) ; save handle
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHOpenTopicByID


; #FUNCTION# =====================================================================================
; Name...........: _HHOpenTopicByURL
; Description....: Opens a topic in a CHM file using an URL to the HTML page.
; Syntax.........: _HHOpenTopicByURL($sChmFile[,$sTopicURL[,$hParent]])
; Parameters.....: $sChmFile	- the name of the CHM file (with path, if needed).
;                  $sTopicURL	- (optional) URL which identifies the topic (page).  See Remarks.
;                  $hParent		- (optional) hWnd (handle) to calling window, usually current
;                  |AutoIt app.  If absent, Help window will have no specific parent; if handle
;                  |to your app is used, Help window is "on top" (maybe not what you want).
;                  |"On top" (child) property only works when opening Help windows for first
;                  |time.
; Return values..: Success:		- 1
;                  Failure:		- 0, @error=1 ($sChmFile not found)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: The $sTopicURL field is optional; if not supplied then the CHM is just opened
;                  at the default page.  The URL to a topic is the location of the actual HTML
;                  file in the CHM, but entered using "/" instead of "\".  The actual file may
;                  be located by using a decompiled CHM file, or by inspecting the file
;                  structure (folders, HTML files) with a tool such as 7-Zip
;                  (http://www.7-zip.org/) which can natively view or extract the files in a CHM
;                  'archive'.  For example, if the CHM contains a folder "Usage" which contains
;                  the file "Invocation.htm", then the $sTopicURL parameter would be
;                  "/Usage/Invocation.htm".  This function can open any page in the CHM file.
; Related........: _HHOpenTopicByID
; Link...........: http://msdn.microsoft.com/en-us/library/ms670084(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHOpenTopicByURL($sChmFile, $sTopicURL = $sNULL, $hParent = $pNULL)
	Local $sFileTopic = $sChmFile
	If $sTopicURL <> $sNULL Then ; URL supplied
		If StringLeft($sTopicURL, 1) <> "/" Then $sTopicURL = "/" & $sTopicURL ; add leading /
		$sFileTopic &= "::" & $sTopicURL
	EndIf
	If FileExists($sChmFile) Then
		$HHWinWhdl = __HHocx($hParent, $sFileTopic, $HH_DISPLAY_TOPIC, $pNULL) ; save handle
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_HHOpenTopicByURL


; #FUNCTION# =====================================================================================
; Name...........: _DecodeHELPINFO
; Description....: Fetchs a HELPINFO structure and extracts its data.
; Syntax.........: _DecodeHELPINFO($lParam)
; Parameters.....: $lParam	- pointer to a HELPINFO structure
; Return values..: A one-dimensional array containing all HELPINFO data
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: $lParam is the parameter from an installed handler for WM_HELP windows
;                  messages, used to intercept F1 and MsgBox Help button presses.  THIS FUNCTION
;                  SHOULD NOT BE USED EXCEPT IN THAT CONTEXT, since no error checking can be
;                  reliably done.
; Related........: _Int64toInt32
; Link...........: http://msdn.microsoft.com/en-us/library/bb773313(v=VS.85).aspx
; Example........: No
; ================================================================================================
Func _DecodeHELPINFO($lParam)
	Local $tHELPINFO = DllStructCreate($tagHELPINFO, $lParam), $aiHIData[7]
	For $i = 1 To 7
		$aiHIData[$i - 1] = _Int64toInt32(DllStructGetData($tHELPINFO, $i)) ; all fields are 32-bit
	Next
	$aiHIData[3] = Ptr($aiHIData[3]) ; make sure it's a pointer/handle
	$tHELPINFO = 0 ; done with structure, free memory
	Return $aiHIData ; struct elements 1..7 are array elements 0..6
EndFunc   ;==>_DecodeHELPINFO


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........: _Int64toInt32
; Description....: Converts a 64-bit integer into a 32-bit integer.
; Syntax.........: _Int64toInt32($iInt64)
; Parameters.....: $iInt64	- 64-bit integer, returned by DllStructGetData
; Return values..: 32-bit integer
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: When operating on Windows structs, DllStructGetData always returns a 64-Bit
;                  integer from all 32-bit integer fields (eg. UINT, int, DWORD, etc.).  HANDLEs
;                  are returned correctly; other pointer types should be verified.  While the
;                  values are suitable for use in AutoIt functions, for Windows calls and
;                  they should be put into the correct bit size, to avoid potential problems.
; Related........: $tagHHCookie, $tagHELPINFO
; Link...........:
; Example........: No
; ================================================================================================
Func _Int64toInt32($iInt64)
	Local $sInt32 = Hex($iInt64) ; convert to hex str - $iInt64 must "fit in a 32 bit signed integer"
	Return Dec($sInt32) ; Dec returns an Int32 (Int does not!)
EndFunc   ;==>_Int64toInt32


; #FUNCTION# =====================================================================================
; Name...........: _HHDispTOC
; Description....: Selects the Contents tab in the CHM's Navigation pane.
; Syntax.........: _HHDispTOC($sChmFile[,$hParent])
; Parameters.....: $sChmFile	- the name of the CHM file (with path, if needed).  This may also
;                  |contain a topic URL, if desired, eg. "C:\MyHelpFile.chm::/intro.htm".
;                  $hParent		- (optional) hWnd (handle) to calling window, usually current
;                  |AutoIt app.  If absent, Help window will have no specific parent; if handle
;                  |to your app is used, Help window is "on top" (maybe not what you want).
;                  |"On top" (child) property only works when opening Help windows for first
;                  |time.
; Return values..: Success:		- 1
;                  Failure:		- 0, @error=1 ($sChmFile not found)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: If Help window is not open, a new window is created, and the Contents tab
;                  selected, if it exists.  If Help window is already open, just the tab is
;                  changed.  Does not change topic - if opening for the first time, the CHM's
;                  default topic is opened.  This function is best suited for Help/Contents.
;                  _HHDispTOC cannot detect whether or not a Contents tab actually exists.
; Related........: _HHDispIndex, _HHDispSearch
; Link...........: http://msdn.microsoft.com/en-us/library/ms670083(v=VS.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHDispTOC($sChmFile, $hParent = $pNULL) ; open file and select Contents tab
	If FileExists($sChmFile) Then
		$HHWinWhdl = __HHocx($hParent, $sChmFile, $HH_DISPLAY_TOC, $pNULL) ; save handle
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHDispTOC


; #FUNCTION# =====================================================================================
; Name...........: _HHDispIndex
; Description....: Selects the Index tab (and key word) in the CHM's Navigation pane.
; Syntax.........: _HHDispIndex($sChmFile[,$sKeyWord[,$hParent]])
; Parameters.....: $sChmFile	- the name of the CHM file (with path, if needed).  This may also
;                  |contain a topic URL, if desired, eg. "C:\MyHelpFile.chm::/intro.htm".
;                  $sKeyWord	- (optional) the keyword to select
;                  $hParent		- (optional) hWnd (handle) to calling window, usually current
;                  |AutoIt app.  If absent, Help window will have no specific parent; if handle
;                  |to your app is used, Help window is "on top" (maybe not what you want).
;                  |"On top" (child) property only works when opening Help windows for first
;                  |time.  _HHDispIndex cannot detect whether or not an Index tab actually
;                  |exists.
; Return values..: Success:		- 1
;                  Failure:		- 0, @error=1 ($sChmFile not found)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Partial keywords may be icluded in the call (eg. "t").  See remarks for
;                  _HHDispTOC, re: CHM closed or already open.
; Related........: _HHDispTOC, _HH_DispSearch
; Link...........: http://msdn.microsoft.com/en-us/library/ms670080(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHDispIndex($sChmFile, $sKeyWord = $sNULL, $hParent = $pNULL)
	Local $tKeyWord = DllStructCreate("CHAR[128]")
	Local $pKeyWord = DllStructGetPtr($tKeyWord) ; will point to KeyWord string
	DllStructSetData($tKeyWord, 1, $sKeyWord)
	If FileExists($sChmFile) Then
		$HHWinWhdl = __HHocx($hParent, $sChmFile, $HH_DISPLAY_INDEX, $pKeyWord) ; save handle
		$tKeyWord = 0 ; free memory
		Return 1
	Else
		SetError(1)
		$tKeyWord = 0
		Return 0
	EndIf
EndFunc   ;==>_HHDispIndex


; #FUNCTION# =====================================================================================
; Name...........: _HH_DispSearch
; Description....: Selects the Search tab, and does an optional search and/or sets search options.
; Syntax.........: _HH_DispSearch($sChmFile[,$sTarget[,$iFlags[,$hParent]]])
; Parameters.....: $sChmFile	- the name of the CHM file (with path, if needed).  This may also
;                  |contain a topic URL, if desired, eg. "C:\MyHelpFile.chm::/intro.htm".
;                  $sTarget		- (optional) the string to search for
;                  $iFlags		- (optional) set search options.  Possible values are:
;                  |$skip		- (default value, if missing) no change to flags
;                  |$preset		- use 1 (Match similar words)
;                  |If flags is 0 or a positive number, it is bit-coded (additive) as:
;                  |0	- clear all options
;                  |1	- Match similar words
;                  |2	- Search titles only
;                  |4	- Search previous results
;                  $hParent		- (optional) hWnd (handle) to calling window, usually current
;                  |AutoIt app.  If absent, Help window will have no specific parent; if handle
;                  |to your app is used, Help window is "on top" (maybe not what you want).
;                  |"On top" (child) property only works when opening Help windows for first
;                  |time.  _HH_DispSearch cannot detect whether or not a Search tab actually
;                  |exists.
; Return values..: Success:		- 1
;                  Failure:		- 0, @error=1 ($sChmFile not found)
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Apparently, the actual search component (in the API) has NEVER worked!
;                  See  http://support.microsoft.com/kb/241381  for proof.  However, this
;                  function 'natively' changes to the search tab, then emulates the broken
;                  features using a mixture of "Send" and official accessibility shortcut keys.
;                  The $sTarget and $iFlags fields are mutully independent; one or both can be
;                  default values ("",$skip).  See remarks for _HHDispTOC, re: CHM closed or
;                  already open.
; Related........: _HHDispTOC, _HHDispIndex
; Link...........: http://msdn.microsoft.com/en-us/library/ms670081(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HH_DispSearch($sChmFile, $sTarget = $sNULL, $iFlags = $skip, $hParent = $pNULL)
	Local $tHH_FTS_QUERY = DllStructCreate("int cbStruct;BOOL fUniCodeStrings;" & _
			"ptr pszSearchQuery;long iProximity;BOOL fStemmedSearch;BOOL fTitleOnly;" & _
			"BOOL fExecute;ptr pszWindow") ; size=32
	Local $pHH_FTS_QUERY = DllStructGetPtr($tHH_FTS_QUERY)
	DllStructSetData($tHH_FTS_QUERY, "cbStruct", 32)
	DllStructSetData($tHH_FTS_QUERY, "fUniCodeStrings", 0)
	DllStructSetData($tHH_FTS_QUERY, "pszSearchQuery", $pNULL) ; no search text
	DllStructSetData($tHH_FTS_QUERY, "iProximity", -1)
	DllStructSetData($tHH_FTS_QUERY, "fStemmedSearch", 0)
	DllStructSetData($tHH_FTS_QUERY, "fTitleOnly", 0)
	DllStructSetData($tHH_FTS_QUERY, "fExecute", 1)
	DllStructSetData($tHH_FTS_QUERY, "pszWindow", $pNULL) ; no window name
	If FileExists($sChmFile) Then
		$HHWinWhdl = __HHocx($hParent, $sChmFile, $HH_DISPLAY_SEARCH, $pHH_FTS_QUERY) ; save handle
		; Function cannot tell if the Search tab exists and was selected, but would have opened the file.
		; The programmer should ensure that the Search tab exists in the CHM to avoid faulty "Send"s.
		If $iFlags = $preset Then
			$iFlags = 1 ; Match similar words
		Else
			If $iFlags <> $skip Then ; flags field present
				Send("!m") ; match similar
				If BitAND($iFlags, 0x0001) = 0 Then
					Send("{NUMPADSUB}") ; unchecked
				Else
					Send("{NUMPADADD}") ; checked
				EndIf
				Send("!r") ; search titles
				If BitAND($iFlags, 0x0002) = 0 Then
					Send("{NUMPADSUB}")
				Else
					Send("{NUMPADADD}")
				EndIf
				Send("!u") ; previous search
				If BitAND($iFlags, 0x0004) = 0 Then
					Send("{NUMPADSUB}")
				Else
					Send("{NUMPADADD}")
				EndIf
			EndIf
		EndIf
		If $sTarget <> $sNULL Then ; search target present
			Send("!w" & $sTarget) ; select edit control, type target
			Send("!l{ENTER}") ; execute search
		EndIf
		$tHH_FTS_QUERY = 0 ; free memory
		Return 1
	Else
		SetError(1)
		$tHH_FTS_QUERY = 0
		Return 0
	EndIf
EndFunc   ;==>_HH_DispSearch


; #INTERNAL_USE_ONLY# ============================================================================
; Name...........: _Coord2Abs
; Description....: Converts window or client-area co-ordinates to absolute screen co-ordinates
; Syntax.........: _Coord2Abs(ByRef $iX,ByRef $iY[,$iCmode[,$hWnd]])
; Parameters.....: $iX		- X value to convert
;                  $iY		- Y value to convert
;                  $iCmode	- (optional) co-ordinate mode (of $iX and $iY)
;                  |	0=window (relative)
;                  |	1=screen (absolute) - default value
;                  |	2=client-area (relative)
;                  $hWnd	- (optional) handle to window, if $iCmode=0 or 2.  If unavailable,
;                  |as in a MsgBox, function uses active window (default).  Needed for
;                  |position/dimensions.
; Return values..: None - new co-ordinates passed by reference
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Special case of -1 (for $iX and/or $iY) corresponds to midpoint of region,
;                  eg. center of screen, window or client-area, horizontal, vertical or both.
;                  This function is flagged as "INTERNAL_USE_ONLY", but will be useful in many
;                  applications - use it as needed!
; Related........: _HHPopupText, _HHPopupResource, _HHPopupID
; Link...........:
; Example........:
; ================================================================================================
Func _Coord2Abs(ByRef $iX, ByRef $iY, $iCmode = 1, $hWnd = $pNULL)
	Local $aiWinPos, $aiClientSize, $tPoint, $iCXOrigin, $iCYOrigin
	If $hWnd = $pNULL Then $hWnd = WinGetHandle("[ACTIVE]") ; need handle for calcs
	Switch $iCmode
		Case 0
			$aiWinPos = WinGetPos($hWnd)
			If $iX = -1 Then
				$iX = Int($aiWinPos[2] / 2) + $aiWinPos[0] ; ie. midpoint of window
			Else
				$iX += $aiWinPos[0] ; correct for absolute window X
			EndIf
			If $iY = -1 Then
				$iY = Int($aiWinPos[3] / 2) + $aiWinPos[1]
			Else
				$iY += $aiWinPos[1]
			EndIf

		Case 1 ; absolute
			If $iX = -1 Then $iX = Int(@DesktopWidth / 2) ; ie. center of hor. resolution
			If $iY = -1 Then $iY = Int(@DesktopHeight / 2)

		Case 2
			$aiClientSize = WinGetClientSize($hWnd)
			; thanks to Jon (presumably) for hints in using ClientToScreen - time saved!
			; see AutoIt help file: example code in GUICtrlCreateContextMenu
			$tPoint = DllStructCreate("int;int") ; point structure
			DllStructSetData($tPoint, 1, 0) ; going to find abs of (0,0) in client co-ords
			DllStructSetData($tPoint, 2, 0)
			DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($tPoint))
			$iCXOrigin = DllStructGetData($tPoint, 1) ; = absolute X of start of client-area
			$iCYOrigin = DllStructGetData($tPoint, 2)
			If $iX = -1 Then
				$iX = Int($aiClientSize[0] / 2) + $iCXOrigin ; ie. midpoint of client-area
			Else
				$iX += $iCXOrigin ; correct for absolute window X
			EndIf
			If $iY = -1 Then
				$iY = Int($aiClientSize[1] / 2) + $iCYOrigin ; ie. midpoint of client-area
			Else
				$iY += $iCYOrigin ; correct for absolute window X
			EndIf
			$tPoint = 0 ; free memory
	EndSwitch
	Return
EndFunc   ;==>_Coord2Abs


; #FUNCTION# =====================================================================================
; Name...........: _PopupSetFont
; Description....: Set Font name, style and color, etc. for _HHPopup... functions
; Syntax.........: _PopupSetFont($iSize[,$iColor[,$iStyle[,$sFace]]])
; Parameters.....: $iSize	- font size (pt), also
;                  |$skip (no change)
;                  |$preset (= 8.5)
;                  $iColor	- (optional) font (foreground) color, 'RGB' (0x00bbggrr) value, also
;                  |$skip (no change) - default value
;                  |$preset (= -1) system color
;                  $iStyle	- (optional) font style eg. "BOLD ITALIC UNDERLINE", also
;                  |$skip (no change) - default value
;                  |$preset (= "") normal style
;                  $sFace	- (optional) Font face name, eg. "Courier New", also
;                  |$skip (no change) - default value
;                  |$preset (= "Tahoma")
; Return values..: none
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: All parameters accept the $skip and $preset values, but only $iSize must be
;                  specified.  $iStyle should be either "" (normal) or a single string with the
;                  styles required (or BOLD ITALIC UNDERLIINE), eg. "BOLD UNDERLINE".
; Related........: _PopupSetWindow, _HHPopupText, _HHPopupResource
; Link...........:
; Example........: Yes
; ================================================================================================
Func _PopupSetFont($iSize, $iColor = $skip, $iStyle = $skip, $sFace = $skip)
	Local $aFont = StringSplit(DllStructGetData($tszFont, 1), ",") ; get current font string as array
	Local $sFontstr
	If $iSize <> $skip Then
		If $iSize = $preset Then $iSize = 8.5
		$aFont[2] = $iSize
	EndIf
	If $iStyle <> $skip Then
		If $iStyle = $preset Then $iStyle = $sNULL ; normal text
		$aFont[4] = $iStyle
	EndIf
	If $sFace <> $skip Then
		If $sFace = $preset Then $sFace = "Tahoma"
		$aFont[1] = $sFace
	EndIf
	$sFontstr = $aFont[1] & "," & $aFont[2] & ",," & $aFont[4]
	DllStructSetData($tszFont, 1, $sFontstr) ; set font string
	If $iColor <> $skip Then
		If $iColor = $preset Then $iColor = -1 ; system color
		DllStructSetData($tHH_POPUP, "clrForeground", $iColor)
	EndIf
EndFunc   ;==>_PopupSetFont


; #FUNCTION# =====================================================================================
; Name...........: _PopupSetWindow
; Description....: Set background window color, text margins for _HHPopup... functions
; Syntax.........: _PopupSetWindow($iColor[,$iLt[,$Rt[,$iTop[,$iBot]]]])
; Parameters.....: $iColor	- font (foreground) color, 'RGB' (0x00bbggrr) value, also
;                  |$skip (no change) - default value
;                  |$preset (= -1) system color
;                  $iLt		- (optional) left margin (pixels), also
;                  |$skip (no change) - default value
;                  |$preset (= -1) system assigned margin
;                  $iRt		- (optional) right margin (pixels), also $skip, $preset (see $iLt)
;                  $iTop	- (optional) top margin (pixels), also $skip, $preset (see $iLt)
;                  $iBot	- (optional) bottom margin (pixels), also $skip, $preset (see $iLt)
; Return values..: none
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: All parameters accept the $skip and $preset values, but only $iColor must be
;                  specified.  'Mucking' with the margins causes some 'unpredictable' window
;                  locations - trial and error may position it to your liking.
; Related........:  _PopupSetFont, _HHPopupText, _HHPopupResource
; Link...........:
; Example........: Yes
; ================================================================================================
Func _PopupSetWindow($iColor, $iLt = $skip, $iRt = $skip, $iTop = $skip, $iBot = $skip)
	Local $aMargin[4]
	If $iColor <> $skip Then
		If $iColor = $preset Then $iColor = -1 ; system color
		DllStructSetData($tHH_POPUP, "clrBackground", $iColor)
	EndIf
	$aMargin[0] = $iLt
	$aMargin[1] = $iTop
	$aMargin[2] = $iRt
	$aMargin[3] = $iBot
	For $i = 0 To 3
		If $aMargin[$i] <> $skip Then
			If $aMargin[$i] = $preset Then $aMargin[$i] = -1
			DllStructSetData($tHH_POPUP, $i + 9, $aMargin[$i])
		EndIf
	Next
EndFunc   ;==>_PopupSetWindow


; #FUNCTION# =====================================================================================
; Name...........: _HHPopupText
; Description....: Displays user text (explicit string) in a popup window
; Syntax.........: _HHPopupText($sText,$iX,$iY[,$iCmode[,$hWnd]])
; Parameters.....: $sText	- text to display in popup window
;                  |$iX		- X pos. for top-center of popup window
;                  |$iY		- Y pos. for top-center of popup window
;                  $iCmode	- (optional) co-ordinate mode (of $iX and $iY)
;                  |	0=window (relative)
;                  |	1=screen (absolute) - default value
;                  |	2=client-area (relative)
;                  $hWnd	- (optional) handle to window, if $iCmode=0 or 2.  If unavailable,
;                  |as in a MsgBox, function uses active window (default).  Needed for
;                  |position/dimensions.
; Return values..: Success:		- 1
;                  Failure		- 0
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: This function can use any style of co-ordinates, but accurate placement of
;                  the popup is impossible, as height/width of the popup are unknown.  Don't
;                  forget - co-ordinates are for TOP-CENTER of popup.  Normally the call to
;                  __HHocx would return a handle to the popup window, but it is not necessary
;                  to save this, as popups 'take care of themselves' and close when their focus
;                  is lost.  Text strings longer than 255 characters cannot be displayed.
; Related........: _PopupSetFont, _PopupSetWindow, _HHPopupResource
; Link...........: http://msdn.microsoft.com/en-us/library/ms670082(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHPopupText($sText, $iX, $iY, $iCmode = 1, $hWnd = $pNULL) ; use popup window - explicit text string
	Local $result
	_Coord2Abs($iX, $iY, $iCmode, $hWnd) ; convert co-ordinates, as necessary
	DllStructSetData($tHH_POPUP, "X", $iX) ; set position
	DllStructSetData($tHH_POPUP, "Y", $iY)
	DllStructSetData($tHH_POPUP, "idString", 0) ; signals explicit text string used
	DllStructSetData($tszText, 1, $sText)
	$result = __HHocx($pNULL, $pNULL, $HH_DISPLAY_TEXT_POPUP, $pHH_POPUP) ; parent not needed
	If VarGetType($result) = "Ptr" Then ; should be handle to popup window
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHPopupText


; #INTERNAL_USE_ONLY# ============================================================================
; _WinAPI_LoadLibraryEx is included here simply to avoid dependencies on other UDFs.
; Thanks to Paul Campbell (PaulIA) - see WinAPI.au3/_WinAPI_LoadLibraryEx for full docs.
; Function has been renamed ("HH" added) to avoid collisions if WinAPI.au3 is #included.
; ================================================================================================
Func _HHWinAPI_LoadLibraryEx($sFileName, $iFlags = 0)
	Local $aResult = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", $sFileName, _
			"ptr", 0, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_HHWinAPI_LoadLibraryEx


; #INTERNAL_USE_ONLY# ============================================================================
; _WinAPI_FreeLibrary is included here simply to avoid dependencies on other UDFs.
; Thanks to Paul Campbell (PaulIA) and jpm - see WinAPI.au3/_WinAPI_FreeLibrary for full docs.
; Function has been renamed ("HH" added) to avoid collisions if WinAPI.au3 is #included.
; ================================================================================================
Func _HHWinAPI_FreeLibrary($hModule)
	Local $aResult = DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hModule)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_HHWinAPI_FreeLibrary


; #FUNCTION# =====================================================================================
; Name...........: _HHPopupResource
; Description....: Displays text from a file's resources in a popup window
; Syntax.........: _HHPopupResource($sFile,$iIDNum,$iX,$iY[,$iCmode[,$hWnd]])
; Parameters.....: $sFile		- path to file (DLL, EXE) containing string resources
;                  $iIDNum		- ID number of the resource string
;                  |$iX			- X pos. for top-center of popup window
;                  |$iY			- Y pos. for top-center of popup window
;                  $iCmode		- (optional) co-ordinate mode (of $iX and $iY)
;                  |	0=window (relative)
;                  |	1=screen (absolute) - default value
;                  |	2=client-area (relative)
;                  $hWnd	- (optional) handle to window, if $iCmode=0 or 2.  If unavailable,
;                  |as in a MsgBox, function uses active window (default).  Needed for
;                  |position/dimensions.
; Return values..: Success:		- 1
;                  Failure		- 0
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: IDs for string resources inside DLLs and EXEs can be obtained using "Resource
;                  Hacker", by Angus Johnson.  Search for it on the Internet - the product
;                  (freeware) has been abandoned, but is still readily available on 'third
;                  party' sites.  _HHPopupResource can use resource strings even from programs or
;                  DLLs currently in use.  For example, strings from AutoIt3.exe may be used,
;                  even though the file is definitely in use (running script).  Resource strings
;                  longer than 255 characters cannot be displayed.
; Related........: _PopupSetFont, _PopupSetWindow, _HHPopupText
; Link...........: http://msdn.microsoft.com/en-us/library/ms670082(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHPopupResource($sFile, $iIDNum, $iX, $iY, $iCmode = 1, $hWnd = $pNULL)
	Local $result, $hFile
	Local Const $LOAD_LIBRARY_AS_DATAFILE = 0x02
	_Coord2Abs($iX, $iY, $iCmode, $hWnd) ; convert co-ordinates, as necessary
	$hFile = _HHWinAPI_LoadLibraryEx($sFile, $LOAD_LIBRARY_AS_DATAFILE) ; see function above
	DllStructSetData($tHH_POPUP, "hinst", $hFile) ; instance handle to file
	DllStructSetData($tHH_POPUP, "idString", $iIDNum)
	DllStructSetData($tHH_POPUP, "X", $iX) ; set position
	DllStructSetData($tHH_POPUP, "Y", $iY)
	$result = __HHocx($pNULL, $pNULL, $HH_DISPLAY_TEXT_POPUP, $pHH_POPUP) ; parent not needed
	_HHWinAPI_FreeLibrary($hFile) ; see function above
	If VarGetType($result) = "Ptr" Then ; should be handle to popup window
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHPopupResource


; #FUNCTION# =====================================================================================
; Name...........: _HHPopupID
; Description....: Displays text from a CHM file's embedded text file in a popup window
; Syntax.........: _HHPopupID($sChm_TextFile,$iIDNum,$iX,$iY[,$iCmode[,$hWnd]])
; Parameters.....: $sChm_TextFile	- 'path' to the textfile inside the CHM file,
;                  |eg. "C:Help\MyCHM::/topics.txt"
;                  $iIDNum			- ID number of the topic in the CHM's text file
;                  |$iX				- X pos. for top-center of popup window
;                  |$iY				- Y pos. for top-center of popup window
;                  $iCmode			- (optional) co-ordinate mode (of $iX and $iY)
;                  |	0=window (relative)
;                  |	1=screen (absolute) - default value
;                  |	2=client-area (relative)
;                  $hWnd			- (optional) handle to window, if $iCmode=0 or 2.
;                  |If unavailable, as in a MsgBox, function uses active window (default).
;                  |Needed for position/dimensions.
; Return values..: Success:		- 1
;                  Failure		- 0
; Author ........: Allen Titley (aka Geodetic)
; Modified.......:
; Remarks........: Popup topics in a CHM file are written into a text file, which is embedded
;                  into the CHM during compilation.  Each topic starts with ".topic ID" where
;                  ID is an integer.  During compilation, a text file (with identifiers) and a
;                  header file (MAP type) are used to map the identifiers to integers in the
;                  text file.
; Related........: _PopupSetFont, _PopupSetWindow, _HHPopupText
; Link...........: http://msdn.microsoft.com/en-us/library/ms670082(v=vs.85).aspx
; Example........: Yes
; ================================================================================================
Func _HHPopupID($sChm_TextFile, $iIDNum, $iX, $iY, $iCmode = 1, $hWnd = $pNULL)
	Local $result, $hFile
	_Coord2Abs($iX, $iY, $iCmode, $hWnd) ; convert co-ordinates, as necessary
	; Note: 'hinst' is supposed to be "ignored if idString is zero, or if idString specifies a file
	; name" - how can a UINT specify a file name?  Setting to null eliminates chance errors.
	DllStructSetData($tHH_POPUP, "hinst", $pNULL)
	DllStructSetData($tHH_POPUP, "idString", $iIDNum)
	DllStructSetData($tHH_POPUP, "X", $iX) ; set position
	DllStructSetData($tHH_POPUP, "Y", $iY)
	$result = __HHocx($pNULL, $sChm_TextFile, $HH_DISPLAY_TEXT_POPUP, $pHH_POPUP) ; parent not needed
	If VarGetType($result) = "Ptr" Then ; should be handle to popup window
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_HHPopupID

