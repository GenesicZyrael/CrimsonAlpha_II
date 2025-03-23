-- Gem-Knight Angel Quartz
Duel.LoadScript("_load_.lua")
local s,id=GetID()
local params = {nil,nil,function(e,tp,mg) return Group.CreateGroup(),s.fcheck end}
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	-- Allow cards in the Extra Deck and Pendulum Zones as fusion materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetCountLimit(1,{id,0})
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_PZONE+LOCATION_DECK,0)
	e1:SetTarget(s.eeftg)
	e1:SetCondition(s.eefcon)
	e1:SetOperation(s.eefope)
	e1:SetLabelObject({s.extrafil_replacement})
	e1:SetValue(s.eefval)
	c:RegisterEffect(e1)
	--Pendulum Set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e3)
	--Material check
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.valcheck)
	c:RegisterEffect(e6)
end
s.listed_series={SET_GEM_KNIGHT}
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_GEM_KNIGHT)
end
function s.mtfilter(c)
	return c:HasFlagEffect(id)
end
function s.valcheck(e,c)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	if c:GetMaterial():IsExists(s.mtfilter,1,nil) then
		s.eefval(e,c)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.eeftg(e,c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
function s.eefcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	return true
end
function s.extrafil_repl_filter(c,tp)
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	c:RegisterFlagEffect(id,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	return c:IsMonster() and c:IsCanBeFusionMaterial() 
		and c:IsSetCard(SET_GEM_KNIGHT)
end
function s.extrafil_replacement(e,tp,mg)
	local tp=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_DECK,0,nil,tp)
	return g,s.fcheck_replacement
end
function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.eefope(e,fc,tp,rg)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SendtoGrave(fc:GetMaterial(),REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
end
function s.eefval(e,c)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return 0 end
	return 1
end
-- {Monster Effect: Place in Pendulum Zone, then Fusion Summon if possible}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,2))
			and Duel.CheckPendulumZones(tp) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end