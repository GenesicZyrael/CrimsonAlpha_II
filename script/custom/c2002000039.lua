--Gishki Curse
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--ritual level
	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsSetCard,SET_GISHKI))
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--ritual material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.rmcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
end
s.listed_series={SET_GISHKI,SET_AQUAMIRROR}
function s.rmcon(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),CARD_SPIRIT_ELIMINATION)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if chk==0 then 
		return c:IsDiscardable() 
			and Duel.IsPlayerCanDiscardDeckAsCost(tp,1) 
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	Duel.SendtoGrave(tc,REASON_COST)
	if tc:IsLocation(LOCATION_GRAVE) 
	and (tc:IsSetCard(SET_GISHKI) or tc:IsSetCard(SET_AQUAMIRROR)) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.filter1(c)
	return c:IsSetCard(SET_GISHKI) 
		and c:IsMonster()
		and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsSetCard(SET_AQUAMIRROR) 
		and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g1>0 then
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
		if e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
			if #g1>0 then
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g1)
			end
		end
	end
end