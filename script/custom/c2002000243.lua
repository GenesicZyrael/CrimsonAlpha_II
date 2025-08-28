--Nekroz of Arma Gram
local s,id=GetID()
function s.initial_effect(c)	
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	c:AddMustBeRitualSummoned()
	--Equip an opponent's monster destroyed by battle to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.eqpcon)
	e1:SetTarget(s.eqptg)
	e1:SetOperation(s.eqpop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),Card.EquipByEffectAndLimitRegister,e1)
	--ritual material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 end)
	e2:SetValue(1)
	e2:SetTarget(s.mttg)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfDiscard)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local c3=e3:Clone()
	c3:SetRange(LOCATION_MZONE)
	c3:SetCountLimit(1,{id,2})
	c3:SetCondition(aux.NekrozOuroCheck)
	c3:SetCost(Cost.SelfTribute)
	c:RegisterEffect(c3)
	--Negate targeted monster's effects, also loses ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_NEKROZ}
function s.mat_filter(c)
	return c:GetLevel()~=10 
end
function s.mttg(e,c)
	local g=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
	return g:IsContains(c)
end
function s.eqpfilter(c,tp)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsPreviousControler(1-tp) and s.exfilter(c,tp)
end
function s.exfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqpfilter,1,nil,tp)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqg=eg:Filter(s.eqpfilter,nil,tp)
	if chk==0 then 
		return #eqg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#eqg 
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NEKROZ),tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetTargetCard(eqg)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,eqg,#eqg,0,0)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<1 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_NEKROZ),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ec then return end
	local tg=Duel.GetTargetCards(e):Filter(s.exfilter,nil,tp)
	if ec:IsFaceup() and #tg>0 and ft>0 then
		local eqg=nil
		if #tg>ft then
			eqg=tg:Select(tp,ft,ft,nil)
		else
			eqg=tg
		end
		for tc in eqg:Iter() do
			if Duel.Equip(tp,tc,ec,true,true) then
				--Equip limit
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(ec)
				tc:RegisterEffect(e1)
			end
		end
		Duel.EquipComplete()
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NEKROZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.distg(c,eqpc)
	return c:IsNegatableMonster() or (eqpc and c:IsFaceup() and c:GetAttack()>0)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsNegatable() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsNegatable() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		if tc:IsType(TYPE_MONSTER) then
			local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,0,nil)
			if ct>0 then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_UPDATE_ATTACK)
				e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e4:SetValue(-ct*1000)
				e4:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e4)
			end
		end
	end
end