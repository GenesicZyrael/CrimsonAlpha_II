-- Elemental HERO's Rush of Wind
local s,id=GetID()
local alias=21844576
function s.initial_effect(c)
    -- This card's name becomes "Elemental HERO Avian" while in hand, Deck, or on the field.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(alias)
    c:RegisterEffect(e1)
    -- Reveal 1 Fusion Monster, Special Summon this card and 1 other material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- "Elemental HERO" Fusion Monsters using this card as material gains this effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.efcon)
    e3:SetOperation(s.efop)
    c:RegisterEffect(e3)
end
s.listed_names={alias}
-- ==========================================
-- Effect 2: Special Summon & Extra Deck Lock
-- ==========================================
function s.edfilter(c,e,tp)
    if not c:IsType(TYPE_FUSION) then return false end
    -- Get the explicitly listed materials of the Fusion monster
    local mats=c.material
    if not mats then return false end
    local alias_is_mat=c:ListsCodeAsMaterial(alias)
    local other_mats={}
    -- Check out the other materials
    for _,code in ipairs(mats) do
        if code~=alias then
            table.insert(other_mats,code)
        end
    end
    -- Must list Avian AND at least one other specific material
    if not alias_is_mat or #other_mats==0 then return false end
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,other_mats)
end
function s.spfilter(c,e,tp,other_mats)
    -- Check if the card in Deck matches any of the other listed materials
    return c:IsCode(table.unpack(other_mats)) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.edfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.edfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    Duel.ConfirmCards(1-tp,g)
    -- Store the revealed Fusion Monster's ID for the operation
    e:SetLabel(g:GetFirst():GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Apply Extra Deck Lock
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp) 
    -- Proceed with Summoning
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end  
    local code=e:GetLabel()
    -- Re-fetch the revealed card to extract its materials during resolution
    local tc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,nil,code)
    if not tc then return end
    local mats=tc.material
    if not mats then return end
    local other_mats={}
    for _,mcode in ipairs(mats) do
        if mcode~=alias then
            table.insert(other_mats,mcode)
        end
    end	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,other_mats)
    if #g>0 then
        g:AddCard(c)
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- ==========================================
-- Effect 3: Grant Spell Immunity to Fusion
-- ==========================================
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    -- Check if it was used for a Fusion Summon of an "Elemental HERO"
    return r==REASON_FUSION and rc:IsSetCard(SET_ELEMENTAL_HERO) and rc:IsType(TYPE_FUSION)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.immunefilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1,true)
end
function s.immunefilter(e,te)
    return te:IsActiveType(TYPE_SPELL)
end