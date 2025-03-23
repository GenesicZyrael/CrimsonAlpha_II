--Worm Falco
--Modified for CrimsonRemodels
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of its effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_FLIP)
end
s.listed_series={SET_WORM}
function s.posfilter1(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end
function s.posfilter2(c)
	return c:IsFaceup() and c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.posfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.posfilter2,tp,LOCATION_MZONE,0,c)
	if chk==0 then return #g1>0 or #g2>0 end
	local op=Duel.SelectEffect(tp,
		{#g1>0,aux.Stringid(id,0)},
		{#g2>0,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,#g1,0,0)
	elseif op==2 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g2,#g2,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local g=Duel.GetMatchingGroup(s.posfilter1,tp,LOCATION_MZONE,0,nil)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	elseif op==2 then
		local g=Duel.GetMatchingGroup(s.posfilter2,tp,LOCATION_MZONE,0,e:GetHandler())
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end