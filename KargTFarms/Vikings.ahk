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

Maximize() 

#IfWinActive, Vikings: War
Escape::
{
	ExitApp
}
Return

FindImageAndClick(img, FixX:=0, FixY:=0)
{	
	path = %A_WorkingDir%\images\%img%.bmp
	
	; Random, OutputVar, Min, Max
	MouseMove 200, 0, 20, R
	Sleep 100

	ImageSearch, FoundX, FoundY, 0,0, 1600, 900, *75 %path%

	if (FoundX>0)
	{
		HitX := FoundX + FixX
		HitY := FoundY + FixY
		MouseMove HitX, HitY
		Sleep 200
		Click HitX, HitY
		Sleep 100
		Return 1
	}
	else
	{		
		MouseMove -200, 0, 100, R
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
	CloseNotify()
	Sleep 500
	FindImageAndClick("max", 8, 8)
}

CompleteTask() {	
	NotifyUser("Complete task")	
	Loop
	{
		ActionCount := 0		
		ActionCount := ActionCount + FindImageAndClick("apply")

		Loop, %g_numTasks%
		{
			ActionCount := ActionCount + FindImageAndClick("start")
			ActionCount := ActionCount + FindImageAndClick("claim")
		}

		if (ActionCount=0)
			break
	}
}

CompleteAllTask() {	
	NotifyUser("Complete task")	
	aux := FindImagesAndClick("tasks-personal", "tasks-personal-inactive")
	if(aux> 0){
		CompleteTask()
	}
	
	aux := FindImagesAndClick("tasks-clan", "tasks-clan-inactive")
	if(aux> 0){
		CompleteTask()
	}
	
	aux := FindImagesAndClick("tasks-premiun", "tasks-premiun-inactive")
	if(aux> 0){
		CompleteTask()
	}
}

FindImagesAndClick(params*) {
	aux := 0
 	for index,param in params
	 	aux := aux + FindImageAndClick(param)
	return aux
}

CloseNotify() {
	FindImageAndClick("close")
	FindImageAndClick("close")
	FindImageAndClick("close2")
	FindImageAndClick("close2")
}

#IfWinActive, Vikings: War
^1::
{
	Send z
	CompleteAllTask()
}
Return

#IfWinActive, Vikings: War
^t::
{
	CompleteTask()
}
Return