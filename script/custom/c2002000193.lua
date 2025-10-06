--Table Flip

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOGRAVE)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,id)
		e1:SetCost(s.cost)
		e1:SetTarget(s.target)
		e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- function s.filter(c,e,tp)
	-- if not (c:IsType(TYPE_MONSTER) and c:IsHasEffect(TYPE_FLIP) and c:IsAbleToGraveAsCost()) then 
		-- return false
	-- end
	-- local eff={c:GetCardEffect(TYPE_FLIP)}
	-- for _,teh in ipairs(eff) do
		-- local te=teh:GetLabelObject()
		-- local con=te:GetCondition()
		-- local tg=te:GetTarget()
		-- if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			-- and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then return true end
	-- end
	-- return false
-- end
-- function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- e:SetLabelObject(g)
	-- Group.KeepAlive(g)
	-- Duel.SendtoGrave(g,REASON_COST)
-- end
-- function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- local tc=e:GetLabelObject():GetFirst()
	-- tc:CreateEffectRelation(e)
	-- if tc and tc:IsRelateToEffect(e) then
		-- local eff={tc:GetCardEffect(TYPE_FLIP)}
		-- local te=nil
		-- local acd={}
		-- local ac={}
		-- for _,teh in ipairs(eff) do
			-- local temp=teh:GetLabelObject()
			-- local con=temp:GetCondition()
			-- local tg=temp:GetTarget()
			-- if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
				-- and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				-- table.insert(ac,teh)
				-- table.insert(acd,temp:GetDescription())
			-- end
		-- end
		-- if #ac==1 then te=ac[1] elseif #ac>1 then
			-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			-- op=Duel.SelectOption(tp,table.unpack(acd))
			-- op=op+1
			-- te=ac[op]
		-- end
		-- if not te then return end
		-- Duel.ClearTargetCard()
		-- local teh=te
		-- te=teh:GetLabelObject()
		-- local tg=te:GetTarget()
		-- local op=te:GetOperation()
		-- if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		-- Duel.BreakEffect()
		-- tc:CreateEffectRelation(te)
		-- Duel.BreakEffect()
		-- local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		-- if g then
			-- for etc in aux.Next(g) do
				-- etc:CreateEffectRelation(te)
			-- end
		-- end
		-- if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		-- tc:ReleaseEffectRelation(te)
		-- if g then
			-- for etc in aux.Next(g) do
				-- etc:ReleaseEffectRelation(te)
			-- end
		-- end
	-- end
	-- Group.DeleteGroup(e:GetLabelObject())
-- end

function s.filter(c,e,tp)
	if not (c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FLIP) and c:IsAbleToGraveAsCost()) then return false end
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
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.operation(e,tp,eg,ep,ev,re,r,rp)
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