--Venin, the Corroding True Dracoverlord
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--maintenance cost
	aux.AmorphageMCost(c)
	--Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--special summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumlimit)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)	
end
s.listed_names={2002000006}
s.listed_series={SET_DRACOVERLORD,SET_AMORPHAGE,SET_DRACOSLAYER}
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL 
		or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.sumcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_AMORPHAGE),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsType(TYPE_PENDULUM)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.cfilter(c,tp)
	return c:IsFacedown() 
		or not (c:IsSetCard(SET_AMORPHAGE)
			or c:IsSetCard(SET_DRACOVERLORD)
			or c:IsSetCard(SET_DRACOSLAYER))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp 
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
function s.filter1(c,e,tp)
	return (c:IsSetCard(SET_AMORPHAGE) or c:IsSetCard(SET_DRACOVERLORD))
		and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.filter2(c,e,tp)
	return (c:IsSetCard(SET_AMORPHAGE) or c:IsSetCard(SET_DRACOVERLORD))
		and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckPendulumZones(tp)
	if chk==0 then return b1
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- Duel.SendtoExtraP(e:GetHandler(),tp,REASON_COST)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if b2 then Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.CheckPendulumZones(tp)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local tc=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil,e,tp):Select(tp,1,1,nil):GetFirst()
	if b1 and tc then 
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		Duel.ShuffleDeck(tp)
		if b2 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			tc=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND,0,nil,e,tp):Select(tp,1,1,nil):GetFirst()
			if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
		end
	end
end