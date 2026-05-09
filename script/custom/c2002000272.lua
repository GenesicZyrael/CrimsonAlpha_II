-- Fuxi, the Lavalval Dracomet
local s,id=GetID()
function s.initial_effect(c)
    -- Pendulum Summon Procedure
    Pendulum.AddProcedure(c)
    -- [Pendulum Effect] Return banished monsters to Deck; optionally add "Laval" S/T
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_REMOVE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.tdcon)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)
    -- [Monster Effect 1] Quick Effect: Discard to send 1 "Laval" monster to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    -- [Monster Effect 2] Place in P-Zone, then optionally banish (Non-Targeting)
    -- Trigger on being added to the Extra Deck face-up
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.pencon1)
    e3:SetTarget(s.pentg)
    e3:SetOperation(s.penop)
    c:RegisterEffect(e3)
    -- Trigger on being sent to the GY by card effect
    local e4=e3:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.pencon2)
    c:RegisterEffect(e4)
end
-----------------------------------------
-- Pendulum Effect Functions
-----------------------------------------
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    -- Triggers if ANY cards are banished
    return eg and #eg>0
end
function s.tdfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function s.thfilter(c)
    return c:IsSetCard(SET_LAVAL) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local max = #eg -- Maximum up to the number of cards banished in this event
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,max,nil)
    if #g>0 then
        -- Returns the cards to the deck and counts how many successfully went back
        local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        if ct>=3 then
            local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
            -- "Add 1 "Laval" Spell/Trap?"
            if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local tg=sg:Select(tp,1,1,nil)
                Duel.SendtoHand(tg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tg)
            end
        end
    end
end

-----------------------------------------
-- Monster Effect 1 (Quick Effect Discard)
-----------------------------------------
function s.tgfilter(c)
    return c:IsSetCard(SET_LAVAL) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
    -- Moved the discard check here so it validates before activation
    if chk==0 then return c:IsDiscardable(REASON_EFFECT) 
        and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_HAND_DES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local c=e:GetHandler()
    -- Only proceed if the card is actually sent to the GY
    if Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end
-----------------------------------------
-- Monster Effect 2 (Pendulum Place + Banish)
-----------------------------------------
function s.pencon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
end
function s.pencon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.CheckPendulumZones(tp) then return end
    -- Places the card in the P-Zone
    if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
        -- Resolution-based Non-Targeting Banish
        local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end