-- Elemental HERO Firestorm
local s,id=GetID()
function s.initial_effect(c)
    -- Must first be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,58932615,84327329,89252153)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)
    -- [Ignition Effect] 
	-- Return 1 "Polymerization" or "Elemental HERO" from banishment/GY to Deck, grant multi-attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCost(s.tdcost)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)
    -- [Continuous Effect] Battle damage inflicted is treated as effect damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_BATTLE_DAMAGE_TO_EFFECT)
    c:RegisterEffect(e2)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
s.listed_names={CARD_POLYMERIZATION}
s.listed_series={SET_ELEMENTAL_HERO}
-- ==========================================
-- Effect 1: Recycle to Grant Attack All
-- ==========================================
function s.tdfilter(c)
    return (c:IsCode(CARD_POLYMERIZATION) or c:IsSetCard(SET_ELEMENTAL_HERO)) 
		and c:IsAbleToDeck()
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) 
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then 
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() 
	end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Can attack all monsters opponent controls once each
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ATTACK_ALL)
        e1:SetValue(s.atkfilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
function s.atkfilter(e,c)
    return c:IsControler(1-e:GetHandlerPlayer())
end