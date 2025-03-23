 --Enveloping Void 
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xc5,0xbb}
function s.filter(c)
	return ( c:IsSetCard(0xc5) 
		or c:IsSetCard(0xbb) )
		and not c:IsCode(id) 
		and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>3
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0,0x4011,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,4,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0,0x4011,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then
		for i=1,4 do
			local token=Duel.CreateToken(tp,34822851)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+0x1fe0000)
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e2:SetRange(LOCATION_MZONE)
				e2:SetAbsoluteRange(tp,1,0)
				e2:SetTarget(s.splimit)
			token:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetRange(LOCATION_MZONE)
				e3:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
				e3:SetTarget(s.efftg)
				e3:SetCode(34822850)
			token:RegisterEffect(e3,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(0xbb) 
end
function s.efftg(e,c)
	return c:IsSetCard(0xbb)
end