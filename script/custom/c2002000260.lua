--Zodiac Moujespecter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--Type Spellcaster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_ONFIELD)
	e0:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e0)
	--tribute substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e1:SetCountLimit(2,{id,0})
	e1:SetValue(s.relval)
	c:RegisterEffect(e1)
	--Place in Pendulum Zone if Tributed or Destroyed
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2a:SetCode(EVENT_DESTROYED)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.pentg)
	e2a:SetOperation(s.penop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e2b)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.DetachFromSelf(1,1,nil))
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup()
		and ((c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_BEASTWARRIOR))
			or c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_PENDULUM))
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.relval(e,re,r,rp)
	return re and re:IsActivated() and (r&REASON_COST)~=0
end
function s.tribute_cost(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToGraveAsCost()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevel(4)		
		and (c:IsRace(RACE_BEASTWARRIOR) or (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER)))
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		if Duel.CheckReleaseGroup(tp,nil,1,false,nil,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local rg=Duel.SelectReleaseGroup(tp,nil,1,1,false,nil,nil)
			if Duel.Release(rg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=0 then
				if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local spg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
				if #spg>0 then
					Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end