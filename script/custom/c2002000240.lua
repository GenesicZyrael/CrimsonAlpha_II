--World Legacy Retribution
local s,id=GetID()
function s.initial_effect(c)
    --Send to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    --Fusion Summon from GY
	local e2=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,s.extraop,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WORLD_LEGACY}
function s.matfilter(c)
	return c:IsLinkMonster()
		and ((c:IsLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsAbleToGrave()) 
			or (c:IsLocation(LOCATION_REMOVED) and c:IsAbleToDeck()))
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_REMOVED,0,nil)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if #rg>0 then
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,1,LOCATION_REMOVED)
end
function s.linkfilter(c,tp)
    return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
    local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
    local ratings={}
    local diff=0
    for lc in g:Iter() do
        if not ratings[lc:GetLink()] then
            ratings[lc:GetLink()]=true
            diff=diff+1
        end
    end
    if chk==0 then return diff>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,diff,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg>0 then
        Duel.SendtoGrave(tg,REASON_EFFECT)
    end
end
