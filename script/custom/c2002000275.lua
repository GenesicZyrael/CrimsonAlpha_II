-- Elemental HERO's Clarity of Water
local s,id=GetID()
local alias=79979666 -- Elemental HERO Bubbleman
function s.initial_effect(c)
    -- This card's name becomes "Elemental HERO Bubbleman" while in hand, Deck, or on the field.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(alias)
    c:RegisterEffect(e1)
    -- Reveal 1 Fusion Monster; add 1 Spell/Trap, then you can send 1 "Elemental HERO"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
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
-- Effect 2: Search, Send & Extra Deck Lock
-- ==========================================
function s.edfilter(c)
    if not c:IsType(TYPE_FUSION) then return false end
    return c.material and c:ListsCodeAsMaterial(alias)
end
function s.thfilter(c)
    if not (c:IsSpellTrap() and c:IsAbleToHand()) then return false end
    -- Check if it mentions the archetype directly
    if c:ListsCodeWithArchetype(SET_ELEMENTAL_HERO) then return true end
    return false
end
function s.tgfilter(c,other_mats)
    return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() 
        and c:IsCode(table.unpack(other_mats))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.edfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.edfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    -- Store the revealed Fusion Monster's ID to parse materials at resolution
    e:SetLabel(g:GetFirst():GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Apply Extra Deck Lock
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    -- Proceed with Search
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        -- Retrieve the revealed Fusion Monster's ID
        local code=e:GetLabel()
        local tc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,nil,code)
        if tc and tc.material then
            -- Collect the explicitly listed materials that are not Bubbleman
            local other_mats={}
            for _,mcode in ipairs(tc.material) do
                if mcode~=alias then
                    table.insert(other_mats,mcode)
                end
            end
            -- Optional Send to GY matching the 'other materials' requirement
            if #other_mats>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,other_mats) 
                and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,other_mats)
                if #sg>0 then
                    Duel.BreakEffect()
                    Duel.SendtoGrave(sg,REASON_EFFECT)
                end
            end
        end
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- ==========================================
-- Effect 3: Grant Indestructibility to Fusion
-- ==========================================
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    return r==REASON_FUSION and rc:IsSetCard(SET_ELEMENTAL_HERO) and rc:IsType(TYPE_FUSION)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1,true)
end