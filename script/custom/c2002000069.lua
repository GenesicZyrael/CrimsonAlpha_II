--Gem-Carbuncle
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pseudo-pendulum
	Pendulum.PseudoAddProc({handler=c,lscale=7,rscale=7})
	--splimit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_PZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_TOHAND)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_TO_GRAVE)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e3:SetTarget(s.thtg)
		e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GEM,SET_GEM_KNIGHT}
-- {Pendulum Summon Restriction: Gem-}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_GEM) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GEM_KNIGHT) 
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) 
			and chkc:IsControler(tp) 
			and s.thfilter(chkc) 
	end
	if chk==0 then 
		return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local r1=Effect.CreateEffect(c)
		r1:SetType(EFFECT_TYPE_SINGLE)
		r1:SetCode(EFFECT_ADD_TYPE)
		r1:SetValue(TYPE_TUNER)
		r1:SetReset(RESET_EVENT+0x1fe0000)
	rc:RegisterEffect(r1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else 
		return true 
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end