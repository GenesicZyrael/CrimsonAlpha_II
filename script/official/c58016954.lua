--イェシャドール－セフィラナーガ
--Shaddoll Zefranaga
--Modified for CrimsonAlpha


local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,CUSTOM_REGISTER_ZEFRA)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(aux.TRUE)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SHADDOLL,SET_ZEFRA}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_SHADDOLL) or c:IsSetCard(SET_ZEFRA) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.cfilter(c)
	return c:IsSetCard(SET_ZEFRA)
end
function s.filter(c)
	return c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end