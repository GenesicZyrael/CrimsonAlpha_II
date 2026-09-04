-- F-X-Saber General Wayne
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_X_SABER),1,99)
    c:EnableReviveLimit()
    -- Continuous: "Saber" and "Gottoms" Spell/Trap effects cannot be negated
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.effectfilter)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.effectfilter)
    c:RegisterEffect(e2)
    -- Trigger 1: Special Summon 1 "X-Saber" or "Gottoms" from Deck on Synchro Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    -- Trigger 2: GY Effect (Return self + GY cards to Deck, search if 10+)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_DUEL)
    e4:SetTarget(s.tdtg)
    e4:SetOperation(s.tdop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_X_SABER,SET_GOTTOMS}

-- Continuous Effect Filtering for Spells/Traps
function s.effectfilter(e,ct)
    local p=e:GetHandler():GetControler()
    local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
    local tc=te:GetHandler()
    return p==tp and (tc:IsSetCard(SET_X_SABER) or tc:IsSetCard(SET_GOTTOMS)) and tc:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- Trigger 1 Condition & Targets
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
    return (c:IsSetCard(SET_X_SABER) or c:IsSetCard(SET_GOTTOMS)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
-- Trigger 2 Filter (Saber or Gottoms in GY, excluding self since self is handled separately)
function s.gyfilter(c)
    return (c:IsSetCard(SET_X_SABER) or c:IsSetCard(SET_GOTTOMS)) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,c) 
    end
    local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,c)
    g:AddCard(c)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
    return c:IsSetCard(SET_X_SABER) and c:IsAbleToHand()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,c)
    if not c:IsRelateToEffect(e) then return end
    g:AddCard(c)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        local og=Duel.GetOperatedGroup()
        local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
        if ct>=10 then
            Duel.BreakEffect()
            local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
            if #thg>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=thg:Select(tp,1,1,nil)
                if #sg>0 then
                    Duel.SendtoHand(sg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,sg)
                end
            end
        end
    end
end