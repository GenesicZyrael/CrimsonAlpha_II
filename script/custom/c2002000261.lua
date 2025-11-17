--True King Phostaros, the Extinguisher
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 2 monsters and Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--banish 2 random cards in the controlling player's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1 end)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--Special summon a monster from hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_TRUE_DRACO_KING}
function s.desfilter(c,e,tp,hc,resolution_chk)
	return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (resolution_chk or s.spcheck(c,e,tp,hc))
end
function s.spcheck(c,e,tp,hc)
	local ctrl=c:GetControler()
	return (Duel.GetMZoneCount(ctrl,c,tp)>0 and hc:IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP,ctrl))
		or (Duel.GetMZoneCount(1-ctrl,nil,tp)>0 and hc:IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP,1-ctrl))
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
		and (Duel.GetMZoneCount(tp)>0 or sg:IsExists(Card.IsInMainMZone,1,nil,tp))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local oppo_location=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,oppo_location,c,e,tp,c,false)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	if not g:IsExists(Card.IsOnField,2,nil) or ((Duel.GetMZoneCount(tp)>1 or Duel.GetMZoneCount(1-tp)>1)
		and (Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_HAND,0,2,c)
		or g:IsExists(aux.FaceupFilter(Card.IsLocation,LOCATION_HAND),2,nil))) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_HAND|LOCATION_ONFIELD)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local relation_chk=c:IsRelateToEffect(e)
	local exc=relation_chk and c or nil
	local oppo_location=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local resolution_chk=not (relation_chk and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,oppo_location,2,c,e,tp,c,false))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,oppo_location,exc,e,tp,c,resolution_chk)
	if #g<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	local light_chk=dg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)==2
	if not dg then return end
	-- if sc:IsOnField() then Duel.HintSelection(sc) end
	if Duel.Destroy(dg,REASON_EFFECT)>0 and relation_chk then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,1,tp,false,false)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP,1-tp)
		if not (b1 or b2) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
		local target_player=op==1 and tp or 1-tp
		if light_chk then 
			Duel.SpecialSummon(c,1,tp,target_player,false,false,POS_FACEUP)
		else
			Duel.SpecialSummon(c,0,tp,target_player,false,false,POS_FACEUP)
		end 
	end

end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:RandomSelect(tp,2)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.thfilter(c,e,tp)
	return c:IsAttributeExcept(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tffilter(c,tp)
	return c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(SET_TRUE_DRACO_KING)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end