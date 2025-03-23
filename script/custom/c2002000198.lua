--Orcustrated by the World Chalice
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c,false)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1160)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--trigger on summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={SET_WORLD_CHALICE,SET_ORCUST,SET_WORLD_LEGACY}
function s.filter(c)
	return c:IsAbleToHand() 
		and c:IsSetCard(SET_WORLD_LEGACY)
		and c:IsType(TYPE_TRAP+TYPE_SPELL)	
end
function s.cfilter(c,tp)
	return c:IsFaceup() 
		and c:IsControler(tp)
		and (c:IsSetCard(SET_WORLD_CHALICE) or c:IsSetCard(SET_ORCUST)) 
end
function s.tdfilter(c)
	return c:IsFaceup() 
		and c:IsMonster() 
		and c:IsAbleToDeck()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)==0 then 
		if chk==0 then 
			return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE)
	end
	return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)==true and Duel.GetFlagEffect(tp,id)==0 
	and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil)
			if td then
				Duel.SendtoDeck(td,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end