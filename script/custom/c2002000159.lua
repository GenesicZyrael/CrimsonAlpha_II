--Elemental HERO Prisman Prime
--This card can be used as a substitute for any 1 Fusion Material whose name is specifically listed on the Fusion Monster Card, but the other Fusion Material(s) must be correct. You can reveal 1 "HERO" Fusion Monster from your Extra Deck; Special Summon 1 monster from your Deck whose name is specifically listed on that card as Fusion Material, then you can apply this effect.
--● Fusion Summon 1 "HERO" Fusion Monster from your Extra Deck, by banishing Fusion Materials you control, including this card.
--You can only use this effect of "Elemental HERO Prisman Prime" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--fusion substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	c:RegisterEffect(e1)
	-- local e3=Effect.CreateEffect(c)
	-- e3:SetType(EFFECT_TYPE_SINGLE)
	-- e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- e3:SetCode(6205579)
	-- c:RegisterEffect(e3)
	--special summon
	local params={aux.FilterBoolFunction(Card.IsSetCard,0x08),Fusion.OnFieldMat(Card.IsAbleToRemove),nil,Fusion.BanishMaterial}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.spcost)
	e2:SetOperation(s.spop(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e2)
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.filter2(c,fc,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	return c:IsCode(table.unpack(fc.material)) 
end
function s.filter1(c,e,tp)
	return c.material 
		and c:IsType(TYPE_FUSION) 
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c,e,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
end
function s.spop(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject(),e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
			if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end