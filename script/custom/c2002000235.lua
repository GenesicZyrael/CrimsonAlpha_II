--Qliphort Compiler
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)	
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_QLI),8,2)
	--Treat "Qli" Level 4 monsters as Level 8 for this card's Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsSetCard(SET_QLI) and c:IsLevel(4) end)
	e0:SetValue(s.lvval)
	c:RegisterEffect(e0)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.qlimit)
	c:RegisterEffect(e1)
	--summon cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_HAND|LOCATION_EXTRA)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--Add 1 "Qli" monster from your GY or face-up Extra Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,id)
	e4:SetCost(aux.dxmcostgen(1,1,nil))
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetRange(LOCATION_ONFIELD|LOCATION_EXTRA)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.matcon)
	e5:SetTarget(s.mattg)
	e5:SetOperation(s.matop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_QLI}
function s.qlimit(e,c)
	return not c:IsSetCard(SET_QLI) 
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*800)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.PayLPCost(tp,800)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc:IsCode(id) then
		return 8
	else
		return lv
	end
end
function s.efilter(e,te)
	if te:IsSpellTrapEffect() then
		return true
	else
		return te:IsActiveType(TYPE_XYZ) and te:IsActivated() and te:GetOwner()~=e:GetOwner()
	end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_QLI) and c:IsAbleToHand()
end
function s.nsfilter(c)
	return c:IsSetCard(SET_QLI) and c:IsSummonable(true,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
	local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		if #g==0 then return end
		if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Summon(tp,sc,true,nil)
		sc:RegisterFlagEffect(id,(RESET_EVENT|RESETS_STANDARD_PHASE_END)-RESET_TOFIELD,0,1)
	end
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	return tc and (tc:GetSummonType()&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
		and tc:GetMaterialCount()>0 and tc:HasFlagEffect(id)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not tc then return end
	local ct=tc:GetMaterialCount()
	local c=e:GetHandler()
	if ct>=1 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
	if ct>=2 and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 then
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g==0 then return end
		local sg=g:RandomSelect(tp,1)
		Duel.BreakEffect()
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	if ct>=3 then
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		if  #g==0 then return end
		for tc in g:Iter() do
			tc:NegateEffects(c,RESET_EVENT|RESETS_STANDARD_PHASE_END,true)
		end
	end
	tc:ResetFlagEffect(id)
end