--Bargoyle of Eclipse
local s,id=GetID()
local EFFECT_BARGOYLE_ATTRIBUTE=ATTRIBUTE_DARK
function s.initial_effect(c)
    -- Cannot be Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.FALSE)
    c:RegisterEffect(e1)
    -- Standby Phase: Shuffle and gain effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.effcon)
    e2:SetCost(s.effcost)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.tdfilter1(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.tdfilter2(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost() and c~=e:GetHandler()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter1,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_MZONE,0,1,nil,e) end
    -- Select 1 from Hand
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g1=Duel.SelectMatchingCard(tp,s.tdfilter1,tp,LOCATION_HAND,0,1,1,nil)
    -- Select 1 from Field
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g2=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_MZONE,0,1,1,nil,e)
    g1:Merge(g2)
    Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    -- Floodgate 1: Neither player can Special Summon monsters, except DARK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetTargetRange(1,1)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    -- Floodgate 2: Negate the effects of all DARK monsters on the field and GYs
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
    e2:SetTarget(s.distg)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:GetAttribute()~=EFFECT_BARGOYLE_ATTRIBUTE
end
function s.distg(e,c)
    return c:IsAttribute(EFFECT_BARGOYLE_ATTRIBUTE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end