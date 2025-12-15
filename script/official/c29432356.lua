--智天の神星龍
--Zefraath
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your face-up Extra Deck) by Tributing all monsters you control, including at least 3 "Zefra" monsters
	local e0a=Effect.CreateEffect(c)
	e0a:SetDescription(aux.Stringid(id,0))
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_SPSUMMON_PROC)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCondition(s.selfspcon)
	e0a:SetOperation(s.selfspop)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0a:SetDescription(aux.Stringid(id,6))
	e0a:SetCondition(s.selfspcon_new)
	e0a:SetTarget(s.selfsptg_new)
	e0a:SetOperation(s.selfspop_new)
	c:RegisterEffect(e0b)
	--Add 1 "Zefra" Pendulum Monster from your Deck to your Extra Deck, face-up, and if you do, change this card's Pendulum Scale to be the same as that Pendulum Monster's, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.textg)
	e1:SetOperation(s.texop)
	c:RegisterEffect(e1)
	--After you Special Summon this card, you can conduct 1 Pendulum Summon of a "Zefra" monster(s) during your Main Phase this turn, in addition to your Pendulum Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),function(c) return c:IsSetCard(SET_ZEFRA) end,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,2),aux.Stringid(id,3),id) end)
	c:RegisterEffect(e2)
	--Special Summon 1 "Zefra" monster from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.deckspcost)
	e3:SetTarget(s.decksptg)
	e3:SetOperation(s.deckspop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZEFRA}
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local rg=Duel.GetReleaseGroup(tp)
	return (#g>0 or #rg>0) and g:FilterCount(Card.IsReleasable,nil)==#g
		and g:FilterCount(Card.IsSetCard,nil,SET_ZEFRA)>=3
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	Duel.Release(rg,REASON_COST)
end


function s.selfspcon_new(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFlagEffect(tp,2002000268)>0 then return end
	local ft=Duel.GetLocationCountFromEx(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE
	if ft>0 then loc=loc+LOCATION_GRAVE end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,loc,0,nil,2002000268)
	if #g<1 then return end
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,loc,0,1,nil,2002000268)
end
function s.selfsptg_new(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCountFromEx(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE
	if ft>0 then loc=loc+LOCATION_GRAVE end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,loc,0,nil,2002000268)
	if #g<1 then return end
	local sg=g:Select(tp,1,1,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
	return true
	end
	return false
end
function s.selfspop_new(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
	Duel.RegisterFlagEffect(tp,2002000268,RESET_PHASE|PHASE_END,0,1)
end

function s.texfilter(c,scale)
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) and not c:IsScale(scale)
end
function s.textg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.texfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetScale()) end
end
function s.texop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))
	local sc=Duel.SelectMatchingCard(tp,s.texfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetScale()):GetFirst()
	if sc and Duel.SendtoExtraP(sc,tp,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA) then
		--Change this card's Pendulum Scale to be the same as that Pendulum Monster's, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(sc:GetLeftScale())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(sc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
function s.deckspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_ZEFRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.decksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.deckspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end