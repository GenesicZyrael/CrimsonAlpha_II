-- Jurrac Pachy
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon Procedure
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    -- Effect 1: If banished, return 2 Dinosaur monsters to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_REMOVE)
    e1:SetTarget(s.rtg)
    e1:SetOperation(s.rop)
    c:RegisterEffect(e1)
    -- Effect 2: If Synchro Summoned, add 1 "Jurrac" card from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    -- Effect 3: Quick Effect Accel Synchro
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_JURRAC}

function s.rtfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_REMOVED,0,1,2,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c)
    return c:IsSetCard(SET_JURRAC) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.exfilter(c,e,tp,lvl,mc)
    return c:IsSetCard(SET_JURRAC) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==lvl
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.gyfilter(c)
    return c:IsSetCard(SET_JURRAC) and c:IsType(TYPE_MONSTER) and c:HasLevel() and c:IsAbleToRemoveAsCost()
end
function s.chkfilter(sg,e,tp,mg,c)
    local lvl=c:GetLevel()
    local total_lvl = sg:GetSum(Card.GetLevel) + lvl
    return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,total_lvl,c)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,c)
    if chk==0 then
        return c:IsAbleToRemoveAsCost() 
			and aux.SelectUnselectGroup(g,e,tp,1,#g,function(sg,e,tp,mg) return s.chkfilter(sg,e,tp,mg,c) end,0)
    end
    local sg=aux.SelectUnselectGroup(g,e,tp,1,#g,function(sg,e,tp,mg) return s.chkfilter(sg,e,tp,mg,c) end,1,tp,HINTMSG_REMOVE)
    local req_lvl = sg:GetSum(Card.GetLevel) + c:GetLevel()
    sg:AddCard(c)
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    e:SetLabel(req_lvl)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end -- Verified in cost
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local req_lvl = e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    
    -- Important: mc (material card) is nil here because Jurrac Pachy has already left the field as cost
    local tc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,req_lvl,nil):GetFirst()
    if tc then
        tc:SetMaterial(nil)
        if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
            tc:CompleteProcedure()
        end
    end
end