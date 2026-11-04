-- Oukarmada - Amagi
local s,id=GetID()
function s.initial_effect(c)
    -- [Quick] Hand monster effect activated: Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- [Trigger] Special Summoned: Shuffle random card(s) & draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.shuftg)
    e2:SetOperation(s.shufop)
    c:RegisterEffect(e2)
    -- [Trigger] Oukarmada card/effect activated: Shuffle random card(s) & draw
	local e3=e2:Clone()
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.actcon)
    c:RegisterEffect(e3)
end
s.listed_series={SET_OUKARMADA}
s.listed_names={id}

-- Effect 1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_HAND and re:GetHandler():GetCode()~=id
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return not c:IsPublic() end
    Duel.ConfirmCards(1-tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Effects 2 & 3
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsSetCard(SET_OUKARMADA) and re:GetHandler():GetCode()~=id
end
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_OUKARMADA)
end
function s.shuftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.shufop(e,tp,eg,ep,ev,re,r,rp)
    local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #hg==0 then return end
    local ct=1
    -- Reduced requirement from 4 down to 3
    if #hg>=2 and Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)>=3 then
        local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if op==1 then ct=2 end
    end
    local sg=hg:RandomSelect(tp,ct)
    if #sg>0 and Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        local og=Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0 then
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end