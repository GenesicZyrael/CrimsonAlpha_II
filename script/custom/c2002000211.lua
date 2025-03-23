--Worm Gulse
--Modified for CrimsonRemodels
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Reptile "Worm" monster from your hand in face-up or face-down Defense Position, except "Worm Gulse"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_FLIP)
end
s.listed_series={SET_WORM}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) and not c:IsCode({id,85754829})
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)>0 and tc:IsFacedown() then
		Duel.ConfirmCards(1-tp,tc)
	end
end