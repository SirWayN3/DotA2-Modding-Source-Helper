#Include "GUIConstants.au3"
$Winmain = GUICreate("MySpy 0.21", 200, 300, -1, -1, -1, $WS_EX_TOPMOST)
GUISetIcon("..Res\AutoItMacroGenerator2.ico", 0)
$Edit1 = GUICtrlCreateEdit("", 5, 5, 190, 290, $ES_WANTRETURN + $ES_READONLY)

$Quit = 0
GUISetState()
Do
    $Msg = GUIGetMsg(1)
    $Mouse = MouseGetPos()
    $mySpy = DllOpen("MySpy021.dll")
    $PHWND = DllCall($mySpy, "hwnd", "AMG_GetPHWND", "long", $Mouse[0], "long", $Mouse[1])
    $HWND = DllCall($mySpy, "hwnd", "AMG_GetHWND", "long", $Mouse[0], "long", $Mouse[1])
    $Classname = DllCall($mySpy, "str", "AMG_GetClassname", "long", $Mouse[0], "long", $Mouse[1])
    $ClassCount = DllCall($mySpy, "long", "AMG_GetClassCount", "long", $Mouse[0], "long", $Mouse[1])
    $WinTitle = DllCall($mySpy, "str", "AMG_GetWinTitle", "long", $Mouse[0], "long", $Mouse[1])
    $WinText = DllCall($mySpy, "str", "AMG_GetWinText", "long", $Mouse[0], "long", $Mouse[1])
    $WinClass = DllCall($mySpy, "str", "AMG_GetWinClass", "long", $Mouse[0], "long", $Mouse[1])
    DllClose($mySpy)
    $data = $PHWND[0] & @CRLF & $HWND[0] & @CRLF & $Classname[0] & @CRLF & $ClassCount[0] & @CRLF & $WinTitle[0] & @CRLF & $WinText[0] & @CRLF & $WinClass[0]
    GUICtrlSetData($Edit1, $data)
    Select
        Case $Msg[0] = $GUI_EVENT_CLOSE And $Msg[1] = $Winmain
            $Quit = 1
    EndSelect


Until $Quit = 1