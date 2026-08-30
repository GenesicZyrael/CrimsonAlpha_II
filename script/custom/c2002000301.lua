-- Horus the Divine Black Flame Dragon Deity
local s,id=GetID()
local LCL_CARD_CANOPIC_PROTECTOR=1490690
function s.initial_effect(c)
    -- Xyz Summon (2+ Level 8 monsters)
    c:EnableReviveLimit()
    -- Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HORUS),8,2,nil,nil,Xyz.InfiniteMats)
    -- Trigger: Place "Canopic Protector"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.plcon)
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)
    -- Quick Effect: Change opponent's monster effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    -- e2:SetCategory(CATEGORY_RELEASE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.chcon)
    e2:SetCost(Cost.DetachFromSelf(2))
    e2:SetTarget(s.chtg)
    e2:SetOperation(s.chop)
    c:RegisterEffect(e2)
    -- Trigger: Attach material from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.atchcon)
    e3:SetTarget(s.atchtg)
    e3:SetOperation(s.atchop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_HORUS}
s.listed_names={LCL_CARD_CANOPIC_PROTECTOR}

-- Effect 1 (Place Canopic Protector)
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.plfilter(c)
    return c:IsCode(LCL_CARD_CANOPIC_PROTECTOR) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- Effect 2 (Change Effect)
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.horusfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HORUS) and c:IsLevelBelow(8) and c:IsReleasable()
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        -- Ensures opponent has a monster and you have a Level 8 or lower Horus
        return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
            and Duel.IsExistingMatchingCard(s.horusfilter,tp,LOCATION_MZONE,0,1,nil) 
    end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
    Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    -- In this operation, 'tp' is the player whose effect was replaced (the opponent)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
    local g2=Duel.SelectMatchingCard(1-tp,s.horusfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g1>0 and #g2>0 then
        -- Uses REASON_RULE for "no effect" mimicking Share the Pain mechanics
        Duel.SendtoGrave(g1,REASON_RULE)
        -- Duel.SendtoGrave(g2,REASON_EFFECT,1-tp)
        Duel.Release(g2,REASON_EFFECT)
    end
end

-- Effect 3 (Attach Material)
function s.cfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) 
        and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.atchcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
        and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
    local tc=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER):GetFirst()
    if tc then
        Duel.Overlay(c,tc)
    end
end