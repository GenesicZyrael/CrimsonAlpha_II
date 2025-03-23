--Gem-Knights' Lapis & Lazuli
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Fusion" card that mentions "Gem-Knight" from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_GEM,SET_FUSION,SET_GEM_KNIGHT}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GEM) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_FUSION) and c:ListsArchetype(SET_GEM_KNIGHT) and c:IsAbleToHand()
end
function s.exfil(c,tp)
	return c:IsSetCard(SET_GEM_KNIGHT) and c:IsType(TYPE_FUSION)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(s.exfil,tp,LOCATION_EXTRA,0,1,nil,tp) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp,s.exfil,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
			if tc and Duel.IsPlayerCanSpecialSummonMonster(tp,2002000072,0,0,0,0,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then 
				Duel.ConfirmCards(1-tp,tc) 
				local token=Duel.CreateToken(tp,2002000072)
				local r1=Effect.CreateEffect(e:GetHandler())
				r1:SetType(EFFECT_TYPE_SINGLE)
				r1:SetCode(EFFECT_CHANGE_RACE)
				r1:SetValue(tc:GetRace())
				r1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				token:RegisterEffect(r1,true)
				local r2=r1:Clone()
				r2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				r2:SetValue(tc:GetAttribute())
				token:RegisterEffect(r2,true)
				local r3=r1:Clone()
				r3:SetCode(EFFECT_CHANGE_CODE)
				r3:SetValue(tc:GetOriginalCode())
				token:RegisterEffect(r3,true)		
				Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)	
			end 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_GEM)
end