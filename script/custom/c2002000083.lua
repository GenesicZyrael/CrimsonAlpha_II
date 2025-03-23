--Zefratorah Metaltron
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	local rparams= {handler=c,
					lvtype=RITPROC_EQUAL,
					desc=aux.Stringid(84388461,1),
					forcedselection=function(e,tp,g,sc)return g:IsContains(e:GetHandler()) end}
	local rittg,ritop=Ritual.Target(rparams),Ritual.Operation(rparams)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Special Summon from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Requires 3 Tributes to Normal Summon/Set
	local e2=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e3=aux.AddNormalSetProcedure(c)
	--Special Summon itself from Extra Deck
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCondition(s.spcon)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Copy a "Zefra" monster's On Pendulum Summon Effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetTarget(s.target(rittg,ritop))
	e5:SetOperation(s.operation(rittg,ritop))
	c:RegisterEffect(e5)
	--to deck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetHintTiming(0,TIMING_END_PHASE)
	e6:SetCountLimit(1,{id,2})
	-- e6:SetCondition(s.tdcon)
	e6:SetTarget(s.tdtg)
	e6:SetOperation(s.tdop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_ZEFRA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ZEFRA)
		and c:IsLevelBelow(6)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then loc=LOCATION_ONFIELD end
	if chk==0 then 
		return Duel.IsExistingMatchingCard(nil,tp,loc,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(nil,tp,loc,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	local op=nil
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then loc=LOCATION_ONFIELD end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,loc,0,1,1,nil)
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if (tc:IsCode(29432356) and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0)
		or (tc and Duel.SpecialSummon(tc,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)>0)	then
			if c:IsLocation(LOCATION_PZONE) then
				op=Duel.SelectEffect(tp,
					{aux.TRUE,aux.Stringid(id,3)},
					{aux.TRUE,aux.Stringid(id,4)})
				if op==1 then
					scale=1
				elseif op==2 then
					scale=7
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LSCALE)
				e1:SetValue(scale)
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CHANGE_RSCALE)
				e2:SetValue(scale)
				c:RegisterEffect(e2)
			end
			-- Deprecated
			--s.splimit(e)
		end
	end
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) 
		and sg:IsExists(Card.IsSetCard,3,nil,SET_ZEFRA)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg>2 
		and rg:IsExists(Card.IsSetCard,3,nil,SET_ZEFRA) 
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE)
	Duel.Release(sg,REASON_COST)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		e:GetHandler():SetMaterial(g)
	end
	g:DeleteGroup()
end

function s.filter(c,tp)
	if not (c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM)
		and c:IsHasEffect(id)) then
		return false
	end
	if c:IsCode(84388461) and c:IsHasEffect(id) then return true end
	local eff=c:GetCardEffect(id)
	local te=eff:GetLabelObject()
	local con=te:GetCondition()
	local tg=te:GetTarget()
	if (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0)) then
		return true
	end
	return false
end
function s.target(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local c=e:GetHandler()
		if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,nil,tp) end
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if sc then 
			Duel.SendtoExtraP(sc,tp,REASON_EFFECT)
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
			e:SetLabelObject(sc:GetCardEffect(id):GetLabelObject())
			if sc:IsCode(84388461) and rittg(e,tp,eg,ep,ev,re,r,rp,0) then 
				e:SetLabel(sc:GetCode())
				return rittg(e,tp,eg,ep,ev,re,r,rp,0)
			end
			local te=e:GetLabelObject()
			local tg=te and te:GetTarget() or nil
			if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
			e:SetLabel(te:GetLabel())
			e:SetLabelObject(te:GetLabelObject())
			e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
			if tg then
				tg(e,tp,eg,ep,ev,re,r,rp,1)
			end
			e:SetLabelObject(te)
			Duel.ClearOperationInfo(0)
		end 
	end
end
function s.operation(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=e:GetLabel()
		-- Zefrasaber work-around
		if tc==84388461 and rittg(e,tp,eg,ep,ev,re,r,rp,0) then 
			ritop(e,tp,eg,ep,ev,re,r,rp)	
			return 
		end
		local te=e:GetLabelObject()
		if not te then return end
		local sc=te:GetHandler()
		if sc:GetFlagEffect(id)==0 then
			e:SetLabel(0)
			e:SetLabelObject(nil)
			return
		end
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then
			op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
		end
		e:SetLabel(0)
		e:SetLabelObject(nil)
		-- Deprecated
		-- s.actlimit(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.CheckLocation(1-tp,LOCATION_PZONE,0) 
		and not Duel.CheckLocation(1-tp,LOCATION_PZONE,1) then return end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		if aux.GetPendulumZoneCount(tp)>0 then 
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end
	end
	-- Deprecated
	-- s.actlimit(e,tp,eg,ep,ev,re,r,rp)
end

function s.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Cannot activate monster effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,6))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.acval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function s.acval(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsType(TYPE_PENDULUM)
		and not rc:IsSetCard(SET_ZEFRA)
end
function s.splimit(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimfilter)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimfilter(e,c) 
	return c:IsType(TYPE_PENDULUM) 
		and not c:IsSetCard(SET_ZEFRA) 
end