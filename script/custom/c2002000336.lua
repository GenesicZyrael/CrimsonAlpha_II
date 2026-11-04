-- Jurrac Tyrannus Rex
local s,id=GetID()
local CARD_JURRAC_VOLCANO=89948817
function s.initial_effect(c)
    -- Effect 1: Special Summon from hand/GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Effect 2: Negate activation
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,4))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
    -- Effect 3: Destruction Replacement for Jurrac Spells/Traps
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_JURRAC} -- Jurrac
s.listed_names={CARD_JURRAC_VOLCANO}

function s.cfilter(c)
    return c:IsRace(RACE_DINOSAUR) and not c:IsCode(id) and c:HasLevel() and c:IsAbleToGraveAsCost()
end
function s.check(sg,e,tp,mg)
    return sg:GetSum(Card.GetLevel)==10
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil)
    if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,3,s.check,0) end
    local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.check,1,tp,HINTMSG_TOGRAVE)
    Duel.SendtoGrave(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.volfilter(c,tp)
    return c:IsCode(CARD_JURRAC_VOLCANO) 
		and (c:IsAbleToHand() or (not c:IsForbidden() and c:CheckUniqueOnField(tp)))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.volfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
            local tc=g:Select(tp,1,1,nil):GetFirst()
            if tc then
                local b1=tc:IsAbleToHand()
                local b2=not tc:IsForbidden() and tc:CheckUniqueOnField(tp) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0)
                local op=0
                if b1 and b2 then
                    op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
                elseif b1 then
                    op=0
                else
                    op=1
                end
                
                if op==0 then
                    Duel.SendtoHand(tc,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,tc)
                else
					Duel.PlaceFieldSpell(tc,tp)
                end
            end
        end
    end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end

function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE)
        and c:IsSetCard(SET_JURRAC) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.rmfilter(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        Duel.SetTargetCard(g)
        return true
    else return false end
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
    end
end
