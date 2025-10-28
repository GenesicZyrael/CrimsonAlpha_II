--Shaddollswarm Ouroboros
local s,id=GetID()
function s.initial_effect(c)
	--flip 
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.rmtg)
		e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)	
	--Special Summon this card from  your hand by sending 1 "Shaddoll" card from Deck, and 2 monsters from hand or field to GY
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
		e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
		e2:SetCountLimit(1,id)
		e2:SetCondition(aux.exccon)
		e2:SetTarget(s.sptg)
		e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetCategory(CATEGORY_TOHAND)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_TO_GRAVE)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e3:SetCountLimit(1,id)
		e3:SetTarget(s.thtg)
		e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SHADDOLL}

function s.rmfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToRemove()
		and ( c:IsMonster() or (c:IsSpellTrap() and c:IsPublic()) )
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return ( not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
			and ( Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_MONSTER)
			or Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_SPELL)
			or Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_TRAP) ) )
			or e:GetHandler():IsFaceup() and e:GetHandler():IsMonster()
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,TYPE_MONSTER)
	local g2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,TYPE_SPELL)
	local g3=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,TYPE_TRAP) 
	if #g1>0 or #g2>0 or #g3>0 
	then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.HintSelection(sg1)
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	end
	--switch ATK and DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SWAP_BASE_AD)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.rescon(sg,e,tp,mg)
	return #sg==2 and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetLevel))
end
function s.spfilter1(c)
	return c:IsSetCard(SET_SHADDOLL) and c:IsAbleToGrave()
end
function s.spfilter2(c,tp)
	return c:IsMonster() and c:IsAbleToGrave() and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
end
function s.rescon(sg,e,tp,mg)
	if #sg>1 then
		return aux.ChkfMMZ(1)(sg,e,tp,mg)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND|LOCATION_MZONE,0,c,tp)
	if chk==0 then return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,c)
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND|LOCATION_MZONE,0,2,c,tp)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local mg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND|LOCATION_MZONE,0,c,tp)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,c)
	local g2=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #g2>1 then end
	g1:Merge(g2)
	if #g1>2 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_DEFENSE)
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_SHADDOLL) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end