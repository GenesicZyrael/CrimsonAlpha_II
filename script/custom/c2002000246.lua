--Unforeseen Disaster
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup()
		and c:IsSpecialSummoned()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(te,rp,tp) return not te:IsMonsterEffect() end)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- Destroy target, then purge all copies
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local g=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,nil,tc:GetCode())
	if Duel.Destroy(tc,REASON_EFFECT)>0 and #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
