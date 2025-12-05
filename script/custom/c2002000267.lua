--Yazi, Spiritual Beast of the Yang Zing
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Special Summon 1 "Ritual Beast"/"Yang Zing" from the Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_REMOVE)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.target)
	e1a:SetOperation(s.operation)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_TO_GRAVE)
	e1b:SetCondition(s.condition)
	c:RegisterEffect(e1b)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_YANG_ZING,SET_RITUAL_BEAST}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and not c:IsCode(id) 
		and (c:IsSetCard(SET_RITUAL_BEAST) or c:IsSetCard(SET_YANG_ZING))
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(Card.IsSetCard,1,nil,SET_RITUAL_BEAST) 
		and sg:IsExists(Card.IsSetCard,1,nil,SET_YANG_ZING))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return ft>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #tg>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.tgfilter(c,e,tp) 
	return c:IsMonster() and c:IsAbleToRemove() 
		or (c:IsDestructable() and c:IsLocation(LOCATION_MZONE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local loc=LOCATION_MZONE
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		loc=LOCATION_MZONE+LOCATION_GRAVE
	end
	if chk==0 then 
		return Duel.IsExistingTarget(s.tgfilter,tp,loc,0,1,c,e,tp,e) 
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,loc,0,1,1,c,e,tp,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local ops={}
	local op=1
	local ev=nil
	ops[1]=aux.Stringid(id,2)
	if tc:IsLocation(LOCATION_MZONE) then 
		ops[2]=aux.Stringid(id,3)
		op=Duel.SelectOption(tp,table.unpack(ops))+1
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		ev=Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		ev=Duel.Destroy(tc,REASON_EFFECT)
	end
	if ev and ev>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end