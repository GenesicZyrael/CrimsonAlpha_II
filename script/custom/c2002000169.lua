--Cyber Dragon Future
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTunerEx(s.matfilter),1,99)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
	--Name becomes "Cyber Dragon" while on the field or in GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetValue(CARD_CYBER_DRAGON)
	c:RegisterEffect(e4)	
end
s.listed_names={CARD_CYBER_DRAGON}
s.listed_series={0x93,0x94,0x1093}
function s.matfilter(c,val,scard,sumtype,tp)
	return c:IsRace(RACE_MACHINE,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp) 
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c)
	return (c:IsSetCard(0x93) or c:IsSetCard(0x94)) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmfilter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x93) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return #sg>0 and sg:GetSum(Card.GetLevel)==5 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local maxct=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	local dg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp) 
	if chk==0 then 
		if maxct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxct=1 end
		if maxct<=0 then return false end
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) 
			and #dg>0 and dg:CheckWithSumEqual(Card.GetLevel,5,1,maxct)
	end
	local g=aux.SelectUnselectGroup(dg,e,tp,1,maxct,s.rescon,1,tp,HINTMSG_SPSUMMON,nil,nil,false)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,#g,#g,e:GetHandler())
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#rg,tp,LOCATION_DECK)	
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g then return end
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local r1=Effect.CreateEffect(e:GetHandler())
		r1:SetType(EFFECT_TYPE_FIELD)
		r1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
		r1:SetDescription(aux.Stringid(id,1))
		r1:SetCode(EFFECT_CANNOT_ACTIVATE)
		r1:SetTargetRange(1,0)
		r1:SetValue(s.aclimit)
		r1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(r1,tp)		
		g:DeleteGroup()
	end
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsRace(RACE_MACHINE)
end