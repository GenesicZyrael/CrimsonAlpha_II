--Mekk-Knight Krawler Cyanapse
local s,id=GetID()
function s.initial_effect(c)
	--FLIP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)
	--Normal Set w/o Tributing
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_PROC)
	e2:SetCondition(s.ntcon)
	c:RegisterEffect(e2)
	--Basically Krawler Soma effect but activates as a Quick Effect while facedown
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.spcon)
	e3:SetCost(Cost.SelfChangePosition(POS_FACEUP_ATTACK))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEKK_KNIGHT,SET_KRAWLER}

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),c)
	end
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.lvfilter(c,e,tp)
	return (c:IsSetCard(SET_KRAWLER) or c:IsSetCard(SET_MEKK_KNIGHT)) 
		and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.lvrescon(mustlv)
	return function(sg)
		local res,stop=aux.dncheck(sg)
		local sum=sg:GetSum(Card.GetLevel)
		return (res and sum==mustlv),(stop or sum>mustlv)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return Duel.IsTurnPlayer(1-tp) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft==0 or not c:HasLevel() or c:IsLevelBelow(2) then return false end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then return true end
		if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then return true end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevelBelow(2) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	local lvs={}
	if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then table.insert(lvs,2) end
	if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then table.insert(lvs,4) end
	if #lvs<1 then return end
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvs))
	if c:UpdateLevel(-lv)~=-lv then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(lv),1,tp,HINTMSG_SPSUMMON,s.lvrescon(lv))
	if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_DEFENSE)>0 then
		local fdg=Duel.GetOperatedGroup():Match(Card.IsFacedown,nil)
		if #fdg==0 then return end
		Duel.ConfirmCards(1-tp,fdg)
	end
end