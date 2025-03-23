--Freezing Winds of the Nekroz
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate(effect)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NEKROZ}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsSetCard(SET_NEKROZ)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_NEKROZ) and c:IsRitualMonster() and c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Remove(eg,POS_FACEUP,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) then
			local op=nil
			local ct1=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0
			local ct2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>1
			op=Duel.SelectEffect(tp,
				{ct1,aux.Stringid(id,1)},
				{ct2,aux.Stringid(id,2)})
			if op~=nil then
				local dis=Duel.SelectDisableField(tp,op,0,LOCATION_MZONE,0)
				Duel.Hint(HINT_ZONE,tp,dis)
				e:SetLabel(dis)
				--Disable the chosen zone(s)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetOperation(function(e) return e:GetLabel() end)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
				e1:SetLabel(dis)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end