-- A-X-Saber Justicia
local s,id=GetID()
local MIN_MATS = 2
function s.initial_effect(c)
    -- Must be Special Summoned to an Extra Monster Zone (Prevents GY/Banish Summons to MMZ)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)
    -- Custom Link Summon Procedure
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.linkcon)
    e1:SetTarget(s.linktg)
    e1:SetOperation(s.linkop)
    e1:SetValue(s.linkval)
    c:RegisterEffect(e1)
    -- Trigger: Shuffle into Deck & Attack All
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
    -- Continuous: Immunity
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)
end
s.listed_series={SET_X_SABER, SET_GOTTOMS}

function s.splimit(e,se,sp,st)
    return e:GetHandler():IsLocation(LOCATION_EMZONE)
end
function s.linkval(e,c)
     return SUMMON_TYPE_LINK,0xff&0x60,1
end
function s.matfilter(c,lc,tp)
    return c:IsFaceup() and c:IsCanBeLinkMaterial(lc,tp)
end
function s.double_filter(c)
    return c:IsSetCard(SET_X_SABER) and c:IsType(TYPE_SYNCHRO)
end

function s.lcheck(g,lc,tp)
    if #g < MIN_MATS then return false end
    if not g:IsExists(Card.IsSetCard,1,nil,SET_X_SABER) then return false end
    local mat_table={}
    for tc in g:Iter() do
        if tc then 
            table.insert(mat_table,tc)
        end
    end
    local function check_sum(index,current_sum)
        if index>#mat_table then
            return current_sum==lc:GetLink()
        end
        local current_card=mat_table[index]
        local val1=1 
        local val2=1
        if current_card:IsType(TYPE_LINK) then
            val2 = current_card:GetLink()
        elseif s.double_filter(current_card) then
            val2 = 2
        end
        return check_sum(index + 1, current_sum + val1) or 
               (val2 > 1 and check_sum(index + 1, current_sum + val2))
    end
    return check_sum(1,0) 
        and Duel.GetLocationCountFromEx(tp,tp,g,lc,0xff&0x60)>0
end
function s.rescon(sg,e,tp,mg)
    return s.lcheck(sg,e:GetHandler(),tp)
end
function s.linkcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,c,tp)
    return aux.SelectUnselectGroup(g,e,tp,MIN_MATS,e:GetHandler():GetLink(),s.rescon,0)
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,c,tp)
    local sg=aux.SelectUnselectGroup(g,e,tp,MIN_MATS,e:GetHandler():GetLink(),s.rescon,1,tp,HINTMSG_LMATERIAL,s.rescon,nil,true)
    if sg and #sg > 0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else
        return false
    end
end
function s.linkop(e, tp, eg, ep, ev, re, r, rp, c)
    local sg = e:GetLabelObject()
    c:SetMaterial(sg)
    Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_LINK)
    sg:DeleteGroup()
end

-- EFFECT 2 (Shuffle with different names & Attack All)
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.gyfilter(c)
    return (c:IsSetCard(SET_X_SABER) or c:IsSetCard(SET_GOTTOMS)) and c:IsType(TYPE_SYNCHRO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
        local ct=g:GetClassCount(Card.GetCode)
        return ct>0 and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
    local max_ct=g:GetClassCount(Card.GetCode)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max_ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        local og=Duel.GetOperatedGroup()
        if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
            local c=e:GetHandler()
            if c:IsRelateToEffect(e) and c:IsFaceup() then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_ATTACK_ALL)
                e1:SetValue(1)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                c:RegisterEffect(e1)
            end
        end
    end
end

-- EFFECT 3 (Immunity)
function s.efilter(e,te)
    if te:IsActiveType(TYPE_MONSTER) then
        local tc=te:GetHandler()
        return tc:IsAttribute(ATTRIBUTE_LIGHT) or tc:IsType(TYPE_FLIP) or tc:IsRace(RACE_REPTILE)
    end
    return false
end