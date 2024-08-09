#Requires AutoHotkey v2

class gToolTip {
    static Hwnds := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    static IsWin11 := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
    static Options := {BackColor: "F9F9F9", FontColor: "575757", FontSize: "9", FontName: "Segoe UI"}
    
    __New(Msg, X?, Y?, WhichToolTip := 1) {
        if (WhichToolTip > 20) {
            throw ValueError("Parameter #4 must an integer between 1 and 20.", -1)
        }
        CurrCoordMode := A_CoordModeMouse
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mX, &mY)
        CoordMode("Mouse", CurrCoordMode)
        
        if (gToolTip.Hwnds[WhichToolTip] = 0) {
            this.Gui := CurrGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
            CurrGui.BackColor := gToolTip.Options.BackColor
            CurrGui.MarginX := 7, CurrGui.MarginY := 2
            CurrGui.xOffset := IsSet(X) ? 0 : 16, CurrGui.yOffset := IsSet(Y) ? 0 : 16
            CurrGui.WM_LBUTTONDOWN := (OnMessage(WM_LBUTTONDOWN := 0x0201, WM_LBUTTONDOWN_HANDLER))
            CurrGui.WM_RBUTTONDOWN := (OnMessage(WM_RBUTTONDOWN := 0x0204, WM_RBUTTONDOWN_HANDLER))
            CurrGui.WM_LBUTTONDBLCLK := (OnMessage(WM_LBUTTONDBLCLK := 0x0203, WM_LBUTTONDBLCLK_HANDLER))
            CurrGui.SetFont("c" gToolTip.Options.FontColor " s" gToolTip.Options.FontSize, gToolTip.Options.FontName)
            CurrGui.add("Text", "vMsg", Msg).GetPos(,, &cWidth, &cHeight)
            if (gToolTip.Hwnds[WhichToolTip] != 0) {
                GuiFromHwnd(gToolTip.Hwnds[WhichToolTip]).Destroy()
            }
            gToolTip.Hwnds[WhichToolTip] := CurrGui.Hwnd
            if (gToolTip.IsWin11) {
                DllCall("Dwmapi.dll\DwmSetWindowAttribute", "Ptr", CurrGui.Hwnd, "UInt", DWMWA_WINDOW_CORNER_PREFERENCE := 33, "Ptr*", DWMWCP_ROUNDSMALL := 3, "UInt", 4)
            }
        } else {
            tGui := Gui()
            tGui.SetFont("c" gToolTip.Options.FontColor " s" gToolTip.Options.FontSize, gToolTip.Options.FontName)
            tGui.Add("Text",, Msg).GetPos(,, &cWidth, &cHeight)
            tGui.Destroy()
            CurrGui := GuiFromHwnd(gToolTip.Hwnds[WhichToolTip])
            CurrGui["Msg"].Value := Msg
            CurrGui["Msg"].Move(,, cWidth, cHeight)
        }
        CurrGui.Show("x" ((IsSet(X) ? X : mX) + CurrGui.xOffset) " y" ((IsSet(Y) ? Y : mY) + CurrGui.yOffset) " w" (cWidth + (CurrGui.MarginX * 2)) " h" (cHeight + (CurrGui.MarginY * 3)))

        WM_LBUTTONDOWN_HANDLER(wParam, lParma, Msg, Hwnd) {
            HwndMatch := gToolTip.Contains(gToolTip.Hwnds, Hwnd)
            if (HwndMatch != 0) {
                PostMessage(0x00A1, 2,,, Hwnd)
            }
        }
        WM_RBUTTONDOWN_HANDLER(wParam, lParam, Msg, Hwnd) {
            HwndMatch := gToolTip.Contains(gToolTip.Hwnds, Hwnd)
            if (HwndMatch != 0) {
                KeyWait("RButton")
                GuiFromHwnd(Hwnd).Destroy()
                gToolTip.Hwnds[HwndMatch] := 0
            }
        }
        WM_LBUTTONDBLCLK_HANDLER(wParam, lParam, Msg, Hwnd) {
            HwndMatch := gToolTip.Contains(gToolTip.Hwnds, Hwnd)
            if (HwndMatch != 0) {
                A_Clipboard := GuiFromHwnd(Hwnd)["Msg"].Value
            }
        }
    }

    static Contains(Haystack, Needle) {
        for Key, Value in Haystack {
            if (Value = Needle) {
                return Key
            }
        }
        return 0
    }

    static ClearAll() {
        for Index, Hwnd in gToolTip.Hwnds {
            if (Hwnd != 0) {
                GuiFromHwnd(Hwnd).Destroy()
                gToolTip.Hwnds[Index] := 0    
            }
        }
    }

    static SetOptions(Options) {
        for Key, Value in Options.OwnProps() {
            gToolTip.Options.%Key% := Value
        }
        gToolTip.UpdateAll()
    }

    static UpdateAll() {
        for Index, Hwnd in gToolTip.Hwnds {
            if (Hwnd != 0) {                
                CurrGui := GuiFromHwnd(Hwnd)
                tGui := Gui()
                tGui.SetFont("c" gToolTip.Options.FontColor " s" gToolTip.Options.FontSize, gToolTip.Options.FontName)
                tGui.Add("Text",, CurrGui["Msg"].Value).GetPos(,, &cWidth, &cHeight)
                tGui.Destroy()
                CurrGui := GuiFromHwnd(Hwnd)
                CurrGui.BackColor := gToolTip.Options.BackColor
                CurrGui["Msg"].SetFont("c" gToolTip.Options.FontColor " s" gToolTip.Options.FontSize, gToolTip.Options.FontName)
                CurrGui["Msg"].Move(,, cWidth, cHeight)
                CurrGui.Move(,, cWidth + (CurrGui.MarginX * 2), cHeight + (CurrGui.MarginY * 3))
            }
        }
    }
}