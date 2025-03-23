-- Ritual Beast Ulti-Cannafalcos
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(Card.IsSetCard,SET_GUSTO),1,99,nil,nil,nil,s.matfilter)
	-- Special Summon Proc: used Fusion Proc for this to simplify effort needed
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_RITUAL_BEAST_ULTI),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_RITUAL_BEAST_TAMER),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SPIRITUAL_BEAST))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true,aux.TRUE,1)
	-- Negate Special Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--spsummon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GUSTO,SET_RITUAL_BEAST,SET_RITUAL_BEAST_TAMER,SET_SPIRITUAL_BEAST,SET_RITUAL_BEAST_ULTI}
-- {Synchro Material Check: ... including at least 1 Synchro Monster}
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil)
end
function s.cfilter(c)
	return c:IsType(TYPE_SYNCHRO)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
-- {Register Effect: Negate Summon}
function s.valcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsSummonLocation,nil,LOCATION_EXTRA)
	e:GetLabelObject():SetLabel(#ct)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
		or e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterial():Filter(Card.IsSummonLocation,nil,LOCATION_EXTRA)
	if #ct>3 then ct=3 else ct=#ct end
	if ct>0 then 
		local r1=Effect.CreateEffect(c)
		r1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
		r1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		if ct==1 then
			r1:SetDescription(aux.Stringid(id,2))
		elseif ct==2 then
			r1:SetDescription(aux.Stringid(id,3))		
		elseif ct==3 then
			r1:SetDescription(aux.Stringid(id,4))		
		end
		r1:SetType(EFFECT_TYPE_QUICK_O)
		r1:SetRange(LOCATION_MZONE)
		r1:SetCode(EVENT_SPSUMMON)
		r1:SetCondition(s.negcon)
		r1:SetCost(s.negcost)
		r1:SetTarget(s.negtg)
		r1:SetOperation(s.negop)
		r1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(r1)
		local r2=r1:Clone()
		r2:SetCode(EVENT_FLIP_SUMMON)
		c:RegisterEffect(r2)
		local r3=r1:Clone()
		r3:SetCode(EVENT_SUMMON)
		c:RegisterEffect(r3)
		-- Activate(effect)
		local r4=Effect.CreateEffect(c)
		r4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
		r4:SetType(EFFECT_TYPE_QUICK_O)
		r4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		r4:SetCode(EVENT_CHAINING)
		r4:SetRange(LOCATION_MZONE)
		r4:SetCondition(s.negcon2)
		r4:SetCost(s.negcost)
		r4:SetTarget(s.negtg2)
		r4:SetOperation(s.negop2)
		r4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(r4)
	end
end
-- {Monster Effect: Negate Summon}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local maxct=c:GetMaterial():Filter(Card.IsSummonLocation,nil,LOCATION_EXTRA)
	local maxct=#maxct
	local curct=c:GetFlagEffect(id)
	if curct<maxct then 
		return Duel.GetCurrentChain()==0
	end 
	return false
end
function s.costfilter(c)
	return c:IsSetCard({SET_GUSTO,SET_RITUAL_BEAST}) 
		and c:IsPublic()
		and c:IsAbleToDeckOrExtraAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,nil) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE|LOCATION_GRAVE|LOCATION_REMOVED,0,2,2,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local curct=c:GetFlagEffect(id)
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
-- {Monster Effect: Negate Effect to Summon}
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local maxct=c:GetMaterial():Filter(Card.IsSummonLocation,nil,LOCATION_EXTRA)
	local maxct=#maxct
	local curct=c:GetFlagEffect(id)
	if curct<maxct then 
		return (re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) or re:IsHasCategory(CATEGORY_SUMMON))
			and Duel.IsChainNegatable(ev)
	end 
	return false
end
function s.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local curct=c:GetFlagEffect(id)
	if not (Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)) then
		if Duel.Destroy(eg,REASON_EFFECT)<1 then
			-- Do nothing
		end
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end