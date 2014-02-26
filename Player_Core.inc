;typedef DWORD OAFilterState;



;/* 获取歌曲长度字符串(ANSC)，只是方便显示 */
Get_Length_StringA PROTO lpszLength:DWORD,sizeof_szLength_in_characters:DWORD

;/* 获取歌曲长度字符串(UniCode),第二个参数为szWLength所能容纳的字符个数*/
Get_Length_StringW PROTO lpWLength:DWORD,sizeof_szWLength_in_characters:DWORD


;/*获取当前和剩余时间*/
GetCurrentAndRemainA PROTO  szCurrent:DWORD,sizeof_szCurrent_in_characters:DWORD,\
						szRemain:DWORD,sizeof_szRemain_in_characters:DWORD
												
GetCurrentAndRemainW PROTO  szWCurrent:DWORD,sizeof_szWCurrent_in_characters:DWORD,\
						 szWRemain:DWORD,sizeof_szWRemain_in_characters:DWORD



;/* 获取歌曲长度,一秒为单位 */
;Get_Length(int *);
Get_Length PROTO llength:DWORD



;/* 播放 */
Play_Music PROTO



;/* 暂停 */
Pause_Music PROTO




;/* 停止 */
Stop_Music PROTO



;/*指定音乐文件*/
SpecifyMusicFileA PROTO szMusicFile:DWORD
SpecifyMusicFileW PROTO WszMusicFile:DWORD




;/* 设置播放速率 */
SetMusicRate PROTO dRate:Real8




;/*设置声道平衡(-10000~0~10000),0则左右声道平衡。10000则左声道无声，-10000则右声道无声*/
SetPlayerBalance PROTO lBalance:DWORD




;/*设置音量(-10000~0),0为最大。-10000则静音*/
SetPlayerVolume PROTO lVolume:DWORD



;/*获取音量(-10000~0),0为最大。-10000则静音*/
;GetPlayerVolume(long *plVolume);
GetPlayerVolume PROTO plVolume:DWORD



;/*获取当前播放位置,以秒为单位*/
;GetPlayerCurrentPosition(int *pCurrentPosition);
GetPlayerCurrentPosition PROTO pCurrentPosition:DWORD



;/*设置播放位置,以秒为单位*/ 
SetPlayerPosition PROTO newPosition:DWORD




;/*获取当前状态
;typedef enum _FilterState
;{   
;    State_Stopped   = 0,
;    State_Paused    = State_Stopped + 1,
;    State_Running   = State_Paused + 1
;} FILTER_STATE;
;*/

;GetCurrentState(OAFilterState *pFilterState); 
GetCurrentState PROTO pFilterState:DWORD

IF      UNICODE
        
SpecifyMusicFile EQU <SpecifyMusicFileW>
Get_Length_String EQU <Get_Length_StringW>
GetCurrentAndRemain EQU <GetCurrentAndRemainW>
        
ELSE
        
SpecifyMusicFile EQU <SpecifyMusicFileA>
Get_Length_String EQU <Get_Length_StringA>    
GetCurrentAndRemain EQU <GetCurrentAndRemainA>    
ENDIF



