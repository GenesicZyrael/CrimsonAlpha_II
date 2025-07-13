--War Rock Impasse
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e0)
	--"War Rock" monsters you control are unaffected by monsters with less ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(SET_WAR_ROCK) end)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	
end
s.listed_series={SET_WAR_ROCK}
function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer() ~= te:GetHandlerPlayer()
		and te:GetOwner():GetAttack()<e:GetHandler():GetAttack() and te:IsActivated()
end