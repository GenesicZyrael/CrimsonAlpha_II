--Injection Fairy Sylvie
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(0x990)
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--lingering: pierce+double damage 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.lingop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INJECTION_FAIRY}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.filter(c)
	return c:IsSetCard(SET_INJECTION_FAIRY) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	return des:IsType(TYPE_MONSTER) and rc:IsRelateToBattle() and rc:IsSetCard(SET_INJECTION_FAIRY) 
		and rc:CanChainAttack() 
		and rc:IsStatus(STATUS_OPPO_BATTLE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end
function s.pietg(e,c)
	return c:IsSetCard(SET_INJECTION_FAIRY)
end
function s.lingop(e,tp,eg,ep,ev,re,r,rp)
	--double attack
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.pietg)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	--pierce
	-- local e1=Effect.CreateEffect(e:GetHandler())
	-- e1:SetType(EFFECT_TYPE_FIELD)
	-- e1:SetCode(EFFECT_PIERCE)
	-- e1:SetTargetRange(LOCATION_MZONE,0)
	-- e1:SetTarget(s.pietg)
	-- e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(e1,tp)
	-- --double battle damage
	-- local e2=Effect.CreateEffect(e:GetHandler())
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	-- e2:SetTargetRange(LOCATION_MZONE,0)
	-- e2:SetCondition(s.damcon)
	-- e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	-- e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(e2,tp)	
end