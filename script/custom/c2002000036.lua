--Gishki Nekrovance
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	local rparams={handler=c,lvtype=RITPROC_GREATER,desc=aux.Stringid(id,1),forcedselection=s.forcedselection,extrafil=s.extrafil,extratg=s.extratg}
	local rittg,ritop=Ritual.Target(rparams),Ritual.Operation(rparams)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Send Gishki monsters from your Deck to the GY to Ritual Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_EXTRA+LOCATION_DECK,0)
	e3:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 end)
	e3:SetCountLimit(1,{id,0})
	e3:SetValue(1)
	e3:SetTarget(s.mttg)
	e3:SetLabelObject({s.forced_replacement})
	c:RegisterEffect(e3)
	--Pendulum Set
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation(rittg,ritop))
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
s.listed_series={SET_GISHKI}
function s.forcedselection(e,tp,sg,sc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_GISHKI)
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel() and c:IsSetCard(SET_GISHKI) 
		and c:IsMonster() and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

-- {Pendulum Effect: Use Deck and Extra Deck for Materials}
function s.mtfil(c)
	return c:IsSetCard(SET_GISHKI) 
end
function s.mttg(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.mtfil,tp,LOCATION_DECK,0,nil)
	return g:IsContains(c)
end
function s.forced_replacement(e,tp,sg,rc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	return ct<=1,ct>1
end
-- {Monster Effect: Place in Pendulum Zone, then Ritual Summon if possible}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end	
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
		local c=e:GetHandler()
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) and Duel.CheckPendulumZones(tp) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
		if rittg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			ritop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end