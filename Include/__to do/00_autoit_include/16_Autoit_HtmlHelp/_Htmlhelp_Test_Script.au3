#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <Constants.au3>
#include <HtmlHelp.au3>



_HHOpen()


_HHOpenTopicByID("Audio Parser Help.chm",1)
ConsoleWrite("Error Step 1: " & @error & @LF)

Sleep(5000)
_HHOpenTopicByID("Audio Parser Help.chm",2)
ConsoleWrite("Error Step 2: " & @error & @LF)

Sleep(5000)

_HHCloseAll()


Sleep(5000)
_HHOpenTopicByID("Audio Parser Help.chm",0)
ConsoleWrite("Error Step 3: " & @error & @LF)

