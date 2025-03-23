--Borreload Punishing Dragon
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	-- Place 1 Pendulum Card in the Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	--Activation limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ROKKET}
function s.pcfilter(c)
	return c:IsSetCard(SET_ROKKET) and not c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) 
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
		local tc=g:GetFirst()
		local fid=g:GetFirst():GetFieldID()
		local nseq=(0xff^2)+16
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true,nseq)
		-- Pendulum Summon
		local r1=Effect.CreateEffect(tc)
			r1:SetDescription(1163)
			r1:SetType(EFFECT_TYPE_FIELD)
			r1:SetCode(EFFECT_SPSUMMON_PROC_G)
			r1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
			r1:SetRange(LOCATION_PZONE)
			r1:SetCondition(Pendulum.Condition())
			r1:SetOperation(Pendulum.Operation())
			r1:SetValue(SUMMON_TYPE_PENDULUM)
			r1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(r1)
		--set left scale
		local r2=Effect.CreateEffect(tc)
			r2:SetType(EFFECT_TYPE_SINGLE)
			r2:SetCode(EFFECT_CHANGE_LSCALE)
			r2:SetValue(1)
			r2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(r2)
		local r3=Effect.CreateEffect(tc)
			r3:SetType(EFFECT_TYPE_SINGLE)
			r3:SetCode(EFFECT_CHANGE_RSCALE)
			r3:SetValue(1)
			r3:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(r3)
		--destroy during the end phase
		tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x1fe0000,0,1,fid)
		local r5=Effect.CreateEffect(tc)
			r5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			r5:SetCode(EVENT_PHASE+PHASE_END)
			r5:SetCountLimit(1)
			r5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			r5:SetLabel(fid)
			r5:SetLabelObject(tc)
			r5:SetCondition(Pendulum.PseudoUpkeepCondition())
			r5:SetOperation(Pendulum.PseudoUpkeepOperation())
		Duel.RegisterEffect(r5,tp)
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() 
		or Duel.GetAttackTarget()==e:GetHandler()
end
function s.atkfilter(c)
	return c:IsLinkMonster() and not c:IsForbidden() and c:IsAbleToDeck()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetChainLimit(function(_e,_ep,_tp) return _tp==_ep end)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)~=0 
	and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end