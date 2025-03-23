--Infection Fairy Julia
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(0x990)
end