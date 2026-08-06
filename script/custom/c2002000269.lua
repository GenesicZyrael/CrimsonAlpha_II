-- Custom World Legacy Win Condition Card
local s,id=GetID()
local LCARD_AVIDA=17469113 -- Avida, Rebuilder of Worlds
local LCARD_LIB=39752820 -- Lib the World Key Blademaster

function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_WORLD_LEGACY}
s.listed_names={17469113,39752820}

-- ==========================================
-- Card Activation Conditions & Logic
-- ==========================================
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Checks for the flag registered by Avida's native script
    return Duel.GetFlagEffect(tp, LCARD_AVIDA) > 0
end

function s.avida_filter(c,tp)
    return c:IsCode(LCARD_AVIDA) and c:IsFaceup() 
		and c:IsControler(tp) and c:IsAbleToRemove()
end

function s.wl_filter(c)
    return c:IsSetCard(SET_WORLD_LEGACY) 
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) 
		and c:IsLevelAbove(5) and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
	return c:IsCode(LCARD_LIB) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local avida_g=Duel.GetMatchingGroup(s.avida_filter,tp,LOCATION_MZONE,0,nil,tp)
    local wl_g=Duel.GetMatchingGroup(s.wl_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if chk==0 then
        return #avida_g>0 and aux.SelectUnselectGroup(wl_g,e,tp,7,7,aux.dncheck,0)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,8,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local avida=Duel.SelectMatchingCard(tp,s.avida_filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    if not avida then return end
    local wl_g=Duel.GetMatchingGroup(s.wl_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    local rg=aux.SelectUnselectGroup(wl_g,e,tp,7,7,aux.dncheck,1,tp,HINTMSG_REMOVE)
    if #rg<7 then return end
    rg:AddCard(avida)
    if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==8 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
        if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- Grant the win condition effect
            local r1=Effect.CreateEffect(e:GetHandler())
            r1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
            r1:SetCode(EVENT_BATTLE_DAMAGE)
            r1:SetOperation(s.winop)
            r1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(r1,true)
        end
    end
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
    if ep~=tp and Duel.GetAttackTarget()==nil then
        Duel.Win(tp,WIN_REASON_WORLD_LEGACY)
    end
end