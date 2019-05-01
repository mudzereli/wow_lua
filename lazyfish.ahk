CoordMode, Mouse, Screen

LAST_ACTION := A_TickCount - 3000

XButton2:: LazyFish("!e")
XButton1:: Reload

LazyFish(keyFishing) {
    global LAST_ACTION
    global BOBBER_X
    global BOBBER_Y
    if(A_TickCount - LAST_ACTION < 3000) 
    {
        ; -- Lock Mouse Position
        MouseGetPos, BOBBER_X, BOBBER_Y, , , 
    } else {
        ; -- Click Bobber
        MouseClick, Right, % BOBBER_X, % BOBBER_Y, , , , 
        Sleep 300
        ; -- Send Fishing Key
        SendInput, !e
    }
    LAST_ACTION := A_TickCount
}