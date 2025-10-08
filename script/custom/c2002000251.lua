--Shaddollswarm Ouroboros
local s,id=GetID()
function s.initial_effect(c)
	--flip 
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.rmtg)
		e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)	
	--tohand
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_TOHAND)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e2:SetCountLimit(1,id)
		e2:SetTarget(s.thtg)
		e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADDOLL}

function s.rmfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToRemove()
		and ( c:IsMonster() or (c:IsSpellTrap() and c:IsPublic()) )
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
		and ( Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_MONSTER)
		or Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_SPELL)
		or Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil,TYPE_TRAP) )
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
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