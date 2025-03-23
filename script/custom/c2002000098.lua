-- Ritual Beast Training
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtarg)
	e2:SetOperation(s.rmope)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RITUAL_BEAST,SET_SPIRITUAL_BEAST_TAMER}
-- {Activation Effect: Search Ritual Beast Monster}
function s.ActFilter(c)
	return c:IsSetCard(SET_RITUAL_BEAST) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ActFilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ActFilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
-- {Graveyard Effect: Activate 1 of these effects}
function s.cfilter(c)
	return c:IsSetCard(SET_RITUAL_BEAST) 
		and c:IsAbleToRemoveAsCost()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tgfilter1(c)
	return c:IsSetCard(SET_RITUAL_BEAST) 
		and c:IsSummonable(true,nil)
end
function s.tgfilter2(c)
	return c:IsSetCard(SET_RITUAL_BEAST) 
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToRemove()
end
function s.tgfilter3(c)
	return c:IsFaceup() 
		and not c:IsSetCard(SET_SPIRITUAL_BEAST_TAMER)
end
function s.rmtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_HAND,0,1,nil)
			or Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
			or Duel.IsExistingTarget(s.tgfilter3,tp,LOCATION_MZONE,0,1,nil)
	end
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_HAND,0,1,nil) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingTarget(s.tgfilter3,tp,LOCATION_MZONE,0,1,nil) then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		e:SetLabel(1)
	elseif opval[op]==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		e:SetLabel(2)
	elseif opval[op]==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		e:SetLabel(3)
		Duel.SelectTarget(tp,s.tgfilter3,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.rmope(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end	
	elseif e:GetLabel()==2 then
		local g=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(SET_SPIRITUAL_BEAST_TAMER)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
		end
	end
end