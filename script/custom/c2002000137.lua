--Obelisk's Disciple
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:SetLimitOnField(3,id)
	--Change its name to "Ra's Disciple"
	local e0=aux.ChangeCode(c,74875003,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK)
	c:RegisterEffect(e0)
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Disciple's Sacrifice
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_PRE_MATERIAL)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
s.listed_names={74875003,CARD_RA,10000020,10000000}
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSummon(tp) end
end
function s.extg(e,c)
	return c:IsCode(CARD_RA,10000020,10000000) 
		or c:ListsCode(CARD_RA,10000020,10000000)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.extg)
	Duel.RegisterEffect(e1,tp)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r==REASON_SUMMON and rc:IsFaceup() and rc:IsAttribute(ATTRIBUTE_DIVINE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)	
end
function s.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.efilter(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and te:GetHandler()~=e:GetHandler() then
		local lv=e:GetHandler():GetLevel()
		local ec=te:GetOwner()
		if ec:IsType(TYPE_LINK) then
			return ec:GetLink()<=lv
		elseif ec:IsType(TYPE_XYZ) then
			return ec:GetOriginalRank()<=lv
		else
			return ec:GetOriginalLevel()<=lv
		end
	else
		return false
	end
end