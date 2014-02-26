UNICODE=0
_WIN32_IE_Greate_Or_Equal_0500H=0
_WIN32_IE_Greate_Or_Equal_0600H=1
_WIN32_IE_Less_0500H=0

.586
.model flat,stdcall
option casemap:none


	include windows.inc
	include user32.inc
	include kernel32.inc
	include MusicPlayer_ASM.Inc
	include Main.inc
	include stdio.inc
	include shell32.inc
	include comdlg32.inc
	include shlwapi.inc
	include shlobj.inc
	
	
	includelib MSVCRT.LIB
	includelib shell32.lib
	includelib user32.lib
	includelib kernel32.lib
	includelib Comdlg32.lib
	includelib shlwapi.lib
	includelib gdi32.lib



.data

	g_CURTRPSelected DD IDM_Opaque
	g_CURPMSelected DD IDM_Sortorder
	isWinVisible DD 1 ; // 记录窗口是否可见，默认为可见
	g_bIsPlaying DD 0 ; // 记录是否处于播放状态，默认为停止

	hInstance HINSTANCE ?
	CommandLine LPSTR ?
	g_hCtl HCONTROLS <>
	filesinfo FILESINFO <>
	rNums RANDOMNUMBERS <>
	g_currentPlayIndex DD ?
	AppNodifyIcon NOTIFYICONDATA <>
	
	lpBtnStopOrigProc dd ?
	lpBtnAboveOrigProc dd ?
	lpBtnNextOrigProc dd ?
	lpBtnPlayPauseOrigProc dd ?
	
	rflag dd ?
	g_hmenu HMENU ?
	g_hPlayList_Menu HMENU ? 
	
	hinst_PlayCore dd ?
	
	
	lpSpecifyMusicFileA			dd ?
	lpPlay_Music					dd ?
	lpPause_Music 					dd ?
	lpStop_Music					dd ?
	lpSetMusicRate 				dd ?
	lpSetPlayerBalance 			dd ?
	lpSetPlayerVolume 			dd ?
	lpGetPlayerVolume 			dd ?
	lpGetPlayerCurrentPosition dd ?
	lpSetPlayerPosition 			dd ?
	lpGetCurrentState				dd ?
	lpGet_Length					dd ?
	lpGetCurrentAndRemainA		dd ?
	lpGet_Length_StringA			dd ?
	
	lptime dd ?
	lpsrand dd ?
	lprand dd ?
	
	;>>>>>>>>>>>>DrawUI.asm
	bTracking	byte	FALSE
	g_bOverStopBtn byte FALSE ; // 鼠标在停止按钮上
	g_bOverPlayPauseBtn byte FALSE;
	g_bOverNextBtn byte FALSE
	g_bOverAboveBtn byte FALSE
	g_rcBtn RECT	<>
	
	half real8 0.5
	one real8 1.0
	two real8 2.0
	
.code

include Main.asm


start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke DialogBoxParam,hInstance,IDD_MAIN,\
		NULL,offset _ProcDlgMain,NULL
	invoke ExitProcess,NULL

end start
