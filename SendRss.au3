;Bonus Script!
HotKeySet("{ESC}", "Terminate")
Func Terminate()
    msgbox(0,'Ending','Macro Ended')
    Exit
 EndFunc

$numstone = 12
$numsilver = 4

SendRss()
Func SendRss()
	WinActivate("Vikings: War of Clans | Plarium.com - Mozilla Firefox")
	sleep(1500)
	MouseClick("left",17, 361) ;Clicks edge of screen to close what is open
	sleep (1000)

	send('"s"') ; opens market
	sleep (1000)
	MouseClick("left",592, 405) ;Clicks in Search Bar
	sleep (1500)
	send('bank')
	sleep (1000)
	MouseClick("left",1249, 486) ;Send res button
	sleep (1000)

	while $numstone > 0
		MouseClick("left",811, 581) ;Clicks Stone Bar
		sleep (100)
		MouseClick("left",1160, 834) ;Clicks Stone Bar
		sleep (100)
		$numstone -=1
	WEnd

	while $numsilver > 0
		MouseClick("left",827, 666) ;Clicks Stone Bar
		sleep (100)
		MouseClick("left",1160, 834) ;Clicks Stone Bar
		sleep (100)
		$numsilver -=1
	WEnd

 EndFunc