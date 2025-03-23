--Zefra Divine Mirror
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)	
	--Activate
	local e1=Ritual.AddProcGreater({handler=c,
									matfilter=aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),
									location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,
									forcedselection=s.forcedselection,
									requirementfunc=Card.GetScale})
	c:RegisterEffect(e1)
	--Return this card to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ZEFRA}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ZEFRA) and c:GetScale()>0 and c:IsLocation(LOCATION_MZONE)
end
function s.forcedselection(e,tp,sg,sc)
	if sc:IsLocation(LOCATION_DECK) then
		return sg:IsExists(s.filter,#sg,nil)
	end
	return true
end
function s.cfilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsPublic() and c:IsAbleToDeckAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED|LOCATION_EXTRA,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED|LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)

end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end