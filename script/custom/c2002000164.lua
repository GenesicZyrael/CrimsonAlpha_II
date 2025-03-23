--Dark Magician the Toon Knight
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,21296502,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--Prevent effect target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Prevent destruction by opponent's effect
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Summoning Sickness
	Toon.SummoningSickness(c)
end
s.material_setcode=SET_TOON
s.listed_names={CARD_TOON_WORLD}
function s.indtg(e,c)
	return c:IsSpellTrap() and c:IsFaceup() and (c:ListsCode(CARD_TOON_WORLD) or c:IsCode(CARD_TOON_WORLD)) 
end