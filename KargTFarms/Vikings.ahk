; Copyright 2017 Paul Cherny (vikingsunthar@gmail.com)
;
; Permission to use, copy, modify, and distribute this software and its documentation for any
; purpose and without fee is hereby granted, provided that the above copyright notice and this
; permission notice appear in all copies and supporting documentation.
;
; No representations are made about the suitability of this software for any purpose.  It is 
; provided "as is" without express or implied warranty.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global g_numTasks := 15

global g_sleep := 100

global g_stop := 0

WinActivate Vikings: War

Maximize() 

#IfWinActive, Vikings: War
^Escape::
{
	ExitApp
}
Return

#IfWinActive, Vikings: War
Escape::
{
	g_stop := 1
}
Return

#IfWinActive, Vikings: War
^1::
{
	g_stop := 0
	Send z
	Sleep %g_sleep%
	CompleteAllTask()
}
Return

#IfWinActive, Vikings: War
^t::
{
	CompleteTask()
}
Return

FindImageAndClick(img, FixX:=0, FixY:=0)
{	
	path = %A_WorkingDir%\images\%img%.bmp
	
	; MouseMove 200, -200, 20, R
	MouseMove 200, 100, 20
	Sleep %g_sleep%
	
	WinGetPos waX, way, waWidth, waHeight
	ImageSearch, FoundX, FoundY, 0, 0, %waWidth%, %waHeight%, *75 %path%

	if (FoundX>0)
	{
		HitX := FoundX + FixX
		HitY := FoundY + FixY
		MouseMove HitX, HitY
		Sleep %g_sleep%
		; MouseClick, left, FoundX, FoundY		
		Click HitX, HitY
		Sleep %g_sleep%
		Return 1
	}
	else
	{		
		; MouseMove -200, 0, 100, R
		; MouseMove 80, 80, 20
		Return 0
	}
	
}

NotifyUser(msg)
{
	logmsg = Calling NotifyUser(%msg%)
	; LogMessage(logmsg)
	TrayTip, InvaderBot, %msg%
}

Activate() {
	WinActivate Vikings: War
	WinMaximize Vikings: War
}

Maximize() {
	NotifyUser("Maximize")	
	Activate()
	Sleep 500
	; CloseNotify()
	Sleep 500
	FindImageAndClick("max", 8, 8)
}

CompleteTask() {
	if (g_stop = 0){
		NotifyUser("Complete task")
		Activate()	
		Loop
		{
			ActionCount := 0		
			ActionCount := ActionCount + FindImageAndClick("apply")

			Loop, %g_numTasks%
			{
				ActionCount := ActionCount + FindImageAndClick("start")
				ActionCount := ActionCount + FindImageAndClick("claim")
			}

			if (ActionCount=0) {
				break
			}

			if ( g_stop = 1){
				break
			}
		}
	}
}

CompleteAllTask() {
	if (g_stop = 0){	
		NotifyUser("Complete task")	
		aux := FindImagesAndClick("tasks-personal", "tasks-personal-inactive")
		if(aux> 0){
			CompleteTask()
		}
	}
	
	if (g_stop = 0){	
		aux := FindImagesAndClick("tasks-clan", "tasks-clan-inactive")
		if(aux> 0){
			CompleteTask()
		}
	}
	
	if (g_stop = 0){	
		aux := FindImagesAndClick("tasks-premiun", "tasks-premiun-inactive")
		if(aux> 0){
			CompleteTask()
		}
	}
}

FindImagesAndClick(params*) {
	aux := 0
 	for index,param in params
	 	aux := aux + FindImageAndClick(param)
	return aux
}

CloseNotify() {
	if (g_stop = 0){
		FindImageAndClick("close")
		FindImageAndClick("close")
		FindImageAndClick("close2")
		FindImageAndClick("close2")
	}
}