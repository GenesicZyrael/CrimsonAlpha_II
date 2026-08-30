--トゥーン・ドラゴン・エッガー
--Manga Ryu-Ran
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	Toon.CreateProc(c)
	--target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(aux.IsToonWorldUp)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(aux.IsToonWorldUp)
	e2:SetTarget(s.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_TOON_WORLD}
function s.atcon(e)
	return Duel.IsExistingMatchingCard(Card.IsLinkMonster,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:GetCode()~=id and c:IsType(TYPE_TOON)
end
function s.tglimit(e,c)
	return c:IsFaceup() and c:GetCode()~=id and c:IsType(TYPE_TOON)
end