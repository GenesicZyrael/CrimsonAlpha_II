--リチュアの写魂鏡
--Gishki Photomirror
--Modified for CrimsonAlpha
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon any "Gishki" Ritual Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    if not s.ritual_matching_function then
        s.ritual_matching_function={}
    end
    s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,SET_GISHKI)
end
s.listed_series={SET_GISHKI}
function s.ritualfilter(c,e,tp,lp)
    if not c:IsRitualMonster() or not c:IsSetCard(SET_GISHKI) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    if not c:IsLocation(LOCATION_HAND) then
		local extra_loc_eff,used=Ritual.ExtraLocationOPTCheck(c,e:GetHandler(),tp)
		if not extra_loc_eff or extra_loc_eff and used then return false end
		if extra_loc_eff:GetProperty()&EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN>0 and Duel.HasFlagEffect(tp,EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN) then 
			return false 
		end
	end
	return lp>c:GetLevel()*500
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local lp=Duel.GetLP(tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_HAND|LOCATION_NOTHAND,0,1,nil,e,tp,lp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lp=Duel.GetLP(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- custom --
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ritualfilter),tp,LOCATION_HAND|LOCATION_NOTHAND,0,nil,e,tp,lp)
	local tc=tg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	Ritual.UseExtraLocationCountLimit(tc,e:GetHandler(),tp)
	--
	mustpay=true
	Duel.PayLPCost(tp,tc:GetLevel()*500)
	mustpay=false
	tc:SetMaterial(nil)
	Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	tc:CompleteProcedure()
end
