--Constellar Counterattack
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
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,{id,1})
		e2:SetHintTiming(TIMING_DAMAGE_STEP)
		e2:SetCost(s.dmgcost)
		e2:SetCondition(s.dmgcon)
		e2:SetOperation(s.dmgact)
	c:RegisterEffect(e2)	
end
s.listed_series={0x53}
-- {Activate Effect: Negate Activation}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsType(TYPE_XYZ)
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
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
--
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local t=Duel.GetAttackTarget()
	return t and t:IsControler(tp) and Duel.GetFlagEffect(tp,id)==0
end
function s.dmgact(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1000)
		tc:RegisterEffect(e1)		
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsRelateToBattle()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,ev*2,REASON_EFFECT)
end