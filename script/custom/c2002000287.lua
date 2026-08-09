-- Supreme King Arc Pendulumgraph Sorcerer
local s,id=GetID()
function s.initial_effect(c)
    -- Enable Pendulum & Fusion mechanics
    Pendulum.AddProcedure(c)
    c:EnableReviveLimit()
    -- Fusion Material: 3+ Pendulum Summoned Pendulum Monsters with different names and scales
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
    -- ==========================================
    -- Pendulum Effect 1: Extra Pendulum Summon
    -- ==========================================
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(function(e,tp) return Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id) and Duel.IsPlayerCanPendulumSummon(tp) end)
	e1:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),nil,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,2),aux.Stringid(id,3),id) end)
	c:RegisterEffect(e1)
    -- ==========================================
    -- Pendulum Effect 2: ATK/DEF Gain & Protection
    -- ==========================================
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.pendtg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(3002)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.pendtg)
	e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
    -- ==========================================
    -- Monster Effect 1: Quick Effect Add & Pendulum Summon
    -- ==========================================
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+1)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    -- ==========================================
    -- Monster Effect 2: Post-Pendulum Banish
    -- ==========================================
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_REMOVE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.rmcon)
    e6:SetTarget(s.rmtg)
    e6:SetOperation(s.rmop)
    c:RegisterEffect(e6)
    -- ==========================================
    -- Monster Effect 3: Place in Pendulum Zone
    -- ==========================================
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,3))
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCode(EVENT_LEAVE_FIELD)
    e7:SetCondition(s.pencon)
    e7:SetTarget(s.pentg)
    e7:SetOperation(s.penop)
    c:RegisterEffect(e7)
end
-- ==========================================
-- Fusion Material Check Group Logic
-- ==========================================
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsType(TYPE_PENDULUM,fc,sumtype,tp) 
		and (not sg or sg:FilterCount(aux.TRUE,c)==0 or not (sg:IsExists(Card.IsScale,1,c,c:GetScale())))	
end
-- ==========================================
-- Pendulum Buff/Protection Logic
-- ==========================================
function s.pendtg(e,c)
	return c:IsPendulumSummoned() and c:GetFlagEffect(id)~=0
end
function s.checktg(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPendulumSummoned()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
-- ==========================================
-- Quick Effect Add & Pendulum Summon Logic
-- ==========================================
function s.thfilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() 
        and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    -- Forces the native Pendulum Summon to only look at the Hand by blocking the Extra Deck
    return c:IsLocation(LOCATION_EXTRA)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then 
        if ft<=0 or not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil) then return false end
        -- Register the lock temporarily to strictly verify if a Pendulum Summon from hand is possible 
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        Duel.RegisterEffect(e1,tp)
        local res = Duel.IsPlayerCanPendulumSummon(tp)
        e1:Reset()
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,ft,nil)
    
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        Duel.BreakEffect()
        
        -- Apply the Extra Deck block for the duration of this chain resolution
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e1,tp)
        
        -- Native engine handles scales and valid levels organically from here
        if Duel.IsPlayerCanPendulumSummon(tp) then
            Duel.PendulumSummon(tp)
        end
    end
end
-- ==========================================
-- Pendulum Banish Trigger Logic
-- ==========================================
function s.pfilter(c)
    return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.pfilter,1,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=eg:FilterCount(s.pfilter,nil)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,ct,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,ct,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
-- ==========================================
-- Leave Field Replacement Logic
-- ==========================================
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckPendulumZones(tp) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end