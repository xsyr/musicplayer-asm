UNICODE=0
DEBUG=1

if UNICODE
	TCHAR typedef WORD
ELSE
	TCHAR typedef byte
ENDIF


include Player_Core.inc

includelib Player_Core.lib


.const
	szAbout TCHAR '关于',0
	PlayMode TCHAR '播放模式',0
	Transparent TCHAR '透明度',0
	Rate TCHAR '播放速率',0
	szTopMost TCHAR '总在最前',0

	
	szPlay TCHAR '播放',0
	szAddFiles TCHAR '添加文件',0
	szAddFolder TCHAR '添加文件夹',0
	szDelete TCHAR '删除',0
	szClear TCHAR '清空列表',0
	
	szformat TCHAR '%d',0

	szNoExistError byte '文件不存在或不支持此格式，请安装完美解码',0
	
	initString byte '00:00',0
	
	szexit byte '退出',0
	
	
	
.code
include Functions.asm
include DrawUI.asm

Main_OnInitDialog PROTO hwnd:HWND
Main_OnCommand proto	hwnd:HWND,id:DWORD,hwndCtl:DWORD,codeNotify:DWORD
TimerProc proto hwnd:DWORD,uMsg:DWORD,idEvent:DWORD,dwTime:DWORD
Main_OnClose proto hwnd:HWND
Form1_OnHScroll proto  hwnd:HWND,  hwndCtl:HWND,  code:UINT,pos:DWORD
ResetControls proto  hdlg:HWND
SetDialogText proto hdlg:HWND
GetVolumeSate proto


RGB MACRO r,g,b
	xor eax,eax
	mov eax,b
	shl eax,16
	mov ah,g
	mov al,r
endm
; ---------------------------------------------------------------------------
_ProcDlgMain proc uses ebx edi esi hWnd:DWORD,wMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	LOCAL points:POINT
	LOCAL nTopIndex:DWORD
	
	LOCAL hwinDC:HDC,hDCMem:HDC,rcwindow:RECT,hBitmap:HBITMAP
	
	mov eax,wMsg
	.if eax == WM_CLOSE
		invoke Main_OnClose,hWnd
		
	.elseif eax == WM_NOTIFY
		invoke OnNotify,hWnd,wParam,lParam
		ret
		
	.elseif eax == WM_INITDIALOG
		invoke Main_OnInitDialog,hWnd
		ret
	.elseif eax == WM_HSCROLL
		mov	eax,wParam
		movzx	ebx,ax
		shr	eax,16
		invoke Form1_OnHScroll,hWnd,lParam,ebx,eax
		
	.elseif eax == WM_VSCROLL
		mov	eax,lParam
		.if	eax==g_hCtl.hTRB_SETVOLUME
			invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_GETPOS,0,0
			mov	ecx,-10
			mul	ecx
			push	eax
			call	lpSetPlayerVolume
		.endif
		
		
	
	.elseif eax == WM_COMMAND
		mov eax,wParam
		movzx edi,ax
		shr eax,16
		movzx esi,ax
		invoke Main_OnCommand,hWnd,edi,lParam,esi
		
	.elseif	eax == WM_VKEYTOITEM
		invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
		push	eax
		invoke SetWindowLong,hWnd, DWL_MSGRESULT, eax
		mov	ebx,wParam
		.if	bx == VK_DELETE
			xor 	eax,eax
			mov ax,IDM_DELETE
			invoke SendMessage,hWnd,WM_COMMAND,eax,0
		.endif
		pop	eax
		ret
		
	.elseif	eax == WM_RBUTTONDOWN

		xor edi,edi
		xor esi,esi
		mov eax,lParam
		mov di,ax
		mov points.x,edi
		shr eax,16
		mov si,ax
		mov points.y,esi
		invoke ClientToScreen,hWnd,addr points
		invoke TrackPopupMenuEx,g_hmenu,0,points.x,points.y,hWnd,NULL
		mov eax,TRUE
		ret
		
	.elseif eax ==WM_CONTEXTMENU
		mov eax,wParam
		.if	eax == g_hCtl.hLST_PLAYLIST
			mov eax,lParam
			movzx ebx,ax 
			mov points.x,ebx ;GET_X_LPARAM
			shr eax,16
			movzx ebx,ax 
			mov points.y,ebx ;GET_Y_LPARAM
			
			invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETTOPINDEX,0,0
			mov nTopIndex,eax
			invoke ScreenToClient,g_hCtl.hLST_PLAYLIST,addr points
			
			xor edx,edx ; edx=points.y mod 17
			mov eax,points.y
			mov ecx,17
			div ecx
			add eax,nTopIndex ; edx =edx+nTopIndex
			invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_SETCURSEL,eax,0
			
			xor eax,eax
			.if	eax==filesinfo.iCountOfFiles
				invoke DisableControls
			.endif
			
			mov eax,lParam
			movzx ebx,ax 
			shr eax,16
			movzx ecx,ax
			invoke TrackPopupMenuEx,g_hPlayList_Menu,0, ; 0=TPM_LEFTALIGN|TPM_TOPALIGN
					ebx,ecx,hWnd,NULL
		.endif
		
		mov eax,TRUE
		ret
		; end elseif eax ==WM_CONTEXTMENU
		
	.elseif	eax==WM_DROPFILES
		invoke AddDropFilesToList,wParam,hWnd
		mov	eax,TRUE
		ret
		
	.elseif eax == WM_SIZE
		mov	eax,SIZE_MINIMIZED
		.if	eax == wParam
			invoke ShowWindow,hWnd,SW_HIDE
		.endif
		mov	eax,TRUE
		ret
	.elseif eax == WM_ERASEBKGND
		invoke GetClientRect,hWnd,addr rcwindow
		mov	eax,wParam
		mov	hwinDC,eax
		invoke CreateCompatibleDC,hwinDC
		mov	hDCMem,eax
		invoke LoadBitmap,hInstance,IDC_BGPIC
		mov	hBitmap,eax
		invoke SelectObject,hDCMem,hBitmap
		invoke BitBlt,hwinDC, 0, 0, rcwindow.right, rcwindow.bottom, 
			    			hDCMem, 0, 0, SRCCOPY
		invoke DeleteObject,hBitmap
		invoke DeleteDC,hDCMem
		invoke ReleaseDC,hWnd,hwinDC
		mov	eax,TRUE
		ret
	
	.elseif eax == WM_DRAWITEM
		invoke OnDrawItem,hWnd,lParam
		mov eax,TRUE
		ret
		
	.elseif eax == WM_ACTIVATE
		invoke GetMenuState,g_hmenu,IDM_OpaqueWhenActive,MF_BYCOMMAND
		.if	eax==MF_CHECKED
			mov	eax,wParam
			movzx	ebx,ax
			shr	eax,16
			movzx	ecx,ax
			.if	ebx==WA_INACTIVE && ecx==0
				mov	eax,g_CURTRPSelected
				and		eax,0000ffffH
				invoke PostMessage,hWnd,WM_COMMAND,eax,0
			.else
				RGB 100,100,100
				invoke SetLayeredWindowAttributes,hWnd,eax,255,LWA_ALPHA
			.endif
		.endif
		xor	eax,eax
		ret
		
	.else
		mov eax,FALSE
		ret
	.endif
		

	mov eax,TRUE
	ret
	

_ProcDlgMain endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Main_OnInitDialog PROC hwnd:HWND
	
	LOCAL sMIInfo:MENUITEMINFO
	LOCAL buff[256]:TCHAR
	
	invoke GetWindowLong,hwnd,GWL_HINSTANCE
	invoke LoadIcon,eax,IDC_ICON1
	push eax ; 保存返回值
	invoke SendMessage,hwnd,WM_SETICON,ICON_BIG,eax
	pop eax
	invoke SendMessage,hwnd,WM_SETICON,ICON_SMALL,eax
	
	invoke GetControlsHandle,hwnd
	invoke InitiateControls
	invoke Initiate_PlayCore,hwnd
	invoke Initiate_CRT
	invoke AddNodifyIcon,hwnd
	
	invoke SetWindowLong,g_hCtl.hBTN_STOP, GWLP_WNDPROC,newBtnStopProc
	mov	lpBtnStopOrigProc,eax
	
	invoke SetWindowLong,g_hCtl.hBTN_PLAY_PAUSE, GWLP_WNDPROC, newBtnPlayPauseProc
	mov	lpBtnPlayPauseOrigProc,eax
	
	invoke SetWindowLong,g_hCtl.hBTN_NEXT, GWLP_WNDPROC,newBtnNextProc
	mov	lpBtnNextOrigProc,eax
	
	invoke SetWindowLong,g_hCtl.hBTN_ABOVE, GWLP_WNDPROC,newBtnAboveProc
	mov	lpBtnAboveOrigProc,eax
	
	
;	; 要使用透明效果，必须修改窗口属性
	invoke SetWindowLong,hwnd,GWL_EXSTYLE,WS_EX_LAYERED
	RGB 100,100,100
	invoke SetLayeredWindowAttributes,hwnd,eax,255,LWA_ALPHA
;	
;	; 创建窗体菜单
	invoke CreatePopupMenu
	mov g_hmenu,eax
	invoke LoadMenu,hInstance,IDR_PlayMode
	invoke AppendMenu,g_hmenu,10H,eax,offset PlayMode ;0x00000010L=MF_POPUP|MF_STRING
	
	invoke LoadMenu,hInstance,IDR_Transparent
	invoke AppendMenu,g_hmenu,10H,eax,offset Transparent ;0x00000010L=MF_POPUP|MF_STRING
	
	invoke LoadMenu,hInstance,IDR_Rate
	invoke AppendMenu,g_hmenu,10H,eax,offset Rate ;0x00000010L=MF_POPUP|MF_STRING
;	
;	; 添加菜单项
;	
	mov sMIInfo.cbSize,sizeof MENUITEMINFO
	mov sMIInfo.fMask,42H ; 42H=MIIM_ID|MIIM_STRING
	mov sMIInfo.wID,IDC_TopMost
	mov sMIInfo.dwTypeData,offset szTopMost
	mov sMIInfo.cch,4
	invoke InsertMenuItem,g_hmenu,3,TRUE,addr sMIInfo
	invoke AppendMenu,g_hmenu,MF_STRING,IDC_ABOUT,offset szAbout
	; 创建管理列表的菜单
	invoke CreatePopupMenu
	mov g_hPlayList_Menu,eax
	invoke AppendMenu,g_hPlayList_Menu,MF_STRING,IDM_PlayCurrentSelect,offset szPlay
	invoke AppendMenu,g_hPlayList_Menu,MF_STRING,IDM_AddFiles,offset szAddFiles
	invoke AppendMenu,g_hPlayList_Menu,MF_STRING,IDM_AddFolder,offset szAddFolder
	invoke AppendMenu,g_hPlayList_Menu,MF_STRING,IDM_DELETE,offset szDelete
	invoke AppendMenu,g_hPlayList_Menu,MF_STRING,IDM_CLEAR,offset szClear
	
	; 初始化菜单，设置菜单默认选项
	invoke GetSubMenu,g_hmenu,0
	invoke CheckMenuRadioItem,eax,IDM_Random,IDM_SingleLoop,IDM_Sortorder,MF_BYCOMMAND
	invoke GetSubMenu,g_hmenu,1
	invoke CheckMenuRadioItem,eax,IDM_Opaque,IDM_P90,IDM_Opaque,MF_BYCOMMAND
	invoke GetSubMenu,g_hmenu,2
	invoke CheckMenuRadioItem,eax,IDM_Half,IDM_Twice,IDM_Nomal,MF_BYCOMMAND

	
	;加载播放列表
	invoke LoadPlayList
	.if	eax
		invoke AddFilesNameToPlayList,filesinfo.iCountOfFiles
	.endif
	.if(filesinfo.iCountOfFiles==0)
		invoke DisableControls
	.endif
	invoke DragAcceptFiles,hwnd,TRUE
	

	
	mov eax,TRUE
	ret 
Main_OnInitDialog endp


PlaySpecifySong proto :HWND,:DWORD

Main_OnCommand proc	hwnd:HWND,id:DWORD,hwndCtl:DWORD,codeNotify:DWORD
	
	LOCAL nCurrentSelected:DWORD,rclickpoint:POINT,oafs:DWORD
	
	mov eax,id
	;////////////////处理播放列表菜单的命令///////
	
	.if	eax==IDM_AddFiles
		invoke AddFiles,hwnd
		xor eax,eax
		.if	filesinfo.iCountOfFiles != eax
			invoke EnableControls
			invoke GetrandomNumbers;获取随机播放顺序
		.endif
		
	.elseif eax== IDM_AddFolder	
		invoke AddFolder,hwnd
		xor eax,eax
		.if	filesinfo.iCountOfFiles != eax
			invoke EnableControls
			invoke GetrandomNumbers;获取随机播放顺序
		.endif
		
	.elseif eax== IDC_ABOUT
		invoke DialogBoxParam,hInstance,IDD_DLGABOUT,NULL,offset Main_AboutProc,NULL
	
	.elseif	eax == IDM_PlayCurrentSelect
		invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
		mov	g_currentPlayIndex,eax
		invoke PlaySpecifySong,hwnd,eax
	
	.elseif	eax == IDM_DELETE
		invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
		mov	nCurrentSelected,eax
		invoke	DeleteItem,eax
		.if	(filesinfo.iCountOfFiles==0)
			call	lpStop_Music
			invoke DisableControls
		.else
			mov	eax,g_currentPlayIndex
			.if	(eax==nCurrentSelected)
				call	lpStop_Music
				mov	g_bIsPlaying ,FALSE
				invoke ResetControls,hwnd
			.elseif (eax>nCurrentSelected)
				dec	g_currentPlayIndex
				invoke	SetDialogText,hwnd
			.endif
		.endif
	
	.elseif	eax == IDM_CLEAR
		call	lpStop_Music
		mov	g_bIsPlaying ,FALSE
		invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_RESETCONTENT,0,0
		invoke RtlZeroMemory,addr filesinfo,sizeof FILESINFO
		invoke SendMessage,g_hCtl.hTRB_PROGRESS,TBM_SETPOS,TRUE,0
		invoke DisableControls
	
	.elseif	eax == IDC_LST_PLAYLIST
		mov	eax,LBN_DBLCLK
		.if	codeNotify == eax
			invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
			mov	g_currentPlayIndex,eax
			invoke PlaySpecifySong,hwnd,eax
		.endif
		
	;>>>>>>>>>>>>>>>>处理图标消息>>>>>>>>>>>>>
	.elseif	eax == IDC_NODIFYICON	
		.if	hwndCtl==WM_LBUTTONDOWN
			.if	isWinVisible
				invoke ShowWindow,hwnd,SW_HIDE
				mov	isWinVisible,FALSE
			.else
				invoke ShowWindow,hwnd,SW_SHOWNORMAL
	         invoke SetForegroundWindow,hwnd
	         mov	isWinVisible,TRUE;
			.endif
			
		.elseif	hwndCtl==WM_RBUTTONDOWN
			invoke ShowWindow,hwnd,SW_SHOWNORMAL
			invoke SetForegroundWindow,hwnd
			mov	isWinVisible,TRUE
			invoke GetCursorPos,addr rclickpoint
			invoke AppendMenu,g_hmenu,MF_STRING,IDM_CLOSE,offset szexit
			invoke TrackPopupMenuEx,g_hmenu,0,rclickpoint.x,rclickpoint.y,hwnd,NULL
			invoke DeleteMenu,g_hmenu,IDM_CLOSE,MF_BYCOMMAND
		.endif
	
	.elseif	eax == IDM_CLOSE
		invoke SendMessage,hwnd,WM_CLOSE,0,0
	
	;>>>>>>>>>>>>>>>>>>>>>控制按钮命令>>>>>>>>>
	.elseif	eax == IDC_BTN_STOP
		call	lpStop_Music
		mov	g_bIsPlaying ,FALSE
		invoke ResetControls,hwnd
	
	.elseif	eax == IDC_BTN_PLAY_PAUSE
		lea	eax,oafs
		push	eax
		call	lpGetCurrentState
		
		.if	oafs==2 ;State_Running
			call	lpPause_Music
			mov	g_bIsPlaying ,FALSE
			
		.elseif	oafs==1;State_Paused
			call	lpPlay_Music
			mov	g_bIsPlaying ,TRUE
			
		.else
			invoke PlaySpecifySong,hwnd,0
			
		.endif
		
	.elseif	eax == IDC_BTN_NEXT
		invoke ResetControls,hwnd
		invoke GetNextPlayIndex,g_CURPMSelected,g_currentPlayIndex
		mov	g_currentPlayIndex,eax
		.if	eax!=-1
			invoke PlaySpecifySong,hwnd,eax
			
		.else
			call	lpStop_Music
			mov	g_bIsPlaying,FALSE
			
		.endif
	
	.elseif	eax == IDC_BTN_ABOVE
		invoke ResetControls,hwnd
		invoke GetAbovePlayIndex,g_CURPMSelected,g_currentPlayIndex
		mov	g_currentPlayIndex,eax
		.if	eax!=-1
			invoke PlaySpecifySong,hwnd,eax
			
		.else
			call	lpStop_Music
			mov	g_bIsPlaying,FALSE
			
		.endif
		
	.elseif	eax == IDC_CHK_MUTE	
		invoke GetVolumeSate
		
	.elseif	eax == IDC_TopMost
		invoke GetMenuState,g_hmenu,IDC_TopMost,MF_BYCOMMAND
		.if	eax==MF_CHECKED
			invoke CheckMenuItem,g_hmenu,IDC_TopMost,0 ; MF_BYCOMMAND|MF_UNCHECKED=0
			invoke SetWindowPos,hwnd,HWND_NOTOPMOST,0,0,0,0,03H ; SWP_NOMOVE|SWP_NOSIZE=03H
		.else
			invoke CheckMenuItem,g_hmenu,IDC_TopMost,08H ; MF_BYCOMMAND|MF_CHECKED
			invoke SetWindowPos,hwnd,HWND_TOPMOST,0,0,0,0,03H ; SWP_NOMOVE|SWP_NOSIZE=03H
		.endif
		
	;//////////////设置播放模式菜单//////////////////
	.elseif	eax == IDM_Random
		invoke SetPlayModeMenu,IDM_Random
		invoke GetrandomNumbers
		
	.elseif	eax == IDM_Sortorder
		invoke SetPlayModeMenu,IDM_Sortorder
		
	.elseif	eax == IDM_Loop
		invoke SetPlayModeMenu,IDM_Loop
		
	.elseif	eax == IDM_Single
		invoke SetPlayModeMenu,IDM_Single	
		
	.elseif	eax == IDM_SingleLoop
		invoke SetPlayModeMenu,IDM_SingleLoop	
	;//////////////设置透明度菜单////////////////
	.elseif	eax == IDM_P10
		invoke SetTransparentMune,IDM_P10
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,230,LWA_ALPHA ; RGB(100,100,100)=0646464H
		
	.elseif	eax == IDM_P20
		invoke SetTransparentMune,IDM_P20
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,204,LWA_ALPHA 
		
	.elseif	eax == IDM_P30
		invoke SetTransparentMune,IDM_P30
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,179,LWA_ALPHA 	
		
	.elseif	eax == IDM_P40
		invoke SetTransparentMune,IDM_P40
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,153,LWA_ALPHA 	
		
	.elseif	eax == IDM_P50
		invoke SetTransparentMune,IDM_P50
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,128,LWA_ALPHA 		
		
	.elseif	eax == IDM_P60
		invoke SetTransparentMune,IDM_P60
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,102,LWA_ALPHA 	
		
	.elseif	eax == IDM_P70
		invoke SetTransparentMune,IDM_P70
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,77,LWA_ALPHA 		
		
	.elseif	eax == IDM_P80
		invoke SetTransparentMune,IDM_P80
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,51,LWA_ALPHA 	
		
	.elseif	eax == IDM_P90
		invoke SetTransparentMune,IDM_P90
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,20,LWA_ALPHA 	
		
	.elseif	eax == IDM_Opaque
		invoke SetTransparentMune,IDM_Opaque
		invoke	SetLayeredWindowAttributes,hwnd,0646464H,255,LWA_ALPHA 		
		
		
	.elseif	eax == IDM_OpaqueWhenActive
		invoke GetMenuState,g_hmenu,IDM_OpaqueWhenActive,0 ; MF_BYCOMMAN
		.if	eax==MF_CHECKED
			mov	eax,g_CURTRPSelected
			and	eax,0000FFFFH
			invoke SendMessage,hwnd,WM_COMMAND,eax,0
			invoke CheckMenuItem,g_hmenu,IDM_OpaqueWhenActive,0 ; MF_BYCOMMAND|MF_UNCHECKED
		.else
			invoke CheckMenuItem,g_hmenu,IDM_OpaqueWhenActive,08H ; MF_BYCOMMAND|MF_CHECKED
			invoke SetLayeredWindowAttributes,hwnd,0646464H,255,LWA_ALPHA
		.endif
		
	;///////////////设置播放速率//////////////
	
	.elseif	eax == IDM_Half
		sub   esp,8
		fld   half
		fstp	qword ptr [esp]
		call	lpSetMusicRate
		add	esp,8
		invoke GetSubMenu,g_hmenu,2
		invoke CheckMenuRadioItem,eax,IDM_Half,IDM_Twice,IDM_Half,MF_BYCOMMAND
	
	.elseif	eax == IDM_Nomal
		sub   esp,8
		fld   one
		fstp	qword ptr [esp]
		call	lpSetMusicRate
		add	esp,8
		invoke GetSubMenu,g_hmenu,2
		invoke CheckMenuRadioItem,eax,IDM_Half,IDM_Twice,IDM_Nomal,MF_BYCOMMAND
	
	.elseif	eax == IDM_Twice
		sub   esp,8
		fld   two
		fstp	qword ptr [esp]
		call	lpSetMusicRate
		add	esp,8
		invoke GetSubMenu,g_hmenu,2
		invoke CheckMenuRadioItem,eax,IDM_Half,IDM_Twice,IDM_Twice,MF_BYCOMMAND
			
	.endif
	
	ret

Main_OnCommand endp

SetDialogText proc hdlg:HWND
	
	LOCAL szCurrentText[MAX_PATH]:byte
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETTEXT,g_currentPlayIndex,addr szCurrentText
	invoke StringCchCopy,addr AppNodifyIcon.szTip,128,addr szCurrentText
	mov	AppNodifyIcon.uFlags,7H ;=NIF_ICON|NIF_MESSAGE|NIF_TIP=7H
	invoke Shell_NotifyIcon,NIM_MODIFY,addr AppNodifyIcon
	
	ret

SetDialogText endp

GetVolumeSate proc
	
	push	ebp
	mov	ebp,esp
	
	push	0
	push	0
	push	0F0H
	push	dword ptr [g_hCtl.hCHK_MUTE]
	call	SendMessage
;	invoke SendMessage,g_hCtl.hCHK_MUTE,BM_GETCHECK,0,0
	.if	eax==BST_CHECKED
		push	-10000
		call	lpSetPlayerVolume
	.elseif	eax==BST_UNCHECKED
		invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_GETPOS,0,0
		mov	ecx,-10
		mul	ecx
		push	eax
		call	lpSetPlayerVolume
	.endif
	leave
;	pop	ebp
	ret

GetVolumeSate endp

PlaySpecifySong proc hDlg:DWORD,song_index:DWORD
	
	LOCAL hr:DWORD,nSongLen:DWORD
	
	invoke SetDialogText,hDlg
	call	lpStop_Music
	mov	g_bIsPlaying,FALSE
	mov 	ebx,offset filesinfo.szFilePath ; filesinfo->szFilePath[loop]
	mov 	eax,song_index
	mov 	ecx,MAX_PATH
	mul 	ecx
	add 	ebx,eax
	
	push	ebx
	call	lpSpecifyMusicFileA
	mov	hr,eax
	.if	eax!=S_OK
		invoke MessageBox,hDlg,offset szNoExistError,NULL,MB_OK
		ret
	.endif
	
	invoke SetTimer,hDlg,IDC_TimerID,1000,TimerProc
	call lpPlay_Music
	invoke EnableWindow,g_hCtl.hTRB_PROGRESS,TRUE
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_SETCURSEL,song_index,0
	lea	eax,nSongLen
	push	eax
	call	lpGet_Length
	mov	ebx,nSongLen
	shl	ebx,16
	xor	bx,bx
	invoke SendMessage,g_hCtl.hTRB_PROGRESS,TBM_SETRANGE,TRUE,ebx
	invoke GetVolumeSate
	mov	g_bIsPlaying,TRUE
	
	ret

PlaySpecifySong endp

ResetControls proc  hdlg:HWND

	invoke SendMessage,hdlg,TBM_SETPOS,TRUE,0
	invoke SetDlgItemText,hdlg,IDC_STC_CURRENT,offset initString
	invoke SetDlgItemText,hdlg,IDC_STC_REMAIN,offset initString
	invoke EnableWindow,g_hCtl.hTRB_PROGRESS,FALSE
	invoke KillTimer,hdlg,IDC_TimerID
	
	ret
ResetControls endp

TimerProc proc hwnd:DWORD,uMsg:DWORD,idEvent:DWORD,dwTime:DWORD

	LOCAL fState:DWORD,nCurrentpos:DWORD,szCurrenttime[10]:byte,szRemaintime[10]:byte
	
	lea	eax,fState
	push	eax
	call	lpGetCurrentState
	
	mov	eax,fState
	.if	eax!=0;State_Stopped=0
		lea	eax,nCurrentpos
		push eax
		call	lpGetPlayerCurrentPosition
		
		push	10
		lea	eax,szRemaintime
		push	eax
		push	10
		lea	eax,szCurrenttime
		push	eax
		call	lpGetCurrentAndRemainA
		
		invoke SetDlgItemText,hwnd,IDC_STC_CURRENT,addr szCurrenttime
		invoke SetDlgItemText,hwnd,IDC_STC_REMAIN,addr szRemaintime
		invoke SendMessage,g_hCtl.hTRB_PROGRESS,TBM_SETPOS,TRUE,nCurrentpos 
		
	.else
		invoke ResetControls,hwnd
		.if	g_CURPMSelected==IDM_Random
			invoke GetNextPlayIndex,g_CURPMSelected,rNums.nNumsCount

		.elseif	g_CURPMSelected==IDM_SingleLoop
		
		.else
			invoke GetNextPlayIndex,g_CURPMSelected,g_currentPlayIndex
		.endif
		
		.if	g_currentPlayIndex!=-1
			invoke PlaySpecifySong,hwnd,g_currentPlayIndex
		.else
			call	lpStop_Music
			mov	g_bIsPlaying,FALSE
		.endif
	
	.endif
	
	
	
	
	
	
	ret
TimerProc endp

Main_OnClose proc hwnd:HWND
	
	call	lpStop_Music
	invoke SavePlayList
	invoke DestroyMenu,g_hmenu
	invoke DestroyMenu,g_hPlayList_Menu
	invoke Shell_NotifyIcon,NIM_DELETE,addr AppNodifyIcon
	invoke EndDialog,hwnd, 0
	
	ret

Main_OnClose endp

Form1_OnHScroll proc  hwnd:HWND,  hwndCtl:HWND,  code:UINT,pos:DWORD
	LOCAL nCurrentpos:DWORD

	mov	eax,hwndCtl
	.if	g_hCtl.hTRB_PROGRESS==eax
		.if	code==SB_THUMBTRACK
			push	pos
			call	lpSetPlayerPosition
		.else
			lea	eax,nCurrentpos
			push	eax
			call	lpGetPlayerCurrentPosition
			invoke SendMessage,g_hCtl.hTRB_PROGRESS,TBM_SETPOS,TRUE,nCurrentpos
		.endif
		
	.elseif	g_hCtl.hTRB_SETBALANCE==eax
			invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_GETPOS,0,0
			mov	ecx,eax
			mov	eax,100
			sbb	eax,ecx
			mov	ecx,100
			imul	ecx
			push	eax
			call	lpSetPlayerBalance
	.endif

	ret
Form1_OnHScroll endp



















