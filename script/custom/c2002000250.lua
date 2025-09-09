--Dragunity Arma Exallion
local s,id=GetID()
function s.initial_effect(c)
	--Synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DRAGUNITY),1,99,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Banish 1 Tuner and non-Tuner to Special Summon a "Dragunity" Synchro
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Equip 1 "Dragunity" Tuner monster to itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.eqcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGUNITY}
function s.tdfilter(c)
	return c:IsSetCard(SET_DRAGUNITY) and c:HasLevel() and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp,lv)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_SYNCHRO)
		and c:IsSetCard(SET_DRAGUNITY)
		and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return #sg==2 and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetLevel))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,nil)
	if chk==0 then return #pg<=0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	e:SetLabel(dg:GetSum(Card.GetLevel))
	Duel.ConfirmCards(1-tp,dg)
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.eqfilter(c,ec)
	return c:IsSetCard(SET_DRAGUNITY) and c:IsType(TYPE_TUNER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_PZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	if #g>0 then
		Duel.Equip(tp,g:GetFirst(),c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(c)
		g:GetFirst():RegisterEffect(e1)
		if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
			or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local x=c:GetEquipCount()
		local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,x,nil)
		if #dg>0 then
			Duel.HintSelection(dg,true)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end