--Infestation Core
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,{id,0})
		e1:SetTarget(s.ActTarg)
		e1:SetOperation(s.ActOp)
	c:RegisterEffect(e1)
	--Attach
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,{id,1})
		e2:SetTarget(s.AttTg)
		e2:SetOperation(s.AttOp)
	c:RegisterEffect(e2)	
	--Banish
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_GRAVE)
		e3:SetCountLimit(1,{id,1})
		e3:SetCost(aux.bfgcost)
		e3:SetTarget(s.BanTg)
		e3:SetOperation(s.BanOp)
	c:RegisterEffect(e3)
end
s.listed_series={SET_STEELSWARM,SET_LSWARM}
-- {Activation Effect: Search lswarm Monster}
function s.ActFilter(c)
	return c:IsSetCard(SET_LSWARM) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsAbleToHand()
end
function s.ActTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.ActFilter,tp,LOCATION_DECK,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.ActOp(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ActFilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
-- {Graveyard Effect: Attach}
function s.AttFilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_LSWARM) 
		and c:GetOverlayCount()==0
end
function s.AttTg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.AttFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.AttFilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.AttFilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.AttOp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
		local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(300)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)	
		local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)	
	end
end
-- {Graveyard Effect: Banish}
function s.BanFilter(c)
	return not (c:IsHasEffect(EFFECT_UNRELEASABLE_SUM) 
		and c:IsHasEffect(EFFECT_UNRELEASABLE_NONSUM))
end
function s.BanTg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.BanFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.BanFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.BanFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.BanOp(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
			e1:SetValue(SET_STEELSWARM)
			e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EXTRA_RELEASE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
			e3:SetDescription(aux.Stringid(id,2))
			e3:SetReset(RESET_PHASE+PHASE_END)
			e3:SetTargetRange(1,1)
		tc:RegisterEffect(e3)	
		local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
			e4:SetDescription(aux.Stringid(id,3))
			e4:SetReset(RESET_PHASE+PHASE_END)
			e4:SetTargetRange(1,1)
		tc:RegisterEffect(e4)	
	end
end
