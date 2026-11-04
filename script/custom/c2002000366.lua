-- Mist Valley Mother Roc
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Effect 2: Search/Recover on Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
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
end
s.listed_series={SET_MIST_VALLEY}

function s.rtfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_MIST_VALLEY) and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    local rg=Duel.GetMatchingGroup(s.rtfilter,tp,LOCATION_ONFIELD,0,nil)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and #rg>0 
        and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or rg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local rg=Duel.GetMatchingGroup(s.rtfilter,tp,LOCATION_ONFIELD,0,nil)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local g=nil
    if ft>0 then
        g=rg
    else
        g=rg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local tc=g:SelectUnselect(nil,tp,false,true,1,1)
    if tc then
        e:SetLabelObject(tc)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    if tc then
        Duel.SendtoHand(tc,nil,REASON_COST)
    end
end

function s.thfilter(c)
    return c:IsSetCard(SET_MIST_VALLEY) and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        Duel.BreakEffect()
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end