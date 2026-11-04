-- Jurrac Slash
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Activate from hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(s.handcon)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
    c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
s.listed_series={SET_JURRAC} -- Jurrac

function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_JURRAC)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsChainNegatable(ev)
end
function s.rmfilter(c)
    return c:IsSetCard(SET_JURRAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(tp,id)==0 
        and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,e:GetHandler())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then e:GetLabelObject():SetLabel(0) return true end
	if e:GetLabelObject():GetLabel()>0 then
        Duel.RegisterFlagEffect(tp,id,0,0,1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,2,c)
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        if Duel.Destroy(eg,REASON_EFFECT)>0 then
            local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
            if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local sg=g:Select(tp,1,1,nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg,REASON_EFFECT)
            end
        end
    end
end