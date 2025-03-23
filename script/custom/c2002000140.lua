--Volcanic Mine
--(This is always treated as a "Blaze Accelerator" card.)
--If this card is sent from the field to the GY (by battle or card effect): You can send 1 "Volcanic" monster from your hand or Deck to the GY, then inflict 500 damage to your opponent. You can only use this effect of "Volcanic Mine" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sendtg)
	e1:SetOperation(s.sendop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.sendcon)
	c:RegisterEffect(e2)
end
s.listed_series={0x32}
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tgfilter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsCode(id) 
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end