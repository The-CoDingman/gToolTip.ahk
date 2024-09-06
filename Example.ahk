#Requires AutoHotkey v2
#SingleInstance Force
#Include gTooltip.ahk
CoordMode("ToolTip", "Screen")

F1:: {
    static FireCount := 0
    FireCount++
    Msg1 := "Custom"
    Msg2 := "HELLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLO"
    Msg3 := "And a 1`nAnd a 2`n    And a 3!"
    Rando := Random(1, 3)
    if (FireCount = 1) {
        Msg := Msg1
    } else if (FireCount = 2) {
        Msg := Msg2
    } else if (FireCount = 3) {
        Msg := Msg3
        FireCount := 0
    }
    gToolTip(Msg)
}

F2:: {
    gToolTip.ClearAll()
}

F3:: {
    BackColors := ["660066", "006600", "e96310"]
    FontColors := ["C0FFEE", "Yellow", "5b7be6"]
    FontNames := ["Segoe UI", "Verdana", "Arial"]
    gToolTip.SetOptions({BackColor: BackColors[Random(1, 3)], FontColor: FontColors[Random(1, 3)], FontSize: Random(8, 14), FontName: FontNames[Random(1, 3)]})
}

F4::ExitApp()