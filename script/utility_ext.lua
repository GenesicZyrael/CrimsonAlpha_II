function Card.HasMultipleRaces(c)
    if not c:IsMonster() then return false end
    local races=c:GetRace()
    return races>0 and races&(races-1)~=0
end
function Card.GetExtraMonsterType(c)
  local extra_type = TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK
  local result = c:GetType()&extra_type
  return result
end
--Check if a card is "pseudo", i.e. created for use with EFFECT_FUSION_MATERIAL_COUNT
--if uid is passed then check if the card has that uid
function Card.IsPseudo(c,uid)
	if not c:HasFlagEffect(PSEUDO_CARD_FLAG) then return false end
	if uid then
		return c:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)==uid
	end
	return true
end
--Check if a card is not "pseudo", i.e. not created for use with EFFECT_FUSION_MATERIAL_COUNT
--if uid is passed then check if the card has that uid
function Card.IsNotPseudo(c,uid)
	if not c:HasFlagEffect(NOT_PSEUDO_CARD_FLAG) then return false end
	if uid then
		return c:GetFlagEffectLabel(NOT_PSEUDO_CARD_FLAG)==uid
	end
	return true
end
local function CheckEffectUniqueCheck(c,tp,code)
	if not (aux.FaceupFilter(Card.IsCode,code) and c:IsHasEffect(EFFECT_UNIQUE_CHECK)) then 
		return false
	end
	return true
end
local function AdjustOp(self,opp,limit,code,location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local phase=Duel.GetCurrentPhase()
		local rm=Group.CreateGroup()
		if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
		if self then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,location,0,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,location,0,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if opp then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,0,location,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,0,location,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if #rm>0 then			
			Duel.SendtoGrave(rm,REASON_RULE)
			Duel.Readjust()
		end
	end
end
local function SummonLimit(limit,code,location)
	return function(e,c,sump,sumtype,sumpos,targetp)
		if not c:IsCode(code) then return false end
		local g=Duel.GetMatchingGroupCount(CheckEffectUniqueCheck,targetp or sump,location,0,1,targetp or sump,code) 
		if g>0 then
			local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,code),targetp or sump,location,0,1)
			return g>limit-1
		end
	end
end
-- Sets the max number of copies the card(code) can have on the field
function Card.SetLimitOnField(c,limit,code,location,self,opp)
	if not limit then limit=1 end
	if not location then location=LOCATION_ONFIELD end	
	if not code then code=c:GetCode() end
	if not self then self=true end
	if not opp then opp=false end
	--Adjust
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(location)
	e1:SetOperation(AdjustOp(self,opp,limit,code,location))
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_LIMIT)
	c:RegisterFlagEffect(CUSTOM_REGISTER_LIMIT,RESET_DISABLE,0,1,3)
	--Cannot Normal/Flip/Special Summon from location
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(SummonLimit(limit,code,location))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
end
-- Returns the max number of copies the card can have on the field
function Card.GetMaxLimitForCard(c)
	return c:GetFlagEffectLabel(CUSTOM_REGISTER_LIMIT)
end
function Auxiliary.CheckEffectUniqueCheck(c,tp,code)
	if not (aux.FaceupFilter(Card.IsCode,code) and c:IsHasEffect(EFFECT_UNIQUE_CHECK)) then 
		return false
	end
	return true
end
function Auxiliary.CheckLimitForCard(tp,code)
	return Duel.IsExistingMatchingCard(aux.CheckEffectUniqueCheck,tp,LOCATION_ALL,0,1,nil,tp,code)
end
-- Returns the max number of copies the card with code can have on the field
function Auxiliary.GetMaxLimitForCard(tp,code,location)
	if not location then location=LOCATION_ALL end	
	local c=Duel.GetMatchingGroup(aux.CheckEffectUniqueCheck,tp,location,0,nil,tp,code):GetFirst()
	if c then return c:GetMaxLimitForCard() end
	return 99
end
-- Returns the number of copies the field can have of a specific card
	-- tp 	    = Target Player
	-- code     = current Card ID
	-- onfield  = flag for checking LOCATION_ONFIELD or LOCATION_ALL
	-- location = if flag for onfield is not met, it will check for the location mentioned
function Auxiliary.GetLimitForCardCount(tp,code,onfield,location)
	if not location then location=LOCATION_ONFIELD end	
	if onfield then 
		onfield=LOCATION_ONFIELD 
	else
		onfield=LOCATION_ALL 
		location=LOCATION_ALL 
	end	
	local max=aux.GetMaxLimitForCard(tp,code,onfield)
	local chk=Duel.IsExistingMatchingCard(aux.CheckEffectUniqueCheck,tp,location,0,1,nil,tp,code)
	if chk then  
		local ct=max-Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,code),tp,LOCATION_MZONE,0,nil)
		return ct
	end
	return max
end
-- Returns Pendulum Zone Location Count for player(tp)
function Auxiliary.GetPendulumZoneCount(tp)
	local ct=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct + 1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct + 1 end
	return ct
end
-- Return summon type of e
function Auxiliary.IsSummonType(sumtype)
	return function(e)
		return e:GetHandler():IsSummonType(sumtype)
	end
end
-- Return the Sum of all Pendulum Scales of tp
function Auxiliary.GetPendulumScaleSum(tp)
	local val=0
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) then val=val+Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale() end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,1) then val=val+Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale() end
	return val
end
function Auxiliary.GetTypeStrings(v)
	local t = {
		[TYPE_RITUAL]  = 1057,
        [TYPE_FUSION]  = 1056,
		[TYPE_SYNCHRO] = 1063,
		[TYPE_XYZ]     = 1073,
		[TYPE_LINK]    = 1076
	}
	local res={}
	local ct=0
	for _,type in aux.BitSplit(v) do
		if t[type] then
			table.insert(res,t[type])
			ct=ct+1
		end
	end
	return pairs(res)
end
function Auxiliary.GetSummonType(c)
	local summon_type_table=
	{
		[TYPE_RITUAL]   = SUMMON_TYPE_RITUAL,
		[TYPE_FUSION]   = SUMMON_TYPE_FUSION,
		[TYPE_SYNCHRO]  = SUMMON_TYPE_SYNCHRO,
		[TYPE_XYZ]      = SUMMON_TYPE_XYZ,
		[TYPE_PENDULUM] = SUMMON_TYPE_PENDULUM,
		[TYPE_LINK]     = SUMMON_TYPE_LINK
	}
	local summon_type = summon_type_table[c:GetExtraMonsterType()]
	if not summon_type then
		summon_type = 0
	end
	return summon_type
end
function Auxiliary.GetReasonType(c)
	local reason_type_table=
	{
		[TYPE_RITUAL]  = REASON_RITUAL,
		[TYPE_FUSION]  = REASON_FUSION,
		[TYPE_SYNCHRO] = REASON_SYNCHRO,
		[TYPE_XYZ]     = REASON_XYZ,
		[TYPE_LINK]    = REASON_LINK
	}
	local reason_type = reason_type_table[c:GetExtraMonsterType()]
	if not reason_type then
		reason_type = 0
	end
	return reason_type
end
-- Used to get columns other than the column of (card|group)
-- (int left|nil): left column
-- (int right|nil): right column
function Auxiliary.GetOtherColumnGroup(c_or_group,left,right)
	local result=Group.CreateGroup()
	if c_or_group then
		if type(c_or_group)=="Group" then
			for tc in aux.Next(c_or_group) do
				local seq=tc:GetColumnGroup(left,right)-tc:GetColumnGroup()
				result:AddCard(seq)
			end
			return result
		elseif type(c_or_group)=="Card" then
			local seq=c_or_group:GetColumnGroup(left,right)-c_or_group:GetColumnGroup()
			result:AddCard(seq)
			return result
		end
	else
		return nil
	end
end
