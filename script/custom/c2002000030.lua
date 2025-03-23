--Majestic Synchron
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--no return
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={0x3f}
--
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(s.pmfilter,1,nil,c)
end
function s.thfilter(c)
	return c:IsSetCard(0x3f) and c:IsAbleToHand()
end
function s.pmfilter(c,sc)
	return c:IsSetCard(0x3f)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--
function s.cfilter1(c,e,tp)
	return c==e:GetHandler() and c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
function s.cfilter2(c,e,tp,tc)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()+tc:GetLevel(),Group.FromCards(c,tc))
end
function s.spfilter(c,e,tp,lv,mg)
	return c:IsSetCard(0x3f) and c:IsType(TYPE_SYNCHRO) and (not chk or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:IsLevel(lv)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g1=e:GetHandler()
	local g2=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp,g1)
	local lv=g1:GetLevel()+g2:GetFirst():GetLevel()
	Duel.SendtoGrave(g1+g2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,true,false,POS_FACEUP)
	end	
end
--
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--may not return
	local r1=Effect.CreateEffect(c)
	r1:SetType(EFFECT_TYPE_FIELD)
	r1:SetCode(id)
	r1:SetTargetRange(LOCATION_MZONE,0)
	r1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(r1,tp)		
	-- local r1=Effect.CreateEffect(e:GetHandler())
		-- r1:SetType(EFFECT_TYPE_FIELD)
		-- r1:SetCode(EFFECT_CANNOT_TO_DECK)
		-- r1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		-- r1:SetTargetRange(LOCATION_ONFIELD,0)
		-- r1:SetReset(RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(r1,tp)
	-- local r2=r1:Clone()
		-- r2:SetCode(EFFECT_CANNOT_TO_HAND)
		-- r2:SetTarget(s.etarget)
	-- Duel.RegisterEffect(r2,tp)
	-- local r3=Effect.CreateEffect(e:GetHandler())
	-- r3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- r3:SetCode(EFFECT_SEND_REPLACE)
	-- r3:SetTarget(s.reptg)
	-- r3:SetValue(s.repval)
	-- r3:SetReset(RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(r3,tp)	
end
-- --
-- function s.etarget(e,c)
	-- return c:GetOriginalType()&TYPE_EXTRA~=0
-- end
-- --
-- function s.repfilter(c,tp)
	-- return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_DECK
		-- and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x3f)
		-- and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
-- end
-- function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- return Duel.SelectYesNo(tp,aux.Stringid(id,0))
-- end
-- function s.repval(e,c)
	-- return s.repfilter(c,e:GetHandlerPlayer())
-- end