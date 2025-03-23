--Advanced Tactics
--Special Summon 1 Level 10 monster that requires 3 or more Tributes to be Normal Summoned/Set from your hand in face-down Defense Position, ignoring its Summoning Conditions, and if you do, add 1 monster with the same name from your Deck. You can treat the Summoned monster as 3 Tributes for the Tribute Summon of a monster during this turn. For the rest of this turn after you activate this card, you cannot Special Summon from the Extra Deck. You can only activate 1 "Advanced Tactics" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(id)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	local se=e:GetLabelObject()
	return c:GetLevel()==10
		and c:IsSummonableCard()
		and not c:IsSummonable(false,se)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEDOWN_DEFENSE)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.cfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsAbleToHand() 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) 
	end	
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	local sptc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local code=sptc:GetFirst():GetCode()
	local adtc=Duel.GetFirstMatchingCard(s.cfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp,code)
	if sptc and adtc then
		if Duel.SpecialSummon(sptc,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE) and Duel.SendtoHand(adtc,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,adtc)
			--Triple Tribute Fodder
			local r1=Effect.CreateEffect(sptc:GetFirst())
				r1:SetType(EFFECT_TYPE_SINGLE)
				r1:SetRange(LOCATION_MZONE)
				r1:SetCode(EFFECT_TRIPLE_TRIBUTE)
				r1:SetTargetRange(LOCATION_MZONE,0)
				r1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				r1:SetValue(aux.TRUE)
			sptc:GetFirst():RegisterEffect(r1,tp)
		end	
	end
	--Cannot special summon from extra deck
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,2),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end