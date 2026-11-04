-- The Weather Thundershowery Canvas
local s,id=GetID()
function s.initial_effect(c)
    -- You can only control 1 "The Weather Thundershowery Canvas"
    c:SetUniqueOnField(1,0,id)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- Effect 1: Place "The Weather" Continuous Spell/Trap from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.plcon)
    e2:SetTarget(s.pltg)
    e2:SetOperation(s.plop)
    c:RegisterEffect(e2)
    -- Effect 2: Grant Effect to "The Weather" monsters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.announcecost)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.eftg)
    e4:SetLabelObject(e3)
    c:RegisterEffect(e4)
end
s.listed_series={SET_THE_WEATHER}

-- =====================================
-- EFFECT 1 LOGIC (Place from GY)
-- =====================================
function s.cfilter(c,tp,re)
    return c:IsPreviousControler(tp) and c:IsSetCard(SET_THE_WEATHER) and c:IsType(TYPE_MONSTER)
        and c:IsReason(REASON_COST) and re and re:GetHandler()==c
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp,re)
end
function s.plfilter(c,tp)
    return c:IsSetCard(SET_THE_WEATHER) and c:IsType(TYPE_CONTINUOUS) and c:IsSpellTrap()
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- =====================================
-- EFFECT 2 LOGIC (Granted Quick Effect)
-- =====================================
function s.eftg(e,c)
    local g=e:GetHandler():GetColumnGroup(1,1)
    return c:IsType(TYPE_EFFECT) and c:IsSetCard(SET_THE_WEATHER) and c:GetSequence()<5 and g:IsContains(c)
end
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
        -- Check if it was an Extra Deck monster
        if tc:IsType(TYPE_MONSTER) and tc:IsOriginalType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK) then
            if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.BreakEffect()
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    end
end