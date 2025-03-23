--Worm Apocalypse
--Modified for CrimsonRemodels
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be used as material, except for the Special Summon of a Reptile "Worm" monster
	aux.XenoMatCheckSummoned(c,s.matfilter)
	--Special Summon as many "Worm Apocalypse" as possible from your hand, Deck, or GY in face-up or face-down Defense Position
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
s.listed_names={id,88650530}
function s.matfilter(e,c)
	if not c then return false end
	return not (c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)) 
end
function s.spfilter(c,e,tp)
	return c:IsCode({id,88650530}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,POS_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	for tc in g:Iter() do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end
