--Gust and Drift
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Cost: Discard 1 valid monster
function s.cfilter(c,tp)
	local att,lv,race,code=c:GetAttribute(),c:GetLevel(),c:GetRace(),c:GetCode()
	if lv<=0 then return false end
	local tc=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp,att,lv,race,code)
	if not tc then return false end
	return c:IsMonster() and c:IsDiscardable()
end

function s.filter1(c,tp,att,lv,race,code)
	return c:IsAttribute(att) and c:IsLevel(lv) and c:IsAbleToHand()
		and not c:IsRace(race) and not c:IsCode(code) 
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,att,lv,race,code1,code2)
end

function s.filter2(c,att,lv,race,code1,code2)
	return c:IsAttribute(att) and c:IsLevel(lv) and c:IsAbleToHand()
		and not c:IsRace(race) and not c:IsCode(code1) and not c:IsCode(code2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end

-- Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

-- Operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local att,lv,race,code1=tc:GetAttribute(),tc:GetLevel(),tc:GetRace(),tc:GetCode()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,tp,att,lv,race,code1)
	local code2=tc1:GetFirst():GetCode()
	local tc2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,att,lv,race,code1,code2)
	local g=Group.CreateGroup()
	g:AddCard(tc1)
	g:AddCard(tc2)
	if #g>1 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit(tc:GetAttribute()))
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetReset(RESET_PHASE|PHASE_END)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.splimit(att)
	return function(e,c)
		return not c:IsAttribute(att)
	end
end
