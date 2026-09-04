-- Saber War Council
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Send to GY and Search)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- GY Effect (Banish to Salvage/Search)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id) -- Shared count limit locks out E1 if E2 is used, and vice versa
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_X_SABER, SET_GOTTOMS}
s.listed_names={id}

-- EFFECT 1 (Activation)
function s.thfilter(c,code)
    return c:IsSetCard(SET_X_SABER) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(code)
end
function s.cfilter(c,tp)
    -- Must verify that a target with a different name will still exist in the Deck AFTER this card is sent as cost
    return c:IsSetCard(SET_X_SABER) and c:IsMonster() and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    e:SetLabel(g:GetFirst():GetCode())
    Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end -- Handled by cost check
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- EFFECT 2 (GY Banish)
function s.syncfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_X_SABER) and c:IsType(TYPE_SYNCHRO)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    -- aux.exccon checks that the card was not sent to the GY this turn
    return aux.exccon(e) and Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.gythfilter(c)
    return (c:IsSetCard(SET_X_SABER) or c:IsSetCard(SET_GOTTOMS)) and c:IsType(TYPE_SPELL+TYPE_TRAP) 
        and not c:IsCode(id) and c:IsAbleToHand()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gythfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gythfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end