--Renshaddoll Winda
local s,id=GetID()
local params={aux.FilterBoolFunction(Card.IsSetCard,SET_SHADDOLL)}
function s.initial_effect(c)
	--flip 
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,id)
		e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
		e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)	
	--effect gain
	local e2=Effect.CreateEffect(c)
	    e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetCountLimit(1,id)
		e2:SetCondition(s.effcon)
		e2:SetTarget(s.efftg)
		e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADDOLL}
function s.efffilter(c)
	return c:IsSetCard(SET_SHADDOLL)
		and c:IsType(TYPE_FUSION)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.efffilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.efffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.HintSelection(tc)
		local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetCategory(CATEGORY_TOGRAVE)
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e1:SetCountLimit(1,{id,1})
			e1:SetCost(s.applycost)
			e1:SetTarget(s.applytg)
			e1:SetOperation(s.applyop)
			e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function s.filter(c,e,tp)
	if not (c:IsSetCard(SET_SHADDOLL) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FLIP) and c:IsAbleToGraveAsCost()) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasType(EFFECT_TYPE_FLIP) then
			local con=eff:GetCondition()
			local tg=eff:GetTarget()
			if (con==nil or con(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0))
				and (tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0)) then
				return true
			end
		end
	end
	return false
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local rc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	Duel.SendtoGrave(rc,REASON_COST)
	local available_effs={}
	local effs={rc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasType(EFFECT_TYPE_FLIP) then
			local con=eff:GetCondition()
			local tg=eff:GetTarget()
			if (con==nil or con(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0))
				and (tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(available_effs,eff)
			end
		end
	end
	e:SetLabelObject(available_effs)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local eff=e:GetLabelObject()
		return eff and eff:GetTarget() and eff:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return true end
	local eff=nil
	local available_effs=e:GetLabelObject()
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
	e:SetLabel(eff:GetLabel())
	e:SetLabelObject(eff:GetLabelObject())
	e:SetProperty(eff:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	local tg=eff:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	eff:SetLabel(e:GetLabel())
	eff:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(eff)
	Duel.ClearOperationInfo(0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabelObject()
	if not eff then return end
	e:SetLabel(eff:GetLabel())
	e:SetLabelObject(eff:GetLabelObject())
	local op=eff:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end