-- Muse of Nephthys
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon (1 "Nephthys" monster)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_NEPHTHYS),1,1)
    -- [Quick] Negate opponent's monster effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    -- [Trigger] Tributed: Register delayed Ritual Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_RELEASE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.regtg)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
	-- [Trigger] Destroyed: Register delayed Ritual Summon
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.regcon)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NEPHTHYS}
s.listed_names={id}

-- Effect 1 (Negation)
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return tp~=Duel.GetTurnPlayer() and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.desfilter(c)
    return c:IsSetCard(SET_NEPHTHYS) and c:IsDestructable()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDestructable() 
        and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        g:AddCard(c)
        if Duel.Destroy(g,REASON_EFFECT)==2 then
            Duel.NegateActivation(ev)
        end
    end
end

-- Effect 2 (Delayed Ritual Summon)
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_EFFECT)~=0
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    -- Creates a lingering Standby Phase effect
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetCondition(s.rscon)
    e1:SetOperation(s.rsop)
    if Duel.GetCurrentPhase()==PHASE_STANDBY then
        e1:SetLabel(Duel.GetTurnCount())
        e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
    else
        e1:SetLabel(0)
        e1:SetReset(RESET_PHASE+PHASE_STANDBY,1)
    end
    Duel.RegisterEffect(e1,tp)
end
function s.rfilter(c,e,tp)
    return (c:IsSetCard(SET_NEPHTHYS) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true))
end
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()~=e:GetLabel() and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.matfilter(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsDestructable(e)
end
function s.ritfilter(c,e,tp,m)
    -- Ensure the target is a Nephthys Ritual Monster that can be summoned
    if not (c:IsSetCard(SET_NEPHTHYS) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)) then return false end
    -- Ensure there are at least 2 other monsters available to destroy
    local g=m:Clone()
    g:RemoveCard(c)
    return #g>=2
end
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    local m=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
    local tg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_HAND,0,nil,e,tp,m)
    if #tg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=tg:Select(tp,1,1,nil):GetFirst()
        m:RemoveCard(tc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local mat=m:Select(tp,2,2,nil)
        tc:SetMaterial(mat)
        -- Destroying as Ritual Material correctly formats it as a Card Effect for Nephthys triggers
        if Duel.Destroy(mat,REASON_EFFECT+REASON_MATERIAL)==2 then
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
    e:Reset()
end