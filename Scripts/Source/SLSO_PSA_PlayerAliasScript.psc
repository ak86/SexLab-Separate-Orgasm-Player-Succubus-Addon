scriptname SLSO_PSA_PlayerAliasScript extends ReferenceAlias

String File
bool hotkey_auto_drain
bool hotkey_manual_drain
bool drain_lock
Actor[] DrainActors
Float drainmagnitude

SLSO_WidgetCoreScript1 Property Widget1 Auto
SLSO_WidgetCoreScript2 Property Widget2 Auto
SLSO_WidgetCoreScript3 Property Widget3 Auto
SLSO_WidgetCoreScript4 Property Widget4 Auto
SLSO_WidgetCoreScript5 Property Widget5 Auto

SexLabFramework property SexLab auto


;=============================================================
;INIT
;=============================================================

Event OnInit()
	Maintenance()
EndEvent

Event OnPlayerLoadGame()
	Maintenance()
EndEvent

function Maintenance()
	self.RegisterForModEvent("OrgasmStart", "Orgasm")
	self.RegisterForModEvent("SexLabOrgasmSeparate", "OrgasmS")
	self.RegisterForModEvent("AnimationStart", "OnSexLabStart")
	self.RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	File = "/SLSO_PSA/Config.json"
	DrainActors = new Actor[5]

	if JsonUtil.GetErrors(File) != ""
		Debug.Notification("SLSO_PSA Json has errors, mod wont work")
	endif
endFunction

function Clear()
	;((Game.GetFormFromFile(0xD62, "SLSO.esp") as quest) as SLSO_WidgetCoreScript1).BorderColor = 0
	Widget1.BorderColor = 0
	Widget2.BorderColor = 0
	Widget3.BorderColor = 0
	Widget4.BorderColor = 0
	Widget5.BorderColor = 0
	drain_lock = false
	drainmagnitude = 0
	hotkey_auto_drain = false
	UnregisterForAllKeys()
endFunction

function Drain(Actor akActor)
	drain_lock = true
;(Game.GetFormFromFile(0x4DBA4, "skyrim.esm") as Spell).cast( Game.GetPlayer(), akActor )	; SOULTRAP
	if JsonUtil.GetIntValue(File, "SoulTrap") == 1
		(Game.GetFormFromFile(0x1D8A, "SLSO_PSA.esp") as Spell).cast( Game.GetPlayer(), akActor )	; SOULTRAP
	endif
;utility.wait(1)
;akActor.kill()
endFunction

;----------------------------------------------------------------------------
;SexLab hooks
;----------------------------------------------------------------------------

Event OnSexLabStart(string EventName, string argString, Float argNum, form sender)
	sslThreadController controller = SexLab.GetController(argString as int)

	if controller.HasPlayer
		self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_auto_drain"))
		self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_manual_drain"))
		DrainActors = new Actor[5]
;		If hotkey_auto_drain == true
;			Widget1.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
;			Widget2.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
;			Widget3.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
;			Widget4.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
;			Widget5.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
;		Else
;			Clear()
;		EndIf
	endif
EndEvent

Event OnSexLabEnd(string EventName, string argString, Float argNum, form sender)
	sslThreadController controller = SexLab.GetController(argString as int)

	if controller.HasPlayer
		if hotkey_auto_drain == true
			Float Damage = (Game.GetPlayer().GetActorValue("Health") + Game.GetPlayer().GetActorValue("Stamina") + Game.GetPlayer().GetActorValue("Magicka")) / 3 * drainmagnitude
			if Damage < 0
				Damage = 0
			endif
			Sexlab.Log("Player Succubus Addon Drain: " + Damage + " Health")
			(self.GetOwningQuest() as SLSO_PSA_PSQ).AddEnergy(Damage)
			
			int i = 0
			while i < DrainActors.Length
				if DrainActors[i] != none && DrainActors[i] != Game.GetPlayer()
					;(Game.GetFormFromFile(0xF5B58, "skyrim.esm") as Spell).cast( Game.GetPlayer(), DrainActors[i] )	; Drain life
					if JsonUtil.GetIntValue(File, "Instantkill") == 1
						DrainActors[i].Kill()
					else
						DrainActors[i].DamageActorValue("Health", Damage)
					endif
				endif
				i += 1
			endwhile
		endif
		Clear()
	endif
EndEvent

;----------------------------------------------------------------------------
;SexLab orgasm hooks
;----------------------------------------------------------------------------

Event Orgasm(string eventName, string argString, float argNum, form sender)
	Actor[] actorList = SexLab.HookActors(argString)
	sslThreadController controller = SexLab.HookController(argString)
	sslBaseAnimation anim = SexLab.HookAnimation(argString)
	
	if actorList.Length > 1 && controller.HasPlayer
		if hotkey_auto_drain == true
			int i = 0
			while i < controller.ActorAlias.Length
				if controller.ActorAlias[i].GetActorRef() != none && controller.ActorAlias[i].GetActorRef() != Game.GetPlayer()
					DrainActors[i] = controller.ActorAlias[i].GetActorRef()
					Drain(controller.ActorAlias[i].GetActorRef())
				endif
				i += 1
			endwhile
			drainmagnitude += 1
		else
			drain_lock = true
		endif
	endif
EndEvent

Event OrgasmS(Form ActorRef, Int Thread)
	sslThreadController controller = SexLab.GetController(Thread)
	if controller.HasPlayer
		if hotkey_auto_drain == true
			if (ActorRef as actor) == Game.GetPlayer()
				if Utility.RandomInt(0, 100) < (JsonUtil.GetFloatValue(File, "pcorgasmdrainchance")*100) as int
					int i = 0
					while i < controller.ActorAlias.Length
						if controller.ActorAlias[i].GetActorRef() != none && controller.ActorAlias[i].GetActorRef() != Game.GetPlayer()
							DrainActors[i] = controller.ActorAlias[i].GetActorRef()
							Drain(controller.ActorAlias[i].GetActorRef())
						endif
						i += 1
					endwhile
					drainmagnitude -= 1
				endif
			elseif (ActorRef as actor) != Game.GetPlayer()
				if Utility.RandomInt(0, 100) < (JsonUtil.GetFloatValue(File, "npcorgasmdrainchance")*100) as int
					int i = 0
					while i < controller.ActorAlias.Length && controller.ActorAlias[i].GetActorRef() != ActorRef
						i += 1
					endwhile
					DrainActors[i] = ActorRef as Actor
					Drain(ActorRef as actor)
					drainmagnitude += 1
				endif
			endif
		else
			drain_lock = true
		endif
	endif
EndEvent

;----------------------------------------------------------------------------
;hotkey
;----------------------------------------------------------------------------

Event OnKeyDown(int keyCode)
	If JsonUtil.GetIntValue(File, "hotkey_auto_drain") == keyCode
		If hotkey_auto_drain == false && Game.GetPlayer().GetActorValue("Magicka") > 25
			Debug.Notification("Draining partner(s)")
			hotkey_auto_drain = true
			Game.GetPlayer().DamageActorValue("Magicka", 25)
			drain_lock = true
			Widget1.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
			Widget2.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
			Widget3.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
			Widget4.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
			Widget5.BorderColor = JsonUtil.GetIntValue(File, "widget_Border_color") as int
		Elseif drain_lock != true
			hotkey_auto_drain = false
			Clear()
		EndIf
	EndIf
EndEvent
