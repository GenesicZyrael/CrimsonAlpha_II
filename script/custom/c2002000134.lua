--Vesicaru, the Festering True Dracolord
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
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	c:RegisterEffect(e3)
end
s.listed_names={2002000006}
s.listed_series={SET_DRACOVERLORD,SET_AMORPHAGE}
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL 
		or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.sumcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_AMORPHAGE),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_DECK) and not c:IsType(TYPE_PENDULUM)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ALL) 
		and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.filter(c,e,tp,b2)
	return c:IsLevelBelow(4) 
		and (c:IsSetCard(SET_AMORPHAGE) or c:IsSetCard(SET_DRACOVERLORD))
		and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (b2 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=Duel.CheckPendulumZones(tp)
	if chk==0 then return (b1 or b2)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b2) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=Duel.CheckPendulumZones(tp)
	if not b1 and not b2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,b2):Select(tp,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleDeck(tp)
	if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then b1=nil end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end