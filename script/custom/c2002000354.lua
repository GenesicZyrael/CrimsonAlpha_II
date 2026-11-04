-- Benevolence of the Voiceless Voice
local s,id=GetID()
local CARD_DORIADO = 2002000353
function s.initial_effect(c)
    -- Activate (Field Spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    -- Effect 1: Send to GY and Draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)
    -- Effect 2: Ritual Summon when a LIGHT Ritual leaves the field
	local ritparams={handler=c,lvtype=RITPROC_GREATER,filter=s.ritfilter,location=LOCATION_GRAVE|LOCATION_EXTRA}
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.rscon)
	e2:SetTarget(Ritual.Target(ritparams))
	e2:SetOperation(Ritual.Operation(ritparams))
    c:RegisterEffect(e2)
end
s.listed_names={CARD_DORIADO}
s.listed_series={SET_VOICELESS_VOICE}

function s.ritfilter(c)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR|RACE_DRAGON))
		or c:IsCode(CARD_DORIADO)
end
function s.tgfilter(c)
    return c:IsSetCard(SET_VOICELESS_VOICE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsPlayerCanDraw(tp,2) 
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_MZONE+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    -- Check if both a field and deck target still exist
    if not (Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    g1:Merge(g2)
    if #g1==2 and Duel.SendtoGrave(g1,REASON_EFFECT)==2 then
        -- Ensure both successfully hit the GY before drawing
        if g1:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==2 then
            Duel.Draw(tp,2,REASON_EFFECT)
        end
    end
end

function s.cfilter(c,tp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_LIGHT) 
        and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
