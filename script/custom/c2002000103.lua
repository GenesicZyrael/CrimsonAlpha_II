 --CCG: Apoqliphort Advent
-- This card can be used to Ritual Summon any Machine Ritual Monster from your hand by 
-- Tributing monsters from your hand or field whose total Levels equal or exceed the Level of that 
-- Ritual Monster. If you would Ritual Summon "Apoqliphort Administrator", you can also Ritual 
-- Summon from your Deck. During your Main Phase, if you control no monsters in your Main 
-- Monster Zones, except during the turn this card was sent to the GY: You can banish this card 
-- from your GY; Special Summon 2 "Qliphort Tokens" (Machine/EARTH/Level 4/ATK 1800/DEF 1000).
-- You can only activate 1 "Apoqliphort Advent" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),nil,aux.Stringid(id,0))
	c:RegisterEffect(e1)	
	local e2=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,1),lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,2002000102),location=LOCATION_DECK})
	c:RegisterEffect(e2)		
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)	
end
s.fit_monster={2002000102}
s.listed_names={2002000102}
function s.tokenfilter(c)
	return c:GetSequence()<5
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ( not Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,0,1,nil) )
		and aux.exccon(e)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2002000106,0x10aa,0x4011,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,2002000106,0x10aa,0x4011,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,2002000106)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()

end