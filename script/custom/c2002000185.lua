--Abbadoctor, the Original Amorphage
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_AMORPHAGE),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Prevent destruction by opponent's effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.incon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.indes)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--scale
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_LSCALE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_PZONE,0)
	e4:SetValue(s.scval(1))
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CHANGE_RSCALE)
	e5:SetValue(s.scval(9))
	c:RegisterEffect(e5)
end
s.listed_series={SET_AMORPHAGE}
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_AMORPHAGE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.incon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.indes(e,c)
	return c:IsSetCard(SET_AMORPHAGE) and c:IsSpellTrap() and c:IsPublic()
end
function s.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	return tc1 and tc2 and tc1:IsSetCard(SET_AMORPHAGE) and tc2:IsSetCard(SET_AMORPHAGE)
end
function s.scval(val)
	return function(e,c)
		local tp=e:GetHandler():GetControler()
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_AMORPHAGE),tp,LOCATION_PZONE,0,nil)
		if ct==2 and not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then 
			return val 
		else
			if val==1 and not Duel.CheckLocation(tp,LOCATION_PZONE,0) then 
				return Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()
			end
			if val==9 and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then 
				return Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale()
			end
		end
	end
end