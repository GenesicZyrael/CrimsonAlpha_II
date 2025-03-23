--CCG: Hyper Neo Space
-- "Elemental HERO Neos" and "Neos" Fusion Monsters you control gain 
-- 500 ATK and are unaffected by the effects of Fusion Monsters. This 
-- card is unaffected by the effects of "Neos" Fusion Monsters. "Neos" 
-- Fusion Monsters do not have to activate their effects that return them 
-- into the Extra Deck during the End Phase. If a "Neos" Fusion 
-- Monster you control leaves the field; You can Special Summon the 
-- Fusion Material Monsters listed on that card from your hand, Deck or 
-- GY. You can only use this effect of "Hyper Neo Space" once per turn.
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Immunity: This card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.ImmFld)
	c:RegisterEffect(e1)	
	--ATK Up: E-HERO Neos / Neos Fusion monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.EffTarg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Immunity: E-HERO Neos / Neos Fusion monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.ImmMon)
	c:RegisterEffect(e3)	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.EffTarg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)	
	--Special: Neo Space Effect 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(42015635)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e5)
	--Special Summon: Fusion Materials
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.SPCon)
	e6:SetTarget(s.SPTarg)
	e6:SetOperation(s.SPOpe)
	c:RegisterEffect(e6)
end
s.listed_names={89943723}
function s.EffTarg(e,c)
	return c:IsCode(89943723) 
		or (c:IsSetCard(0x9) and c:IsType(TYPE_FUSION))
end
function s.ImmFld(e,te)
	return te:GetHandler():IsSetCard(0x9)
		and te:IsActiveType(TYPE_FUSION)
end
function s.ImmMon(e,te)
	return te:IsActiveType(TYPE_FUSION) 
		and te:GetOwner()~=e:GetOwner()
end
function s.SPCon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 
		and (tc:IsSetCard(0x9) and tc:IsType(TYPE_FUSION))
		and (tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_FACEUP))
		and tc:GetPreviousControler()==tp
end
function s.SPFilter(c,e,tp)
	return c:IsCode(89943723) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.SPTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.SPFilter,tp,0x13,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function s.SPOpe(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.SPFilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)		
	end	
end