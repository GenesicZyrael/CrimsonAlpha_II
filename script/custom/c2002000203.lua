--Xtra HERO Void Phantom
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--spsummon cost
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCost(s.splimcost)
	e0:SetOperation(s.splimop)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--addtohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.stcon)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)	
end
s.listed_names={CARD_DARK_FUSION}
s.listed_series={SET_HERO}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_FIEND,lc,sumtype,tp) and not c:IsCode(id)
end
function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA  and c:IsRace(RACE_FIEND)
end
function s.splimcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.splimop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_EXTRA)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(CARD_DARK_FUSION) 
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	--Extra Fusion Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_DECK,0)
	e1:SetTarget(s.extratg)
	e1:SetValue(1)
	e1:SetLabelObject({s.extrafil_replacement})
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--
function s.extratg(e,c) 
	return c:IsAbleToGrave() and c:IsMonster() and (c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) 
end
function s.extrafil_repl_filter(c,tp)
	return c:IsCanBeFusionMaterial() and (c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR))
end
function s.extrafil_replacement(e,tp,mg)
	local tp=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_DECK,0,nil,tp)
	if e:GetHandler():GetCode()==CARD_DARK_FUSION then 
		return g,s.fcheck_true
	else
		return g,s.fcheck_false
	end
end
function s.fcheck_true(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fcheck_false(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=0
end

function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>1
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>1 
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		e:SetLabel(1)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		e:SetLabel(2)
	end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		if e:GetLabel()==1 then
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		elseif e:GetLabel()==2 then
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		end
		c:RegisterEffect(e1)
	end
end