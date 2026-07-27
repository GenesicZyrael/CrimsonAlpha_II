-- Elemental HERO Nightblaze
local s,id=GetID()
function s.initial_effect(c)
    -- Must first be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,58932615,89252153) -- Burstinatrix + Necroshade
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)
    -- This card can attack directly
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e1)
    -- ATK is halved during damage calculation (when bypassing monsters)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    -- If Fusion Summoned: Take 1 opponent's S/T, add to hand or send to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
-- ==========================================
-- Effect 2: ATK Halving Logic
-- ==========================================
function s.atkcon(e)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
    local c=e:GetHandler()
	local tp=c:GetControler()
    return Duel.GetAttacker()==c and Duel.GetAttackTarget()==nil 
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==1
        and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function s.atkval(e,c)
    return math.ceil(c:GetAttack()/2)
end

-- ==========================================
-- Effect 3: Steal/Mill Opponent's Spell/Trap
-- ==========================================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.thfilter(c)
    return c:IsSpellTrap() and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_DECK,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- Target the opponent's deck (0, LOCATION_DECK)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_DECK,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local op=0
        if tc:IsAbleToHand() and tc:IsAbleToGrave() then
            -- Prompt the player with choices
            op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif tc:IsAbleToHand() then
            op=0
        else
            op=1
        end
        -- Execute chosen operation
        if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            Duel.SendtoHand(tc,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end