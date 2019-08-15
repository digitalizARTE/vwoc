; ------------------------------------------------------------------------------------------------
; InvaderBot v.01
; By Paul Cherny aka Sunthar (vikingsunthar@gmail.com)
; ------------------------------------------------------------------------------------------------
; Usage: CTRL+click on an invader to auto-attack.  Press ESC to exit InvaderBot.
;			You will probably need to update the sustained attack bonus value in InvaderBot.ahk 
;			to suite your Hero.
;
; Note: InvaderBot only works on invaders you can see without scrolling.
;
; Warning: Moving your mouse or clicking while InvaderBot is running will disturb InvaderBot.
;          Set AutoHotKey.exe to run as administrator if you want to prevent this.
;
; See README.txt for more information.
;
; Copyright 2017 Paul Cherny (vikingsunthar@gmail.com)
;
; Permission to use, copy, modify, and distribute this software and its documentation for any
; purpose and without fee is hereby granted, provided that the above copyright notice and this
; permission notice appear in all copies and supporting documentation.
;
; No representations are made about the suitability of this software for any purpose.  It is 
; provided "as is" without express or implied warranty.

; ------------------------------------------------------------------------------------------------
; You may need to tweak these values depending on your Hero, at least the sustained attack bonus.
; ------------------------------------------------------------------------------------------------

; Attack bonus percentage at which to start using sustained attack:
global g_sustainedAttackBonus := 540

; Refill energy using boosts when it drops below this amount:
; This is based on sustained hits damage, not actual energy, due to OCR issue
; Set this to 0 to never refill using boosts
global g_energyRefillThreshhold	:= 2500

; Maximum amount of time to wait, in seconds, for hero to walk to invader (or 0 to wait indefinately):
global g_maxWalkTime := 30							

; Maximum energy to refill up to:
global g_maxEnergy := 50000							

; This may need to be changed if a different version of Capture2Text is used
global g_Capture2TextFolderName := "Capture2Text_v4.3.0_64bit"

; ------------------------------------------------------------------------------------------------
; Only change things under here if you know what you are doing!
; ------------------------------------------------------------------------------------------------

#NoEnv						; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.

if not FileExist("Disclaimer.txt")
{
	disclaimer = Copyright 2017 Paul Cherny (vikingsunthar@gmail.com)`r`n`r`nPermission to use, copy, modify, and distribute this software and its`r`ndocumentation for any purpose and without fee is hereby granted, provided`r`nthat the above copyright notice and this permission notice appear in all`r`ncopies and supporting documentation.`r`n`r`nNo representations are made about the suitability of this software for any`r`npurpose.  It is provided "as is" without express or implied warranty.`r`n`r`nBy using this software you agree to abide by all terms of use as described`r`nin company.plarium.com/terms-of-use/

	MsgBox Usage: CTRL+click on an invader to activate InvaderBot. Press ESC to exit InvaderBot. You will probably need to update the sustained attack bonus value in InvaderBot.ahk to suite your Hero.`n`nNote: InvaderBot only works on invaders you can see without scrolling.`n`nWarning: Moving your mouse or clicking while InvaderBot is running will disturb InvaderBot. Set AutoHotKey.exe to run as administrator if you want to prevent this (see Tips section in README.txt).`n`n%disclaimer%`n`n----------------------------------------------------------------------------`n`nYou will not see this message again. See README.txt for more info.`n`n
	file := FileOpen("Disclaimer.txt", "w")
	if !IsObject(file)
	{
		MsgBox Can't open "%FileName%" for writing.
		return
	}
	file.Write(disclaimer)
	file.Close()
}

if not (FileExist("logs"))
{
	FileCreateDir, logs 
}

FormatTime, ts,, yyMMddHHmmss
logFilePath = logs\ib_%ts%.log
global g_logFile := logFilePath

f := FileOpen(g_logFile, "w")
if !IsObject(f)
{
	MsgBox Can't open log file "%FileName%" for writing.
}
else
{
	f.Close()
}

; used to hide the command window used for OCR
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")
WinActivate Vikings: War of Clans

WinGetPos, X, Y, Width, Height, Vikings: War of Clans
WinGetTitle, winTitle, Vikings: War of Clans
if (Height<>"" and Height<1100)
{
	MsgBox Current window height is %Height% pixels. Minimum recommended window height for InvaderBot is 1200 pixels (otherwise, the in-game popups interfere with InvaderBot).
}

path = %A_WorkingDir%\%g_Capture2TextFolderName%\Capture2Text_CLI.exe
global g_Capture2TextPath := path

if not FileExist(g_Capture2TextPath)
{
	MsgBox Cannot find Capture2Text in [%g_Capture2TextPath%] -- Make sure it exists and is in the same folder as InvaderBot.AHK
	ExitApp
}

NotifyUser("Starting InvaderBot")
logmsg = Title=[%winTitle%] X=[%X%], Y=[%Y%], Width=[%Width%], Height=[%Height%]
LogMessage(logmsg)

logmsg = g_sustainedAttackBonus=[%g_sustainedAttackBonus%] g_energyRefillThreshhold=[%g_energyRefillThreshhold%] g_maxWalkTime=[%g_maxWalkTime%] g_maxEnergy=[%g_maxEnergy%] g_Capture2TextFolderName=[%g_Capture2TextFolderName%]
LogMessage(logmsg)

#IfWinActive, Vikings: War of Clans
Escape::
{
	NotifyUser("Stopping InvaderBot")
	ExitApp
}
Return

LogMessage(msg)
{
	msg = %msg%`r`n
	FormatTime, ts,, yyyy-MM-dd HH:mm:ss
	FileAppend, %ts% %msg%, %g_logFile%
}

OCR(x1, y1, x2, y2)
{	
	logmsg = Calling OCR(%x1%,%y1%,%x2%,%y2%)
	LogMessage(logmsg)
	
	command = %comspec% /c ""%g_Capture2TextPath%" parameter "--screen-rect" "%x1% %y1% %x2% %y2%" parameter "|clip""	
	result := ComObjCreate("WScript.Shell").Exec(command).StdOut.ReadAll()
	StringReplace, result, result, `r, , All
	StringReplace, result, result, `n, , All
	logmsg = OCR() returning [%result%]
	LogMessage(logmsg)	
	
	Return %result%
}

CleanNumber(num)
{
	len := StrLen(num)
	logmsg = Calling CleanNumber(%num%) StrLen()=%len%
	LogMessage(logmsg)
		
	num := StrReplace(num," ","")
	num := StrReplace(num,",","")
	num := StrReplace(num,"+","")
	num := StrReplace(num,"%","")
	
	; lol, replace letter O with 0 (zero)
	num := StrReplace(num,"O","0") 
	num := StrReplace(num,"o","0")
	
	StringReplace,num,num,`r`n,,A
	
	num := num+0
	
	logmsg = CleanNumber() returning [%num%]
	LogMessage(logmsg)	
	
	Return %num%
}

ocrNumber(img,topLeftOffsetX,topLeftOffsetY,bottomRightOffsetX,bottomRightOffsetY)
{
	logmsg = Calling ocrNumber(%img%,%topLeftOffsetX%,%topLeftOffsetY%,%bottomRightOffsetX%,%bottomRightOffsetY%)
	LogMessage(logmsg)
	
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *75 %A_WorkingDir%\images\%img%.bmp	
	if (FoundX>0)
	{					
		FoundX := FoundX + topLeftOffsetX
		FoundY := FoundY + topLeftOffsetY
		FoundX2 := FoundX + bottomRightOffsetX
		FoundY2 := FoundY + bottomRightOffsetY
								
		num := OCR(FoundX,FoundY,FoundX2,FoundY2)				
		num := CleanNumber(num)
		result = %num%
	}
	else
	{
		result = ""
	}
	
	logmsg = ocrNumber() returning [%result%]
	LogMessage(logmsg)	
	
	Return %result%
}

LongClick(x,y)
{
	logmsg = Calling LongClick(%x%,%y%)
	LogMessage(logmsg)
	
	MouseClick, left, x, y, D
	Sleep, 200
	MouseClick, left, x, y, U
}

FindImageAndClick(img, longClick, moveX, moveY)
{	
	logmsg = Calling FindImageAndClick(%img%, %longClick%, %moveX%, %moveY%)
	LogMessage(logmsg)
	
	path = %A_WorkingDir%\images\%img%.bmp
	
	if (moveX>0 or moveY>0)
	{
		MouseMove moveX,moveY,100,R
		Sleep 350
	}
	
	ImageSearch, FoundX, FoundY, 0,0, A_ScreenWidth, A_ScreenHeight, *75 %path%
	
	if (FoundX>0)
	{
		MouseMove FoundX, FoundY		
		
		if (longClick=1)
		{
			LongClick(FoundX,FoundY)
		}
		else
		{
			MouseClick, left, FoundX, FoundY 
		}
		
		Sleep 150
		result = 1
	}
	else
	{
		MouseMove moveX*-1,moveY*-1,100,R
		result = 0
	}
	
	logmsg = FindImageAndClick() returning [%result%]
	LogMessage(logmsg)	
	
	Return %result%
}

; wait for img to appear on screen
; wait for up to maxTime seconds (or indefinately if maxTime=0)
; store found coords in FoundX and FoundY
; return 1 if found, 0 if not found
WaitFor(img1, img2, maxTime, ByRef FoundX, ByRef FoundY) 
{
	logmsg = Calling WaitFor(%img1%, %img2%, %maxTime%, ByRef FoundX, ByRef FoundY) 
	LogMessage(logmsg)
	
	delay := 500
	found := 0
	
	i := 0
	
	Loop
	{			
		if ((i*delay) > (maxTime*1000) or g_cancel=1)
		{
			break
		}
		ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *75 %A_WorkingDir%\images\%img1%.bmp				
		
		if (FoundX>0)
		{
			found := 1
			break
		}
		else if (img2<>"")
		{
			ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *75 %A_WorkingDir%\images\%img2%.bmp
			if (FoundX>0)
			{
				found := 1
				break
			}
		}
		
		i := i + 1
		
		SleepUnblock(delay)
	}

	logmsg = WaitFor() returning [%found%]
	LogMessage(logmsg)	
	
	Return %found%
}

MsgBoxUnblock(msg)
{
	logmsg = Calling MsgBoxUnblock(%msg%)
	LogMessage(logmsg)
	BlockInput, off
	MsgBox %msg%
}

NotifyUser(msg)
{
	logmsg = Calling NotifyUser(%msg%)
	LogMessage(logmsg)
	TrayTip, InvaderBot, %msg%
}

SleepUnblock(t)
{
	BlockInput, off
	Sleep, t
	BlockInput, on
}

Splash(msg)
{
	SplashTextOn, , , %msg%
	Sleep 1000
	SplashTextOff
}

ApplyEnergyBoost(img)
{
	logmsg = Calling ApplyEnergyBoost(%img%) 
	LogMessage(logmsg)
	
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *75 %A_WorkingDir%\images\%img%.bmp	

	if not (FoundX>0)
	{	
		LogMessage("Oops, could not find energy boost! Bailing out.")
		Return
	}
	
	x1 := FoundX + 356
	y1 := FoundY + 18
	x2 := x1 + 188
	y2 := y1 + 59
		
	; search for apply button
	ImageSearch, FoundX, FoundY, x1, y1, x2, y2, *75 %A_WorkingDir%\images\apply.bmp	
		
	if (FoundX>0)
	{		
		buttonX := x1+70
		buttonY := y1+35
		
		MouseMove buttonX,buttonY					; hover over apply button
		Sleep 300					
		
		MouseMove 0,46,100,R						; move to more button		
		Sleep 500
		Click										; click more button

		applyItem := WaitFor("numberofitems","",5,FoundX,FoundY) 
		if (applyItem=0)
		{
			LogMessage("Oops, could not find number of items! Bailing out.")
			Return
		}		
		
		FoundX := FoundX + 367
		FoundY := FoundY + 2
		
		LongClick(FoundX, FoundY)
		
		SetKeyDelay, 100, 300
		logmsg = In ApplyEnergyBoost() sending [9999]
		
		Send 9999									; send 9999 to determine maximum
		Sleep 200
		MouseMove 0,-100,100,R						; move mouse out of the way so as not to interfere with OCR
		Click
		
		numItems := ocrNumber("numberofitems", 328, -10, 100, 30)
		
		logmsg = In ApplyEnergyBoost() max items = [%numItems%]
		LogMessage(logmsg)
	
		if (numItems>0)
		{
			if (numItems>1)
			{
				numItems := numItems-1				; subtract one so as not to waste boosts
			}
			
			LongClick(FoundX, FoundY)

			logmsg = In ApplyEnergyBoost() sending [%numItems%]
			LogMessage(logmsg)			
			
			Send %numItems%							; send text
			SleepUnblock(200)

			result := FindImageAndClick("apply2",0,0,0)
			if (result=0)
			{
				LogMessage("Oops, could not find apply button! Bailing out.")
				Return
			}
		}
	}
}

RefillEnergySlave(img,max)
{
	logmsg = Calling RefillEnergySlave(%img%,%max%) 
	LogMessage(logmsg)

	purchaseEnergyDialog := WaitFor("herosenergy","",5,FoundX,FoundY) 
	if (purchaseEnergyDialog=0)
	{
		LogMessage("Oops, could not find purchase energy dialog! Bailing out.")
		Return
	}
	
	energy := ocrNumber("herosenergy", -5, 37, 123, 24)
	mustRefill := 0

	if (energy="")
	{
		mustRefill := 1
	}
	else
	{
		ImageSearch, FoundX, FoundY, 0,0,A_ScreenWidth,A_ScreenHeight, *75 %A_WorkingDir%\images\progressnotfull.bmp			
		if (FoundX>0)
		{	
			mustRefill := 1
		}
	}
	
	logmsg = In RefillEnergySlave() mustRefill=[%mustRefill%] energy=[%energy%] max=[%max%]
	LogMessage(logmsg)
	
	if (mustRefill=1 or (energy>0 and energy<=max))
	{
		ApplyEnergyBoost(img)
	}
}

RefillEnergy(maxEn)
{	
	logmsg = Calling RefillEnergy(%maxEn%) 
	LogMessage(logmsg)
	
	result := FindImageAndClick("add",1,100,0)
	if (result=0)
	{
		LogMessage("Oops, could not find add (energy) button! Bailing out.")
		Return
	}
	
	EnergyDialog := WaitFor("herosenergy","",5,FoundX,FoundY) 
	
	if (EnergyDialog=1)
	{		
		RefillEnergySlave("energy2000",maxEn-2000)			; apply 2,000 unit boosts	
		RefillEnergySlave("energy1000",maxEn-1000)			; apply 1,000 unit boosts
		RefillEnergySlave("energy500",maxEn-500)			; apply 500 unit boosts	
		Click WheelDown
		
		RefillEnergySlave("energy200",maxEn-200)			; apply 200 unit boosts	
		RefillEnergySlave("energy100",maxEn-100)			; apply 100 unit boosts	
		
		Sleep 300
		
		FindImageAndClick("closex",0,0,0)

		SleepUnblock(300)
	}
	else
	{
		LogMessage("Oops, could not find energy dialog. Bailing out.")
		Return
	}
}

DestroyInvader()
{
	NotifyUser("Destroying Invader")
	LogMessage("Calling DestroyInvader()")
	
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen

	g_cancel = 0
	
	MouseGetPos, targetX, targetY				; get invader coordinates	
	
	; wait until ctrl button is released before proceeding
	Loop
	{
		GetKeyState, state, Control
		if (state = "U")
		{
			break
		}
		Sleep 200
	}
	
	BlockInput, on								; this only works if running AutoHotKey.exe in admin mode
	
	AttackX := 0
	AttackY := 0
	Loop
	{			
		logmsg = Attempting to attack invader at coordinate %targetX%,%targetY%
		LogMessage(logmsg)
		
		MouseMove, %targetX%,%targetY%
		Sleep 1000
		MouseClick, left, targetX,targetY
		InvaderFound := WaitFor("invader1","invader2",3,FoundX,FoundY) 
	
		if (InvaderFound=1)
		{				
			CanAttack := WaitFor("normalattack","",g_maxWalkTime,AttackX,AttackY) 		
			if (CanAttack=1)
			{			
				energy := ocrNumber("enhancedattack", 31, -76, 68, 20)				
				if (energy>g_energyRefillThreshhold or g_energyRefillThreshhold=0)
				{					
					bonus := ocrNumber("attackbonus", 338, -7, 52, 16)					
					if (bonus=g_sustainedAttackBonus)
					{
						result := FindImageAndClick("enhancedattack",0,200,0)												
						if (result=0)
						{
							LogMessage("Oops, could not find enhanced attack button!")
						}
					}
					else
					{	
						MouseClick, left, AttackX, AttackY 
					}

					Sleep 300
					
					FindImageAndClick("close",0,0,0)
				}
				else
				{
					RefillEnergy(g_maxEnergy)
				}
			}
			else
			{
				NotifyUser("Timed out waiting to attack or the invader was destroyed.")
				break
			}
		}
		else
		{	
			Capture := WaitFor("capture","",3,FoundX,FoundY) 
			if (Capture=1)
			{
				NotifyUser("Invader destroyed!")
				break
			}
			else
			{
				Relocation := WaitFor("relocation","",1,FoundX,FoundY) 
				if (Relocation=1)
				{
					FindImageAndClick("closex2",0,0,0)
				}
				else
				{												
					NotifyUser("Invader not found or has been destroyed.")
					break
				}
			}			
		}		
	}	
	
	Loop
	{		
		result := FindImageAndClick("closex",0,0,0)
		if (result=0)
		{
			break
		}
		Sleep 500
	}
	
	LogMessage("DestroyInvader() Done.")
	
	BlockInput, off
}
Return

global g_cancel := 0

#IfWinActive, Vikings: War of Clans
~lbutton::
{
	if (g_cancel=0)
	{
		LogMessage("Detected mouse click. Setting cancel flag.")
		g_cancel = 1
	}
}
Return

#IfWinActive, Vikings: War of Clans
^lbutton::
{
	DestroyInvader()
}
Return

