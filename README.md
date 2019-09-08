# CustomHotkey-Class
OOP AHK class that grants the user the ability to create their own custom hotkeys in combination with an user interface.
The whole **CustomHotkey.ahk** file is basically just an example script on how-to make use of the class itself.


The UI and the class go hand in hand - meaning you cannot make use of this class by removing specific parts of the UI.


# Adding more hotkeys
Adding hotkeys requires the developer to do the following (few) things.


1. Add more UI elements for the user. (Reference line 5 through 31)
2. Add more "CustomHotkey" Labels. (Reference line 46 through 99)
3. Update `static maxHotkeys := 5` in line 114 to the max. amount of hotkeys.

The number of UI elements and CustomHotkey labels should equal `static maxHotkeys := 5`
