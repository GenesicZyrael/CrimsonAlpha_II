--Heavymetal Ignition Lord
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter1,s.fusfilter2,s.fusfilter3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)	
	--Activate: destroy own cards then banish opponent's, then search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.fusfilter1(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp)
end
function s.fusfilter2(c,fc,sumtype,tp)
	return c:IsType(TYPE_NORMAL,fc,sumtype,tp)
end
function s.fusfilter3(c,fc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,fc,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.contactfil(tp)
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_MZONE,0,nil)
	return g
end
function s.contactop(g)
	return Duel.Destroy(g,REASON_COST+REASON_MATERIAL)
end

-- any own card in Monster Zone or Pendulum Zone
function s.ownfilter(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_MZONE) -- allow face-down monsters too by not restricting faceup if desired
end
-- search filter: FIRE Normal Pendulum Monster
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.tgfilter(c,e,tp)
	return c:IsDestructable()
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local ct_max=#tg
	if #tg>3 then ct_max=3 end
	local dg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE|LOCATION_PZONE,0,1,ct_max,nil,e,tp)
	if not(#dg>0 and Duel.Destroy(dg,REASON_COST)>0) then return false end
	local ct=#dg
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	e:SetLabel(ct)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=0
	ct=e:GetLabel()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rmg=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmg,#rmg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end