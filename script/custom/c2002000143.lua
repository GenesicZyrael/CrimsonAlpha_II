--Possessed Spirit Art - Kaijo
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xbf,0x10c0}
function s.costfilter(c)
	return c:IsSetCard(0x10c0) and c:IsType(TYPE_MONSTER)
end
function s.charmer_filter(c)
	return c:IsSetCard(0x10c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2002000130)}) do
		fg:AddCard(pe:GetHandler())
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then 
		if #fg>0 then
			return (ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)) 
				or (ft>0 and Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil))	
		else
			return ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) 
		end
	end	
	local g=Group.CreateGroup()
	if ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) then
		g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil)
	end
	if #fg>0 then 
		if ft>0 and Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil) then 
			if #g>0 then 
				if Duel.SelectYesNo(tp,aux.Stringid(2002000130,2)) then
					g=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil)
				end
			else
				g=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil)
			end 
		end
	end
	local tg=g:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if tc:GetLocation() ~= LOCATION_DECK then
		Duel.Release(tc,REASON_COST)
	else
		local fc=nil
		if #fg==1 then
			fc=fg:GetFirst()
		else
			fc=fg:Select(tp,1,1,nil)
		end
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(2002000130,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
function s.cfilter(c,e,tp)
	return c:IsSetCard(0xbf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attr=0
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	for tc in aux.Next(g) do
		attr=(attr|tc:GetAttribute())
	end	
	local att=Duel.AnnounceAttribute(tp,1,attr)
	Duel.SetTargetParam(att)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(0xbf) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.filter(c)
	return c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,att)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,g)
		local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		local tc=sg:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetCode(EFFECT_ADD_ATTRIBUTE)
			e1:SetValue(att)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end		
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.tgfilter)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(s.atlimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)		
	end
end
function s.atlimit(e,c)
	return (c:IsFaceup() and c:IsSetCard(0xbf)) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))
end

function s.tgfilter(e,c)
	return (c:IsFaceup() and c:IsSetCard(0xbf)) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))
end