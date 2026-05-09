-- Vylon Draconis
local s,id=GetID()
function s.initial_effect(c)
    -- Pendulum Summon Procedure
    Pendulum.AddProcedure(c)
    
    -- [Pendulum Effect 1] Destroy 1 other "Vylon" card; Add 1 "Vylon" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.thtg1)
    e1:SetOperation(s.thop1)
    c:RegisterEffect(e1)

    -- [Pendulum Effect 2] Special Summon 1 "Vylon" non-Tuner from hand or GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    
    -- [Monster Effect 1] Add 1 "Vylon" Spell/Trap on Normal/Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.thtg2)
    e3:SetOperation(s.thop2)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    
    -- [Monster Effect 2] Place in P-Zone when leaving the field or sent to GY
    -- Trigger on leaving the field
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetCountLimit(1,{id,3})
    e5:SetCondition(s.pencon1)
    e5:SetTarget(s.pentg)
    e5:SetOperation(s.penop)
    c:RegisterEffect(e5)
    -- Trigger on being sent to the GY (from elsewhere)
    local e6=e5:Clone()
    e6:SetCode(EVENT_TO_GRAVE)
    e6:SetCondition(s.pencon2)
    c:RegisterEffect(e6)
end

-----------------------------------------
-- Pendulum Effect 1 (Search Monster)
-----------------------------------------
function s.desfilter(c)
    return c:IsSetCard(SET_VYLON)
end
function s.thfilter1(c)
    return c:IsSetCard(SET_VYLON) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c)
        and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tg=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
        if #tg>0 then
            Duel.SendtoHand(tg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tg)
        end
    end
end

-----------------------------------------
-- Pendulum Effect 2 (Special Summon)
-----------------------------------------
function s.cfilter(c,tp)
    return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
        and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsSetCard(SET_VYLON)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()~=PHASE_DAMAGE and eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_VYLON) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-----------------------------------------
-- Monster Effect 1 (Search Spell/Trap)
-----------------------------------------
function s.thfilter2(c)
    -- Ensures it searches a Vylon Spell/Trap and isn't somehow pulling this specific card ID
    return c:IsSetCard(SET_VYLON) and c:IsSpellTrap() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-----------------------------------------
-- Monster Effect 2 (Pendulum Place)
-----------------------------------------
function s.pencon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pencon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not (c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE))
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    -- Restriction: Cannot Special Summon for the rest of the turn, except "Vylon" monsters.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    -- Place in Pendulum Zone
    if not Duel.CheckPendulumZones(tp) then return end
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(SET_VYLON)
end