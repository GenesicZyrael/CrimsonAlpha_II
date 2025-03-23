--Silver Wing Magician
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ASSAULT_MODE}
s.assault_mode_all=id
function s.spfilter(c,e,tp,zone)
	return c:ListsCode(CARD_ASSAULT_MODE) and c:IsMonster() 
		and (c:IsAbleToHand() or (zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zone) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)	
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone)
	local sc=sg:GetFirst()
	if sc then
		if zone~=0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) then
			aux.ToHandOrElse(sc,tp,function(c)
				return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) 
					and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
					function(c)
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone) end,
					aux.Stringid(id,0)
			)
		else
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
		end
	end
	-- end
end