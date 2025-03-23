--Worm Erokin
--Modified for CrimsonRemodels
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,s.ffilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,aux.TRUE,1)
	--Special Summon 2 Reptile "Worm" monsters with the same Level from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(aux.SelfTributeCost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WORM}
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_WORM,fc,sumtype,tp) 
		and (not sg or not sg:IsExists(Card.IsLevel,1,c,c:GetLevel()))
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return #g>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetMZoneCount(tp,e:GetHandler())>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.matfilter(e,c)
	return c:IsSetCard(SET_WORM)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)	
	for tc in dg:Iter() do
		if Duel.SpecialSummonStep(tc,154,tp,tp,false,false,POS_FACEUP) then
			--Cannot activate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3302)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Cannot be used as material for a monster from the Extra Deck, unless all other materials are "Worm" monsters
			aux.XenoMatCheckOthers(c,s.matfilter,RESET_EVENT|RESETS_STANDARD)
		end
	end
	Duel.SpecialSummonComplete()
end