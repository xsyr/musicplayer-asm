
HRESULT typedef DWORD
STRSAFE_E_INVALID_PARAMETER equ 80070057H
STRSAFE_E_INSUFFICIENT_BUFFER   equ 8007007AH
STRSAFE_MAX_CCH equ 2147483647

;	include stdio.inc
;	include Winbase.inc
;	include stdio.inc
;	
;	includelib MSVCRT.LIB
;;	includelib LIBC.LIB
;	includelib kernel32.lib

StringCchCopyNW PROTO pszDestW:DWORD,cchDestW:DWORD,pszSrcW:DWORD,cchSrcW:DWORD
StringCchCopyNA PROTO pszDestA:DWORD,cchDestA:DWORD,pszSrcA:DWORD,cchSrcA:DWORD

StringCchCatW PROTO pszDestW:DWORD,cchDestW:DWORD,pszSrcW:DWORD
StringCchCatA PROTO pszDestA:DWORD,cchDestA:DWORD,pszSrcA:DWORD

StringCchCopyW PROTO pszDestW:DWORD,cchDestW:DWORD,pszSrcW:DWORD
StringCchCopyA PROTO pszDestA:DWORD,cchDestA:DWORD,pszSrcA:DWORD

StringCchPrintfW PROTO C pszDestW:DWORD,cchDestW:DWORD,pszFormatW:DWORD,parmvaluesA:VARARG
StringCchPrintfA PROTO C pszDestA:DWORD,cchDestA:DWORD,pszFormatA:DWORD,parmvaluesA:VARARG

StringCchLengthW PROTO pszW:DWORD,cchMaxW:DWORD,pcchW:DWORD
StringCchLengthA PROTO pszA:DWORD,cchMaxA:DWORD,pcchA:DWORD

StringCbLengthA proto psz:DWORD,cbMax:DWORD,pcb:DWORD

IF UNICODE

	StringCchCopyN EQU <StringCchCopyNW>
	StringCchCat EQU <StringCchCatW>
	StringCchCopy EQU <StringCchCopyW>
	StringCchPrintf EQU <StringCchPrintfW>
	StringCchLength EQU <StringCchLengthW>
	
	
ELSE

	StringCchCopyN EQU <StringCchCopyNA>
	StringCchCat EQU <StringCchCatA>
	StringCchCopy EQU <StringCchCopyA>
	StringCchPrintf EQU <StringCchPrintfA>	
	StringCchLength EQU <StringCchLengthA>
	StringCbLength	equ <StringCbLengthA>
	
ENDIF




StringCopyNWorkerA proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD,cchSrc:DWORD

	LOCAL hr:HRESULT
	
	mov hr,S_OK
	.if	cchDest == 0
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		xor ebx,ebx
		mov esi,pszSrc
		mov edi,pszDest
		.while (cchDest && cchSrc  && byte ptr [esi+ebx]!=0)
			mov al,byte ptr [esi+ebx]
			mov byte ptr [edi+ebx],al
			inc ebx
			dec cchDest
			dec cchSrc
		.endw
		
		.if	cchDest == 0
			dec ebx
			mov hr,STRSAFE_E_INSUFFICIENT_BUFFER
		.endif
		
		mov byte ptr [edi+ebx],0
	.endif
	
	mov eax,hr
	ret 
StringCopyNWorkerA endp

StringCopyNWorkerW proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD,cchSrc:DWORD

	LOCAL hr:HRESULT
	
	mov hr,S_OK
	.if	cchDest == 0
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		xor ebx,ebx
		mov esi,pszSrc
		mov edi,pszDest
		.while (cchDest && cchSrc  && word ptr [esi+2*ebx]!=0)
			mov ax,word ptr [esi+2*ebx]
			mov word ptr [edi+2*ebx],ax
			inc ebx
			dec cchDest
			dec cchSrc
		.endw
		
		.if	cchDest == 0
			dec ebx
			mov hr,STRSAFE_E_INSUFFICIENT_BUFFER
		.endif
		mov word ptr [edi+2*ebx],0
	.endif
	
	mov eax,hr
	ret 
StringCopyNWorkerW endp

StringCchCopyNA  proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD,cchSrc:DWORD

	LOCAL hr:HRESULT
	
	.if	(cchDest > STRSAFE_MAX_CCH) || (cchSrc > STRSAFE_MAX_CCH)
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCopyNWorkerA,pszDest, cchDest, pszSrc, cchSrc
		mov hr,eax
	.endif
	mov eax,hr
	ret 
StringCchCopyNA endp

StringCchCopyNW  proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD,cchSrc:DWORD

	LOCAL hr:HRESULT
	
	.if	(cchDest > STRSAFE_MAX_CCH) || (cchSrc > STRSAFE_MAX_CCH)
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCopyNWorkerW,pszDest, cchDest, pszSrc, cchSrc
		mov hr,eax
	.endif
	mov eax,hr
	ret 
StringCchCopyNW endp

StringCopyWorkerA proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	LOCAL hr:HRESULT
	
	mov hr,S_OK
	.if	cchDest == 0
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		xor ebx,ebx
		mov esi,pszSrc
		mov edi,pszDest
		.while (cchDest && byte ptr [esi+ebx]!=0)
			mov al,byte ptr [esi+ebx]
			mov byte ptr [edi+ebx],al
			inc ebx
			dec cchDest
		.endw
		
		.if	cchDest == 0
			dec ebx
			mov hr,STRSAFE_E_INSUFFICIENT_BUFFER
		.endif
		
		mov byte ptr [edi+ebx],0
	.endif
	
	mov eax,hr
	ret 

StringCopyWorkerA endp

StringCopyWorkerW proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	LOCAL hr:HRESULT
	
	mov hr,S_OK
	.if	cchDest == 0
		mov hr,STRSAFE_E_INVALID_PARAMETER
	.else
		xor ebx,ebx
		mov esi,pszSrc
		mov edi,pszDest
		.while (cchDest && word ptr [esi+2*ebx]!=0)
			mov ax,word ptr [esi+2*ebx]
			mov word ptr [edi+2*ebx],ax
			inc ebx
			dec cchDest
		.endw
		
		.if	cchDest == 0
			dec ebx
			mov hr,STRSAFE_E_INSUFFICIENT_BUFFER
		.endif
		mov word ptr [edi+2*ebx],0
	.endif
	
	mov eax,hr
	ret 
StringCopyWorkerW endp

StringLengthWorkerA proc psz:DWORD,cchMax:DWORD,pcch:DWORD

	LOCAL hr:HRESULT,cchMaxPrev:DWORD
	
	mov eax,cchMax
	mov cchMaxPrev,eax
	mov eax,psz
	.while (cchMax !=0 && (byte ptr [eax] != 0))
		inc psz
		dec cchMax
		mov eax,psz
	.endw
	 
	 .if (cchMax == 0)
	 	mov hr, STRSAFE_E_INVALID_PARAMETER
	 .endif
	 
	 .if (hr >=0 && pcch !=0)
	 	mov eax,cchMaxPrev
	 	sub eax,cchMax
	 	mov esi,pcch
	 	mov dword ptr [esi],eax
	 .endif
	mov eax,hr
	ret
StringLengthWorkerA endp

StringLengthWorkerW proc psz:DWORD,cchMax:DWORD,pcch:DWORD

	LOCAL hr:HRESULT,cchMaxPrev:DWORD
	
	mov eax,cchMax
	mov cchMaxPrev,eax
	
	xor ebx,ebx
	mov eax,psz
	.while (cchMax && (word ptr [eax+2*ebx] != 0))
		inc ebx
		dec cchMax
		mov eax,psz
	.endw
	 
	 .if (cchMax == 0)
	 	mov hr, STRSAFE_E_INVALID_PARAMETER
	 .endif
	 
	 .if (hr >=0 && pcch !=0)
	 	mov eax,cchMaxPrev
	 	sub eax,cchMax
	 	mov esi,pcch
	 	mov dword ptr [esi],eax
	 .endif
	mov eax,hr
	ret
StringLengthWorkerW endp

StringCatWorkerA proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	LOCAL cchDestCurrent:DWORD
	
	mov cchDestCurrent,0
	
;	lea eax,cchDestCurrent
	invoke StringLengthWorkerA,pszDest, cchDest, addr cchDestCurrent
	
	.if (eax >=0)
		mov eax,pszDest
		add eax,cchDestCurrent
		mov ebx,cchDest
		sub ebx,cchDestCurrent
		invoke StringCopyWorkerA,eax,ebx,pszSrc
	.endif

	ret
StringCatWorkerA endp

StringCatWorkerW proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	LOCAL cchDestCurrent:DWORD
	
	mov cchDestCurrent,0
	
	lea eax,cchDestCurrent
	invoke StringLengthWorkerW,pszDest, cchDest, eax
	
	.if (eax >=0)
		mov eax,pszDest
		add eax,cchDestCurrent
		mov ebx,cchDest
		sub ebx,cchDestCurrent
		invoke StringCopyWorkerW,eax,ebx,pszSrc
	.endif
	
	ret
StringCatWorkerW endp

StringCchCatA proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD
	
	.if (cchDest > STRSAFE_MAX_CCH)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCatWorkerA,pszDest,cchDest,pszSrc
	.endif

	ret
	
StringCchCatA endp

StringCchCatW proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD
	
	.if (cchDest > STRSAFE_MAX_CCH)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCatWorkerW,pszDest, cchDest, pszSrc
	.endif

	ret
	
StringCchCatW endp


StringCchCopyA proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	.if (cchDest > STRSAFE_MAX_CCH)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCopyWorkerA,pszDest, cchDest, pszSrc
	.endif

	ret
	
StringCchCopyA endp

StringCchCopyW proc pszDest:DWORD,cchDest:DWORD,pszSrc:DWORD

	.if (cchDest > STRSAFE_MAX_CCH)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringCopyWorkerW,pszDest, cchDest, pszSrc
	.endif

	ret
	
StringCchCopyW endp

StringCchLengthA proc psz:DWORD,cchMax:DWORD,pcch:DWORD
	
	.if (cchMax > STRSAFE_MAX_CCH || psz == NULL)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringLengthWorkerA,psz, cchMax, pcch
	.endif
	
	ret

StringCchLengthA endp

StringCchLengthW proc psz:DWORD,cchMax:DWORD,pcch:DWORD
	
	.if (cchMax > STRSAFE_MAX_CCH || psz == NULL)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		invoke StringLengthWorkerW,psz, cchMax, pcch
	.endif
	
	ret

StringCchLengthW endp

StringVPrintfWorkerA proc pszDest:DWORD,cchDest:DWORD,pszFormat:DWORD,argList:DWORD
	
	.if	(cchDest==0)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		xor esi,esi
		mov edi,cchDest ; edi == cchMax
		sub edi,1
		invoke _vsnprintf,pszDest,edi,pszFormat,argList
		
		.if	((eax < 0) || (eax > edi))
			add pszDest,edi
			mov byte ptr [pszDest],0
			mov eax,STRSAFE_E_INSUFFICIENT_BUFFER
		.elseif(eax == edi)
			add pszDest,edi
			mov byte ptr [pszDest],0
			mov eax,S_OK
		.endif
		
	.endif
	
	ret

StringVPrintfWorkerA endp


StringVPrintfWorkerW proc pszDest:DWORD,cchDest:DWORD,pszFormat:DWORD,argList:DWORD
	
	.if	(cchDest==0)
		mov eax,STRSAFE_E_INVALID_PARAMETER
	.else
		xor esi,esi
		mov edi,cchDest ; edi == cchMax
		sub edi,1
		invoke _vsnwprintf,pszDest,edi,pszFormat,argList
		
		.if	((eax < 0) || (eax > edi))
			add pszDest,edi
			mov word ptr [pszDest],0
			mov eax,STRSAFE_E_INSUFFICIENT_BUFFER
		.elseif(eax == edi)
			add pszDest,edi
			mov word ptr [pszDest],0
			mov eax,S_OK
		.endif
		
	.endif
	
	ret

StringVPrintfWorkerW endp

StringCchPrintfA proc C pszDest:DWORD,cchDest:DWORD,pszFormat:DWORD,parmvalues:VARARG
	
	.if (cchDest > STRSAFE_MAX_CCH)
        mov eax, STRSAFE_E_INVALID_PARAMETER;
    .else
    	lea edi,pszFormat ; edi == argList,此处获取可变参数的地址
    	add edi,4
    	invoke StringVPrintfWorkerA,pszDest, cchDest, pszFormat, edi
    .endif
	ret

StringCchPrintfA endp

StringCchPrintfW proc C pszDest:DWORD,cchDest:DWORD,pszFormat:DWORD,parmvalues:VARARG
	
	.if (cchDest > STRSAFE_MAX_CCH)
        mov eax, STRSAFE_E_INVALID_PARAMETER;
    .else
    	lea edi,pszFormat ; edi == argList,此处获取可变参数的地址
    	add edi,4
    	invoke StringVPrintfWorkerW,pszDest, cchDest, pszFormat, edi
    .endif
	ret

StringCchPrintfW endp


StringCbLengthA proc psz:DWORD,cbMax:DWORD,pcb:DWORD

	LOCAL hr,cchMax,cch
	
	mov	cch,0
	mov	eax,cbMax
	mov	cchMax,eax
	.if	((psz == NULL) || (cchMax > STRSAFE_MAX_CCH))
		mov	hr,STRSAFE_E_INVALID_PARAMETER
		
	.else
		invoke StringLengthWorkerA,psz, cchMax, addr cch
		mov	hr,eax
	.endif
	
	.if	hr >=0 && pcb
		mov	eax,cch
		mov	ebx,pcb
		mov	dword ptr [ebx],eax
	.endif
	
	mov	eax,hr
	ret
StringCbLengthA endp












