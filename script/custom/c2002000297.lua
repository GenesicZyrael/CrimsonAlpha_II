-- Oukarmada - Hiryuu
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon procedure: If you control no cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    -- Continuous: Indestructible once per turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetCountLimit(1)
    e2:SetValue(s.valcon)
    c:RegisterEffect(e2)
    -- Ignition: Mill 1, Place 1 from GY to Decktop
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.miltg)
    e3:SetOperation(s.milop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_OUKARMADA}
s.listed_names={id}

-- Effect 1: If you control no cards
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end

-- Effect 2
function s.valcon(e,re,r,rp)
    return (r&REASON_BATTLE)~=0 or ((r&REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer())
end

-- Effect 3
function s.miltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.milop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
    Duel.DisableShuffleCheck()
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if Duel.SendtoGrave(top,REASON_EFFECT)>0 and top:IsLocation(LOCATION_GRAVE) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
        local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_GRAVE,0,1,1,top)
        if #g>0 then
            Duel.MoveSequence(g:GetFirst(),SEQ_DECKTOP)
        end
    end
end