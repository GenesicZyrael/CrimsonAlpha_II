-- Elemental HERO Tombstone
local s,id=GetID()
function s.initial_effect(c)
    -- Must first be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,84327329,89252153) -- Clayman + Necroshade
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- Your opponent cannot target monsters for attacks, except this one
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.atg)
    c:RegisterEffect(e1)

    -- If this card battles, opponent cannot activate cards/effects until the end of the Damage Step
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(1)
    e2:SetCondition(s.actcon)
    c:RegisterEffect(e2)

    -- [Quick Effect] Banish 1 "Elemental HERO" to gain DEF equal to ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_DAMAGE_STEP)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    -- e3:SetCondition(aux.dscon) -- Restricts to Damage Step rules if activated then
    e3:SetCost(s.defcost)
    e3:SetOperation(s.defop)
    c:RegisterEffect(e3)

    -- After damage calculation: Negate the opponent's monster's effects
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLED)
    e4:SetCondition(s.negcon)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}

-- ==========================================
-- Effect 1: Attack Target Restriction
-- ==========================================
function s.atg(e,c)
    return c~=e:GetHandler()
end

-- ==========================================
-- Effect 2: Armades-style Lockdown
-- ==========================================
function s.actcon(e)
    local c=e:GetHandler()
    return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end

-- ==========================================
-- Effect 3: Banish to Gain DEF
-- ==========================================
function s.cfilter(c)
    return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetValue(c:GetAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- ==========================================
-- Effect 4: Post-Battle Negation
-- ==========================================
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and not bc:IsDisabled()
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() and bc:IsFaceup() and not bc:IsDisabled() then
        -- Negate Effects
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        bc:RegisterEffect(e1)
        
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        bc:RegisterEffect(e2)
    end
end