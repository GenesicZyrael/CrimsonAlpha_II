--Evisgishki Recollection
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)	
	--Allow Ritual Summoning from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.ritgy)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GISHKI,SET_AQUAMIRROR}
function s.thfilter(c)
	return c:IsSetCard(SET_GISHKI) or c:IsSetCard(SET_AQUAMIRROR) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 
	local g=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return a end
	if a and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		-- declare name to discard excavated
		e:SetLabel(1)
	else
		-- shuffle back excavated
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,5)
	local th=g:FilterCount(s.thfilter,nil)>0
	if chk==0 then return #g==5 end
	if e:GetLabel()==1 then
		s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		Duel.SetTargetParam(ac)
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(s.thfilter,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=g:FilterSelect(tp,s.thfilter,1,1,false,nil)
			if tc then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
				Duel.ShuffleHand(tp)
				if e:GetLabel()==1 then
					local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
					local ac=g:Filter(Card.IsCode,nil,code):GetFirst()
					if ac then
						g:Sub(tc)
						Duel.ConfirmCards(1-tp,ac)
						Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE)
						return
					end
				end
			end
			g:Sub(tc)
		end
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_EXCAVATE)
		Duel.ShuffleDeck(tp)
	end
	e:SetLabel(0)
end
function s.ritgy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RITUAL_LOCATION)
	e1:SetProperty(EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end