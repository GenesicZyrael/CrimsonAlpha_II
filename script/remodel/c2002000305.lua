--トゥーン・ワールド
--Toon World
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Cannot be targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Attack Directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.drcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOON))
	c:RegisterEffect(e3)
	--destroy when leaving the field
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_TOON}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.tgcon(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_TOON),c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.drcon(e)
	local c=e:GetHandler()
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_TOON),c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
		and c:IsReason(REASON_DESTROY) and aux.NOT(aux.IsToonWorldUp(e))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_TOON),tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_TOON),tp,LOCATION_MZONE,0,nil)
	Duel.Destroy(g,REASON_EFFECT)
end