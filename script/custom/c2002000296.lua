-- Oukarmada - Nagato
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon (Link-3, Exactly 3 Oukarmada monsters)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_OUKARMADA),3,3)
    -- Continuous: ATK Boost
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.atktg)
    e1:SetValue(300)
    c:RegisterEffect(e1)
    -- Trigger: Draw 1 card on Link Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
    -- Ignition: Declare, Reveal, Banish, Draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.rmcon)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_OUKARMADA}
s.listed_names={id}

-- Effect 1
function s.atktg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(SET_OUKARMADA)
end

-- Effect 2
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

-- Effect 3
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_OUKARMADA)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Must be in EMZ and control 3+ Oukarmada cards
    return c:GetSequence()>4 and Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)>=3
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local ac=Duel.AnnounceCard(tp)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    -- Recheck condition for resolution
    if e:GetHandler():GetSequence()<=4 or Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)<3 then return end
    
    local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    local g=Duel.GetDecktopGroup(tp,1)
    if #g>0 then
        Duel.ConfirmCards(1-tp,g)
        local tc=g:GetFirst()
        if tc:IsCode(ac) then
            -- Banish 1 from Hand (Random), Field, GY
            local hg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
            local fg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
            local gg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
            
            if #hg>0 and #fg>0 and #gg>0 then
                local rg=Group.CreateGroup()
                local hrand=hg:RandomSelect(tp,1)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                local fsel=fg:Select(tp,1,1,nil)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                local gsel=gg:Select(tp,1,1,nil)
                
                rg:Merge(hrand)
                rg:Merge(fsel)
                rg:Merge(gsel)
                
                if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==3 then
                    Duel.Draw(tp,1,REASON_EFFECT)
                end
            end
        end
        Duel.ShuffleDeck(tp)
    end
end