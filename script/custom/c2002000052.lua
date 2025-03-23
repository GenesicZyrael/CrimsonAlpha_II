--Dragunity Bayonet
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Add Pseudo-PendulumProc
	Pendulum.PseudoAddProc({handler=c,lscale=7,rscale=7})
	--splimit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_PZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--synchro limit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetValue(s.synlimit)
	c:RegisterEffect(e2)
	--Can be treated as level 3 for a Synchro Summon
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetRange(LOCATION_ONFIELD)
		e3:SetCode(EFFECT_SYNCHRO_LEVEL)
		e3:SetValue(s.slevel)
	c:RegisterEffect(e3)
	--Special Summon itself while it is equipped to a monster
	local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
		e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetRange(LOCATION_SZONE)
		e4:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
		e4:SetTarget(s.sptg)
		e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DRAGUNITY}
-- {Pendulum Summon Restriction: Dragunity}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_DRAGUNITY) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_DRAGUNITY)
end
function s.slevel(e,c)
	return 3<<16|e:GetHandler():GetLevel()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end