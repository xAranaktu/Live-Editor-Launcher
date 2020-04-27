;!Highly recommended for improved overall performance and responsiveness of the GUI effects etc.! (after compiling):
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm /pe

;YOU NEED TO EXCLUDE FOLLOWING FUNCTIONS FROM AU3STRIPPER, OTHERWISE IT WON'T WORK:
#Au3Stripper_Ignore_Funcs=_iHoverOn,_iHoverOff,_iFullscreenToggleBtn,_cHvr_CSCP_X64,_cHvr_CSCP_X86,_iControlDelete
;Please not that Au3Stripper will show errors. You can ignore them as long as you use the above Au3Stripper_Ignore_Funcs parameters.

;Required if you want High DPI scaling enabled. (Also requries _Metro_EnableHighDPIScaling())
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon
#include "UDF\MetroGUI-UDF\MetroGUI_UDF.au3"
#include "UDF\MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <GUIConstants.au3>
#include <Timers.au3>

Global Const $GITHUB = "https://github.com/xAranaktu/FIFA-20-Live-Editor-Launcher"
Global Const $CONFIG_INI = @ScriptDir & "\launcher_config.ini"
Global Const $INJECTOR = @ScriptDir & "\Injector\Injector.exe"
Global $PROC_NAME = "FIFA20.exe"
Global $DLL_NAME = "FIFALiveEditor.DLL"
Global $DLL_INJECTED = False
ReadConfigIni()

;=======================================================================Creating the GUI===============================================================================
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe

;Set Theme
_SetTheme("DarkTeal") ;See MetroThemes.au3 for selectable themes or to add more

;Create resizable Metro GUI
Global Const $Wnd_Title = "FIFA 20 Live Editor Launcher"

$Form1 = _Metro_CreateGUI($Wnd_Title, 500, 300, -1, -1, True)
$TitleLabel = GUICtrlCreateLabel($Wnd_Title, 60, 45, 440, 33)
GUICtrlSetFont (-1, 25, 400, 0, "Calibri", 3)
GUICtrlSetColor(-1, $FontThemeColor)

$main_lbl_1 = GUICtrlCreateLabel("Status:", 20, 90, 70, 33)
GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
GUICtrlSetColor(-1, $FontThemeColor)

$main_lbl_2 = GUICtrlCreateLabel("Waiting for " & $PROC_NAME & " process", 120, 90, 350, 33)
GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
GUICtrlSetColor(-1, $FontThemeColor)


;Add/create control buttons to the GUI
$Control_Buttons = _Metro_AddControlButtons(True, True, True, True, True) ;CloseBtn = True, MaximizeBtn = True, MinimizeBtn = True, FullscreenBtn = True, MenuBtn = True

;Set variables for the handles of the GUI-Control buttons. (Above function always returns an array this size and in this order, no matter which buttons are selected.)
$GUI_CLOSE_BUTTON = $Control_Buttons[0]
$GUI_MAXIMIZE_BUTTON = $Control_Buttons[1]
$GUI_RESTORE_BUTTON = $Control_Buttons[2]
$GUI_MINIMIZE_BUTTON = $Control_Buttons[3]
$GUI_FULLSCREEN_BUTTON = $Control_Buttons[4]
$GUI_FSRestore_BUTTON = $Control_Buttons[5]
$GUI_MENU_BUTTON = $Control_Buttons[6]
;======================================================================================================================================================================


GUISetState(@SW_SHOW)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			_EXIT()
		Case $GUI_MAXIMIZE_BUTTON
			GUISetState(@SW_MAXIMIZE, $Form1)
		Case $GUI_MINIMIZE_BUTTON
			GUISetState(@SW_MINIMIZE, $Form1)
		Case $GUI_RESTORE_BUTTON
			GUISetState(@SW_RESTORE, $Form1)
		Case $GUI_FULLSCREEN_BUTTON, $GUI_FSRestore_BUTTON
			ConsoleWrite("Fullscreen toggled" & @CRLF) ;Fullscreen toggle is processed automatically when $ControlBtnsAutoMode is set to true, otherwise you need to use here _Metro_FullscreenToggle($Form1)
		Case $GUI_MENU_BUTTON
			;Create an Array containing menu button names
			Local $MenuButtonsArray[3] = ["Settings", "About", "Exit"]
			; Open the metro Menu. See decleration of $MenuButtonsArray above.
			Local $MenuSelect = _Metro_MenuStart($Form1, 150, $MenuButtonsArray)
			Switch $MenuSelect ;Above function returns the index number of the selected button from the provided buttons array.
				Case "0"
				  _GUIDisable($Form1, 0, 30) ;For better visibility of the MsgBox on top of the first GUI.
				  SettingsWindow()
				  _GUIDisable($Form1)
				Case "1"
				  _GUIDisable($Form1, 0, 30) ;For better visibility of the MsgBox on top of the first GUI.
				  AboutWindow()
				  _GUIDisable($Form1)
				Case "2"
					_EXIT()
			EndSwitch
	EndSwitch

   Sleep(100)
   Inject_DLL()
 WEnd

Func SettingsWindow()
   Local $SettingsGUI = _Metro_CreateGUI("Settings", 500, 300, -1, -1, True)
   Local $lbl_1 = GUICtrlCreateLabel("Settings", 10, 10, 70, 33)
   GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
   GUICtrlSetColor(-1, $FontThemeColor)

   Local $Control_Buttons_3 = _Metro_AddControlButtons(True, False, False, False, False)
   Local $GUI_CLOSE_BUTTON = $Control_Buttons_3[0]
   Local $GUI_MAXIMIZE_BUTTON = $Control_Buttons_3[1]
   Local $GUI_RESTORE_BUTTON = $Control_Buttons_3[2]
   Local $GUI_MINIMIZE_BUTTON = $Control_Buttons_3[3]
   Local $GUI_FULLSCREEN_BUTTON = $Control_Buttons_3[4]
   Local $GUI_FSRestore_BUTTON = $Control_Buttons_3[5]
   GUISetState(@SW_SHOW)
   While 1
	  $nMsg = GUIGetMsg()
	  Switch $nMsg
		 Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			 _Metro_GUIDelete($SettingsGUI) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
			 Return 0
	  EndSwitch
   WEnd

EndFunc
Func AboutWindow()
   Local $AboutGUI = _Metro_CreateGUI("About", 500, 300, -1, -1, True)
   Local $lbl_1 = GUICtrlCreateLabel("About", 10, 10, 50, 33)
   GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
   GUICtrlSetColor(-1, $FontThemeColor)

   Local $lbl_2 = GUICtrlCreateLabel("Simple GUI for DLL injector", 30, 50, 250, 33)
   GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
   GUICtrlSetColor(-1, $FontThemeColor)

   Local $lbl_3 = GUICtrlCreateLabel("Source Code: ", 30, 80, 120, 33)
   GUICtrlSetFont (-1, 15, 400, 0, "Calibri", 3)
   GUICtrlSetColor(-1, $FontThemeColor)
   Local $GitHubBtn = _Metro_CreateButton("Github", 30, 110, 70, 33)


   Local $Control_Buttons_2 = _Metro_AddControlButtons(True, False, False, False, False)
   Local $GUI_CLOSE_BUTTON = $Control_Buttons_2[0]
   Local $GUI_MAXIMIZE_BUTTON = $Control_Buttons_2[1]
   Local $GUI_RESTORE_BUTTON = $Control_Buttons_2[2]
   Local $GUI_MINIMIZE_BUTTON = $Control_Buttons_2[3]
   Local $GUI_FULLSCREEN_BUTTON = $Control_Buttons_2[4]
   Local $GUI_FSRestore_BUTTON = $Control_Buttons_2[5]
   GUISetState(@SW_SHOW)
   While 1
	  $nMsg = GUIGetMsg()
	  Switch $nMsg
		 Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			 _Metro_GUIDelete($AboutGUI) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
			 Return 0
		  Case $GitHubBtn
			 ShellExecute($GITHUB)
	  EndSwitch
   WEnd
 EndFunc

Func ReadConfigIni()
   $PROC_NAME = IniRead($CONFIG_INI, "Settings", "PROC_NAME", $PROC_NAME)
   $DLL_NAME = IniRead($CONFIG_INI, "Settings", "DLL_NAME", $DLL_NAME)
EndFunc

Func Inject_DLL()
   If ($DLL_INJECTED) Then
	  _EXIT()
   EndIf
   local $DLL_PATH = @ScriptDir & "\" & $DLL_NAME

   If Not FileExists($DLL_PATH) Then
	  MsgBox(16, "Launcher", "Error, file not exists:\n" & $DLL_PATH)
	  _EXIT()
   EndIf

   If Not FileExists($INJECTOR) Then
	  MsgBox(16, "Launcher", "Error, file not exists:\n" & $INJECTOR)
	  _EXIT()
   EndIf

   local $pid = ProcessExists($PROC_NAME)
   If $pid <= 0 Then
	  return
   EndIf
   GUICtrlSetData($main_lbl_2, "Injecting DLL")

   $cmd = '"' & $INJECTOR & '" --process-name ' & $PROC_NAME & ' --inject "' & $DLL_PATH & '"'
   Local $params = '--process-name ' & $PROC_NAME & ' --inject "' & $DLL_PATH & '"'

   ;local $inject_ret = RunWait(@ComSpec & " /C " & $cmd, "", @SW_MAXIMIZE  )
   local $inject_ret = ShellExecuteWait($INJECTOR, $params, "", "", @SW_HIDE )
   If $inject_ret == 0 Then
	  GUICtrlSetData($main_lbl_2, "Done")
	  $DLL_INJECTED = True
   Else
	  MsgBox(16, "", "DLL Inject failed." & @CRLF & "Injector path: " & $INJECTOR & @CRLF & "Params: " & $params)
   EndIf
   _EXIT()
EndFunc

Func _EXIT()
   _Metro_GUIDelete($Form1) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
   Exit
EndFunc