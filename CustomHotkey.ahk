#SingleInstance Force
#InstallKeybdHook
#UseHook On

{ ; UI
    ; Hotkeys
    Gui, Add, Hotkey, x22 y19 w190 h40 vHotkey_Key1,
    Gui, Add, Hotkey, x22 y69 w190 h40 vHotkey_Key2,
    Gui, Add, Hotkey, x22 y119 w190 h40 vHotkey_Key3,
    Gui, Add, Hotkey, x22 y169 w190 h40 vHotkey_Key4,
    Gui, Add, Hotkey, x22 y219 w190 h40 vHotkey_Key5,
    ; Hotkeys Text
    Gui, Add, Edit, x222 y19 w540 h40 vHotkey_Text1,
    Gui, Add, Edit, x222 y69 w540 h40 vHotkey_Text2,
    Gui, Add, Edit, x222 y119 w540 h40 vHotkey_Text3,
    Gui, Add, Edit, x222 y169 w540 h40 vHotkey_Text4,
    Gui, Add, Edit, x222 y219 w540 h40 vHotkey_Text5,
    ; Buttons
    Gui, Add, Button, x782 y19 w110 h40 gHotkey_ButtonAdd1, Update
    Gui, Add, Button, x782 y69 w110 h40 gHotkey_ButtonAdd2, Update
    Gui, Add, Button, x782 y119 w110 h40 gHotkey_ButtonAdd3, Update
    Gui, Add, Button, x782 y169 w110 h40 gHotkey_ButtonAdd4, Update
    Gui, Add, Button, x782 y219 w110 h40 gHotkey_ButtonAdd5, Update
    Gui, Add, Button, x962 y19 w110 h40 gHotkey_Delete1, Delete
    Gui, Add, Button, x962 y69 w110 h40 gHotkey_Delete2, Delete
    Gui, Add, Button, x962 y119 w110 h40 gHotkey_Delete3, Delete
    Gui, Add, Button, x962 y169 w110 h40 gHotkey_Delete4, Delete
    Gui, Add, Button, x962 y219 w110 h40 gHotkey_Delete5, Delete
    Gui, Add, Button, x962 y309 w110 h50 ,Save
    Gui, Show, w1094 h389,CustomHotkey Class
}

; Load your CustomHotkey after your UI has been set up
CustomHotkey.LoadHotkeys()
return

F12::
GuiClose:
    ExitApp
return

ButtonSave:
    CustomHotkey.SaveToFile()
return

{ ; CustomHotkey Labels
    ; Hotkey Labels that are triggered when the button is pressed
    Hotkey_CustomHotkey1:
    Hotkey_CustomHotkey2:
    Hotkey_CustomHotkey3:
    Hotkey_CustomHotkey4:
    Hotkey_CustomHotkey5:
        if(WinActive("Untitled - Notawdepad")) {
            CustomHotkey.Send(A_ThisLabel)
        } else {
            tmp_key := ""
            if(RegExMatch(A_ThisHotkey, "i)(!|\+|\^)?(!|\+|\^)?(!|\+|\^)?(.*)", args) == 1) {
                tmp_key := args1 "" args2 "" args3 "{" args4 "}"
            }
            Send %tmp_key%
        }
    return

    Hotkey_ButtonAdd1:
    Hotkey_ButtonAdd2:
    Hotkey_ButtonAdd3:
    Hotkey_ButtonAdd4:
    Hotkey_ButtonAdd5:
        hkName := StrReplace(A_ThisLabel,"Hotkey_ButtonAdd","Hotkey_CustomHotkey")
        hkKey := StrReplace(A_ThisLabel,"Hotkey_ButtonAdd","Hotkey_Key")
        hkText := StrReplace(A_ThisLabel,"Hotkey_ButtonAdd","Hotkey_Text")


        GuiControlGet, hkKey,,%hkKey%
        GuiControlGet, hkText,,%hkText%

        CustomHotkey.Add(hkName,hkKey,hkText)
    return

    Hotkey_Delete1:
    Hotkey_Delete2:
    Hotkey_Delete3:
    Hotkey_Delete4:
    Hotkey_Delete5:
        hotkey_control := StrReplace(A_ThisLabel,"Hotkey_Delete","Hotkey_Key")
        GuiControlGet, hkKey,,%hotkey_control%
        GuiControl,,%hotkey_control%,

        CustomHotkey.GUI_Delete(hkKey)

        text_control := StrReplace(A_ThisLabel,"Hotkey_Delete","Hotkey_Text")
        GuiControl,,%text_control%
    return

    ; Single label for validating a hotkey
    Hotkey_TryAdd:
    return

}

{ ; Class CustomHotkey

    ; CustomHotkey Class written by Aiden

    ; Github: https://github.com/Aiden2368
    ; Github repository: https://github.com/Aiden2368/CustomHotkey-Class
    ; Discord: Aiden#2368

    Class CustomHotkey {
        static hotkeysFile := "CustomHotkeys.txt"
        static allHotkeys := {}
        ; The amount of maxHotkeys should equal the amount of
        ; "Hotkey_CustomHotkey" labels as seen in line number 46
        static maxHotkeys := 5

        ; "Only" creates a new hotkey object
        __New(name,text,key) {
            this.hotkeyLabelName := name
            this.hotkeyText := text
            this.hotkeyKey := key
        }

        ; Creates a new hotkey and sets it up to be able to run
        Add(name,key,text) {
            if(Trim(name) == "" || Trim(text) == "" || Trim(key) == "") {
                return
            }

            try {
                Hotkey,%key%,Hotkey_TryAdd
            } catch e {
                return
            }

            newHotkey := new CustomHotkey(name,text,key)
            
            ; Check if this hotkey has an entry in the allHotkeys array
            ; This is important for saving the hotkeys in a file later on. See function description
            exist := CustomHotkey.Exist(key)
            if(exist != -1) {
                ; Disabling the already existing hotkey is optional. It will be overwritten down below anyway without any problems...
                CustomHotkey.Disable(name)
                CustomHotkey.allHotkeys.Remove(exist)
            }

            ; Check if another hotkey is pointing to this hotkey label and turn the hotkey for this label off
            ; Prevents two hotkeys from firing the same hotkey label
            temp_obj := CustomHotkey.allHotkeys[name]
            isObj := CustomHotkey.customIsObj(temp_obj)

            if(isObj) {
                CustomHotkey.Disable(name)
                CustomHotkey.allHotkeys[name] := newHotkey
            } else {
                CustomHotkey.allHotkeys.Insert(name, newHotkey)
            }

            ; Activates a hotkey
            Hotkey,%key%,%name%, ON
        }

        ; Send a text when a CustomHotkey has been triggered
        Send(hotkeyIndex) {
            obj := CustomHotkey.allHotkeys[hotkeyIndex]
            objText := obj.hotkeyText

            MsgBox % objText

            ; SendInput {raw}%objText%
            ; SendInput {enter}
        }

        ; Loads saved hotkeys from the file
        LoadHotkeys() {
            if(!FileExist(CustomHotkey.hotkeysFile)) {
                return
            }

            hotkeysFile := CustomHotkey.hotkeysFile

            FileRead,readFile,%hotkeysFile%
            hotkeys_in_file := StrSplit(readFile, "`r`n")

            if(hotkeys_in_file.MaxIndex() <= 0 || hotkeys_in_file.MaxIndex() == "") {
                return
            }

            for k, v in hotkeys_in_file
                if(RegExMatch(v,"i)Hotkey_CustomHotkey([0-9]{1,});(.*);""(.*)""; END",args) == 1) {
                    ch_nr := Trim(args1)
                    ch_key := Trim(args2)
                    ch_text := Trim(args3)

                    if(!CustomHotkey.isNumber(ch_nr) || ch_nr > CustomHotkey.maxHotkeys || ch_nr < 1 || ch_key == "" || ch_text == "") {
                        Continue
                    }

                    CustomHotkey.Add("Hotkey_CustomHotkey" ch_nr, ch_key, ch_text)
                    CustomHotkey.GUI_Add(ch_nr,ch_key,ch_text)
                }
        }

        ; Check if the hotkey exists in allHotkeys array
        ; We need to remove the hotkey from the array so we can later on save all single hotkeys in a file.
        ;
        ; If we dont remove an existing hotkey from the array we will later have two hotkeys that may point to multiple hotkey labels
        ; Example:
        ;
        ; Hotkey "4" points to "Hotkey_CustomHotkey1" based on the allHotkeys array
        ; Hotkey "4" points to "Hotkey_CustomHotkey2" based on the allHotkeys array
        ;
        ; In this case, we would write the same hotkey pointing to multiple labels into the hotkeys saving file even though all but one hotkey "4" are turned off
        Exist(key) {
            i := 1
            while(i <= CustomHotkey.maxHotkeys) {
                index := "Hotkey_CustomHotkey" i
                isObj := CustomHotkey.customisObj(CustomHotkey.allHotkeys[index])

                if(isObj) {
                    obj := CustomHotkey.allHotkeys[index]
                    if(obj.hotkeyKey = key) {
                        return index 
                    }
                }

                i++
            }
            return -1
        }

        ; Turns off an active hotkey based on the key data from key:value in allHotkeys array
        ; Example:
        ;
        ; if Hotkey_CustomHotkey2 has already a key "3" assigned to it,
        ; and we add another key "4" on the same position "Hotkey_CustomHotkey2" we need to turn off the key "3"
        ;
        ; Otherwise both keys 3 and 4 will trigger the same hotkey label
        Disable(name) {
            obj := CustomHotkey.allHotkeys[name]
            objKey := obj.hotkeyKey

            try {
                Hotkey,%objKey%,OFF
            }
        }

        ; You wouldn't want to lose your hotkeys, would ya?
        SaveToFile() {
            hotkeysFile := CustomHotkey.hotkeysFile
            if(FileExist(hotkeysFile)) {
                FileDelete, %hotkeysFile%
            }

            hotkeys_text := ""
            i := 1
            while(i <= CustomHotkey.maxHotkeys)  {
                index := "Hotkey_CustomHotkey" i

                isObj := CustomHotkey.customisObj(CustomHotkey.allHotkeys[index])

                if(isObj) {
                    obj := CustomHotkey.allHotkeys[index]

                    hkName := obj.hotkeyLabelName
                    hkText  := obj.hotkeyText
                    hkKey := obj.hotkeyKey

                    hotkeys_text .= hkName ";" hkKey ";""" hkText """; END`n"
                }
                i++
            }

            if(hotkeys_text != "") {
                FileAppend,%hotkeys_text%,%hotkeysFile%,utf-8
            }
        }

        ; Cleans up the UI for that specific hotkey and removes the hotkey
        GUI_Delete(key) {
            if(Trim(key) == "") {
                return
            }

            exist := CustomHotkey.Exist(key)
            if(exist) {
                CustomHotkey.Disable(exist)
                CustomHotkey.allHotkeys.Remove(exist)
            }
        }

        ; Updates the UI for the CustomHotkey
        GUI_Add(ui_nr, ui_key, ui_text) {
            key_control := "Hotkey_Key" ui_nr
            text_control := "Hotkey_Text" ui_nr

            GuiControl,,%key_control%,%ui_key%
            GuiControl,,%text_control%,%ui_text%
        }

        customIsObj(obj) {
            if IsObject(obj)
                return true
            return false
        }

        isNumber(vNumber) {
            if vNumber is not number
                return false
            return true
        }
    }
}
