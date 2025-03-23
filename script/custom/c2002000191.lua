--Pot of Plundering
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsLocation(LOCATION_GRAVE)
		and c:IsAbleToHandAsCost() 
		and c:IsCanBeEffectTarget(e)
		and c:IsControler(1-tp)
		and not c:IsType(TYPE_TOKEN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then 
		return eg:IsExists(s.filter,1,nil,e,tp) 
			and not eg:IsContains(e:GetHandler())
			and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,tc)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end