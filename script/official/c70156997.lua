--Earth Spirit Art - Kurogane
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c,att)
	return c:IsAttribute(att) 
end
function s.charmer_filter(c,att)
	return (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsAttribute(att) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2202500154)}) do
		fg:AddCard(pe:GetHandler())
	end
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then 
		if #fg>0 then
			return (ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_EARTH)) 
				or (ft>0 and Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_EARTH))	
		else
			return ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_EARTH) 
		end
	end	
	local g=Group.CreateGroup()
	if ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_EARTH) then
		g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_EARTH)
	end
	if #fg>0 then 
		if ft>0 and Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_EARTH) then 
			if #g>0 then 
				if Duel.SelectYesNo(tp,aux.Stringid(2202500154,2)) then
					g=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_EARTH)
				end
			else
				g=Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_EARTH)
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
		fc:RegisterFlagEffect(2202500154,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
		Duel.SendtoGrave(tc,REASON_COST)
	end
	e:SetLabelObject(tc)
end
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	local ex=nil
	if e:GetLabel()==1 then
		ex=e:GetLabelObject()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,ex,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end