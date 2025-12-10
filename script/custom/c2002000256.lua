--Shenlong, Divine Yang Zing of Zefra
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,{SET_YANG_ZING,SET_ZEFRA}),1,99)
	c:AddMustFirstBeSynchroSummoned()
	--register effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--material count check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--Special summon itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--summon limit
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.synlimit)
	c:RegisterEffect(e3)
	--Special summon 1 "Yang Zing" or "Zefra" monster from deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_YANG_ZING,SET_ZEFRA}
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_YANG_ZING,scard,sumtype,tp) or c:IsSetCard(SET_ZEFRA,scard,sumtype,tp)
end
function s.setcheck(c)
	return c:IsSetCard(SET_YANG_ZING) or c:IsSetCard(SET_ZEFRA)
end
function s.valcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsSetCard,nil,{SET_YANG_ZING,SET_ZEFRA}):GetClassCount(Card.GetAttribute)
	e:GetLabelObject():SetLabel(ct)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()>0
end
function s.chkfilter(c,label)
	return c:GetFlagEffect(label)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local r1=Effect.CreateEffect(c)
	r1:SetDescription(aux.Stringid(id,1))
	r1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	r1:SetType(EFFECT_TYPE_QUICK_O)
	r1:SetRange(LOCATION_MZONE)
	r1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	r1:SetCode(EVENT_FREE_CHAIN)
	r1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	r1:SetReset(RESET_EVENT+(RESETS_STANDARD&~RESET_TURN_SET))
	r1:SetCountLimit(ct)
	r1:SetTarget(s.destg)
	r1:SetOperation(s.desop)
	c:RegisterEffect(r1)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_YANG_ZING)
end
function s.spfilter1(c,e,tp)
	if c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,tp,nil,c)==0 then return false end
	return (c:IsSetCard(SET_YANG_ZING) or c:IsSetCard(SET_ZEFRA)) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return not c:HasFlagEffect(id) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
		if Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2))
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.desfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) 
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
	and (c:IsSetCard(SET_YANG_ZING) or c:IsSetCard(SET_ZEFRA))
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.desfilter,1,nil,tp)
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(Card.IsSetCard,1,nil,SET_YANG_ZING) and sg:IsExists(Card.IsSetCard,1,nil,SET_ZEFRA))
end
function s.tdfilter(c,e)
	return c:IsAbleToDeck() and c:IsSetCard({SET_YANG_ZING,SET_ZEFRA}) and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then
		if Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter2(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return (c:IsSetCard(SET_YANG_ZING) or c:IsSetCard(SET_ZEFRA)) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_DECK end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_DECK end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,loc,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		if aux.GetPendulumZoneCount(tp)>0 then
			Duel.BreakEffect()
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end
	end
end