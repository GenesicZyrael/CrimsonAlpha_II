--Reprisal of the Monarchs
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate(effect)
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCountLimit(1,{id,0})
		e1:SetCondition(s.ActCond)
		e1:SetTarget(s.ActTarg)
		e1:SetOperation(s.ActOp)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		-- e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,{id,1})
		e2:SetCost(aux.bfgcost)
		e2:SetCondition(s.thcon)
		e2:SetTarget(s.thtg)
		e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xbe}
-- {Activate Effect: Negate Activation}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.ActCond(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.ActTarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.ActOp(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.SendtoDeck(ec,nil,2,REASON_EFFECT)
	end
end
--
function s.thfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.banfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA and c:IsAbleToRemove()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return (tc:GetSummonType()&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
		and tc:GetMaterialCount()>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:GetMaterialCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)	
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local ct=tc:GetMaterialCount()
	local rg=Duel.GetMatchingGroup(s.banfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if ct>=1 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	if ct>=2 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local srg=rg:Select(tp,1,1,nil)
		Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)
	end
	if ct>=3 and #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local shg=hg:Select(tp,1,1,nil)
		Duel.SendtoHand(shg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,shg)
	end
end