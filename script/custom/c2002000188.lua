--Sorcerer of Chaos Magic
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- 2 Level 9 monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),9,2)
	-- Can use "Dark Magician" monsters as Level 9 materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(function(e,c) return c:IsSetCard(SET_DARK_MAGICIAN) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 9 or 0 end)
	c:RegisterEffect(e0)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--gain effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_MAGICIAN}
s.listed_series={SET_DARK_MAGICIAN}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,CARD_DARK_MAGICIAN) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END
		c:RegisterFlagEffect(id,0,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Change name
	local r1=Effect.CreateEffect(c)
		r1:SetType(EFFECT_TYPE_SINGLE)
		r1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		r1:SetCode(EFFECT_CHANGE_CODE)
		r1:SetRange(LOCATION_MZONE)
		r1:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(r1)
	--Apply the effects of a Dark Magician spell
	local r2=Effect.CreateEffect(c)
		r2:SetDescription(aux.Stringid(id,1))
		r2:SetType(EFFECT_TYPE_IGNITION)
		r2:SetRange(LOCATION_MZONE)
		r2:SetCountLimit(1,{id,1})
		r2:SetCost(aux.AND(aux.dxmcostgen(1,1,nil),s.copycost))
		r2:SetTarget(s.copytg)
		r2:SetOperation(s.copyop)
	c:RegisterEffect(r2)
end
function s.copfilter(c)
	return c:IsAbleToRemoveAsCost()
		and c:ListsCode(CARD_DARK_MAGICIAN) 
		and c:GetType()==TYPE_SPELL 
		and c:CheckActivateEffect(false,true,true)~=nil 
end


function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	if chkc then
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
	if not Duel.Remove(g,POS_FACEUP,REASON_COST) then return end
	local te=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end
