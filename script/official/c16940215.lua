--ナチュル・ナーブ
--Naturia Vein
--Modified for CrimsonAlpha

Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Negate Spell/Trap Card activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetCost(aux.CostWithReplace(s.discost,CARD_NATURIA_CAMELLIA))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(CARD_NATURIA_WENDI,0))
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(aux.AND(s.discon,aux.NaturiaWendiCheck))
	e2:SetCost(aux.CostWithReplace(aux.AND(aux.NaturiaWendiCost,s.discost),EFFECT_CAMELLIA_WENDI))
	c:RegisterEffect(e2)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_series={SET_NATURIA}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsSetCard(SET_NATURIA) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,c)
	Duel.Release(g:AddCard(c),REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end