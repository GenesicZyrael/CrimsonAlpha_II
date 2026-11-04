-- Master's Dragonmaid
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion Material Setup
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DRAGONMAID),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
    -- Effect 1: Special Summon, Dump, and Level Reduce
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Effect 2: Quick Effect Synchro
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.sccon)
    e2:SetTarget(s.sctg)
    e2:SetOperation(s.scop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGONMAID}
function s.matfilter(c)
    return c:IsAbleToRemoveAsCost() and c:IsMonster()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.deckfilter(c,e,tp)
    return c:IsSetCard(SET_DRAGONMAID) and c:IsType(TYPE_MONSTER) and c:HasLevel()
        and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToGrave())
end
function s.rescon(sg,e,tp,mg)
    if #sg~=2 then return false end
    local c1=sg:GetFirst()
    local c2=sg:GetNext()
    -- Must have same Attribute but different Levels
    if c1:GetAttribute() ~= c2:GetAttribute() then return false end
    if c1:GetLevel() == c2:GetLevel() then return false end
    -- At least one must be able to be Special Summoned, and the other sent to GY
    local b1 = c1:IsCanBeSpecialSummoned(e,0,tp,false,false) and c2:IsAbleToGrave()
    local b2 = c2:IsCanBeSpecialSummoned(e,0,tp,false,false) and c1:IsAbleToGrave()
    return b1 or b2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil,e,tp)
    
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_OPERATECARD)
    if #sg==2 then
        local tc1=sg:GetFirst()
        local tc2=sg:GetNext()
        local can_sp1 = tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc2:IsAbleToGrave()
        local can_sp2 = tc2:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc1:IsAbleToGrave()
        
        local sc, gc = nil, nil
        -- If both are valid to summon, let the player choose which one to summon
        if can_sp1 and can_sp2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            sc=sg:Select(tp,1,1,nil):GetFirst()
            gc=(sc==tc1) and tc2 or tc1
        -- Otherwise auto-assign based on validity
        elseif can_sp1 then
            sc=tc1
            gc=tc2
        else
            sc=tc2
            gc=tc1
        end
        
        if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            if Duel.SendtoGrave(gc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
                local lvl=sc:GetLevel()
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(-lvl)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e1)
            end
        end
    end
end

-- =====================================
-- EFFECT 2 LOGIC (Quick Synchro)
-- =====================================
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,sg:GetFirst(),c)
    end
end