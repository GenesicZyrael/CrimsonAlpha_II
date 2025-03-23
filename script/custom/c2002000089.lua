--Purging Light of the Yang Zing
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Chain
	local e2=e1:Clone()
	e1:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.chaining_con)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
s.listed_series={SET_YANG_ZING}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YANG_ZING)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.free_chain_con(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain(true)>0 then
		return false
	end
	return true
end
function s.chaining_con(e,tp,eg,ep,ev,re,r,rp)
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and (te:IsMonsterEffect() or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.costfilter(c)
	return c:IsSetCard(SET_YANG_ZING) and c:IsMonster() and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ng=Group.CreateGroup()
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_YANG_ZING),tp,LOCATION_ONFIELD,0,1,c)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	if e:GetLabel()==1 then
		for i=1,ev do
			local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			if tgp~=tp and (te:IsMonsterEffect() or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
				local tc=te:GetHandler()
				ng:AddCard(tc)
			end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_YANG_ZING),tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE+HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	if e:GetLabel()==1 then Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		for i=1,ev do
			local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			local tc=te:GetHandler()
			if (te:IsMonsterEffect() or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.NegateActivation(i) then
				if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
					tc:CancelToGrave()
				end
			end
		end
	end
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) 
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end