--Ceremonial Spirt Art - Gishiki
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcEqual(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),nil,aux.Stringid(id,0))
	c:RegisterEffect(e1)	
	local e2=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,1),lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),extrafil=s.extragroup,
								extraop=s.extraop,stage2=nil,location=LOCATION_HAND,matfilter=s.matfilter})
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
	local e3=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,2),lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,2002000124),location=LOCATION_GRAVE})
	c:RegisterEffect(e3)	
	local e4=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,3),lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsCode,2002000124),extrafil=s.extragroup,
								extraop=s.extraop,stage2=nil,location=LOCATION_GRAVE,matfilter=s.matfilter})
	e4:SetCondition(s.condition2)
	e4:SetCost(s.cost)
	c:RegisterEffect(e4)
	--Tribute
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCost(s.spcost)	
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)		
end
s.listed_names={2002000124}
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
end
function s.matfilter(c)
	return (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.ritcheck(e,tp,g,sc)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2002000130),tp,LOCATION_FZONE,0,1,nil)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2002000130)}) do
		fg:AddCard(pe:GetHandler())
	end
	return e:GetHandler():GetCode()==id and #fg>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2002000130),tp,LOCATION_FZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2002000130)}) do
		fg:AddCard(pe:GetHandler())
	end
	if chk==0 then 
		if #fg>0 then
			return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_DECK,0,1,nil) 		
		end
	end	
	local fc=nil
	if #fg==1 then
		fc=fg:GetFirst()
	else
		fc=fg:Select(tp,1,1,nil)
	end
	Duel.Hint(HINT_CARD,0,fc:GetCode())
	fc:RegisterFlagEffect(2002000130,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
end



function s.costfilter(c)
	return (c:IsSetCard(0x10c0) or c:IsType(TYPE_RITUAL)) and c:IsType(TYPE_MONSTER)
end
function s.charmer_filter(c)
	return c:IsSetCard(0x10c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,2002000130)}) do
		fg:AddCard(pe:GetHandler())
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then 
		if #fg>0 then
			return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
				and ((ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)) 
				or   (ft>0  and Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil)))
		else
			return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
				and (ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)) 
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
		Duel.Remove(c,POS_FACEUP,REASON_COST)
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
		Duel.Remove(c,POS_FACEUP,REASON_COST)
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
function s.spfilter1(c,e,tp)
	return c:IsDefenseBelow(1500) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.spfilter2(c,e,tp,atc)
	return c:IsDefenseBelow(1500) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and c:IsAttribute(atc:GetAttribute()) 
		and not c:IsCode(atc:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g1>0 then
		local atc=g1:GetFirst()
		local att=atc:GetAttribute()
		local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,atc)
		g1:Merge(g2)
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,g1)	
	end
end