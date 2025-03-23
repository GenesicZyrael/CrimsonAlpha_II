--Warding Spirt Art - Kekkai
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon1)
	e1:SetCost(s.negcost(0xbf))
	e1:SetTarget(s.negtg1)
	e1:SetOperation(s.negop1)
	c:RegisterEffect(e1)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(s.negcon2)
	e1:SetCost(s.negcost(0x10c0))
	e1:SetTarget(s.negtg2)
	e1:SetOperation(s.negop2)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)	
end
s.listed_series={0xbf,0x10c0}
function s.costfilter(c,set)
	return c:IsSetCard(set) and c:IsType(TYPE_MONSTER)
end
function s.charmer_filter(c,set)
	return c:IsSetCard(set) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.negcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.negcost(set)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local fg=Group.CreateGroup()
		for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2002000130)}) do
			fg:AddCard(pe:GetHandler())
		end
		if chk==0 then 
			if #fg>0 then
				return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,set) 
					or Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil,set) 				
			else
				return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,set) 
			end
		end
		local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil,set)
		if #fg>0 then 
			local g2=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil,set)
			g:Merge(g2)
		end		
		local tg=g:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if tc:GetLocation() ~= LOCATION_DECK then
			Duel.Release(tc,REASON_COST)
		else
			local fc=nil
			if #fg==1 then
				fc=fg:GetFirst()
			else
				fc=fg:Select(tp,1,1,nil)
			end
			Duel.Hint(HINT_CARD,0,fc:GetCode())
			fc:RegisterFlagEffect(2002000130,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
			Duel.SendtoGrave(tc,REASON_COST)
		end		
	end
end
function s.negtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end