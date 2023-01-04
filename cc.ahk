; /////////////////////////////////// Script for Cookie Clicker

; ============================== Setup
#NoEnv
#SingleInstance force
#MaxThreadsPerHotkey 1
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2

Hotkey, IfWinActive, Cookie Clicker
Hotkey, a, click
Hotkey, s, delay
Hotkey, v, coord1
Hotkey, b, buy
Hotkey, n, coord2
Hotkey, g, checkGolden
Hotkey, h, setHome
Hotkey, x, close
Hotkey, i, info

Gui, Color, 00ADEF
Gui, +Disabled +LastFound +AlwaysOnTop +Border +Owner -SysMenu
; no interact, winset target, not hidden on click, show outline, not on taskbar, no minimize etc.
WinSet, TransColor, 00ADEF

; ------------------------- Variables
AToggle := false
AState := "off"
ADelay := 50

BToggle := false
BState := "off"
bx := 0
by := 0
x1 := 0
y1 := 0
x2 := 0
y2 := 0

GToggle := false
GState := "off"
gx := 0
gy := 0

hx := 300
hy := 450
ThisTitle := "Cookie Clicker Autobuy"

; ============================== Functions
MsgBox, , %ThisTitle%, %A_ScriptName% started... {i} for info, 5
SetTimer, checkActive, 1000

TurnOff:
AToggle := false
BToggle := false
GToggle := false
return

saveToggles() {
	global AToggle
	global BToggle
	global GToggle
	global sAToggle
	global sBToggle
	global sGToggle
	sAToggle := AToggle
	sBToggle := BToggle
	sGToggle := GToggle
	AToggle := false
	BToggle := false
	GToggle := false
}
return

loadToggles() {
	global AToggle
	global BToggle
	global GToggle
	global sAToggle
	global sBToggle
	global sGToggle
	AToggle := sAToggle
	BToggle := sBToggle
	GToggle := sGToggle
}
return

setToggleStates() {
	global AToggle
	global BToggle
	global GToggle
	global AState
	global BState
	global GState
	AState := AToggle ? "on" : "off"
	BState := BToggle ? "on" : "off"
	GState := GToggle ? "on" : "off"
}
return

showBox() {
	global x1
	global y1
	global x2
	global y2
	if Min(x1, y1, x2, y2) > 0 {
		Gosub ShowGui
		SetTimer, HideGui, -2000
	}
}
return

ShowGui:
w := Ceil(Abs(x2 - x1) * 0.8)
h := Ceil(Abs(y2 - y1) * 0.8)
xx := Min(x1, x2) - 10
yy := Min(y1, y2) - 40
Gui, Show, x%xx% y%yy% w%w% h%h% NoActivate, Buy Region
return

HideGui:
Gui, Hide
return

Tt(msg) {
	Tooltip, %msg%, 50, 50
	SetTimer, RemoveTooltip, -1000
}
return
RemoveTooltip:
Tooltip
return

GoHome:
Click, %hx% %hy%, 0
return

; ------------------------- Info Box
info:
setToggleStates()
saveToggles()
MsgBox, 64, %ThisTitle%,
(
// While Cookie Clicker is Active //
{i} -> Information (this)
{x} -> Close program/turn all toggles off
{h} -> Set home location (current: %hx%, %hy%)

{v} -> Set buy corner 1 (current: %x1%, %y1%)
{n} -> Set buy corner 2 (current: %x2%, %y2%)
{b} -> Toggle buying (current: %BState%)

{a} -> Toggle clicking (current: %AState%)
{s} -> Set delay (current: %ADelay%ms)

{g} -> Toggle golden cookie search (current: %GState%)

// Anytime //
{Ctrl+x} -> Close program
)
loadToggles()
Tt("Functions resumed.")
return

; ------------------------- Exit
^x::Gosub close
close:
Gosub TurnOff
Tt("Functions stopped.")
MsgBox, 17, %ThisTitle%, Exit %A_ScriptName%?,
IfMsgBox, OK
	ExitApp
MsgBox, , %ThisTitle%, Script continuing..., 1
return

; ------------------------- Disable on unactive
checkActive:
if WinActive("Cookie Clicker") {
	WinWaitNotActive, Cookie Clicker
	Gosub TurnOff
	Tt("Functions stopped.")
}
return

; ------------------------- Home
setHome:
MouseGetPos, hx, hy
Tt("Home set.")
return

; ------------------------- Autobuy Buildings
buy:
BToggle := !BToggle
if BToggle {
	SetTimer, bLoop, 100
	Tt("Building clicker on.")
} else {
	SetTimer, bLoop, Off
	Tt("Building clicker off.")
}
return
bLoop:
PixelSearch, px, py, Max(x1,x2), Max(y1,y2), Min(x1,x2), Min(y1,y2), 0xFFFFFF, , Fast
if !ErrorLevel and BToggle {
	Click, %px% %py%
	Tt("Bought building.")
	Gosub GoHome
}
Sleep BDelay
return

coord1:
MouseGetPos, x1, y1
Tt("Coord 1 set.")
ShowBox()
return

coord2:
MouseGetPos, x2, y2
Tt("Coord 2 set.")
ShowBox()
return

; ------------------------- Autoclick
click:
AToggle := !AToggle
if AToggle {
	SetTimer, aLoop, %ADelay%
	Tt("Autoclicker on.")
} else {
	SetTimer, aLoop, Off
	Tt("Autoclicker off.")
}
return
aLoop:
Send {LButton}
Sleep ADelay
return 

delay:
InputBox, ADelay, %ThisTitle%, New autoclick delay (ms), , , , , , , , %ADelay%
if ADelay is not number
	delay := 50
return

; ------------------------- Golden
checkGolden:
GToggle := !GToggle
if GToggle {
	SetTimer, gLoop, 1500
	Tt("Golden clicker on.")
} else {
	SetTimer, gLoop, Off
	Tt("Golden clicker off.")
}
return
gLoop:
Tt("Looking for golden cookies...")
Loop 5 {
	PixelSearch, gx, gy, 0, 0, A_ScreenWidth, A_ScreenHeight, 0x66C2DC, 1, Fast
	if !ErrorLevel and GToggle {
		Click, %gx% %gy%
		Tt("Found golden cookie!")
		Gosub GoHome
		Sleep 100
	}
}
return