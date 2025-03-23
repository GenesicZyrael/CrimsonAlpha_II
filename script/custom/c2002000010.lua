--Charming Spirit Art - Shokan
-- Target 1 face-up "Charmer" or "Familiar-Possessed" monster you control; Special Summon 1
-- monster with 1500 ATK/200 DEF and with the same Attribute from your Deck, but it's effects 
-- are negated and it's ATK and DEF becomes 0. You can banish this card and 2 monsters in your 
-- GY with the same Attribute; Special Summon 1 "Familiar-Possessed" monster from your Deck 
-- or GY. You can only use each effect of "Charming Spirit Art - Shokan" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish from GY 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.cost)
	e2:SetOperation(s.ope)
	c:RegisterEffect(e2)
end
s.listed_series={0xbf,0x10c0}
function s.filter1(c,e,tp)
	return c:IsFaceup() and (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function s.filter2(c,e,tp,att)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(att) and c:GetAttack()==1500 and c:GetDefense()==200
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
	local sc=g:GetFirst()
	if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)	
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3)	
		local e4=e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		sc:RegisterEffect(e4)
		Duel.SpecialSummonComplete()	
	end
end

function s.cfilter1(c,e,tp)
	local att=c:GetAttribute()
	return c:IsType(TYPE_MONSTER) 
		and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) 
end
function s.cfilter2(c,tc,e,tp)
	return c:IsType(TYPE_MONSTER) 
		and c:IsAbleToRemoveAsCost()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute() 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c,tc)
		and c~=tc
end
function s.spfilter(c,e,tp,tc1,tc2)
	return c:IsSetCard(0x10c0) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (c~=tc1 and c~=tc2)
end
function s.rescon(sg,e,tp,mg)
    return aux.ChkfMMZ(1)(sg,e,tp,mg) 
		and sg:GetClassCount(Card.GetAttribute)==1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	end
	local rg=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_GRAVE,0,nil,e,tp)
	rg:Merge(Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_GRAVE,0,nil,rg:GetFirst(),e,tp))
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x10c0) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ope(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end	
end