-- Elemental HERO Dark Wingman
local s,id=GetID()
function s.initial_effect(c)
    -- Must first be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,21844576,89252153) -- Avian + Necroshade
    -- This card can attack your opponent directly
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e1)
    -- ATK is halved during damage calculation (when attacking directly)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    -- When Special Summoned: Set up to 3 Spells/Traps from Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
    -- At the start of the Damage Step: Return opponent's monster to hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLE_START)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}

function s.atkcon(e)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
    local c=e:GetHandler()
	local tp=c:GetControler()
    return Duel.GetAttacker()==c and Duel.GetAttackTarget()==nil 
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==1
        and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.atkval(e,c)
    return c:GetAttack()/2
end

function s.setfilter(c,tg)
    if not (c:IsSpellTrap() and c:IsSSetable()) then return false end
	for tc in aux.Next(tg) do
        if c:ListsCode(tc:GetCode()) then return true end
    end
    return false
end
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsFaceup() 
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tg)
    end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local ft = Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft <= 0 then return end
    local max_set = math.min(ft,3)
    local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,tg)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
	if sg and #sg > 0 then
		Duel.ConfirmCards(1-tp,sg)
        Duel.SSet(tp,sg)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,bc,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        Duel.SendtoHand(bc,nil,REASON_EFFECT)
    end
end