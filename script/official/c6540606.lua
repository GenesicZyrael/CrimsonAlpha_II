--Water Spirit Art - Aoi
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c,att)
	return c:IsAttribute(att) 
end
function s.charmer_filter(c,att)
	return (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsAttribute(att) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2202500154)}) do
		fg:AddCard(pe:GetHandler())
	end
	if chk==0 then 
		if #fg>0 then
			return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_WATER) 
			    or Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_WATER) 		
		else
			return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_WATER) 
		end
	end
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_WATER)
	if #fg>0 then 
		local g2=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_WATER)
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
		fc:RegisterFlagEffect(2202500154,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
		Duel.SendtoGrave(tc,REASON_COST)
	end	
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
		local sg=g:Select(p,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.ShuffleHand(1-p)
	end
end