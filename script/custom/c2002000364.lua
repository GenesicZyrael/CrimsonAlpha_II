-- Dragonmaid Vernesta
local s,id=GetID()
function s.initial_effect(c)
    -- Pendulum Setup
    Pendulum.AddProcedure(c)
	--scale
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_CHANGE_LSCALE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetRange(LOCATION_PZONE)
	e1a:SetCondition(s.slcon)
	e1a:SetValue(10)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e1b)
	--ATK/DEF Boost
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_UPDATE_ATTACK)
	e2a:SetRange(LOCATION_PZONE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetValue(s.val)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2b)
	--Dragonmaid Gimmick
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE|PHASE_BATTLE)
    e3:SetRange(LOCATION_PZONE)
    e3:SetCountLimit(1,{id,0})
    e3:SetTarget(s.pentg)
    e3:SetOperation(s.penop)
    c:RegisterEffect(e3)
	--indestructible
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetCondition(s.indcon)
    e4:SetValue(1)
    c:RegisterEffect(e4)
	-- Bounce + Special Summon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_HAND)
    e5:SetHintTiming(TIMING_END_PHASE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCost(Cost.SelfDiscard)
    e5:SetTarget(s.thsptarg)
    e5:SetOperation(s.thspop)
    c:RegisterEffect(e5)
end
s.listed_series={SET_DRAGONMAID}

function s.atkfilter(c,tp)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase() and eg:IsExists(s.atkfilter,1,nil,tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=eg:Filter(s.atkfilter,nil,tp)
    Duel.SetTargetCard(g)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local g=Duel.GetTargetCards(e)
    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            tc:RegisterEffect(e2)
        end
    end
end

function s.slcon(e)
	return Duel.IsBattlePhase() 
end
function s.val(e,c)
	if c:IsSetCard(SET_DRAGONMAID) then
		return 500
	else
		return 0
	end
end

function s.pzfilter(c,tp)
    return c:IsSetCard(SET_DRAGONMAID) and c:IsType(TYPE_PENDULUM) and c:IsLevel(2)
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp)
        and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pzfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
        Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end

function s.fusfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.fusfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c,e,tp,lvl)
    return c:IsSetCard(SET_DRAGONMAID) and (c:IsLevel(lvl+5) or c:IsLevel(lvl-5))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c,e,tp)
    return c:IsFaceup() and c:HasLevel() and c:IsAbleToHand()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
function s.thsptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
        local lvl=tc:GetLevel()
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,lvl)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end