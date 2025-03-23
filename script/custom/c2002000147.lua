--Ascension of the Destruction Swordsmaster
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_BUSTER_BLADER),nil,s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Return itself to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BUSTER_BLADER}
s.listed_series={SET_DESTRUCTION_SWORD}
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,RACE_DRAGON) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(CARD_BUSTER_BLADER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local c=e:GetHandler()
		c:SetCardTarget(tc)
		--Cannot Special Summon from the Extra Deck, 
		-- except monsters that specifically list "Buster Blader" in its text
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e3:SetTargetRange(1,0)
		e3:SetTarget(s.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		--Clock Lizard check
		aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsCode(CARD_BUSTER_BLADER) and not c.listed_names==CARD_BUSTER_BLADER and not c.ListsCodeAsMaterial(c,CARD_BUSTER_BLADER) end)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsCode(CARD_BUSTER_BLADER) 
		   and not c.listed_names==CARD_BUSTER_BLADER
		   and not c.ListsCodeAsMaterial(c,CARD_BUSTER_BLADER)
end
function s.cfilter(c)
	return c:IsSetCard(SET_DESTRUCTION_SWORD) and c:IsDiscardable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_DISCARD+REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end