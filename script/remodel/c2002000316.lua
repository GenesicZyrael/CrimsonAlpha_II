--トゥーン・デーモン
--Toon Summoned Skull
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	Toon.CreateProc(c)
	--Destroy opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(aux.IsToonWorldUp)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_TOON_WORLD}
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetDefense()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetDefense()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
