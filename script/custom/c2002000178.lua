--Performapal Odd-Eyes Trump Witch
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),1,1)
	--Cannot be Link Summoned unless you have 2 cards in your Pendulum Zones
	--- that have a difference of 4+ between the 2 Pendulum Scales
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcost)
	c:RegisterEffect(e0)
	--addtohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- Allow cards in the Pendulum Zones as fusion materials
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_PZONE,0)
	e3:SetValue(aux.TRUE)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_POLYMERIZATION}
function s.spcfilter(c,e,tp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2) then return false end
	local hisc=0
	local lowsc=0
	if tc1:GetLeftScale()>tc2:GetRightScale() then
		hisc=tc1:GetLeftScale()
		lowsc=tc2:GetLeftScale()
	else
		hisc=tc2:GetLeftScale()
		lowsc=tc1:GetLeftScale()
	end
	local diff=hisc-lowsc
	return diff>=4
end
function s.spcost(e,c,tp,st)
	if (st&SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	return aux.GetPendulumZoneCount(tp)==0
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
end
function s.filter(c)
	return c:IsAbleToHand() and c:IsCode(CARD_POLYMERIZATION) 
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end