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

FindImagesAndClick(params*) {
	aux := 0
 	for index, param in params
	 	aux := aux + FindImageAndClick(param)
	return aux
}

FindImageAndClick(img)
{	
	path = %A_WorkingDir%\images\%img%.bmp
	
	; MouseMove 200, -200, 20, R
	MouseMove 200, 100, 20
	Sleep %g_sleep%
	
	WinGetPos waX, way, waWidth, waHeight
	ImageSearch, FoundX, FoundY, 0, 0, %waWidth%, %waHeight%, *75 %path%

	if (FoundX>0)
	{
		MouseMove FoundX, FoundY, 20
		Sleep %g_sleep%
		; MouseClick, left, FoundX, FoundY		
		Click, FoundX, FoundY		
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

#IfWinActive, Vikings: War
^t::
{
	g_stop := 0
	LoopCompleteAllTask()
}
Return

#IfWinActive, Vikings: War
^3::
{
	g_stop := 0
	LoopCompleteAllPremiumTask()
}
Return

#IfWinActive, Vikings: War
^2::
{
	g_stop := 0
	LoopCompleteAllClanTask()
}
Return


#IfWinActive, Vikings: War
^1::
{
	g_stop := 0
	LoopCompleteAllPersonalTask()	
}
Return

LoopCompleteAllTask() {	
	local loopCnt := 0
	loop {
		OpenTasks()
		CompleteAllTask()
		loopCnt := loopCnt + 1
		
		if (g_stop = 1) {
			Break
		}

		if (loopCnt >= 3) {
			Break
		}		
	}
}

LoopCompleteAllPersonalTask() {	
	local loopCnt := 0
	loop {
		CompleteAllPersonalTask()
		loopCnt := loopCnt + 1
		
		if (g_stop = 1) {
			Break
		}

		if (loopCnt >= 3) {
			Break
		}		
	}
}

CompleteAllPersonalTask() {	
	if (g_stop = 0){
		OpenTasks()
		; FindImagesAndClick("tasks-personal", "tasks-personal-inactive")
		; FindImagesAndClick("tasks-personal", "tasks-personal-inactive")
		FindImageAndClick("tasks-personal")
		FindImageAndClick("tasks-personal-inactive")
		CompleteAllTask()
	}
}

LoopCompleteAllClanTask() {	
	local loopCnt := 0
	loop {
		CompleteAllClanTask()	
		loopCnt := loopCnt + 1
		
		if (g_stop = 1) {
			Break
		}

		if (loopCnt >= 3) {
			Break
		}		
	}	
}

CompleteAllClanTask() {	
	if (g_stop = 0){
		OpenTasks()		
		; FindImagesAndClick("tasks-clan", "tasks-clan-inactive")
		; FindImagesAndClick("tasks-clan", "tasks-clan-inactive")
		FindImageAndClick("tasks-clan")
		FindImageAndClick("tasks-clan-inactive")
		CompleteAllTask()
	}
}

LoopCompleteAllPremiumTask() {	
	local loopCnt := 0
	loop {
		CompleteAllPersonalTask()	
		loopCnt := loopCnt + 1
		
		if (g_stop = 1) {
			Break
		}

		if (loopCnt >= 3) {
			Break
		}		
	}
}

CompleteAllPremiumTask() {	
	if (g_stop = 0){
		OpenTasks()
		FindImagesAndClick("tasks-premium", "tasks-premium-inactive")
		FindImagesAndClick("tasks-premium", "tasks-premium-inactive")
		CompleteAllTask()
	}
}

CompleteAllTask() {	
	if (g_stop = 0){
		; WinActivate Vikings: War
		Loop
		{
			MouseMove 200, 100, %g_sleep%
			ActionCount := 0	
			
			ActionCount := ActionCount + FindImageAndClick("apply")				
			ActionCount := ActionCount + FindImageAndClick("apply")	
			ActionCount := ActionCount + CompleteTask()

			if (ActionCount = 0){
				break
			}

			if ( g_stop = 1){
				break
			}
		}
	}
}

CompleteTask() {	
	ActionCount := 0
	if (g_stop = 0){
		Loop, %g_numTasks%
		{
			ActionCount := ActionCount + FindImageAndClick("start")
			ActionCount := ActionCount + FindImageAndClick("claim")

			if (g_stop = 1){
				break
			}
		}	
	}

	return ActionCount
}

OpenTasks() {
	WinActivate Vikings: War
	Send z
	Sleep 500
}
