--Odd-Eyes Hyperlink Dragon
Duel.LoadScript("_load_.lua")
local s,id=GetID()
local TYPES=TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),3,3,s.lcheck)
	--extra mat
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(1,0)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={16178681}
s.listed_series={0x99}
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,16178681),tp,LOCATION_PZONE,0,nil)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and #(aux.zptgroup(eg,nil,c))>=2
end
function s.ctfilter(c)
	return c:IsType(TYPES) and c:IsSetCard(0x99) 
end
local function getcount(tp)
	local tottype=0
	Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,0,nil):ForEach(function(c) tottype=tottype|c:GetType() end)
	tottype=tottype&(TYPES)
	local ct=0
	while tottype~=0 do
		if tottype&0x1~=0 then ct=ct+1 end
		tottype=tottype>>1
	end
	return ct
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_PZONE)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return c:GetSummonType()==SUMMON_TYPE_LINK and g:FilterCount(Card.IsPreviousLocation,nil,LOCATION_PZONE)>0
end
function s.thfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToHand() and not c:IsType(TYPE_MONSTER) 
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=getcount(tp)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=getcount(tp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local sg=Group.CreateGroup()
	if #g<1 or ct<1 then 
		return 
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		sg=g:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
			Duel.ShuffleHand(1-tp)
		end
		Duel.DisableShuffleCheck()
	end
end