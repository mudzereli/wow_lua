DO_PIXEL_CHECK := true

CoordMode, Pixel, Screen
SetTimer, AutoPetBattle, 333

F4::ToggleAutoPetBattles()
F5::PixelCheck(1211,995)
F3::MountYell()

ToggleAutoPetBattles()
{
    global IS_AUTO_PET_BATTLING
    IS_AUTO_PET_BATTLING := !IS_AUTO_PET_BATTLING
    MsgBox, , Auto Pet Battles, IS_AUTO_PET_BATTLING=%IS_AUTO_PET_BATTLING%, 1
}

PixelCheck(x,y)
{
    PixelGetColor, _color, x, y
    ;MsgBox, , % _color, % _color, 1
    return _color
}


MountYell()
{
    SendInput, {SPACE}
    Sleep, 250
    SendInput, {w DOWN}
    Sleep, 100
    SendInput, {w UP}
}

AutoPetBattle:
    global IS_AUTO_PET_BATTLING
    global DO_PIXEL_CHECK
    if IS_AUTO_PET_BATTLING
    {
        _sendOK := true
        if DO_PIXEL_CHECK
            _sendOK := PixelCheck(1211,995) == "0x00108F"
        if _sendOK
            ControlSend, , a, World of Warcraft, , , 
    }
    return