-- X-Saber Urein
local s,id=GetID()
function s.initial_effect(c)
    -- Custom Activity Counter for Extra Deck restriction
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
    -- Synchro Level 2 or 4
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
    -- Trigger: Special Summon from GY (Tribute)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_RELEASE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon1)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    -- Trigger: Special Summon from GY (Normal Summoned X-Saber Tuner)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetCondition(s.spcon2)
    c:RegisterEffect(e4)
end
s.listed_series={SET_X_SABER}
-- Counter Filter (Allows Main Deck summons, restricts Extra Deck to X-Sabers)
function s.counterfilter(c)
    return c:IsSetCard(SET_X_SABER) or not c:IsLocation(LOCATION_EXTRA)
end
-- Synchro Level Values
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return sc:IsSetCard(SET_X_SABER) and ((sum+2==lv) or (sum+4==lv)),true
end
-- Condition 1: Tributed for a monster effect
function s.cfilter(c)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_COST)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentPhase()==PHASE_DAMAGE then return false end
    return re and re:IsActiveType(TYPE_MONSTER) and eg:IsExists(s.cfilter,1,nil)
        and not eg:IsContains(e:GetHandler())
end
-- Condition 2: X-Saber Tuner is Normal Summoned
function s.sumfilter(c)
    return c:IsSetCard(SET_X_SABER) and c:IsType(TYPE_TUNER) and c:IsFaceup()
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentPhase()==PHASE_DAMAGE then return false end
    return eg:IsExists(s.sumfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_X_SABER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end