-- Rank-Up-Magic: Rebellion Blitz
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Rank-Up)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(s.rumcon)
    e1:SetTarget(s.rumtg)
    e1:SetOperation(s.rumop)
    c:RegisterEffect(e1)
    -- GY Salvage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS, SET_REBELLION, SET_XYZ_DRAGON} -- Phantom Knights, Rebellion, Xyz Dragon

-- EFFECT 1 (Rank-Up during Battle Phase)
function s.rumcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
function s.rumfilter(c,e,tp,mc,rank)
    return c:GetRank()>rank and (c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) or c:IsSetCard(SET_REBELLION) or c:IsSetCard(SET_XYZ_DRAGON))
        and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.rumtgfilter(c,e,tp)
    -- Checks if the target is face-up, Xyz, AND has declared an attack this turn
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetAttackedCount()>0
        and Duel.IsExistingMatchingCard(s.rumfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
function s.rumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rumtgfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.rumtgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.rumtgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rumop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rumfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
    local sc=g:GetFirst()
    if sc then
        -- Transfer Materials and Xyz Summon
        local mg=tc:GetOverlayGroup()
        if #mg~=0 then
            Duel.Overlay(sc,mg)
        end
        sc:SetMaterial(Group.FromCards(tc))
        Duel.Overlay(sc,Group.FromCards(tc))
        Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end

-- EFFECT 2 (GY Salvage)
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return aux.exccon(e)
end
function s.thfilter(c)
    return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsMonster() and c:IsAbleToHand()
        and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    -- Up to 2
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end