--Arcana Wild Joker
local s,id=GetID()
function s.initial_effect(c)	
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,s.matfilter,1,1,Synchro.NonTunerEx(s.matfilter),1,99,s.exmatfilter)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--add 1 "Joker's Knight
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	-- e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_QUEEN_KNIGHT,CARD_KING_KNIGHT,CARD_JACK_KNIGHT,29284413}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp)
end
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsCode(CARD_QUEEN_KNIGHT) 
		or c:IsCode(CARD_KING_KNIGHT) 
		or c:IsCode(CARD_JACK_KNIGHT) 
end
function s.costfilter(c,tp)
	local tpe=c:GetType()
	return tpe~=0 
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tpe)
		and not c:IsPublic()
end
function s.rmfilter(c,tpe)
	return c:IsFaceup() and c:IsAbleToRemove() and not c:IsType(tpe)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp)
			and c:GetFlagEffect(id)==0 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,tp)
	local g=Duel.GetOperatedGroup()
	e:SetLabel(g:GetFirst():GetMainCardType())
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil,e:GetLabel())
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:RandomSelect(tp,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and e:GetHandler():IsPreviousControler(tp)
end

function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost() 
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,3,nil)
			and aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.check,1,tp,HINTMSG_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCode(29284413) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,CATEGORY_TOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end