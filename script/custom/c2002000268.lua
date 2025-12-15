--Zefra Metaltron - Divine Strike
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1)
	--Place 1 "Zefra" Pendulum Monster to your Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(Condition.IsLinkSummoned)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZEFRA}
s.listed_names={29432356}
function s.matfilter(c)
	return c:IsSetCard(SET_ZEFRA)
end
function s.filter(c,tp)
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) 
		and not c:IsForbidden() and Duel.CheckPendulumZones(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then 
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end