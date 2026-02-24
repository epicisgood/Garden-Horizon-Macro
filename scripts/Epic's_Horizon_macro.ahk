#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir A_ScriptDir . "\.."
KeyDelay := 40

Setkeydelay KeyDelay

GetRobloxClientPos()
pToken := Gdip_Startup()
bitmaps := Map()
bitmaps.CaseSense := 0
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

WKey:="sc011" ; w
AKey:="sc01e" ; a
SKey:="sc01f" ; s
Dkey:="sc020" ; d


RotLeft := "vkBC" ; ,
RotRight := "vkBE" ; .
RotUp := "sc149" ; PgUp
RotDown := "sc151" ; PgDn
ZoomIn := "sc017" ; i
ZoomOut := "sc018" ; o
Ekey := "sc012" ; e
Rkey := "sc013" ; r
Lkey := "sc026" ; l
EscKey := "sc001" ; Esc
EnterKey := "sc01c" ; Enter
SpaceKey := "sc039" ; Space
SlashKey := "vk6F" ; /
SC_LShift:="sc02a" ; LShift



#Include "%A_ScriptDir%"
#include ..\lib\

#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include roblox.ahk
#Include ComVar.ahk
#Include Promise.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk

#Include ..\images\
#include bitmaps.ahk
#include ..\scripts\

#Include gui.ahk
#Include webhook.ahk
#Include timers.ahk




;@Ahk2Exe-AddResource Gui\index.html, Gui\index.html
;@Ahk2Exe-AddResource Gui\script.js, Gui\script.js
;@Ahk2Exe-AddResource Gui\style.css, Gui\style.css
;@Ahk2Exe-AddResource ..\Lib\32bit\WebView2Loader.dll, 32bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\Lib\64bit\WebView2Loader.dll, 64bit\WebView2Loader.dll


HyperSleep(ms) {
    static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
    DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
    current := 0, finish := begin + ms * freq / 1000
    while (current < finish) {
        if ((finish - current) > 30000) {
            DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
        }
        DllCall("QueryPerformanceCounter", "Int64*", &current)
    }
}

Walk(studs, MoveKey1, MoveKey2:=0) {
	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
	Sleep studs
	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
}

CheckDisconnnect(){
    static VipLink := IniRead(settingsFile, "Settings", "VipLink")
    hwnd := GetRobloxHWND()
    GetRobloxClientPos()
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1 || GetRobloxHWND() == 0)  {
        PlayerStatus("Starting Garden Horizon", "0x00a838", ,false, ,false)    
        Gdip_DisposeImage(pBMScreen)
        CloseRoblox()
        PlaceID := 130594398886540

        linkCode := ""
        shareCode := ""

        if RegExMatch(VipLink, "privateServerLinkCode=(\d+)", &match)
            linkCode := match[1]
        else if RegExMatch(VipLink, "code=([a-f0-9]+)&type=Server", &match)
            shareCode := match[1]
        
        if linkCode {
        DeepLink := "roblox://placeID=" PlaceID "&linkCode=" linkCode
        } else if shareCode {
            DeepLink := "https://www.roblox.com/share?code=" shareCode "&type=Server"
        } else {
            DeepLink := "roblox://placeID=" PlaceID
        }
        try Run DeepLink

        loop 60 {
            if GetRobloxHWND() {
                Sleep(500)
                for hwnd in WinGetList(,, "Program Manager")
                {
                    p := WinGetProcessName("ahk_id " hwnd)
                    if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                        continue ; skip roblox and AHK windows
                    title := WinGetTitle("ahk_id " hwnd)
                    if (title = "")
                        continue ; skip empty title windows
                    s := WinGetStyle("ahk_id " hwnd)
                    if ((s & 0x8000000) || !(s & 0x10000000))
                        continue ; skip NoActivate and invisible windows
                    s := WinGetExStyle("ahk_id " hwnd)
                    if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                        continue ; skip ToolWindow and AlwaysOnTop windows
                    try
                    {
                        WinActivate "ahk_id " hwnd
                        WinMaximize("ahk_id " hwnd)
                        Sleep 500
                        Send "^{w}"
                    }
                    break
                }
                Sleep(500)
                ActivateRoblox()
                Sleep(10000)
                ActivateRoblox()
                ResizeRoblox()
                GetRobloxClientPos(GetRobloxHWND())
                relativeMouseMove(0.5,0.5)
                Click
                Send("w")
                Sleep(4000)
                relativeMouseMove(0.5,0.86)
                Sleep(500)
                Click
                Click
                Sleep(1000)
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Sleep(1000)
                Send("{Tab}")
                Sleep(300)
                CloseChat()
                Sleep(1500)
                return 1
            }
            Sleep(1000)
        }
        if (A_Index == 60){
            Sleep(500)
            for hwnd in WinGetList(,, "Program Manager")
            {
                p := WinGetProcessName("ahk_id " hwnd)
                if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                    continue ; skip roblox and AHK windows
                title := WinGetTitle("ahk_id " hwnd)
                if (title = "")
                    continue ; skip empty title windows
                s := WinGetStyle("ahk_id " hwnd)
                if ((s & 0x8000000) || !(s & 0x10000000))
                    continue ; skip NoActivate and invisible windows
                s := WinGetExStyle("ahk_id " hwnd)
                if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                    continue ; skip ToolWindow and AlwaysOnTop windows
                try
                {
                    WinActivate "ahk_id " hwnd
                    WinMaximize("ahk_id " hwnd)
                    Sleep 500
                    Send "^{w}"
                }
                break
            }
            Sleep(500)
        }
        Gdip_DisposeImage(pBMScreen)
        return 0

    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }
}


CloseChat(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.25 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Chat"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}



openBag(){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.5 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Openbag"] , &OutputList, , , , , 100,,8) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + 2
        y := Cords[2] + windowY + 2
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}

closeBag(){
    relativeMouseMove(0.95, 0.5)
    Click
    Sleep(500)
}

clearSearch(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 "|" windowY + 30 "|" windowWidth // 2 "|" windowHeight - 30)
    ; Change X to Search Icon To select the search bar
    if (Gdip_ImageSearch(pBMScreen, bitmaps["x"] , &OutputList, , , , , 25,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["x2"] , &OutputList, , , , , 25,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 31
        MouseMove(x, y)
        Sleep(750)
        Click
        Click
        Sleep(250)
        Send("{Backspace}")
        Sleep(500)
    }
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Favorite"] , &OutputList, , , , , 20,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(750)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}


searchItem(keyword){
    keyword := StrReplace(keyword, " ", "%S+")
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    openBag()
    Sleep(1000)
    clearSearch()
    Sleep(1000)
    cordx := 0
    cordy := 0
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Search"] , &OutputList, , , , , 50) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        cordx := x
        cordy := y
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
        Send(keyword)
        Sleep(500)
        Gdip_DisposeImage(pBMScreen)
    } else {
        PlayerStatus("Could not detect Search in inventory", "0xFF0000")
        Gdip_DisposeImage(pBMScreen)
    }
}

clickItem(keyword, searchbitmap){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    Sleep(500)
    if (searchbitmap == "Bracket"){
        capX := windowX
        capY := windowY + 200 + windowHeight - 600
        capW := windowWidth
        capH := windowHeight - (400 + windowHeight - 600)
        pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Bracket2"], &OutputList, , , , , 20) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX + 4
            y := Cords[2] + capY + 4
            MouseMove(x, y)
            Sleep(250)
            Click
            Sleep(250)
            Gdip_DisposeImage(pBMScreen)
            closeBag()
            return true
        }
        Gdip_DisposeImage(pBMScreen)
    }
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)

    if (Gdip_ImageSearch(pBMScreen, bitmaps[searchbitmap], &OutputList, , , , , 20) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX + 4
        y := Cords[2] + capY + 4
        MouseMove(x, y)
        Sleep(250)
        Click
        Sleep(250)
        Gdip_DisposeImage(pBMScreen)
        if !(searchbitmap == "Recall Wrench"){
            closeBag()
        }
        return true
    } else {
        PlayerStatus("Missing " keyword " in inventory!", "0xff0000")
        Gdip_DisposeImage(pBMScreen)
        closeBag()
        return false
    }
}


clickCategory(category){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[category] , &OutputList, , , , , 100) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}


equipRecall(){
    searchItem("recall")

    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Recall Wrench"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Send("{Click down}")
        Sleep(300)
    }
    Gdip_DisposeImage(pBMScreen)

    pBMScreen := Gdip_BitmapFromScreen(
        windowX "|" 
        windowY + windowHeight - (windowHeight // 8) - 35 "|" 
        windowWidth * 0.4 "|" 
        windowHeight // 8
    )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["recall slot"] , &OutputList, , , , , 30,,6) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["recall slot2"] , &OutputList, , , , , 30,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + windowHeight - (windowHeight // 8) 
        MouseMove(x, y)
        Sleep(300)
        Send("{Click up}")
        Sleep(300)
    }
    Send("{Click up}")
    Sleep(500)
    clearSearch()
    closeBag()
    Gdip_DisposeImage(pBMScreen)

}



CheckSetting(item,value){
    if (IniRead(settingsFile, item, value) == 1){
        return true
    }
    return false
}


relativeMouseMove(relx, rely) {
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    moveX := windowX + Round(relx * windowWidth)
    moveY := windowY + Round(rely * windowHeight)
    MouseMove(moveX,moveY)
}


;   Haystack search Direction
;     Vertical preference:
;       1 = top->left->right->bottom [default]
;       2 = bottom->left->right->top
;       3 = bottom->right->left->top
;       4 = top->right->left->bottom
;     Horizontal preference:
;       5 = left->top->bottom->right
;       6 = left->bottom->top->right
;       7 = right->bottom->top->left
;       8 = right->top->bottom->left

Clickbutton(button, clickit := 1){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)    
    
    if (button == "Garden" || button == "Sell" || button == "Seeds"){
        capX := windowX + (windowWidth // 4)
        capY := windowY + 30
        capW := windowWidth // 2
        capH := 100
        varation := 10
        direction := 7
    } else if (button == "Robux"){
        capX := windowX + windowWidth // 4
        capY := windowY 
        capW := windowWidth //2
        capH := windowHeight
        varation := 10
        direction := 7
    }

    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , varation,,direction) = 1) {
        if (clickit == 1){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX - 2
            y := Cords[2] + capY - 2
            MouseMove(x, y)
            Sleep(100)
            Click
        }
        Gdip_DisposeImage(pBMScreen)
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}



ChangeCamera(type){
    Send("{" EscKey "}")
    HyperSleep(750)
    Send("{Tab}")
    HyperSleep(333)
    loop 10 {
        Send("{Up}")
        Sleep(50)
    }
    Sleep(150)
    Send("{Down}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    checkCamera(type)
    Send("{" EscKey "}")
    HyperSleep(1000)
}


checkCamera(type){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    loop 8 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
        if (Gdip_ImageSearch(pBMScreen, bitmaps[type] , , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return 1
        } else {
            Send("{Right}")
            Sleep(1000)
            Gdip_DisposeImage(pBMScreen)
        }
    }

}




ZoomAlign(){
    relativeMouseMove(0.5,0.5)
    Click
    Loop 40 {
        Send("{WheelUp}")
        Sleep 20
    }

    Sleep(500)
    Loop 6 {
        Send("{WheelDown}")
        Sleep 50
    }
    Sleep(100)
    Click
    Sleep(250)
}


CameraCorrection(){
    if (Disconnect()){
        Sleep(1500)
        ; equipRecall()
        Sleep(500)
    }

    Clickbutton("Garden")
    CloseClutter()
    Sleep(300)
    ChangeCamera("Follow")

    ZoomAlign()

    Click("Right", "Down")
    Sleep(200)
    relativeMouseMove(0.5, 0.5)
    Sleep(200)
    MouseMove(0, 800, 10, "R")
    Sleep(200)
    Click("Right", "Up")
    Sleep(250)

    loop 5 {
        Clickbutton("Sell") 
        Sleep(500)
        Clickbutton("Seeds") 
        Sleep(500)
    }
    Sleep(500)
    Clickbutton("Seeds")
    Sleep(250)

    ChangeCamera("Classic")
    Sleep(1000)
    relativeMouseMove(0.5,0.5)
    Sleep(500)
    PlayerStatus("Finished Aligning!","0x2260e6",,false,,false)
}

SpamClick(amount){
    loop amount {
        Click
        Sleep 20
    }
}








CheckStock(index, list){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    
    captureX := windowX + windowWidth * 0.43
    captureWidth := windowWidth * 0.1
    if (index == 1){
        captureY := windowY + windowHeight * 0.25
        captureHeight := windowHeight * 0.35
    } else if (index == 2){
        captureY := windowY + windowHeight * 0.5
        captureHeight := windowHeight * 0.25
    } else {
        captureY := windowY + windowHeight * 0.6
        captureHeight := windowHeight * 0.25
    }
    
    x := 0
    y := 0
    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    If (Gdip_ImageSearch(pBMScreen, bitmaps["NoStock"], , , , , , 25) = 1) {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }
    IsStock := false

    If (Gdip_ImageSearch(pBMScreen, bitmaps["ClickedGreenStock"], &OutputList , , , , , 25) = 1) {
        IsStock := true
    } else If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList , , , , , 25) = 1) {
        IsStock := true
    } else if (Gdip_ImageSearch(pBMScreen, bitmaps["HoveredGreenStock"], &OutputList, , , , , 25) = 1) {
        IsStock := true
    }


    if (IsStock) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + captureX 
        y := Cords[2] + captureY + 3
        MouseMove(x, y)
        Sleep(25)
        Click
        Gdip_DisposeImage(pBMScreen)
    } else {
        ; Gdip_DisposeImage(pBMScreen)
        PlayerStatus("Stock Not Found for " list[index] ".", "0xe67422",,false,,pBMScreen)
        return 0
    }

    loop {
        IsStock := false 
        pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)

        If (Gdip_ImageSearch(pBMScreen, bitmaps["ClickedGreenStock"], &OutputList , , , , , 25) = 1) {
            IsStock := true
        } else If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList , , , , , 25) = 1) {
            IsStock := true
        } else if (Gdip_ImageSearch(pBMScreen, bitmaps["HoveredGreenStock"], &OutputList, , , , , 25) = 1) {
            IsStock := true
        }
        
        If (Gdip_ImageSearch(pBMScreen, bitmaps["NoStock"], , , , , , 25) = 1) {
            PlayerStatus("Bought " A_Index " " list[index] "s!", "0x22e6a8",,false,,true)
            Gdip_DisposeImage(pBMScreen)
            return 0
        }

        If (IsStock) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + captureX 
            y := Cords[2] + captureY + 3
            MouseMove(x, y)
            Click
            Sleep(25)
            Gdip_DisposeImage(pBMScreen)
        } else {
            PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false,,true)
            Gdip_DisposeImage(pBMScreen)
            return 1
        }

        if (A_index == 25) {
            PlayerStatus("Bought 25 " list[index] "s!", "0x22e6a8",,false,,true)
            Gdip_DisposeImage(pBMScreen)
            return 0
        }
    }

}


buyShop(itemList, itemType){
    pos := 0.75

    for (item in itemlist){
        if (A_Index == 1) {
            relativeMouseMove(0.4,pos)
            Loop itemList.length * 2 {
                Send("{WheelUp}")
                Sleep 20
            }
        }


        if A_Index == 1 {
            relativeMouseMove(0.4,0.4)
            Click
            Sleep(250)
        } else if A_Index == 2 {
            relativeMouseMove(0.4,0.66)
            Click
            Sleep(250)
        } else if A_Index == 3 {
            relativeMouseMove(0.4,0.8)
            Sleep(250)
            Click
            Sleep(250)
            if A_ScreenHeight == 600 {
                ScrollDown(0.8)
            } else {
                ScrollDown(1)
            }
            Sleep(500)
        } else {
            Sleep(250)
            if A_ScreenHeight >= 1000 {
                ScrollDown(2.1)
            } else if A_ScreenHeight == 768 {
                ScrollDown(2.15)
            } else if A_ScreenHeight == 600 {
                ScrollDown(1.67)
            }
            Sleep(250)   
            Click
            Sleep(500)
        }

        if (CheckSetting(itemType, StrReplace(item, " ", ""))){
            CheckStock(A_Index, itemlist)
        }

    }
    CloseShop(itemType)

}


ScrollDown(amount := 1) {
    BaseHeight := 1080

    ; Scale factor (based mostly on height, since scroll is vertical)
    Scale := WindowHeight / BaseHeight

    AdjustedAmount := Round(-amount * 120 * Scale)

    DllCall("user32.dll\mouse_event"
        , "UInt", 0x0800   ; MOUSEEVENTF_WHEEL
        , "UInt", 0
        , "UInt", 0
        , "UInt", AdjustedAmount
        , "UPtr", 0)
}



DetectShop(shop){
    loop 15 {
        Sleep(500)
        if (CloseShop(shop, false,1) == 1){
            Sleep(2500)
            PlayerStatus("Detected " shop " shop opened", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to open " shop " shop", "0x22e6a8",,false,,true)
    return 0
}

CloseShop(shop, Clickit := true, amount := 15) {
    capX := windowX + windowWidth * 0.60
    capY := windowY + windowHeight * 0.1
    capW := windowWidth * 0.38
    capH := windowHeight * 0.25
    direction := 7
    local names := []

    if shop == "Seeds" {
        varation := 25
        names := ["SeedsCloseButton", "SeedsHoverCloseButton"]
    } else if shop == "Gears" {
        varation := 20
        names := ["GearsCloseButton"]
    }

    
    loop amount {
        pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
        ; Gdip_SaveBitmapToFile(pBMScreen,'ss.png')
        for index, name in names {
            if (Gdip_ImageSearch(pBMScreen, bitmaps[name], &OutputList, , , , , varation,, direction) = 1) {

                if (Clickit) {
                    Cords := StrSplit(OutputList, ",")
                    x := Cords[1] + capX - 2
                    y := Cords[2] + capY - 2
                    MouseMove(x, y)
                    Sleep(100)
                    Click
                }

                Sleep(1000)

                if amount > 5
                    PlayerStatus("Closed shop!", "0x22e6a8",, false,, false)

                Gdip_DisposeImage(pBMScreen)
                return true
            }
        }

        Sleep(500)
        Gdip_DisposeImage(pBMScreen)
    }


    if amount > 5
        PlayerStatus("Failed to close shop.", "0xFF0000",, false,, true)

    return false
}


CloseClutter(){
    CloseShop("Seeds",false,1)
    CloseShop("Gears",false,1)
    Sleep(200)
    Clickbutton("Robux")
    Sleep(100)
}

getItems(item){
    static fileContent := ""

    if !fileContent {
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            request.Open("GET", "https://raw.githubusercontent.com/epicisgood/Horizion-Updater/refs/heads/main/items.json", true)
            request.Send()
            request.WaitForResponse()
            fileContent := JSON.parse(request.ResponseText)
            global MyWindow
            MyWindow.ExecuteScriptAsync("document.querySelector('#random-message').textContent = '" fileContent["message"] "'")
            
        } catch as e {
            PlayerStatus("This is a very rare error! " e.Message, "0xFF0000",,true,,false)
        }
    }
    names := []
    for itemObj in fileContent[item] {
        names.Push(itemObj["name"])
    }
    return names
}

initShops() {
    static shopInit := true
    
    minuteMod := Mod(A_Min, 10)
    ; hourMod := Mod(A_Hour, 24)

    if (shopInit && (minuteMod = 3 || minuteMod = 8)) {
        global LastShopTime
        LastShopTime := nowUnix()
        shopInit := false
    }
}

BuySeeds(){
    seedItems := getItems("Seeds")
    if !(CheckSetting("Seeds", "Seeds")){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy Seeds!", "0x22e6a8",,false,,false)
        relativeMouseMove(0.5, 0.5)
        Sleep(500)
        Clickbutton("Seeds")
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("Seeds"){
            CameraCorrection()
            continue
        }
        buyShop(seedItems, "Seeds")
        CloseClutter()
        return 1
    }
    PlayerStatus("Failed to buy seeds 3 times, CLOSING ROBLOX!", "0x001a12")
    CloseRoblox()
}






BuyGears(){
    gearItems := getItems("Gears")
    if !(CheckSetting("Gears", "Gears")){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy Gears!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Clickbutton("Seeds",1)
        Sleep(500)

        Walk(1900, WKey,Akey)
        Walk(1200 ,Akey)
        Walk(500, Wkey)
        Send("{" Ekey "}")
        if !DetectShop("Gears"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, "Gears")
        CloseClutter()
        return 1
    }
    
    CloseClutter()
    Sleep(1500)
    ; equipRecall()
    PlayerStatus("failed to open gear shop 3 times.", "0x001a12")
}



Closelb(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth - 300  
    capY := windowY                      
    capW := 300                          
    capH := 200                          
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Leaderboard"], , , , , , 50) = 1) {
        Send("{Tab}")
        Sleep(100)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false 
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Macro Functions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Disconnect(){
    loop 3 {
        if (CheckDisconnnect()){
            return 1
        }
    }
}
GearCraftingTime := 10000000000
SeedCraftingTime := 10000000000
EventCraftingTime := 10000000000

MainLoop() {

    if (GetRobloxHWND()){
        ResizeRoblox()
    }
    
    if (Disconnect()){
        Sleep(1500)
        return
    }

    MyWindow.Destroy()
    CloseChat() 
    Closelb()
    CameraCorrection()
    BuySeeds()
    BuyGears()
    loop {

        initShops()
        minuteMod := Mod(A_Min, 10)
        
        if ((minuteMod = 3 || minuteMod = 8)) {
            if A_Sec < 5 {
                CameraCorrection()
            }
            RewardInterupt()
        }
        if (minuteMod == 0){
            CloseClutter()
            Closelb()
            if (Disconnect()){
                Sleep(500)
                CameraCorrection()
            }
        }
        ShowToolTip()
        Sleep(1000)
    }
    
    
    
}


ShowToolTip(){
    global LastShopTime

    static SeedsEnabled := IniRead(settingsFile, "Seeds", "Seeds") + 0
    static GearsEnabled := IniRead(settingsFile, "Gears", "Gears") + 0

    currentTime := nowUnix()

    tooltipText := ""
    if (SeedsEnabled) {
        static SeedTime := 300
        SeedRemaining := Max(0, SeedTime - (currentTime - LastShopTime))
        tooltipText .= "Seeds: " (SeedRemaining // 60) ":" Format("{:02}", Mod(SeedRemaining, 60)) "`n"
    }


    if (GearsEnabled) {
        static GearTime := 300
        GearRemaining := Max(0, GearTime - (currentTime - LastShopTime))
        tooltipText .= "Gears: " (GearRemaining // 60) ":" Format("{:02}", Mod(GearRemaining, 60)) "`n"
    }
    

    ToolTip(tooltipText, 100, 100)
}


F3::
{
    ; ActivateRoblox()
    ; ResizeRoblox()
    ; hwnd := GetRobloxHWND()
    ; GetRobloxClientPos(hwnd)
    ; pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    ; Gdip_SaveBitmapToFile(pBMScreen,"ss.png")
    ; Gdip_DisposeImage(pBMScreen)
    PauseMacro()
}


