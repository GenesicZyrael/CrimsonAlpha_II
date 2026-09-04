-- E-X-Saber Flameveilknight
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Always treated as an "Infernoble Knight" (SET_INFERNOBLE_KNIGHT) and "Flamvell" (SET_FLAMVELL) card
    local e0a=Effect.CreateEffect(c)
    e0a:SetType(EFFECT_TYPE_SINGLE)
    e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0a:SetCode(EFFECT_ADD_SETCODE)
    e0a:SetValue(SET_INFERNOBLE_KNIGHT)
    c:RegisterEffect(e0a)
    local e0b=e0a:Clone()
    e0b:SetValue(SET_FLAMVELL)
    c:RegisterEffect(e0b)
    -- Ignition: Equip 1 "Saber" Monster from Hand/Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    -- e1:SetCountLimit(1)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    -- Quick Effect: Negate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_SABER, SET_X_SABER, SET_INFERNOBLE_KNIGHT, SET_FLAMVELL}

-- EFFECT 1 (Equip and Copy)
function s.eqfilter(c)
    return c:IsSetCard(SET_SABER) and c:IsType(TYPE_EFFECT) and c:IsMonster() and not c:IsForbidden()
end
function s.check_equipped(c)
    return c:GetFlagEffect(id)>0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and c:GetEquipGroup():FilterCount(s.check_equipped,nil)==0
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
    
    if tc and Duel.Equip(tp,tc,c) then
        -- Tag the equipped card as being equipped by this specific effect (for the max 1 check)
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
        local code=tc:GetOriginalCode()
        -- Name Change
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)       
        -- Effect Copying
        local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
        -- Cleanup Listener: Removes the copied name/effect immediately if the equip card is destroyed
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_LEAVE_FIELD)
        e2:SetRange(LOCATION_MZONE)
        e2:SetLabel(cid)
        e2:SetLabelObject(e1)
        e2:SetCondition(s.clearcon(tc))
        e2:SetOperation(s.clearop)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
        -- Standard Equip Limits
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_EQUIP_LIMIT)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetValue(s.eqlimit)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
    end
end
function s.clearcon(tc)
    return function(e,tp,eg,ep,ev,re,r,rp)
        return eg:IsContains(tc)
    end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:ResetEffect(e:GetLabel(),RESET_COPY)
    local e1=e:GetLabelObject()
    if e1 then e1:Reset() end
    e:Reset()
end
function s.eqlimit(e,c)
    return e:GetOwner()==c
end

-- EFFECT 2 (Quick Effect Destroy & Negate)
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    -- id+1 handles the 'Once per Chain' limit natively without interfering with other turn-based triggers
    if chk==0 then return e:GetHandler():GetFlagEffect(id+1)==0
        and e:GetHandler():GetEquipGroup():GetCount()>0
        and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    e:GetHandler():RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    
    local g=e:GetHandler():GetEquipGroup()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=c:GetEquipGroup():Select(tp,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end