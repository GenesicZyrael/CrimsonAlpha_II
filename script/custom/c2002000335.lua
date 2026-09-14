-- Elephant Booster
local s,id=GetID()
local CARD_FLYING_ELEPHANT=66765023
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,CARD_FLYING_ELEPHANT))
	e0:SetDescription(aux.Stringid(id,0))
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    -- EQUIPPED: Can attack directly
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e2)
	-- EQUIPPED: Battle Indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    -- REPLACE: First effect becomes "destroy 1 'Flying Elephant'"
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.chcon)
    e4:SetOperation(s.chop)
    c:RegisterEffect(e4)
end
s.listed_names={CARD_FLYING_ELEPHANT} 
function s.filter(c,e,tp)
    if not c:IsCode(CARD_FLYING_ELEPHANT) then return false end
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup()
    else
        return (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) 
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_FLYING_ELEPHANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	return rp==1-tp 
		and Duel.GetFlagEffect(tp,id)==0
		and not (rc and rc:IsCode(CARD_FLYING_ELEPHANT))
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
    Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCode,1-tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,CARD_FLYING_ELEPHANT)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        Duel.HintSelection(sg)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end