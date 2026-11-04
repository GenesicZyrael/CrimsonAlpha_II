-- Dragonmaid En'Gard
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon Procedure
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2)
    -- Effect 1: Burn on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    -- Effect 2: Detach to Burn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.burtg)
	e3:SetOperation(s.burop)
	c:RegisterEffect(e3)
    -- Effect 3: Tag Out (Mandatory)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.rtcon)
    e4:SetTarget(s.rttg)
    e4:SetOperation(s.rtop)
    c:RegisterEffect(e4)
    -- Global Tracker for Dragon Summons this turn
	if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SUMMON_SUCCESS)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(ge2,0)
    end
end
s.listed_series={SET_DRAGONMAID}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsSetCard,nil,SET_DRAGONMAID)
    for tc in aux.Next(g) do
        -- Register a flag effect on player 0 to act as a global counter
        Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
    end
end

function s.addcount(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsMonster() and tc:GetOriginalRace()==RACE_DRAGON then
			s[0]=s[0]+1
		end
	end
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end

function s.burtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFlagEffect(0,id)>0 end
    local ct=Duel.GetFlagEffect(0,id)
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(ct*200)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function s.burop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFlagEffect(0,id)
    if ct>0 then
        Duel.Damage(1-tp,ct*200,REASON_EFFECT)
    end
end

function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayCount()==0
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_DRAGONMAID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return true end -- Mandatory trigger, chk bypass
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end