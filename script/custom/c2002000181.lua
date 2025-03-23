--Ghost Fox & Wild Performer
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Change Effect Target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Change Player Target
	-- local e2=e1:Clone()
	-- e2:SetCondition(s.plyrcon)
	-- e2:SetTarget(s.plyrtg)
	-- e2:SetOperation(s.plyrop)
	-- c:RegisterEffect(e2)
	--Change Attack Target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- if not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- if ep==tp then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- return tc:IsLocation(LOCATION_MZONE)
	return tc
end
function s.filter(c,re,rp,tf,ceg,cep,cev,cre,cr,crp)
	-- return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c) 
		-- and c:IsFaceup()
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c) 
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tf=re:GetTarget()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ALL,LOCATION_ALL,1,e:GetLabelObject(),re,rp,tf,ceg,cep,cev,cre,cr,crp) end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tf=re:GetTarget()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ALL,LOCATION_ALL,1,1,e:GetLabelObject(),re,rp,tf,ceg,cep,cev,cre,cr,crp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangeTargetCard(ev,g)
	end
end

function s.plyrcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) 
		and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
function s.plyrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local te=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		local ftg=te:GetTarget()
		return ftg==nil or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.plyrop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER)
	Duel.ChangeTargetPlayer(ev,1-p)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ag,da=eg:GetFirst():GetAttackableTarget()
		local at=Duel.GetAttackTarget()
		return ag:IsExists(aux.TRUE,1,at) or (at~=nil and da)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ag,da=eg:GetFirst():GetAttackableTarget()
	local at=Duel.GetAttackTarget()
	if da and at~=nil then
		local sel=0
		Duel.Hint(HINT_SELECTMSG,tp,31)
		if ag:IsExists(aux.TRUE,1,at) then
			sel=Duel.SelectOption(tp,1213,1214)
		else
			sel=Duel.SelectOption(tp,1213)
		end
		if sel==0 then
			Duel.ChangeAttackTarget(nil)
			return
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
	local g=ag:Select(tp,1,1,at)
	local tc=g:GetFirst()
	if tc then
		Duel.ChangeAttackTarget(tc)
	end
end