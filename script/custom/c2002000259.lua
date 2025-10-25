--Dinotron Giggantos
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,s.matfilter1,1,1,Synchro.NonTunerEx(s.matfilter2),1,99,s.exmatfilter)	
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
function s.matfilter1(c,scard,sumtype,tp)
	return c:IsRace(RACE_MACHINE,scard,sumtype,tp)
end
function s.matfilter2(c,scard,sumtype,tp)
	return c:IsRace(RACE_MACHINE,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp)
end
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_MACHINE) 
		or c:IsAttribute(ATTRIBUTE_WATER) 
		or c:IsType(TYPE_PENDULUM) 
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) 
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
function s.tgfilter(c,e,tp)
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_MACHINE) 
		and  c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		Duel.SendtoGrave(g,REASON_REPLACE+REASON_EFFECT)
		--destroy
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TOFIELD))
		e1:SetCountLimit(1)
		e1:SetCost(s.descost)
		e1:SetTarget(s.destg)
		e1:SetOperation(s.desop)
		c:RegisterEffect(e1)
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.filter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,e:GetHandler())
	if a and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,e:GetHandler())
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
	--Activation legality
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return #cg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,cg,#cg,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if e:GetLabel()==1 then
			local cg=c:GetColumnGroup(1,1):Filter(Card.IsControler,nil,1-tp)
			if #cg<=0 then return end
			Duel.Destroy(cg,REASON_EFFECT)
		else
			local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
			if #cg<=0 then return end
			Duel.Destroy(cg,REASON_EFFECT)
		end
	end
end