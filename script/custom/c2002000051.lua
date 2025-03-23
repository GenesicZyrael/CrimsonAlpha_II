--Dragunity Knight Exallion
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--s/t synchro
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3a:SetCode(CUSTOM_ST_SYNCHRO)
	e3a:SetLabel(id)
	e3a:SetValue(s.synval)
	-- c:RegisterEffect(e3a)
	--s/t synchro: effect gain
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3b:SetRange(LOCATION_PZONE)
	e3b:SetTargetRange(LOCATION_MZONE,0)
	e3b:SetTarget(s.eftg)
	e3b:SetLabelObject(e3a)
	c:RegisterEffect(e3b)
	--Can be treated as a non-Tuner for a Synchro Summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_NONTUNER)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
	--equip itself
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_DECK)
	e5:SetCountLimit(1,{id,0})
	e5:SetCondition(s.eqcon)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(aux.TRUE)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetCode(EVENT_TO_DECK)
	e7:SetTarget(s.pentg)
	e7:SetOperation(s.penop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCondition(aux.TRUE)
	c:RegisterEffect(e8)
	--Atk up
	local eq1=Effect.CreateEffect(c)
	eq1:SetType(EFFECT_TYPE_EQUIP)
	eq1:SetCode(EFFECT_UPDATE_ATTACK)
	eq1:SetValue(500)
	c:RegisterEffect(eq1)
	--indes
	local eq2=Effect.CreateEffect(c)
	eq2:SetType(EFFECT_TYPE_EQUIP)
	eq2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	eq2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	eq2:SetValue(1)
	c:RegisterEffect(eq2)
	--Destruction replacement for the equipped monster
	local eq3=Effect.CreateEffect(c)
	eq3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	eq3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	eq3:SetCode(EFFECT_DESTROY_REPLACE)
	eq3:SetTarget(s.reptg)
	eq3:SetOperation(s.repop)
	c:RegisterEffect(eq3)
end
s.listed_series={SET_DRAGUNITY}
-- {Pendulum Effect: Synchro Summon using Dragunity monsters in the S/T Zone]
function s.eftg(e,c)
	return c:IsType(TYPE_MONSTER) 
		and c:IsSetCard(SET_DRAGUNITY)
end
function s.synval(e,c,sc)
	if c:IsLocation(LOCATION_SZONE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(CUSTOM_ST_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(id)
		e1:SetTarget(s.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function s.chk(c)
	if not c:IsHasEffect(CUSTOM_ST_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(CUSTOM_ST_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()~=id then return false end
	end
	return true
end
function s.chk2(c)
	if not c:IsHasEffect(CUSTOM_ST_SYNCHRO) or c:IsHasEffect(CUSTOM_ST_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(CUSTOM_ST_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==id then return true end
	end
	return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=true
		if sg:IsExists(s.chk,1,c) or (not tg:IsExists(s.chk2,1,c) and not ntg:IsExists(s.chk2,1,c) 
			and not sg:IsExists(s.chk2,1,c)) then return false end
		local trg=tg:Filter(s.chk,nil)
		local ntrg=ntg:Filter(s.chk,nil)
		return res,trg,ntrg
	else
		return true
	end
end
-- {Monster Effect: Special Summon}
function s.costfilter(c,lv)
	local clv=c:GetLevel()
	return clv>0 and clv<lv 
		and c:IsAbleToGraveAsCost() 
		and c:IsSetCard(SET_DRAGUNITY)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local clv=c:GetLevel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		lv=clv-lv
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- {Monster Effect: Equip self}
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) 
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc,true)
		--Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (r&REASON_EFFECT)~=0
		and not c:IsReason(REASON_REPLACE) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(e:GetOwnerPlayer(),c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end