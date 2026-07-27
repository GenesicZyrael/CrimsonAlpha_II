-- Nemleria Dream Princess - Lucidulce
local s,id=GetID()
local CARD_DREAMING_NEMLERIA=70155677

function s.initial_effect(c)
    -- Xyz & Pendulum Summon Procedures
    Pendulum.AddProcedure(c,false)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEAST),10,2,nil,nil,99)
    c:EnableReviveLimit()
    -- [Pendulum Effect] Banish 3 face-down; Special Summon Level 10 Nemleria (Cannot be negated)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCost(s.pcost)
    e1:SetTarget(s.ptg)
    e1:SetOperation(s.pop)
    c:RegisterEffect(e1)

    -- [Monster Effect 1] Name becomes "Dreaming Nemleria" while face-up in Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetRange(LOCATION_EXTRA)
    e2:SetCondition(s.nmcon)
    e2:SetValue(CARD_DREAMING_NEMLERIA)
    c:RegisterEffect(e2)

    -- [Monster Effect 2] Detach to Banish 3 FD, Banish 1 FD, Set 1 Spell/Trap
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e3:SetCost(aux.dxmcostgen(1,1,nil))
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)

    -- [Monster Effect 3] Place in Pendulum Zone
    -- Condition A: Leaves the Monster Zone
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.pzcon1)
    e4:SetTarget(s.pztg)
    e4:SetOperation(s.pzop)
    c:RegisterEffect(e4)
    
    -- Condition B: If you control "Dreaming Nemleria"
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.pzcon2)
    e5:SetTarget(s.pztg)
    e5:SetOperation(s.pzop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e6)
    local e7=e5:Clone()
    e7:SetCode(EVENT_CONTROL_CHANGED)
    c:RegisterEffect(e7)
end

-- ==========================================
-- Pendulum Effect
-- ==========================================
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
        and Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3 end
    Duel.DisableShuffleCheck()
    Duel.Remove(Duel.GetDecktopGroup(tp,3),POS_FACEDOWN,REASON_COST)
end

function s.pfilter(c,e,tp)
    return c:IsSetCard(SET_NEMLERIA) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.pop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    -- Apply Extra Deck Lock
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    -- Proceed with Summon
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_PENDULUM)
end

-- ==========================================
-- Monster Effect 1: Face-up Extra Deck Name
-- ==========================================
function s.nmcon(e)
    return e:GetHandler():IsFaceup()
end

-- ==========================================
-- Monster Effect 2: Quick Effect Removal & Set
-- ==========================================
function s.rmfilter(c)
    return c:IsAbleToRemove(tp,POS_FACEDOWN)
end

function s.setfilter(c)
    return c:IsSetCard(SET_NEMLERIA) and c:IsSpellTrap() and c:IsSSetable()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
            and Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 
            and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,0,LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
    
    local g=Duel.GetDecktopGroup(tp,3)
    Duel.DisableShuffleCheck()
    if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local opp_g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
        
        if #opp_g>0 and Duel.Remove(opp_g,POS_FACEDOWN,REASON_EFFECT)>0 then
            local set_g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
            if #set_g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                local sg=set_g:Select(tp,1,1,nil)
                Duel.SSet(tp,sg:GetFirst())
            end
        end
    end
end

-- ==========================================
-- Monster Effect 3: Place in Pendulum Zone
-- ==========================================
function s.pzcon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) 
end

function s.dn_filter(c,tp)
    return c:IsCode(CARD_DREAMING_NEMLERIA) and c:IsControler(tp) and c:IsFaceup()
end

function s.pzcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.dn_filter,1,nil,tp)
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
end

function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckPendulumZones(tp) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end