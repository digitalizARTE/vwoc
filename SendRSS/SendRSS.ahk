; Copyright 2017 Paul Cherny (vikingsunthar@gmail.com)
;
; Permission to use, copy, modify, and distribute this software and its documentation for any
; purpose and without fee is hereby granted, provided that the above copyright notice and this
; permission notice appear in all copies and supporting documentation.
;
; No representations are made about the suitability of this software for any purpose.  It is 
; provided "as is" without express or implied warranty.

; Press CTRL-T at the stronghold send resources screen and it will prompt you for the resource to send
; Press ESC to exit

global g_rssPerMarch := 999999999
; global g_delayBetweenMarches := 5000
global g_delayBetweenMarches := 23 * 2 * 1000 / 7 * 1.15

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WinActivate Vikings: War of Clans

Global g_ScreenWidth := 1600 ; A_ScreenWidth
Global g_ScreenHeight := 900 ; A_ScreenHeight

global g_sleep := 100

global g_stop := 0

global g_resource_food := 1
global g_resource_lumber := 2
global g_resource_iron := 3
global g_resource_stone := 4
global g_resource_silver := 5

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

#IfWinActive, Vikings: War of Clans
^t::
{	
	g_stop := 0
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen

	InputBox, UserInput, Specify Resouce Type, Which resource type would you like to send?`r`r"1" for food`r"2" for lumber`r"3" for iron`r"4" for stone`r"5" for silver`r, , 200, 320

 	if (UserInput=""){
 		return
	}

	WinActivate Vikings: War
	SendRSS(UserInput)
}
Return

#IfWinActive, Vikings: War of Clans
^1::
{	
	TrayTip, Send Rss, Send Food
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_food) 
}
Return

#IfWinActive, Vikings: War of Clans
^2::
{	
	TrayTip, Send Rss, Send Lumber
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_lumber) 
}
Return

#IfWinActive, Vikings: War of Clans
^3::
{	
	TrayTip, Send Rss, Send Iron
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_iron) 
}
Return

#IfWinActive, Vikings: War of Clans
^4::
{	
	TrayTip, Send Rss, Send Stone
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_stone) 
}
Return

#IfWinActive, Vikings: War of Clans
^5::
{	
	TrayTip, Send Rss, Send Silver
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_silver) 
}
Return

#IfWinActive, Vikings: War of Clans
^a::
{	
	TrayTip, Send Rss, Send Food
	g_stop := 0
	WinActivate Vikings: War
	SendRSS(g_resource_food) 

	if ( g_stop = 0){
		TrayTip, Send Rss, Send Lumber
		WinActivate Vikings: War
		SendRSS(g_resource_lumber) 
	}

	if ( g_stop = 0){
		TrayTip, Send Rss, Send Iron
		WinActivate Vikings: War
		SendRSS(g_resource_iron) 
	}

	if ( g_stop = 0){
		TrayTip, Send Rss, Send Stone
		WinActivate Vikings: War
		SendRSS(g_resource_stone) 
	}

	if ( g_stop = 0){
		TrayTip, Send Rss, Send Silver
		WinActivate Vikings: War
		SendRSS(g_resource_silver) 
	}
}
Return

SendRSS(resource) {
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen
	img := GetResourceName(resource)

	if (resource>g_resource_lumber)
	{
		path = %A_WorkingDir%\images\sendAnchor.bmp
		ImageSearch, sendAnchorX, sendAnchorY, 0,0, g_ScreenWidth, g_ScreenHeight, *75 %path%
		
		MouseMove, sendAnchorX-100, sendAnchorY-100, 50		
		Click WheelDown
		Sleep 250

		MouseMove, sendAnchorX-100, sendAnchorY-100, 50		
		Click WheelDown
		Sleep 250

		MouseMove, sendAnchorX-100, sendAnchorY-100, 50		
		Click WheelDown
		Sleep 250

		MouseMove, sendAnchorX-100, sendAnchorY-100, 50		
		Click WheelDown
		Sleep 250
	}

	path = %A_WorkingDir%\images\%img%.bmp

	Sleep 250
	
	ImageSearch, FoundX, FoundY, 0,0, g_ScreenWidth, g_ScreenHeight, *75 %path%
		
	if (FoundX>0)
	{		
		textX := FoundX+300
		textY := FoundY+35
		
		Loop
		{
			if ( g_stop = 1){
				break
			}

			MouseMove, textX, textY, 50
			Sleep 250
			MouseClick, left, , ,D
			Sleep 250
			MouseClick, left, , ,U
			Sleep 250
			Send %g_rssPerMarch%
			Sleep 250
			
			FoundX := 0
			FoundY := 0
			
			path = %A_WorkingDir%\images\sendAnchor.bmp
			ImageSearch, sendAnchorX, sendAnchorY, 0,0, g_ScreenWidth, g_ScreenHeight, *75 %path%
			
			If(sendAnchorX>0)
			{
				FoundX := sendAnchorX-80
				FoundY := sendAnchorY+140
			}
			else If(Send1X>0)
			{
				FoundX := Send2X
				FoundY := Send2Y
			}
						
			If (FoundX>0)
			{
				MouseClick, left, FoundX, FoundY
				Sleep %g_delayBetweenMarches%
				
				path = %A_WorkingDir%\images\maximum.bmp
			
				ImageSearch, FoundX, FoundY, 0,0, g_ScreenWidth, g_ScreenHeight, *75 %path%
				
				If (FoundX>0)
				{
					path = %A_WorkingDir%\images\close.bmp
			
					ImageSearch, FoundX, FoundY, 0,0, g_ScreenWidth, g_ScreenHeight, *75 %path%
					
					If (FoundX>0)
					{						
						MouseMove, %FoundX% , %FoundY% 	
						MouseClick, left,,,D
						Sleep 250
						MouseClick, left,,,U
					}
					Else
					{
						MsgBox Couldn't find close button.
						break
					}
				}
			}
			else
			{
				MsgBox Couldn't find send button.
				break
			}
		}
	} else {
		MsgBox No se encontro el recurso
	}		
}

GetResourceName(resource) {
	name := ""
	
	if (resource=g_resource_food)
	{
		name := "food"		
	}
	else if (resource=g_resource_lumber)
	{
		name := "lumber"		
	}
	else if (resource=g_resource_iron)
	{
		name := "iron"		
	}
	else if (resource=g_resource_stone)
	{
		name := "stone"		
	}
	else if (resource=g_resource_silver)
	{
		name := "silver"		
	}

	Return name
}