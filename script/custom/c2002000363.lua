-- Servante Dragonmaid
local s,id=GetID()
function s.initial_effect(c)
    -- Pendulum Setup
    Pendulum.AddProcedure(c)
    -- At the start of the Battle Phase: Place and Pendulum Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetRange(LOCATION_ONFIELD|LOCATION_EXTRA)
	e1b:SetCondition(s.matcon)
	e1b:SetTarget(s.mattg)
	e1b:SetOperation(s.matop)
	c:RegisterEffect(e1b)
    -- Search or Send to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    -- Place in Pendulum Zone
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.pzcon)
    e4:SetTarget(s.pztg)
    e4:SetOperation(s.pzop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_DRAGONMAID}
function s.pzfilter(c,tp)
    return c:IsSetCard(SET_DRAGONMAID) and c:IsType(TYPE_PENDULUM) and c:IsLevel(7)
        and not c:IsForbidden() 
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.CheckPendulumZones(tp)
            and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,tp) 
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)~=0 then	
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_PHASE_END,0,1)
		if Duel.IsPlayerCanPendulumSummon(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then 
			Duel.PendulumSummon(tp)
		else 
			Duel.BreakEffect()
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	return tc and (tc:GetSummonType()&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
		and c:HasFlagEffect(id)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.BreakEffect()
	Duel.Destroy(c,REASON_EFFECT)
end

function s.thtgfilter(c)
    return c:IsSetCard(SET_DRAGONMAID) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thtgfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local b1=tc:IsAbleToHand()
        local b2=tc:IsAbleToGrave()
        local op=0
        if b1 and b2 then
            op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        elseif b1 then
            op=0
        else
            op=1
        end
        
        if op==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end

function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.CheckPendulumZones(tp)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end