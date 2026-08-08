-- Exxod, the Millennium Guard Incarnate
local s,id=GetID()
function s.initial_effect(c)
    -- [Ignition Effect] Special Summon from Hand/S&T, then place 1 "Forbidden One" from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- [Quick Effect] Opponent activates -> Place 1 "Forbidden One" from Hand/Deck/GY & Burn 1000
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.plcon)
    e2:SetTarget(s.pltg)
    e2:SetOperation(s.plop)
    c:RegisterEffect(e2)
    -- [Continuous Effect] Alternate Win Condition
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.winop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_FORBIDDEN_ONE}
s.listed_names={24221739}
function s.costfilter(c)
    return c:IsCode(CARD_MILLENNIUM_CROSS) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.CheckLPCost(tp,2000)
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 1: Pay 2000 LP, 2: Reveal Cross
    elseif b1 then
        op=0
    else
        op=1
    end
    if op==0 then
        Duel.PayLPCost(tp,2000)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
    end
end
function s.fbfilter(c)
    return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster() and not c:IsForbidden()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        -- Ensure there is S&T space (or this card is freeing an S&T zone by summoning itself)
        local szone_free = Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and szone_free
            and Duel.IsExistingMatchingCard(s.fbfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,s.fbfilter,tp,LOCATION_DECK,0,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            -- Place in S&T zone and treat as Continuous Spell
            if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
                local e1=Effect.CreateEffect(c)
                e1:SetCode(EFFECT_CHANGE_TYPE)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
                e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
                tc:RegisterEffect(e1)
            end
        end
    end
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.fbfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    -- Allow NecroValleyFilter so picking from GY works legally
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fbfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)
            
            -- Inflict damage after successful placement
            Duel.BreakEffect()
            Duel.Damage(1-tp,1000,REASON_EFFECT)
        end
    end
end
function s.winfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsOriginalType(TYPE_MONSTER)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.winfilter,tp,LOCATION_SZONE,0,nil)
    -- Check if there are 5 unique IDs among the Forbidden One cards in the S&T zone
    if g:GetClassCount(Card.GetCode)>=5 then
        Duel.Win(tp,WIN_REASON_MILLENNIUM_EXXOD)
    end
end