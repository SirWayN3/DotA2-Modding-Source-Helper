

; Hier werden alle MsgBox Funktionen gebündelt.
; Als Return Value wird das Return Value der MsgBox genommen
; Workaround für MsgBox, die ein Fenster schließen und zum Gui1 zurückkehren
; Local als Return MsgBox benutzen, wenn ein Fenster gesperrt wird.

#cs;~ ; Return Value
   OK  1 
   CANCEL  2 
   ABORT  3 
   RETRY  4 
   IGNORE  5 
   YES  6 
   NO  7 
   TRY AGAIN ** 10 
   CONTINUE ** 11 
#ce << Return Value

#cs >> Flag Value
   0 OK button 0x0 
   1 OK and Cancel 0x1 
   2 Abort, Retry, and Ignore 0x2 
   3 Yes, No, and Cancel 0x3 
   4 Yes and No 0x4 
   5 Retry and Cancel 0x5 
   6 ** Cancel, Try Again, Continue 0x6 
   decimal flag Icon-related Result hexadecimal flag 
   0 (No icon) 0x0 
   16 Stop-sign icon 0x10 
   32 Question-mark icon 0x20 
   48 Exclamation-point icon 0x30 
   64 Information-sign icon consisting of an 'i' in a circle 0x40 
   decimal flag Default-related Result hexadecimal flag 
   0 First button is default button 0x0 
   256 Second button is default button 0x100 
   512 Third button is default button 0x200 
   decimal flag Modality-related Result hexadecimal flag 
   0 Application  0x0 
   4096 System modal (dialog has an icon) 0x1000 
   8192 Task modal 0x2000 
   decimal flag Miscellaneous-related Result hexadecimal flag 
   0 (nothing else special) 0x0 
   262144 MsgBox has top-most attribute set 0x40000 
   524288 title and text are right-justified 0x80000 
#ce << Flag Value


#cs Flag 		Title 		LanguageGetID
   32			Frage…		400
   64			Hinweis…	401
   64			Hilfe…		402
   16			Fehler…		403
   48			Warnung…	406



#ce

Func _ShowBox44(); Info über unterstützte Musikdateien in Playlist
   Return MsgBox(64,_LanguageGet(401),_LanguageGet(513) & $sPlaylistPattern,0,$hGui1)
EndFunc


Func _ShowBox43()
   Return MsgBox(4+48,_LanguageGet(406),_LanguageGet(512),0,$hGui11)
EndFunc


Func _ShowBox42(); Playlist Export erfolgreich
   Return MsgBox(64,_LanguageGet(401),_LanguageGet(511),0,$hGui11)
EndFunc


Func _ShowBox41(); Playlist leeren
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(510),0,$hGui11)
EndFunc


Func _ShowBox40(); Einstellungen Replace Comment zu groß (>29)
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(509),0,$hGui3)
EndFunc


Func _ShowBox39(); FilePlay Öffnen fehlerhaft
   Return MsgBox(64,_LanguageGet(401),_LanguageGet(508),0,$hGui1)
EndFunc


Func _ShowBox38(); Log Delete
   Return MsgBox(1+48+256,_LanguageGet(400),_LanguageGet(507),0,$hGui8)
EndFunc

Func _ShowBox37(); FirstSetup Skip
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(506),0,$hGui9)
EndFunc

Func _ShowBox36(); FirstSetup Cancel
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(505),0,$hGui9)
EndFunc


Func _ShowBox35()
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(502),0,$hGui1)
EndFunc


Func _ShowBox34($mode); Doppelte Datei Benutzerfehler
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(500) & $mode & _LanguageGet(501),0,$hGui4)
EndFunc


Func _ShowBox33(); Cover entfernen
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(490),0,$hGui1)
EndFunc


Func _ShowBox32(); Language Set
   Return MsgBox(64,_LanguageGet(400),_LanguageGet(496),0,$hGui1)
EndFunc


Func _ShowBox31(); CheckRunFolder Fehler, Datei liegt auf dem Desktop
   Return MsgBox(48+1,_LanguageGet(406) & " - " & $sScriptName,_LanguageGet(495))
EndFunc


Func _ShowBox30($mode); Language Datei
   If $mode = 1 Then Return MsgBox(48,"Error....","I could not find any Language File. Labels are wrong or completely missing!" & @CRLF & @CRLF & "This Program will exit now. Please send a message to the Author: " & $sScriptAuthor)
   If $mode = 2 Then Return MsgBox(48,"Error....","An error occured while reading the Language File. Labels might be wrong or are completely missing!")
EndFunc


Func _ShowBox29(); Programm wird doppelt ausgeführt, SingleInstance
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(494))
EndFunc

Func _ShowBox28($i); Fehler Sortierung Ini
   ; $i für errorlevel
   ; 0 = ID3V1 Tag ausgewählt, ID3V2 Tags verwendet
   ; _LanguageGet(484-493)
   GuiSetState(@SW_DISABLE,$hGui3)
   Local $s
   If $i = 1 Then $s = _LanguageGet(485)
   If $i = 2 Then $s = _LanguageGet(486)
   If $i = 3 Then $s = _LanguageGet(487)
   If $i = 4 Then $s = _LanguageGet(488)
   If $i = 5 Then $s = _LanguageGet(489)
   $i = MsgBox(16,_LanguageGet(403),_LanguageGet(484) & $s,0,$hGui1)
   GuiSetState(@SW_ENABLE,$hGui3)
   Return $i
EndFunc

Func _ShowBox27(); Speicher Warnung ausgeben
   Return MsgBox(48,_LanguageGet(406),_LanguageGet(483),"",$hGui1)
EndFunc


Func _ShowBox26(); Speicher Alarm ausgeben
  Return MsgBox(16,_LanguageGet(403),_LanguageGet(482),"",$hGui1)
EndFunc


Func _ShowBox25(); Intro zeigen bei FirstRun
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(481),"",$hGui1)
EndFunc

Func _ShowBox24(); Cover löschen 
   Return MsgBox(4+256+48,_LanguageGet(400),_LanguageGet(480),"",$hGui1)
EndFunc


Func _ShowBox23($i); Double Folder Fehler
   ; index für Fehler in den Doppelten Ordner anzeige
   ; 1 = falscher CurrentFolder
   ; 2 = falscher Zielordner
   Switch $i
   Case 1
	  $s = _LanguageGet(477)
   Case 2
	  $s = _LanguageGet(478)
   Case 3
	  $s = _LanguageGet(479)
   EndSwitch
   GuiSetState(@SW_DISABLE,$hGui3)
   $i = MsgBox(16,_LanguageGet(403),_LanguageGet(475) & $s & _LanguageGet(476),"",$hGui1)
   GuiSetState(@SW_ENABLE,$hGui3)
   Return $i
EndFunc

Func _ShowBox22(); Menu Item bearbeitung abbrechen
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(474),"",$hGui1)
EndFunc

Func _ShowBox21(); Show Intro Info
   Return MsgBox(4+32,_LanguageGet(400),_LanguageGet(473),"",$hGui1)
EndFunc

Func _ShowBox20(); To Do Liste
   Return MsgBox(64,_LanguageGet(407),_LanguageGet(472),"",$hGui1)
EndFunc

Func _ShowBox19(); Größere Datei überprüfen hat einen Fehler
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(471),"",$hGui1)
EndFunc

Func _ShowBox18(); Einstellung reminder
   GuiSetState(@SW_DISABLE,$hGui3)
   Local $i = MsgBox(4+32,_LanguageGet(400),_LanguageGet(470),0,$hGui1)
   GuiSetState(@SW_ENABLE,$hGui3)
   Return $i
EndFunc

Func _ShowBox17(); Fehler bei dem CombineTags
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(469),0,$hGui1)
EndFunc

Func _ShowBox16(); Dateiname existiert bei Bearbeitung nicht mehr
   Return MsgBox(4+16+256,_LanguageGet(403),_LanguageGet(468),0,$hGui1)
EndFunc

Func _ShowBox15(); Dateiname existiert bereits, beim abspeichern
   Return MsgBox(4+16+256,_LanguageGet(403),_LanguageGet(467),0,$hGui1)
EndFunc

Func _ShowBox14($i); Fehler Edit Felder sind nicht komplett ausgefüllt
   ; zusätzliche Information in GuiSetInfo(15)
   ; durch CheckSortingSave verwendet
   ; _LanguageGet(457-466)
   Local $s
   Switch $i 
   Case -7
	  $s = _LanguageGet(466)
   Case -6; $cEdit6 hat Fehler > 65535, Jahr zu groß
	  $s = _LanguageGet(458)
   Case -4; $cEdit4 hat Fehler > 255, Track zu groß
	  $s = _LanguageGet(459)
   Case -3
	  $s = _LanguageGet(465)
   Case -2
	  $s = _LanguageGet(464)
   Case -1
	  $s = _LanguageGet(463)
   Case 1; Das Feld ist leer
	  $s = _LanguageGet(460)
   Case 2; unerlaubtes Zeichen benutzt
	  $s = _LanguageGet(461)
   Case 3; kein \ am Ende
	  $s = _LanguageGet(462)
   Case 4; ID3V2 Tags in ID3V1 sortierung
	  ; nicht verwendet
   Case 5; Keine Kürzel in Sortierung gefunden
	  ; nicht verwendet
   EndSwitch
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(457) & $s,0,$hGui1)
EndFunc

Func _ShowBox13($i); Fehler bei Abspeichern der Dateien
   ; $i für ErrorLevel aus SaveFile()
   ; LanguageGet(452-456)
   Switch $i
   Case 1
	  Return MsgBox(48,"Fehler...",_LanguageGet(452),0,$hGui1)
   Case 2
	  Return MsgBox(48,"Fehler...",_LanguageGet(453),0,$hGui1)
   Case 3
	  Return MsgBox(48,"Fehler...",_LanguageGet(454),0,$hGui1)
  EndSwitch
EndFunc

Func _ShowBox12(); Folder Index erstellen erfolgreich, Datei öffnen
   Return MsgBox(4+32,_LanguageGet(400),_LanguageGet(451),0,$hGui1)
EndFunc

Func _ShowBox11(); Fehler auslesen  Dateien, keine Dateien gefunden
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(450),0,$hGui2)
EndFunc

Func _ShowBox10($i); Fehler Sortierung Einstellungen
   ; $i für errorlevel
   ; 0 = ID3V1 Tag ausgewählt, ID3V2 Tags verwendet
   ; LanguageGet(440-449)
   GuiSetState(@SW_DISABLE,$hGui3)
   GuiSetState(@SW_DISABLE,$hGui9)
   Local $s
   If $i = 1 Then $s = _LanguageGet(440)
   If $i = 2 Then $s = _LanguageGet(441)
   If $i = 3 Then $s = _LanguageGet(442)
   If $i = 4 Then $s = _LanguageGet(443)
   If $i = 5 Then $s = _LanguageGet(444)
   $i = MsgBox(16,_LanguageGet(403),_LanguageGet(439) & $s,0,$hGui1)
   GuiSetState(@SW_ENABLE,$hGui3)
   GuiSetState(@SW_ENABLE,$hGui9)
   Return $i
EndFunc

Func _ShowBox9(); Einstellungen schließen
   GuiSetState(@SW_DISABLE,$hGui3)
   Local $s = MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(438),0,$hGui1)
   GuiSetState(@SW_ENABLE,$hGui3)
   Return $s
EndFunc

Func _ShowBox8(); Programm beenden
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(437),0,$hGui1)
EndFunc

Func _ShowBox7(); Fehlender Zielordner vor dem abspeichern
   Return MsgBox(16,_LanguageGet(403),_LanguageGet(436),"",$hGui1)
EndFunc

Func _ShowBox6(); Select Folder überschreiben
   Return MsgBox(4+32+256,_LanguageGet(400),_LanguageGet(435),"",$hGui1)
EndFunc

Func _ShowBox5(); Help / About
   Return MsgBox(64,_LanguageGet(402),_LanguageGet(434),"",$hGui1)
EndFunc

Func _ShowBox4(); _NextFile
   Return MsgBox(0,_LanguageGet(401),_LanguageGet(433),"",$hGui1)
EndFunc

Func _ShowBox3(); Credits
   Return MsgBox(64,_LanguageGet(404),_LanguageGet(432),"",$hGui1)
EndFunc

;~ 		 "Danke an 'joeyb1275' von AutoIt für das Auslesen der ID3 Tags." & @CRLF & @CRLF & _
;~ 		 "Danke an 'Oscar' von AutoIt für das Auslesen der ID3 Header." & @CRLF & @CRLF & _
Func _ShowBox2(); Update Funktion
   Return MsgBox(4+32,$sScriptName & " - " & _LanguageGet(405),_LanguageGet(431))
EndFunc

Func _ShowBox1(); Update Funktion
   Return MsgBox(48,_LanguageGet(406),_LanguageGet(430),"",$hGui1)
EndFunc

