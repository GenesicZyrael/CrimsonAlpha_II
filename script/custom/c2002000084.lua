--Resolve of Zefra
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_ZEFRA))
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Prevent effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Cannot be destroyed by the opponent's card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.fcond)
	e5:SetCountLimit(1)
	e5:SetTarget(Fusion.SummonEffTG())
	e5:SetOperation(Fusion.SummonEffOP())
	c:RegisterEffect(e5)
end
s.listed_series={SET_ZEFRA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ZEFRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
function s.atkval(e,c)
	local tp=e:GetHandler():GetOwner()
	local val=aux.GetPendulumScaleSum(tp) + aux.GetPendulumScaleSum(1-tp)
	return val*100
end
function s.fcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():IsControler(tp)
end
function s.forcedmat(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():GetEquipTarget()
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA|LOCATION_REMOVED)<=1
end
function s.extrafil(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_ZEFRA) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA|LOCATION_REMOVED,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA|LOCATION_REMOVED) and c:IsMonster() and c:IsPublic() 
		and c:IsSetCard(SET_ZEFRA) and c:IsAbleToHand()
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.exfilter,nil)
	if #rg>0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_ZEFRA) then
		Duel.SendtoHand(rg,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end