


#include <Job_List/Job_List_Add.au3>
#include <Job_List/Job_List_Save.au3>
#include <Job_List/Job_List_Load.au3>
#include <Job_List/Job_List_Check.au3>



Global $iJobListCount = 0;	Anzahl der Jobs

Global $iJobListIndex = 0; 	Index der Job List
Global $aJobListInf[8][2] = [["ID"],["Ersteller"],["Titel"],["Beschreibung"],["Datum"],["Est.Time"],["Parameter1"],["Parameter2"]] _
;		Array für Informationen des Aktuellen Jobs


