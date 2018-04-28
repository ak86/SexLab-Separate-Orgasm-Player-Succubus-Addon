scriptname SLSO_PSA_MCM extends SKI_ConfigBase
{MCM Menu script}

String File

;=============================================================
;INIT
;=============================================================

event OnConfigInit()
    ModName = "SLSO player succubus addon"
	self.RefreshStrings()
endEvent

Function RefreshStrings()
	Pages = new string[1]
	Pages[0] = "$page1"
	
	File = "/SLSO_PSA/Config.json"

EndFunction

event OnPageReset(string page)
	if page == ""
		self.RefreshStrings()
		self.Page_Config()
	else
		;self.UnloadCustomContent()
	endif

	if page == "$page1"
		self.Page_Config()
	endif
endEvent

;=============================================================
;PAGES Layout
;=============================================================

function Page_Config()
	SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Orgasm drain chance")
			AddSliderOptionST("PCOrgasmDrainChance", "Drain Npc during PC orgasm", (JsonUtil.GetFloatValue(File, "pcorgasmdrainchance")*100) as int)
			AddSliderOptionST("NPCOrgasmDrainChance", "Drain Npc during NPC orgasm", (JsonUtil.GetFloatValue(File, "npcorgasmdrainchance")*100) as int)
			AddEmptyOption()

		AddHeaderOption("Drain hotkey")
			AddKeyMapOptionST("hotkey_auto_drain", "Auto drain", JsonUtil.GetIntValue(File, "hotkey_auto_drain"))
			;AddKeyMapOptionST("hotkey_manual_drain", "$hotkey_manual_drain", JsonUtil.GetIntValue(File, "hotkey_manual_drain"))
			AddEmptyOption()

		AddHeaderOption("SLSO widget change")
			AddColorOptionST("Widget_Border_color", "Widget Border color change", JsonUtil.GetIntValue(File, "widget_Border_color") as int)
	SetCursorPosition(1)
		AddHeaderOption("Cheats")
			AddToggleOptionST("SoulTrap", "SoulTrap", JsonUtil.GetIntValue(File, "SoulTrap"))
			AddEmptyOption()
			AddEmptyOption()
			AddEmptyOption()
			AddToggleOptionST("Instantkill", "Drain always kills", JsonUtil.GetIntValue(File, "Instantkill"))
	
endfunction

;=============================================================
;Sliders
;=============================================================

state PCOrgasmDrainChance
	event OnSliderOpenST()
		SetSliderDialogStartValue((JsonUtil.GetFloatValue(File, "pcorgasmdrainchance")*100) as int)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "pcorgasmdrainchance", value/100)
		SetSliderOptionValueST((JsonUtil.GetFloatValue(File, "pcorgasmdrainchance")*100) as int)
	endEvent

	event OnHighlightST()
		SetInfoText("Soultraps all parteners, reduces drain power")
	endEvent
endState

state NPCOrgasmDrainChance
	event OnSliderOpenST()
		SetSliderDialogStartValue((JsonUtil.GetFloatValue(File, "npcorgasmdrainchance")*100) as int)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "npcorgasmdrainchance", value/100)
		SetSliderOptionValueST((JsonUtil.GetFloatValue(File, "npcorgasmdrainchance")*100) as int)
	endEvent
	
	event OnHighlightST()
		SetInfoText("Soultraps orgasming partener, increases drain power")
	endEvent
endState

;=============================================================
;TOGGLES
;=============================================================

state SoulTrap
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "SoulTrap") == 1
			JsonUtil.SetIntValue(File, "SoulTrap", 0)
		else
			JsonUtil.SetIntValue(File, "SoulTrap", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "SoulTrap"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("Soultrap orgasming partener /n Default: On")
	endEvent
endState

state Instantkill
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "Instantkill") == 1
			JsonUtil.SetIntValue(File, "Instantkill", 0)
		else
			JsonUtil.SetIntValue(File, "Instantkill", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "Instantkill"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("Kill orgasming partener instead of drain")
	endEvent
endState

;=============================================================
;HOTKEYS
;=============================================================

state hotkey_auto_drain
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_auto_drain", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_auto_drain"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_auto_drain"))
	endEvent

	event OnHighlightST()
		SetInfoText("Disable/Enable drain during orgasm (requires 25 magicka)\n Drain power = Player(HP+SP+MP)/3 * (npc orgasms - pc orgasms)")
	endEvent
endState

state hotkey_manual_drain
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_manual_drain", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_manual_drain"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_manual_drain"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_manual_drain_description")
	endEvent
endState

;=============================================================
;Widgets
;=============================================================

;=============================================================
;Widget Colours
;=============================================================

state Widget_Border_color
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.GetIntValue(File, "widget_border_color") as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.SetIntValue(File, "widget_border_color", value as int)
		SetColorOptionValueST(JsonUtil.GetIntValue(File, "widget_border_color") as int)
	endEvent
endState