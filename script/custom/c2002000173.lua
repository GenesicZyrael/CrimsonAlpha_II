--Exodia's Disciple
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--setcode
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(SET_FORBIDDEN_ONE)
	c:RegisterEffect(e1)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE|LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
s.listed_series={SET_FORBIDDEN_ONE,SET_MILLENNIUM}
s.listed_names={CARD_MILLENNIUM_CROSS}

function s.spcon(e)
	return e:GetHandler():IsContinuousSpell() 
		or e:GetHandler():GetLocation()==LOCATION_HAND
end
function s.spcostfilter(c)
	return c:IsCode(CARD_MILLENNIUM_CROSS) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckLPCost(tp,2000)
	local b2=Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		Duel.PayLPCost(tp,2000)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		-- local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil)
		local g=Duel.GetFirstMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsCode(CARD_MILLENNIUM_CROSS) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.plfilter(c,tp)
	return c:IsSetCard(SET_MILLENNIUM) and c:IsMonster() 
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and not c:IsCode(id)
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) 
		and c:IsRace(RACE_SPELLCASTER) 
		and c:IsLevel(10)
		and c:GetTextAttack()==-2
		and c:IsAbleToHand() 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>1 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
		e:SetLabel(1)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		e:SetLabel(2)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		local dc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if not dc then return end
		Duel.BreakEffect()
		s.place(dc,c,tp)
	end
	e:SetLabel(0)
end
function s.place(c,rc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return false end
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	return true
end