--Destructor Pain, the True Dracoreaping Tyrant
local s,id=GetID()
function s.initial_effect(c)
	--Tribute using Continuous Spell/Traps
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP)
	c:RegisterEffect(e1)
	--tribute check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--immune reg
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.discost)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	--Register Attributes used
	aux.GlobalCheck(s,function()
		s.attr_list={}
		s.attr_list[0]=0
		s.attr_list[1]=0
		aux.AddValuesReset(function()
			s.attr_list[0]=0
			s.attr_list[1]=0
		end)
	end)
end
s.listed_series={SET_TRUE_DRACO_KING}
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local typ=0
	for tc in g:Iter() do
		typ=typ|(tc:GetOriginalType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP))
	end
	e:SetLabel(typ)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsTributeSummoned()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ=e:GetLabelObject():GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.efilter)
	e1:SetLabel(typ)
	c:RegisterEffect(e1)
	if typ&TYPE_MONSTER~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
	if typ&TYPE_SPELL~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
	if typ&TYPE_TRAP~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
function s.efilter(e,te)
	return te:IsActiveType(e:GetLabel()) and te:GetOwner()~=e:GetOwner()
end
function s.cfilter(c,tp)
	local attr=c:GetAttribute()
	return s.attr_list[tp]&attr==0 and c:IsMonster() 
		and c:IsSetCard(SET_TRUE_DRACO_KING) and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	s.attr_list[tp]=s.attr_list[tp]|g:GetFirst():GetAttribute()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsMonsterEffect() and Duel.IsChainNegatable(ev) and c:IsTributeSummoned() and rp~=tp
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)

		local g=e:GetLabelObject()
		local available_effs={}
		local effs={g:GetFirst():GetOwnEffects()}
		for _,eff in ipairs(effs) do
			if eff:GetCode()==EVENT_CHAINING then
				local con=eff:GetCondition()
				local tg=eff:GetTarget()
				if (tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0)) then
					table.insert(available_effs,eff)
				end
			end
		end

		if #available_effs>0 then
			if #available_effs>1 then
				local available_effs_desc={}
				for _,eff in ipairs(available_effs) do
					table.insert(available_effs_desc,eff:GetDescription())
				end
				local op=Duel.SelectOption(tp,table.unpack(available_effs_desc))
				eff=available_effs[op+1]
			else
				eff=available_effs[1]
			end

			Duel.Hint(HINT_OPSELECTED,1-tp,eff:GetDescription())
			local tg=eff:GetTarget()
			if tg then
				tg(e,tp,eg,ep,ev,re,r,rp,1)
			end
			local op=eff:GetOperation()
			if op then
				op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
			end
		end
		e:SetLabelObject(nil)
	end
end