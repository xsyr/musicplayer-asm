

newBtnNextProc proc  hwnd:HWND,  sMsg:UINT,  wParam:WPARAM,  lParam:LPARAM
	
	LOCAL tme:TRACKMOUSEEVENT
	
	.if	sMsg==WM_MOUSEMOVE
		
		invoke LoadCursor,NULL, IDC_HAND
		invoke SetCursor,eax
		
		.if	!bTracking
			mov	tme.cbSize,sizeof TRACKMOUSEEVENT
			mov	tme.dwFlags,03H ;TME_HOVER | TME_LEAVE
			mov	tme.dwHoverTime,5
			mov	eax,hwnd
			mov	tme.hwndTrack,eax
			invoke TrackMouseEvent,addr tme
			mov	bTracking,al
		.endif
	.elseif	sMsg==WM_MOUSELEAVE
	
		mov	g_bOverNextBtn,FALSE
		mov	bTracking ,FALSE
		invoke	InvalidateRect,hwnd, offset g_rcBtn, FALSE ; // 使窗口区域无效 
		xor	eax,eax
		ret

	.elseif	sMsg==WM_MOUSEHOVER
		
		mov	g_bOverNextBtn , TRUE
		invoke	GetClientRect,hwnd, addr g_rcBtn
		invoke	InvalidateRect,hwnd, addr g_rcBtn, FALSE
		xor	eax,eax
		ret
			
	.endif
	
	invoke CallWindowProc,lpBtnNextOrigProc, hwnd, sMsg, wParam, lParam
	
	ret

newBtnNextProc endp


newBtnAboveProc proc  hwnd:HWND,  sMsg:UINT,  wParam:WPARAM,  lParam:LPARAM
	
	LOCAL tme:TRACKMOUSEEVENT
	
	.if	sMsg==WM_MOUSEMOVE
		
		invoke LoadCursor,NULL, IDC_HAND
		invoke SetCursor,eax
		
		.if	1;!bTracking
			mov	tme.cbSize,sizeof TRACKMOUSEEVENT
			mov	tme.dwFlags,03H ;TME_HOVER | TME_LEAVE
			mov	tme.dwHoverTime,5
			mov	eax,hwnd
			mov	tme.hwndTrack,eax
			invoke TrackMouseEvent,addr tme
			mov	bTracking,al
		.endif
	.elseif	sMsg==WM_MOUSELEAVE
	
		mov	g_bOverAboveBtn,FALSE
		mov	bTracking ,FALSE
		invoke	InvalidateRect,hwnd, offset g_rcBtn, FALSE ; // 使窗口区域无效 
		xor	eax,eax
		ret

	.elseif	sMsg==WM_MOUSEHOVER
		
		mov	g_bOverAboveBtn , TRUE
		invoke	GetClientRect,hwnd, addr g_rcBtn
		invoke	InvalidateRect,hwnd, addr g_rcBtn, FALSE
		xor	eax,eax
		ret
			
	.endif
	
	invoke CallWindowProc,lpBtnAboveOrigProc, hwnd, sMsg, wParam, lParam
	
	ret

newBtnAboveProc endp


newBtnStopProc proc  hwnd:HWND,  sMsg:UINT,  wParam:WPARAM,  lParam:LPARAM
	
	LOCAL tme:TRACKMOUSEEVENT
	
	.if	sMsg==WM_MOUSEMOVE
		
		invoke LoadCursor,NULL, IDC_HAND
		invoke SetCursor,eax
		
		.if	!bTracking
			mov	tme.cbSize,sizeof TRACKMOUSEEVENT
			mov	tme.dwFlags,03H ;TME_HOVER | TME_LEAVE
			mov	tme.dwHoverTime,5
			mov	eax,hwnd
			mov	tme.hwndTrack,eax
			invoke TrackMouseEvent,addr tme
			mov	bTracking,al
		.endif
	.elseif	sMsg==WM_MOUSELEAVE
	
		mov	g_bOverStopBtn,FALSE
		mov	bTracking ,FALSE
		invoke	InvalidateRect,hwnd, offset g_rcBtn, FALSE ; // 使窗口区域无效 
		xor	eax,eax
		ret

	.elseif	sMsg==WM_MOUSEHOVER
		
		mov	g_bOverStopBtn , TRUE
		invoke	GetClientRect,hwnd, addr g_rcBtn
		invoke	InvalidateRect,hwnd, addr g_rcBtn, FALSE
		xor	eax,eax
		ret
			
	.endif
	
	invoke CallWindowProc,lpBtnStopOrigProc, hwnd, sMsg, wParam, lParam
	
	ret

newBtnStopProc endp


newBtnPlayPauseProc proc  hwnd:HWND,  sMsg:UINT,  wParam:WPARAM,  lParam:LPARAM
	
	LOCAL tme:TRACKMOUSEEVENT
	
	.if	sMsg==WM_MOUSEMOVE
		
		invoke LoadCursor,NULL, IDC_HAND
		invoke SetCursor,eax
		
		.if	!bTracking
			mov	tme.cbSize,sizeof TRACKMOUSEEVENT
			mov	tme.dwFlags,03H ;TME_HOVER | TME_LEAVE
			mov	tme.dwHoverTime,5
			mov	eax,hwnd
			mov	tme.hwndTrack,eax
			invoke TrackMouseEvent,addr tme
			mov	bTracking,al
		.endif
	.elseif	sMsg==WM_MOUSELEAVE
	
		mov	g_bOverPlayPauseBtn,FALSE
		mov	bTracking ,FALSE
		invoke	InvalidateRect,hwnd, offset g_rcBtn, FALSE ; // 使窗口区域无效 
		xor	eax,eax
		ret

	.elseif	sMsg==WM_MOUSEHOVER
		
		mov	g_bOverPlayPauseBtn , TRUE
		invoke	GetClientRect,hwnd, addr g_rcBtn
		invoke	InvalidateRect,hwnd, addr g_rcBtn, FALSE
		xor	eax,eax
		ret
			
	.endif
	
	invoke CallWindowProc,lpBtnPlayPauseOrigProc, hwnd, sMsg, wParam, lParam
	
	ret

newBtnPlayPauseProc endp


DrawBtnBitmap proc  hBtn:HWND,  hBtnDC:HDC,  rcBtn:RECT,  bmOrigID:UINT,  bmOverID:UINT,bBtnState:word
	
	LOCAL hbm:HBITMAP,hdcMem:HDC
	
	invoke CreateCompatibleDC,hBtnDC
	mov	hdcMem,eax
	.if bBtnState
		invoke LoadBitmap,hInstance,bmOverID
		mov	hbm,eax
	.else
		invoke LoadBitmap,hInstance,bmOrigID
		mov	hbm,eax
	.endif
	
	.if	hbm
		invoke SelectObject,hdcMem, hbm
		invoke BitBlt,hBtnDC, 0, 0, rcBtn.right, rcBtn.bottom, 
		hdcMem, 0, 0, SRCCOPY
	.endif
	
	invoke DeleteDC,hdcMem
	invoke ReleaseDC,hBtn, hBtnDC
	invoke DeleteObject,hbm
	
	ret

DrawBtnBitmap endp

OnDrawItem proc  hwnd:HWND,lpDrawItem:DWORD
	
	mov	ebx,lpDrawItem
	mov	eax,dword ptr [ebx+4]
	.if	eax==IDC_BTN_PLAY_PAUSE
		.if (g_bIsPlaying)
			xor	eax,eax
			movzx	ax,g_bOverPlayPauseBtn
			push	ax
			
			push	IDC_BMONPLAYOVER
			push	IDM_BMONPLAY
			push	dword ptr [ebx+40]
			push	dword ptr [ebx+36]
			push	dword ptr [ebx+32]
			push	dword ptr [ebx+28]
			push	dword ptr [ebx+24]
			push	g_hCtl.hBTN_PLAY_PAUSE
			
			call DrawBtnBitmap
			
		.else
			xor	eax,eax
			movzx	ax,g_bOverPlayPauseBtn
			push	ax
			
			push	IDC_BMONPAUSEOVER
			push	IDM_BMONPAUSE
			push	dword ptr [ebx+40]
			push	dword ptr [ebx+36]
			push	dword ptr [ebx+32]
			push	dword ptr [ebx+28]
			push	dword ptr [ebx+24]
			push	g_hCtl.hBTN_PLAY_PAUSE
			
			call DrawBtnBitmap
			
		.endif
		
	.elseif	eax==IDC_BTN_STOP
		xor	eax,eax
		movzx	ax,g_bOverStopBtn
			push	ax
			
			push	IDC_BMSTOPOVER
			push	IDC_BMSTOP
			push	dword ptr [ebx+40]
			push	dword ptr [ebx+36]
			push	dword ptr [ebx+32]
			push	dword ptr [ebx+28]
			push	dword ptr [ebx+24]
			push	g_hCtl.hBTN_STOP
			
			call DrawBtnBitmap
			
	.elseif	eax==IDC_BTN_NEXT
		xor	eax,eax
		movzx	ax,g_bOverNextBtn
		push	ax
		
		push	IDC_BMONNEXTOVER
		push	IDC_BMONNEXT
		push	dword ptr [ebx+40]
		push	dword ptr [ebx+36]
		push	dword ptr [ebx+32]
		push	dword ptr [ebx+28]
		push	dword ptr [ebx+24]
		push	g_hCtl.hBTN_NEXT
		
		call DrawBtnBitmap
		
	.elseif	eax==IDC_BTN_ABOVE
		
		xor eax,eax
		movzx	ax,g_bOverAboveBtn
			push	ax
			
			push	IDC_BMABOVEOVER
			push	IDC_BMABOVE
			push	dword ptr [ebx+40]
			push	dword ptr [ebx+36]
			push	dword ptr [ebx+32]
			push	dword ptr [ebx+28]
			push	dword ptr [ebx+24]
			push	g_hCtl.hBTN_ABOVE
			
			call DrawBtnBitmap
	.endif
	ret

OnDrawItem endp

