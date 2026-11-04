-- The Weather Stormy Canvas
local s,id=GetID()
function s.initial_effect(c)
    -- You can only control 1 "The Weather Stormy Canvas"
    c:SetUniqueOnField(1,0,id)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- Effect 1: Send up to 2 Spells/Traps, place from hand/GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,0})
    e2:SetCost(s.plcost)
    e2:SetTarget(s.pltg)
    e2:SetOperation(s.plop)
    c:RegisterEffect(e2)
    -- Effect 2: Granted Quick Effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.announcecost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.eftg)
    e4:SetLabelObject(e3)
    c:RegisterEffect(e4)
end
s.listed_series={SET_THE_WEATHER}

function s.cfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.plfilter(c,tp,codes)
    if not (c:IsSetCard(SET_THE_WEATHER) and c:IsType(TYPE_CONTINUOUS) and c:IsSpellTrap() 
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)) then return false end
    -- Must have a different name from the cards sent
    if codes then
        for _,code in ipairs(codes) do
            if c:IsCode(code) then return false end
        end
    end
    return true
end
function s.costchk(sg,e,tp,mg)
    local codes = {}
    for tc in aux.Next(sg) do table.insert(codes,tc:GetCode()) end
    local place_g = Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,sg,tp,codes)
    return place_g:GetClassCount(Card.GetCode) >= #sg
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
    if chk==0 then 
        return c:IsAbleToGraveAsCost() and s.costchk(Group.FromCards(c),e,tp,g)
    end
    -- Select 1 to 2 Spells/Traps, strictly enforcing that `c` is included and valid replacements exist
    local sg=aux.SelectUnselectGroup(g,e,tp,1,2,function(sg2) return sg2:IsContains(c) and s.costchk(sg2,e,tp,g) end, 1, tp, HINTMSG_TOGRAVE)
    sg:KeepAlive()
    e:SetLabelObject(sg)
    Duel.SendtoGrave(sg,REASON_COST)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end -- Safety already handled dynamically in costchk
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local sg=e:GetLabelObject()
    if not sg then return end
    local ct=#sg
    local codes={}
    for tc in aux.Next(sg) do table.insert(codes,tc:GetCode()) end
    sg:DeleteGroup()
    
    local place_g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,tp,codes)
    if place_g:GetClassCount(Card.GetCode) < ct then return end
    
    for i=1,ct do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=place_g:Select(tp,1,1,nil):GetFirst()
        if tc then
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            -- Prevent selecting the same name again for the second placement
            place_g:Remove(Card.IsCode,nil,tc:GetCode())
        end
    end
end

function s.eftg(e,c)
    local g=e:GetHandler():GetColumnGroup(1,1)
    return c:IsType(TYPE_EFFECT) and c:IsSetCard(SET_THE_WEATHER) and c:GetSequence()<5 and g:IsContains(c)
end
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.tgfilter2(c)
    return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and s.tgfilter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.tgfilter2,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.decktgfilter(c)
    return c:IsSetCard(SET_THE_WEATHER) and c:IsAbleToGrave()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        local g=Duel.GetMatchingGroup(s.decktgfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoGrave(sg,REASON_EFFECT)
        end
    end
end