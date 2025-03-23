--Mekk-Knighted by the World Chalice
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
	--trigger on leaving the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WORLD_CHALICE,SET_MEKK_KNIGHT}
function s.filter(c)
	return c:IsAbleToHand() 
		and (c:IsSetCard(SET_WORLD_CHALICE) or c:IsSetCard(SET_MEKK_KNIGHT))
end
function s.cfilter(c,tp)
	return (c:IsSetCard(SET_WORLD_CHALICE) or c:IsSetCard(SET_MEKK_KNIGHT))
		and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsPreviousPosition(POS_FACEUP)
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
	end
	return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)==true and Duel.GetFlagEffect(tp,id)==0 
	and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end