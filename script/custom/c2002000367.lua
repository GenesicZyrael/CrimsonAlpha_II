-- Roosting Watchers of the Mist Valley
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon Procedure
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_WIND),1,99)
    -- Effect 1: Quick Effect Tribute to Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCondition(s.spcon1)
    e1:SetCost(Cost.SelfTribute)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    -- Effect 2: Protection (Cannot be attacked)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(0,LOCATION_MZONE)
	e2a:SetValue(s.tglimit)
	c:RegisterEffect(e2a)
	-- Effect 2: Protection (Cannot be targeted)
    local e2b=Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetTargetRange(LOCATION_MZONE,0)
    e2b:SetTarget(s.tglimit)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)
    -- Effect 3: GY Revival
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) -- Mandatory trigger (no "you can")
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.spcon2)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
end
s.listed_series={SET_MIST_VALLEY}

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
        and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter1(c,e,tp)
    return c:IsSetCard(SET_MIST_VALLEY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.tglimit(e,c)
    return c:IsSetCard(SET_MIST_VALLEY) and c~=e:GetHandler()
end

function s.revfilter(c)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_MONSTER)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.revfilter,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return true end 
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end