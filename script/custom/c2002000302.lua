-- Horus the Ebon Flame Dragon
local s,id=GetID()
local LCL_CARD_HORUS_LV8=48229808
function s.initial_effect(c)
    -- Name becomes "Horus the Black Flame Dragon LV8" everywhere
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_MZONE)
    e0:SetValue(LCL_CARD_HORUS_LV8)
    c:RegisterEffect(e0)
    -- Quick Effect: Change opponent's Spell effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.chcon)
    e1:SetTarget(s.chtg)
    e1:SetOperation(s.chop)
    c:RegisterEffect(e1)
    -- Trigger: Special Summon when card leaves the field by opponent's effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HORUS}
s.listed_names={CARD_KING_SARCOPHAGUS, LCL_CARD_HORUS_LV8}

-- Check for King's Sarcophagus on field
function s.sarc_filter(c)
    return c:IsFaceup() and c:IsCode(CARD_KING_SARCOPHAGUS)
end

-- Effect 1 (Change Spell Effect)
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsSpellEffect()
        and Duel.IsExistingMatchingCard(s.sarc_filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.horusfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HORUS)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.horusfilter,tp,LOCATION_MZONE,0,1,nil) 
    end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	-- local g=Group.CreateGroup()
	-- Duel.ChangeTargetCard(ev,g)
    Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    -- 'tp' is the opponent during this resolution
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(1-tp,s.horusfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g>0 then
        -- REASON_RULE handles sending to GY "for no effect" cleanly
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- Effect 2 (Special Summon)
function s.spconfilter(c,tp,opp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReasonPlayer(opp) and c:IsReason(REASON_EFFECT)
		and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spconfilter,1,nil,tp,1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
