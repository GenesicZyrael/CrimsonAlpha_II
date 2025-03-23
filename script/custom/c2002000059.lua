--Naturia Bee
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Add Pseudo-PendulumProc
	Pendulum.PseudoAddProc({handler=c,lscale=7,rscale=7})
	--splimit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_PZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- --return to hand
	-- local e3=Effect.CreateEffect(c)
		-- e3:SetDescription(aux.Stringid(id,1))
		-- e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		-- e3:SetCode(EVENT_TO_GRAVE)
		-- e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		-- e3:SetCountLimit(1,{id,0})
		-- e3:SetCondition(s.thcon)
		-- e3:SetTarget(s.thtg)
		-- e3:SetOperation(s.thop)
	-- c:RegisterEffect(e3)	
	-- --add tuner
	-- local e4=Effect.CreateEffect(c)
		-- e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		-- e4:SetCode(EVENT_BE_MATERIAL)
		-- e4:SetCondition(s.tncon)
		-- e4:SetOperation(s.tnop)
	-- c:RegisterEffect(e4)
	--Destruction replacement for a "Perfomapal" card
	local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EFFECT_DESTROY_REPLACE)
		e5:SetRange(LOCATION_GRAVE)
		e5:SetTarget(s.reptg)
		e5:SetValue(s.repval)
		e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_NATURIA}
-- {Pendulum Summon Restriction: Naturia}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_NATURIA) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_NATURIA) 
		and not c:IsCode(id) 
		and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		if c.IsLocation(c,LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		end
    end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
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

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_NATURIA) and c:IsOnField()
		and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end