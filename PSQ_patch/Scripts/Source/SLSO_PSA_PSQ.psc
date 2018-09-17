Scriptname SLSO_PSA_PSQ extends Quest Hidden

Function AddEnergy (float value)
	If Game.GetModbyName("PSQ PlayerSuccubusQuest.esm") != 255
		playersuccubusquestscript PSQ = Quest.GetQuest("PlayerSuccubusQuest") as playersuccubusquestscript
		Float MaxEnergy = PSQ.MaxEnergy
		
		if PSQ.SuccubusEnergy.GetValue() + value <= MaxEnergy
			PSQ.SuccubusEnergy.SetValue(PSQ.SuccubusEnergy.GetValue() + value)
		else 
			PSQ.SuccubusEnergy.SetValue(MaxEnergy)
		endif
	endif
EndFunction