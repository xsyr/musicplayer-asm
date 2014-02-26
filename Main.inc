IDC_TimerID EQU 1023      ;定时器ID 
IDC_TopMost EQU 1025     ;置顶菜单标识 
IDC_ABOUT EQU  1026     ;关于菜单 

IDM_PlayCurrentSelect EQU 12001
IDM_AddFiles EQU 12003
IDM_AddFolder EQU 12004
IDM_DELETE EQU 12002
IDM_CLEAR EQU 12005
IDM_CLOSE EQU 12006



HCONTROLS 		struct

hTRB_PROGRESS    	DWORD    ?
hLST_PLAYLIST    	DWORD    ?
hBTN_STOP    		DWORD    ?
hBTN_ABOVE    		DWORD    ?
hBTN_PLAY_PAUSE   	DWORD    ?
hBTN_NEXT    		DWORD    ?
hTRB_SETVOLUME    	DWORD    ?
hCHK_MUTE    		DWORD    ?
hBTN_OPENFILE    	DWORD    ?
hBTN_OPENFOLDER   	DWORD    ?
hSTC_REMAIN    		DWORD    ?
hSTC_CURRENT    	DWORD    ?
hTRB_SETBALANCE   	DWORD    ?
hIDC_UDN1    		DWORD    ?
	
HCONTROLS 		ends


FILESINFO 	struct
	
szFilePath   	Byte    256*MAX_PATH dup(?)
iCountOfFiles   DWORD    ? ; 歌曲数 

FILESINFO	ends

RANDOMNUMBERS struct 	; 用来存放随机数 

arrayNums	Byte   256 dup(?)
nNumsCount     	DWORD    ? ; 在产生随机数时用于记录当前已经产生的随机数个数；在用于随机播放时，记录当前前播放的arrayNums下标数 
RANDOMNUMBERS	ends



