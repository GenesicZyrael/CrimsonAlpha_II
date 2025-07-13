--Infernoid Belial
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,60551528,s.ffilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Can only be Special Summoned once per turn
	c:SetSPSummonOnce(id)
	--main effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.rmcost)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INFERNOID}
s.listed_names={60551528}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_INFERNOID,fc,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then return val>0 and Duel.IsPlayerCanDiscardDeck(tp,val) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,0)
end
function s.filter(c)
	return c:IsSetCard(SET_INFERNOID) and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	local g=Duel.GetDecktopGroup(tp,val)
	if val>0 then 
		Duel.DiscardDeck(tp,val,REASON_EFFECT)
		local tg=g:Filter(aux.FilterBoolFunction(Card.IsMonster),nil)
		if #tg>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil) then
			Duel.BreakEffect()
			local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,#tg,nil)
			if #sg>0 then
				Duel.SendtoGrave(sg,REASON_EFFECT|REASON_RETURN)
			end
		end
	end
end
function s.rmcostfilter(c)
	return c:IsMonster() and c:IsRace(RACE_FIEND) and not c:IsPublic()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_EXTRA,0,1,c) 
			and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_EXTRA,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetCode())
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=g:Select(tp,1,1,nil)
		Duel.HintSelection(tc)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end