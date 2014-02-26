UNICODE=0




	
MAKELONG MACRO wLow,wHigh
		
		xor eax,eax
		mov ax,wHigh
		shl eax,16
		mov ax,wLow
		
		 ENDM

if UNICODE
	TCHAR typedef WORD
ELSE
	TCHAR typedef BYTE
ENDIF

.const

	song_Index TCHAR '%d. %s',0
	invalid_song TCHAR '无效 %s',0
	filterstr 	byte '音乐文件(mp3、wma、wav、APE、FLAC、MIDI、OGG、AAC)',0
			byte '*.mp3;*.wma;*.wav;*.APE;*.FLAC;*.mid;*.OGG;*.m4a',0
			byte '所有文件(*.*)',0
			byte '*.*',0
			byte 'mp3、wma\0*.mp3;*.wma',0
			byte 'APE、FLAC、MIDI、OGG、AAC',0
			byte '*.ape;*.flac;*.mid;*.ogg;*.m4a',0,0
				
	lpstrDefExt byte '*.mp3',0
	
	xiegang TCHAR '\',0
	search byte '\*',0
	
	mid	byte		'.mid',0
	mp3	byte		'.mp3',0
	wma	byte		'.wma',0
	wav	byte		'.wav',0
	ogg	byte		'.OGG',0
	m4a	byte		'.m4a',0
	flac	byte		'.flac',0
	ape	byte		'.ape',0
	
	chooseFolder byte '请选择要添加的文件夹',0
	
	szDll byte 'Player_Core.dll',0
	
	szSpecifyMusicFileA 			byte 'SpecifyMusicFileA',0
	szPlay_Music 					byte 'Play_Music',0
	szPause_Music 					byte 'Pause_Music',0
	szStop_Music					byte 'Stop_Music',0
	szSetMusicRate 				byte 'SetMusicRate',0
	szSetPlayerBalance 			byte 'SetPlayerBalance',0
	szSetPlayerVolume 			byte 'SetPlayerVolume',0
	szGetPlayerVolume 			byte 'GetPlayerVolume',0
	szGetPlayerCurrentPosition byte 'GetPlayerCurrentPosition',0
	szSetPlayerPosition 			byte 'SetPlayerPosition',0
	szGetCurrentState				byte 'GetCurrentState',0
	szGet_Length					byte 'Get_Length',0
	szGetCurrentAndRemainA		byte 'GetCurrentAndRemainA',0
	szGet_Length_StringA			byte 'Get_Length_StringA',0
	
	szError 							byte '无法找到Player_Core.dll,程序将退出',0
	szTip		byte '音乐播放器V2.001',0
	szszInfoTitle byte '嘻嘻……',0
	
	
	szCRTDll byte 'msvcrt.dll',0
	sztime byte 'time',0
	szsrand byte  'srand',0
	szrand byte 'rand',0
	
	plstname	byte	5CH,'PlayList.PLST',0
	
.code

include strsafe.asm

AddFilesNameToPlayList PROTO nfiles:DWORD
	


;>>>>>>>>>>>>>>>获取控件句柄>>>>>>>>

Initiate_PlayCore proc hwnd:HWND

	invoke LoadLibrary,offset szDll
	.if	eax
		mov	hinst_PlayCore,eax
		
		invoke GetProcAddress,eax,offset szSpecifyMusicFileA
		mov	lpSpecifyMusicFileA,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szPlay_Music
		mov	lpPlay_Music,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szPause_Music
		mov	lpPause_Music,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szStop_Music
		mov	lpStop_Music,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szSetMusicRate
		mov	lpSetMusicRate,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szSetPlayerBalance
		mov	lpSetPlayerBalance,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szSetPlayerVolume
		mov	lpSetPlayerVolume,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGetPlayerVolume
		mov	lpGetPlayerVolume,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGetPlayerCurrentPosition
		mov	lpGetPlayerCurrentPosition,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szSetPlayerPosition
		mov	lpSetPlayerPosition,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGetCurrentState
		mov	lpGetCurrentState,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGet_Length
		mov	lpGet_Length,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGetCurrentAndRemainA
		mov	lpGetCurrentAndRemainA,eax
		
		invoke GetProcAddress,hinst_PlayCore,offset szGet_Length_StringA
		mov	lpGet_Length_StringA,eax
	
	.else
		invoke MessageBox,hwnd,offset szError,offset szError,MB_OK
		invoke ExitProcess,1
	.endif
	
	
	ret
Initiate_PlayCore endp

Initiate_CRT proc
	
	push	ebp
	mov	ebp,esp
	

	invoke LoadLibrary,offset szCRTDll
	.if	eax
	
		push	eax
		invoke GetProcAddress,eax,offset sztime
		mov	lptime,eax
		pop 	eax
		push 	eax
		invoke GetProcAddress,eax,offset szsrand
		mov	lpsrand,eax
		pop 	eax
		push 	eax
		invoke GetProcAddress,eax,offset szrand
		mov	lprand,eax
		
	.endif
	
	leave
	ret
Initiate_CRT endp

GetControlsHandle PROC hDlg:HWND

	invoke GetDlgItem,hDlg,IDC_BTN_ABOVE
	mov 	g_hCtl.hBTN_ABOVE,eax
	
	invoke GetDlgItem,hDlg,IDC_BTN_NEXT
	mov 	g_hCtl.hBTN_NEXT,eax
	
	invoke GetDlgItem,hDlg,IDC_BTN_PLAY_PAUSE
	mov 	g_hCtl.hBTN_PLAY_PAUSE,eax
	
	invoke GetDlgItem,hDlg,IDC_BTN_STOP
	mov 	g_hCtl.hBTN_STOP,eax
	
	invoke GetDlgItem,hDlg,IDC_CHK_MUTE
	mov 	g_hCtl.hCHK_MUTE,eax
	
	invoke GetDlgItem,hDlg,IDC_LST_PLAYLIST
	mov 	g_hCtl.hLST_PLAYLIST,eax
	
	invoke GetDlgItem,hDlg,IDC_STC_CURRENT
	mov 	g_hCtl.hSTC_CURRENT,eax
	
	invoke GetDlgItem,hDlg,IDC_STC_REMAIN
	mov 	g_hCtl.hSTC_REMAIN,eax
	
	invoke GetDlgItem,hDlg,IDC_TRB_PROGRESS
	mov 	g_hCtl.hTRB_PROGRESS,eax
	
	invoke GetDlgItem,hDlg,IDC_TRB_SETBALANCE
	mov 	g_hCtl.hTRB_SETBALANCE,eax
	
	invoke GetDlgItem,hDlg,IDC_TRB_SETVOLUME
	mov 	g_hCtl.hTRB_SETVOLUME,eax
	
	invoke GetDlgItem,hDlg,IDC_UDN1
	mov 	g_hCtl.hIDC_UDN1,eax
	
	xor 	eax,eax
	ret

GetControlsHandle ENDP

InitiateControls PROC
	
	; 设置声道平衡控件 
	;相当于MAKELONG(0,200)

	MAKELONG 0,200
	invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_SETRANGE,TRUE,eax
	
	;设置声道平衡控件默认位置
	invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_SETPOS,TRUE,100
	invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_SETTICFREQ,10,0
	invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_SETLINESIZE,0,10
	invoke SendMessage,g_hCtl.hTRB_SETBALANCE,TBM_SETPAGESIZE,0,10
	
	;设置播放列表行高度
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_SETITEMHEIGHT,0,17
	
	;设置音量控件
	MAKELONG 0,1000
	invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_SETRANGE,TRUE,eax
	invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_SETLINESIZE,0,50
	invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_SETPAGESIZE,0,50
	invoke SendMessage,g_hCtl.hTRB_SETVOLUME,TBM_SETTICFREQ,50,0
	
	xor eax,eax
	ret

InitiateControls endp

AddFiles PROC hDlg:HWND

	LOCAL szfiledata:dword,hHeap:dword
	LOCAL ofn:OPENFILENAME
	LOCAL szFilesPath[MAX_PATH]:TCHAR
	LOCAL fileNamePointer:DWORD,nlen:DWORD,nAddFilesCount:DWORD
	

	invoke GetProcessHeap
	.if	eax !=NULL
		mov hHeap,eax ; 保存进程堆的句柄
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,256*MAX_PATH ; 分配堆空间
		.if eax !=NULL
			mov szfiledata,eax ; 保存所分配的堆的指针
			
			invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
			
			mov ofn.lStructSize,sizeof OPENFILENAME
			mov eax,hDlg
			mov ofn.hwndOwner,eax 
			mov ofn.lpstrFilter,offset filterstr
			mov ofn.lpstrCustomFilter,NULL
			mov ofn.nFilterIndex,1
			
			mov ofn.nMaxFile,256*MAX_PATH
			mov eax,szfiledata
			mov ofn.lpstrFile,eax
			mov byte ptr [eax],0
			mov ofn.lpstrFileTitle,NULL
			mov ofn.nMaxFileTitle,0
			mov ofn.lpstrTitle,NULL
			mov ofn.Flags,81A04H ;OFN_HIDEREADONLY|OFN_FILEMUSTEXIST|OFN_PATHMUSTEXIST|OFN_EXPLORER|OFN_ALLOWMULTISELECT
			
			invoke GetOpenFileName,addr ofn
		    .IF eax !=0
		    	
				invoke RtlZeroMemory,addr szFilesPath,MAX_PATH ; szFilesPath清零
				mov fileNamePointer,NULL
				mov nlen,0
				mov nAddFilesCount,0
				
				movzx	eax,word ptr [ebp-1Ch] ; ofn.nFileOffset入栈
				push	eax
				push	dword ptr [szfiledata] ; szfiledata入栈
				push	104h ; MAX_PATH入栈
				lea		eax,szFilesPath
				push	eax  ;szFilesPath 入栈
				call	StringCchCopyN ; 将路径复制到szFilesPath中，不包括'\'
				invoke StringCchCat,addr szFilesPath,MAX_PATH,offset xiegang 
				
				movzx	eax,ofn.nFileOffset
				mov		ebx,szfiledata
				add		ebx,eax
				mov		fileNamePointer,ebx
				
				mov		ecx,fileNamePointer
				.while	byte ptr [ecx] !=0
					
					mov		ebx,offset filesinfo.szFilePath ; filesinfo->szFilePath[lpfilesinfo->iCountOfFiles]
					mov 	eax,filesinfo.iCountOfFiles
					mov 	ecx,MAX_PATH
					mul 	ecx
					add 	ebx,eax
					push 	ebx ; 保存filesinfo->szFilePath[lpfilesinfo->iCountOfFiles]的地址
					
					invoke 	StringCchCopy,ebx,MAX_PATH,addr szFilesPath
					pop 	ebx
					invoke 	StringCchCat,ebx,MAX_PATH,fileNamePointer
					invoke 	StringCchLength,fileNamePointer,MAX_PATH,addr nlen
					inc 	nlen
					mov 	eax,nlen
					add 	fileNamePointer,eax
					inc 	filesinfo.iCountOfFiles
					inc 	nAddFilesCount
					mov 	ecx,fileNamePointer
				.endw
				
				invoke AddFilesNameToPlayList,nAddFilesCount
		    .ENDIF ; end
			
			invoke HeapFree,hHeap,HEAP_NO_SERIALIZE,szfiledata ; 释放所分配的堆
		.endif
	.endif

    xor eax,eax
    ret
	
AddFiles ENDP

AddFilesNameToPlayList PROC nfiles:DWORD
	
	LOCAL looptime:DWORD
	LOCAL szAddMark[MAX_PATH]:TCHAR,szTempstring[MAX_PATH]:TCHAR,szTempstring2[MAX_PATH]:TCHAR
	
	mov eax,filesinfo.iCountOfFiles
	sub eax,nfiles
	mov looptime,eax
	; for repeat begain
	cmp filesinfo.iCountOfFiles,0
	je end_for
	cmp filesinfo.iCountOfFiles,256
	jae end_for
	jmp for_cmp
	
for_3th:inc DWORD PTR looptime
	dec DWORD PTR nfiles
	
for_cmp:cmp nfiles,0
	je 	end_for
	mov 	ebx,offset filesinfo.szFilePath ; filesinfo->szFilePath[loop]
	mov 	eax,looptime
	mov 	ecx,MAX_PATH
	mul 	ecx
	add 	ebx,eax
	
	push	ebx ; 保存filesinfo->szFilePath[loop]的地址
	
	invoke 	StringCchCopy,addr szAddMark,MAX_PATH,ebx
	invoke 	PathRemoveExtension,addr szAddMark
	invoke 	PathFindFileName,addr szAddMark
	push 	eax ;StringCchPrintf倒数第一个参数
	mov 	ecx,looptime
	inc		ecx
	push 	ecx ;StringCchPrintf倒数第二个参数
	push 	offset song_Index ;StringCchPrintf倒数第三个参数
	push 	MAX_PATH ;StringCchPrintf倒数第四个参数
	lea 	eax, szTempstring
	push 	eax ;StringCchPrintf倒数第五个参数
	call 	StringCchPrintf
	add		esp,20 ; 处理堆栈
	
	invoke 	StringCchCopy,addr szTempstring2,MAX_PATH,addr szTempstring
	
	pop		ebx
	invoke PathFileExists,ebx
	cmp 	eax,TRUE
	je		sendmsg
	invoke 	StringCchPrintf,addr szTempstring2,MAX_PATH,offset invalid_song,addr szTempstring
	
sendmsg:
	invoke 	SendMessage,g_hCtl.hLST_PLAYLIST,LB_ADDSTRING,0,addr szTempstring2
	jmp 	for_3th
end_for:xor eax,eax
	ret

AddFilesNameToPlayList endp

DisableControls proc
	
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_PlayCurrentSelect,3 ; 3= MF_DISABLED|MF_GRAYED
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_DELETE,3 
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_CLEAR,3 
	invoke EnableWindow,g_hCtl.hBTN_STOP,FALSE
	invoke EnableWindow,g_hCtl.hBTN_ABOVE,FALSE
	invoke EnableWindow,g_hCtl.hBTN_PLAY_PAUSE,FALSE
	invoke EnableWindow,g_hCtl.hBTN_NEXT,FALSE
	invoke EnableWindow,g_hCtl.hTRB_PROGRESS,FALSE
	invoke EnableWindow,g_hCtl.hIDC_UDN1,FALSE

	ret

DisableControls endp

EnableControls proc
	
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_PlayCurrentSelect,MF_ENABLED
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_DELETE,MF_ENABLED
	invoke EnableMenuItem,g_hPlayList_Menu,IDM_CLEAR,MF_ENABLED
	invoke EnableWindow,g_hCtl.hBTN_STOP,TRUE
	invoke EnableWindow,g_hCtl.hBTN_ABOVE,TRUE
	invoke EnableWindow,g_hCtl.hBTN_PLAY_PAUSE,TRUE
	invoke EnableWindow,g_hCtl.hBTN_NEXT,TRUE
	invoke EnableWindow,g_hCtl.hTRB_PROGRESS,TRUE
	invoke EnableWindow,g_hCtl.hIDC_UDN1,TRUE
	
	ret

EnableControls endp

CompareExtension proto lpExt:dword
AddDropFilesToList proc hDropFiles:DWORD,hdlg:DWORD
	
	LOCAL szFilename[MAX_PATH]:byte
	LOCAL nFileCount:DWORD,i:DWORD
	
	mov   nFileCount,0
	mov   i,0
	invoke DragQueryFile,hDropFiles,0ffffffffh,NULL, 0
	mov   nFileCount,eax
	.if   (eax>0)
	   ;begin for
	   jmp	for_begin
for_add:inc	i
for_begin:
		mov	eax,i
		cmp	eax,nFileCount
		jge	for_end
		invoke	DragQueryFile,hDropFiles,i,addr szFilename,MAX_PATH
		invoke CompareExtension,addr szFilename
		.if eax
				mov 	ebx,offset filesinfo.szFilePath ; lpsfi->szFilePath[lpsfi->iCountOfFiles]
				mov 	eax,filesinfo.iCountOfFiles;
				mov 	ecx,MAX_PATH
				mul 	ecx
				add 	ebx,eax
				
				invoke StringCchCopy,ebx,MAX_PATH,addr szFilename
				
				inc	filesinfo.iCountOfFiles
		.endif
		jmp for_add
	.endif
for_end:
	invoke DragFinish,hDropFiles
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_RESETCONTENT,0,0
	invoke AddFilesNameToPlayList,filesinfo.iCountOfFiles
	ret
AddDropFilesToList endp

CompareExtension proc lpExt:dword
	
	LOCAL bequal:dword
	
	mov	bequal,TRUE
	
	invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset mid,-1
	.if	eax != 2;CSTR_EQUAL
		invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset mp3,-1
		.if	eax !=2
			invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset wma,-1
			.if	eax !=2
				invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset wav,-1
				.if	eax !=2
					invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset ogg,-1
					.if	eax !=2
						invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset m4a,-1
						.if	eax !=2
							invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset flac,-1
							.if	eax !=2
								invoke CompareString,LOCALE_USER_DEFAULT,5h,lpExt,-1,offset ape,-1
								.if	eax !=2
									mov bequal,FALSE
								.endif
							.endif
						.endif
					.endif
				.endif
			.endif
		.endif
	.endif

	ret
CompareExtension endp

SearchFilesCondition proc lpSearchPath:DWORD,lpFileExtension:DWORD

	LOCAL szTempPath[2*MAX_PATH]:byte,hFindFile:HANDLE,sfd:WIN32_FIND_DATA
	LOCAL nCountOfFiles:DWORD
	
	invoke RtlZeroMemory,addr szTempPath,2*MAX_PATH
	invoke StringCchCat,addr szTempPath,2*MAX_PATH,lpSearchPath
	invoke StringCchCat,addr szTempPath,2*MAX_PATH,offset search
	invoke StringCchCat,addr szTempPath,2*MAX_PATH,lpFileExtension
	
	invoke FindFirstFile,addr szTempPath,addr sfd
	.if	eax != INVALID_HANDLE_VALUE
		mov	hFindFile,eax
		mov	nCountOfFiles,0
		do:
			.if	sfd.cFileName ==2eH ; '.'=2eH
				jmp do_while
			.endif
			mov 	ebx,offset filesinfo.szFilePath ; lpsfi->szFilePath[lpsfi->iCountOfFiles]
			mov 	eax,filesinfo.iCountOfFiles;
			mov 	ecx,MAX_PATH
			mul 	ecx
			add 	ebx,eax
			push	ebx ; 保存lpsfi->szFilePath[lpsfi->iCountOfFiles]
			invoke StringCchCopy,ebx,MAX_PATH,lpSearchPath
			pop	ebx
			push	ebx
			invoke StringCchCat,ebx,MAX_PATH,offset xiegang
			pop ebx
			invoke StringCchCat,ebx,MAX_PATH,addr sfd.cFileName
			inc	nCountOfFiles
			inc	filesinfo.iCountOfFiles
		do_while:
			invoke FindNextFile,hFindFile,addr sfd
			cmp	eax,TRUE
			je		do
			
			invoke AddFilesNameToPlayList,nCountOfFiles
	.endif
	

	ret
SearchFilesCondition endp

AddFolder proc hdlg:HWND
	
	LOCAL sBrowseInfo:BROWSEINFO,lpitem:DWORD
	LOCAL szBuffer_Directory[2*MAX_PATH]:byte
	
	invoke RtlZeroMemory,addr sBrowseInfo,sizeof sBrowseInfo 
	mov	eax,hdlg
	mov	sBrowseInfo.hwndOwner,eax
	mov	sBrowseInfo.lpszTitle,offset chooseFolder
	mov	sBrowseInfo.ulFlags,1001H ; 1001=BIF_RETURNONLYFSDIRS|BIF_BROWSEFORCOMPUTER
	
	invoke SHBrowseForFolder,addr sBrowseInfo
	.if	eax
		mov	lpitem,eax
		invoke RtlZeroMemory,addr szBuffer_Directory,2*MAX_PATH
		invoke SHGetPathFromIDList,lpitem,addr szBuffer_Directory
		invoke SearchFilesCondition,addr szBuffer_Directory,offset mp3
		invoke SearchFilesCondition,addr szBuffer_Directory,offset wma
		invoke SearchFilesCondition,addr szBuffer_Directory,offset wav
		invoke SearchFilesCondition,addr szBuffer_Directory,offset ape
		invoke SearchFilesCondition,addr szBuffer_Directory,offset flac
		invoke SearchFilesCondition,addr szBuffer_Directory,offset mid
		invoke SearchFilesCondition,addr szBuffer_Directory,offset m4a
		invoke SearchFilesCondition,addr szBuffer_Directory,offset ogg
	.endif
	
	
	ret

AddFolder endp

GetNextPlayIndex proc  nPlayMode:UINT,nCurrentPlayIndex:DWORD
	
	.if	nPlayMode==IDM_Random
		mov	eax,rNums.nNumsCount
		.if	(eax<filesinfo.iCountOfFiles)
			lea	ebx,rNums.arrayNums
			add	ebx,eax
			movzx	eax,byte ptr [ebx]
			inc	rNums.nNumsCount
			ret
		.else
			mov	eax,-1
			ret
		.endif
	.elseif	nPlayMode==IDM_Sortorder
		inc	nCurrentPlayIndex
		mov	eax,nCurrentPlayIndex
		.if	eax<filesinfo.iCountOfFiles
			ret
		.else
			mov	eax,0
			ret
		.endif
	.elseif	((nPlayMode==IDM_SingleLoop)||(nPlayMode==IDM_Loop))
		inc	nCurrentPlayIndex
		mov	eax,nCurrentPlayIndex
		mov	ecx,filesinfo.iCountOfFiles
		div	ecx
		mov	eax,edx
		ret
	.endif
	
	mov	eax,-1
	ret

GetNextPlayIndex endp

AddNodifyIcon proc hWnd:HWND
	
	mov	AppNodifyIcon.cbSize,sizeof NOTIFYICONDATA
	mov	eax,hWnd
	mov	AppNodifyIcon.hwnd,eax
	mov	AppNodifyIcon.uID,IDC_NODIFYICON
	mov	AppNodifyIcon.uFlags,17H; NIF_ICON|NIF_MESSAGE|NIF_TIP|NIF_INFO
	mov	AppNodifyIcon.uCallbackMessage,WM_COMMAND
	invoke GetWindowLong,hWnd,GWL_HINSTANCE
	invoke LoadIcon,eax,IDC_NODIFYICON
	mov	AppNodifyIcon.hIcon,eax
	invoke StringCchCopy,addr AppNodifyIcon.szTip,64,offset szTip
	invoke StringCchCopy,addr AppNodifyIcon.szInfo,256,offset szTip
	invoke StringCchCopy,addr AppNodifyIcon.szInfoTitle,64,offset szszInfoTitle
	
	mov	AppNodifyIcon.dwInfoFlags,11H ;NIIF_INFO|NIIF_NOSOUND
	mov	AppNodifyIcon.dwStateMask,1h ; NIS_HIDDEN
	mov	AppNodifyIcon.dwState,1h
	invoke Shell_NotifyIcon,NIM_ADD,addr AppNodifyIcon
	
	mov	eax,TRUE
	ret

AddNodifyIcon endp

GetAbovePlayIndex proc  nPlayMode:UINT,nCurrentPlayIndex:DWORD
	
	.if	nPlayMode==IDM_Random
		mov	eax,rNums.nNumsCount
		.if	( eax >=0 )
			lea	ebx,rNums.arrayNums
			add	ebx,eax
			movzx	eax,byte ptr [ebx]
			dec	rNums.nNumsCount
			ret
		.else
			mov	eax,-1
			ret
		.endif
	.elseif	nPlayMode==IDM_Sortorder
		dec	nCurrentPlayIndex
		mov	eax,nCurrentPlayIndex
		cmp	eax,0
		jl	_else
		.if	eax>=0
			ret
	_else:
			mov	eax,filesinfo.iCountOfFiles
			dec	eax
			ret
		.endif
	.elseif	((nPlayMode==IDM_SingleLoop)||(nPlayMode==IDM_Loop))
		mov	eax,nCurrentPlayIndex
		.if	(eax!=0)
			dec	eax
			ret
		.else
			mov	eax,filesinfo.iCountOfFiles
			dec	eax
			ret
		.endif
	.endif
	
	mov	eax,-1
	ret

GetAbovePlayIndex endp

DeleteItem proc nBeDeleted:DWORD
	
	LOCAL sfsiTemp:DWORD,nLoops:DWORD,hHeap:DWORD
	
	mov	nLoops,0
	
	invoke GetProcessHeap
	.if	eax !=NULL
		mov hHeap,eax ; 保存进程堆的句柄
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof FILESINFO ; 分配堆空间
		.if eax !=NULL
			mov sfsiTemp,eax ; 保存所分配的堆的指针
			invoke RtlZeroMemory,sfsiTemp,sizeof FILESINFO
			mov	eax,nLoops
			.while (eax<filesinfo.iCountOfFiles)
				.if	eax==nBeDeleted
					inc	nLoops
					inc	eax
					.continue
				.endif
				
				lea	esi,filesinfo.szFilePath
				mov	ecx,MAX_PATH
				mov	eax,nLoops
				mul	ecx
				add	esi,eax
				push	esi
				push	MAX_PATH
				
				mov	ebx,sfsiTemp;sfsiTemp.szFilePath
				mov	eax,DWORD PTR [ebx+256*MAX_PATH]; sfsiTemp.iCountOfFiles
				mov	ecx,MAX_PATH
				mul	ecx
				add	ebx,eax
				push	ebx
				call	StringCchCopy
				
				mov	ebx,sfsiTemp;sfsiTemp
				inc	DWORD PTR [ebx+256*MAX_PATH]
				inc	nLoops
				mov	eax,nLoops
				
			.endw
			
			lea	edi,filesinfo
			mov	esi,sfsiTemp
			mov	ecx,4101H; sizeof FILESINFO/4
			rep	movsd
			invoke HeapFree,hHeap,HEAP_NO_SERIALIZE,sfsiTemp ; 释放所分配的堆
		.endif
	.endif
	
	

	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_RESETCONTENT,0,0
	invoke AddFilesNameToPlayList,filesinfo.iCountOfFiles

	ret

DeleteItem endp

Main_AboutProc proc  hWnd:HWND,  uMsg:UINT,  wParam:WPARAM,  lParam:LPARAM
	
	.if	uMsg==WM_COMMAND
		mov	eax,wParam
		.if	ax==IDC_BTN
			invoke EndDialog,hWnd,0
		.endif
		
	.endif
	mov	eax,FALSE
	ret

Main_AboutProc endp

GetrandomNumbers proc
	LOCAL i,ncheck,randnum
	

	push	NULL
	call	lptime
	add	esp,4
	push	eax
	call	lpsrand
	add	esp,4
	
	.if	filesinfo.iCountOfFiles==0
		mov	byte ptr rNums,0
		mov	rNums.nNumsCount,0
		ret
	.elseif	filesinfo.iCountOfFiles==1
		mov	byte ptr rNums,0
		mov	rNums.nNumsCount,1
		ret
	.endif
	
	call	lprand
	mov	ecx,filesinfo.iCountOfFiles
	div 	ecx
	mov	rNums.arrayNums,dl
	mov	rNums.nNumsCount,1
	
	
	mov	i,1
	jmp	for_loop_cmp
for_loop:
	inc i
for_loop_cmp:
	mov	eax,i
	cmp	filesinfo.iCountOfFiles,eax
	jbe	for_loop_end
	
	call	lprand ;rand()
	mov	ecx,filesinfo.iCountOfFiles
	div	ecx
	mov	randnum,edx ; rand()%filesinfo.iCountOfFiles
	mov	ncheck,0
	jmp	for_check_cmp
	for_check:
		inc	ncheck
	for_check_cmp:
		mov	eax,ncheck
		cmp	rNums.nNumsCount,eax
		jbe	for_check_end
		lea	ebx,rNums.arrayNums
		mov	ecx,ncheck
		movzx	eax,byte ptr [ebx+ecx]
		.if	randnum==eax
			call	lprand
			mov	ecx,filesinfo.iCountOfFiles
			div	ecx
			mov	randnum,edx
			mov	ncheck,-1
		.endif
		jmp	for_check
	for_check_end:
	
	
	lea	ebx,rNums.arrayNums
	mov	ecx,i
	mov	eax,randnum
	mov	byte ptr [ebx+ecx],al
	inc	rNums.nNumsCount
	jmp	for_loop
for_loop_end:
	mov	rNums.nNumsCount,0
	ret

GetrandomNumbers endp

RefillFilesInfo proc nNoNeedToCopy:DWORD
	
	LOCAL nHaveLooped:DWORD,lpsfi:DWORD,hHeap
	
	invoke GetProcessHeap
	.if	eax !=NULL
		mov hHeap,eax ; 保存进程堆的句柄
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof FILESINFO ; 分配堆空间
		.if eax !=NULL
			mov lpsfi,eax ; 保存所分配的堆的指针
			invoke RtlZeroMemory,lpsfi,sizeof FILESINFO
			mov	ebx,lpsfi
			mov	eax,256*MAX_PATH
			mov	edx,filesinfo.iCountOfFiles
			mov	dword ptr [ebx+eax],edx
			
			.if	nNoNeedToCopy==0
				mov	nHaveLooped,1
				mov	eax,nHaveLooped
				.while	eax<filesinfo.iCountOfFiles
					lea	esi,filesinfo.szFilePath
					mov	ecx,nHaveLooped
					mov	eax,MAX_PATH
					mul	ecx
					add	esi,eax
					
					mov	edi,lpsfi
					mov	eax,MAX_PATH
					dec	ecx
					mul	ecx
					add	edi,eax
					invoke StringCchCopy,edi,MAX_PATH,esi
					inc	nHaveLooped
					mov	eax,nHaveLooped
				.endw
				
				mov	edi,lpsfi ;sfi.szFilePath[nHaveLooped-1]
				mov	eax,MAX_PATH
				mov	ecx,nHaveLooped
				dec	ecx
				mul	ecx
				add	edi,eax
				
				lea	esi,filesinfo.szFilePath
				invoke	StringCchCopy,edi,MAX_PATH,esi
			.else
				mov	nHaveLooped,0
				mov	edi,lpsfi
				
				lea	esi,filesinfo.szFilePath
				mov	ecx,MAX_PATH
				mov	eax,filesinfo.iCountOfFiles
				dec	eax
				mul	ecx
				add	esi,eax
				invoke	StringCchCopy,edi,MAX_PATH,esi
				
				mov	eax,nHaveLooped
				mov	ecx,filesinfo.iCountOfFiles
				dec	ecx
				.while	eax<ecx
					lea	esi,filesinfo.szFilePath
					mov	ecx,MAX_PATH
					mul	ecx
					add	esi,eax
					
					mov	edi,lpsfi
					mov	eax,nHaveLooped
					inc	eax
					mov	ecx,MAX_PATH
					mul	ecx
					add	edi,eax
					
					invoke	StringCchCopy,edi,MAX_PATH,esi
					
					inc	nHaveLooped
					mov	eax,nHaveLooped
					mov	ecx,filesinfo.iCountOfFiles
					dec	ecx
				.endw
				
			.endif
			
			lea	edi,filesinfo
			mov	esi,lpsfi
			mov	ecx,4101H; sizeof FILESINFO/4
			rep	movsd
			invoke HeapFree,hHeap,HEAP_NO_SERIALIZE,lpsfi ; 释放所分配的堆
		.endif
		
	.endif
	
	
	
	ret

RefillFilesInfo endp


MoveUp proc ;lpnCurrentPlay:DWORD,hdlg:DWORD
	
	LOCAL szTemp[MAX_PATH]:byte,nIndexDest,nIndexSrc
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
	mov	nIndexSrc,eax
	.if (eax!=0)
		mov	eax,nIndexSrc
		dec	eax
		mov	nIndexDest,eax
		
		lea	esi,filesinfo.szFilePath
		mov	eax,MAX_PATH
		mov	ecx,nIndexDest
		mul	ecx
		add	esi,eax
		push	esi ;保存lpfsi->szFilePath[nIndexDest]
		
		lea	edi,szTemp
		invoke StringCchCopy,edi,MAX_PATH,esi
		
		lea	esi,filesinfo.szFilePath
		mov	eax,MAX_PATH
		mov	ecx,nIndexSrc
		mul	ecx
		add	esi,eax

		pop	edi
		push	esi ; 保存lpfsi->szFilePath[nIndexSrc]
		invoke	StringCchCopy,edi,MAX_PATH,esi
		pop	edi
		invoke StringCchCopy,edi,MAX_PATH,addr szTemp
		
	.else
		
		invoke RefillFilesInfo,0
		mov	eax,filesinfo.iCountOfFiles
		dec	eax
		mov	nIndexDest,eax
		
	.endif
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_RESETCONTENT,0,0
	invoke AddFilesNameToPlayList,filesinfo.iCountOfFiles
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_SETCURSEL,nIndexDest,0
	mov	eax,nIndexDest
	mov	g_currentPlayIndex,eax

	ret
MoveUp endp

MoveDown proc
	
	LOCAL szTemp[MAX_PATH]:byte,nIndexDest,nIndexSrc
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
	mov	nIndexSrc,eax
	mov	eax,filesinfo.iCountOfFiles
	dec	eax
	.if	eax!=nIndexSrc
		mov	eax,nIndexSrc
		inc	eax
		mov	nIndexDest,eax
		
		lea	edi,szTemp
		lea	esi,filesinfo.szFilePath
		mov	ecx,MAX_PATH
		mul	ecx
		add	esi,eax
		push	esi ; 保存filesinfo.szFilePath[nIndexDest]
		
		invoke StringCchCopy,edi,MAX_PATH,esi
		mov	eax,nIndexSrc
		mov	ecx,MAX_PATH
		mul	ecx
		lea	esi,filesinfo.szFilePath
		add	esi,eax
		pop	edi ; 取出filesinfo.szFilePath[nIndexDest]
		push	esi ;  保存filesinfo.szFilePath[nIndexSrc]
		invoke StringCchCopy,edi,MAX_PATH,esi
		pop	edi ; 保存filesinfo.szFilePath[nIndexSrc]
		lea	esi,szTemp
		invoke StringCchCopy,edi,MAX_PATH,esi
		
	.else
		mov	nIndexDest,0
		mov	eax,filesinfo.iCountOfFiles
		dec	eax
		invoke RefillFilesInfo,eax
	.endif
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_RESETCONTENT,0,0
	invoke AddFilesNameToPlayList,filesinfo.iCountOfFiles
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_SETCURSEL,nIndexDest,0
	mov	eax,nIndexDest
	mov	g_currentPlayIndex,eax
	
	ret

MoveDown endp

SetDialogText proto hdlg:HWND

OnNotify proc  hdlg:HWND,  wParam:WPARAM,  lParam:LPARAM
	
	invoke SendMessage,g_hCtl.hLST_PLAYLIST,LB_GETCURSEL,0,0
	mov	ebx,lParam
	mov	ecx,[ebx+4] ;hdr.idFrom
	
	.if	ecx==IDC_UDN1 && eax!=LB_ERR
		mov	eax,[ebx+16] ; iDelta
		cmp	eax,0
		jge	_else
			invoke MoveUp
			jmp	settext
	_else:
		invoke MoveDown	
			
settext:	invoke SetDialogText,hdlg
	invoke SetWindowLong,hdlg,DWL_MSGRESULT,TRUE			
	
	.endif
	

	mov	eax,TRUE
	ret

OnNotify endp


SavePlayList proc

	LOCAL loops,pstring,palloc,dwsize,dwtotalsizeinbytes
	LOCAL hfile,dwwrite,szFilePath[MAX_PATH]:byte
	LOCAL len,dwbytetowrite

	mov	dwtotalsizeinbytes,0
	mov	loops,0
	mov	eax,loops
	.while	eax<filesinfo.iCountOfFiles
		mov	ebx,offset filesinfo.szFilePath
		mov	ecx,MAX_PATH
		mov	eax,loops
		mul	ecx
		add	ebx,eax
		invoke StringCbLength,ebx,MAX_PATH,addr dwsize
		mov	eax,dwsize
		inc	eax
		add	dwtotalsizeinbytes,eax
		inc	loops
		mov	eax,loops
	.endw
	
	mov	eax,dwtotalsizeinbytes
	inc	eax
	invoke GlobalAlloc,40H,eax
	mov	pstring,eax
	mov	palloc,eax
	.if	(palloc!=NULL)
		mov	loops,0
		xor	eax,eax
		.while	eax<filesinfo.iCountOfFiles
			mov	ecx,MAX_PATH
			mul	ecx
			mov	ebx,offset filesinfo.szFilePath
			add	ebx,eax
			push	ebx
			invoke StringCchCopy,pstring,dwtotalsizeinbytes,ebx
			pop	ebx
			invoke StringCchLength,ebx,MAX_PATH,addr len
			mov	eax,len
			add	pstring,eax
			mov	ebx,pstring
			mov	byte ptr [ebx],0AH ;'\n'
			inc	pstring
			
			inc	loops
			mov	eax,loops
		.endw
		mov	ebx,pstring
		mov	byte ptr [ebx],0 ; '\0'
		
		invoke GetModuleFileName,hInstance,addr szFilePath,MAX_PATH
		invoke PathRemoveFileSpec,addr szFilePath
		invoke StringCchCat,addr szFilePath,MAX_PATH ,offset plstname
		invoke CreateFile,addr szFilePath,GENERIC_WRITE,FILE_SHARE_READ ,NULL,
				CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov	hfile,eax
		.if	hfile!=INVALID_HANDLE_VALUE
			mov	ebx,dwtotalsizeinbytes
			inc	ebx
			invoke StringCbLength,palloc,ebx,addr dwbytetowrite
			invoke WriteFile,hfile,palloc,dwbytetowrite,addr dwwrite,NULL
			invoke CloseHandle,hfile
		.endif
		invoke GlobalFree,palloc
	.endif
	
	
	ret
SavePlayList endp


LoadPlayList proc
	
	LOCAL bSuccess,hfile,szplaylistpath[MAX_PATH]:byte,dwFileSize,lpfilepath,dwread
	LOCAL ptmp,icntfile,ilen
	
	mov	bSuccess,FALSE
	invoke GetModuleFileName,hInstance,addr szplaylistpath,MAX_PATH
	invoke PathRemoveFileSpec,addr szplaylistpath
	invoke StringCchCat,addr szplaylistpath,MAX_PATH,offset plstname
	invoke CreateFile,addr szplaylistpath,GENERIC_READ,FILE_SHARE_READ,NULL,
					OPEN_EXISTING,0,NULL
	mov	hfile,eax
					
	.if	eax!=INVALID_HANDLE_VALUE
		invoke GetFileSize,hfile,NULL
		mov	dwFileSize,eax
		cmp	eax,0
		jle	end_if
		
		invoke GlobalAlloc,40H,dwFileSize
		.if	eax!=NULL
			mov	lpfilepath,eax
			invoke ReadFile,hfile,lpfilepath,dwFileSize,addr dwread,NULL
			.if	eax!=0
				mov	eax,lpfilepath
				mov	ptmp,eax
				mov	icntfile,0
				
				mov	ebx,lpfilepath
				mov	ecx,dwFileSize
		loop_bgn:
				.if	byte ptr [ebx]==0AH ; '\n'
					mov	byte ptr [ebx],0 ; '\0'
					inc	icntfile
				.endif
				inc	ebx
				loop	loop_bgn
				
				.if	icntfile!=0
					xor	eax,eax
					mov	ecx,icntfile
					mov	ebx,lpfilepath
			loop_cpy:
					push	eax
					push	ecx
					push	ebx
					
					mov	edx,MAX_PATH
					mul	edx
					mov	edi,offset filesinfo.szFilePath
					add	edi,eax
					invoke StringCchCopy,edi,MAX_PATH,ebx
					pop	ebx
					push	ebx
					invoke StringCchLength,ebx,MAX_PATH,addr	ilen
					pop	ebx
					inc	ilen
					add	ebx,ilen
					inc	filesinfo.iCountOfFiles
					pop	ecx
					pop	eax
					inc	eax
					loop	loop_cpy
				.endif
				
				mov	bSuccess,TRUE
				
			.endif
			invoke GlobalFree,lpfilepath
		.endif
end_if:
		invoke CloseHandle,hfile
	.endif				
	
	
	mov	eax,bSuccess
	ret

LoadPlayList endp

SetPlayModeMenu proc  nMenuID:UINT
	
	invoke GetSubMenu,g_hmenu,0
	invoke CheckMenuRadioItem,eax,IDM_Random,IDM_SingleLoop,nMenuID,MF_BYCOMMAND
	mov	eax,nMenuID
	mov	g_CURPMSelected,eax
	
	ret

SetPlayModeMenu endp


SetTransparentMune proc	nMenuID:UINT
	
	invoke GetSubMenu,g_hmenu,1
	invoke CheckMenuRadioItem,eax,IDM_Opaque,IDM_P90,nMenuID,MF_BYCOMMAND
	mov	eax,nMenuID
	mov	g_CURTRPSelected,eax
	
	ret

SetTransparentMune endp











