--Zefra Marshalling
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Place in Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.pzcon)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZEFRA}
s.listed_names={29432356}
function s.filter(c,e,tp)
	return (c:IsSetCard(SET_ZEFRA) 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false) 
		and c:IsOriginalType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM))
		or (c:IsCode(29432356)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_PZONE end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if chk==0 then 
		return ( Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp) 
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 )
			or ( Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
				and Duel.GetLocationCountFromEx(tp)>0 )
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_PZONE end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,nil,e,tp):GetFirst()
	if tc:IsCode(29432356) then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
	else
		Duel.SpecialSummon(tc,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)
	end
end
function s.mtfilter(c)
	return c:IsSetCard(SET_ZEFRA) 
		and c:IsType(TYPE_MONSTER)
end
function s.getmats(c,tp)
	return c:GetMaterial():IsExists(s.mtfilter,1,nil) and c:GetControler()==tp
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	if not eg:IsExists(s.getmats,1,nil,tp) then return end
	local tribute_chk=eg:IsExists(s.getmats,1,nil,tp) and eg:GetFirst():IsSummonType(SUMMON_TYPE_TRIBUTE)
	local ritual_chk=eg:IsExists(s.getmats,1,nil,tp) and eg:GetFirst():IsSummonType(SUMMON_TYPE_RITUAL)
	local extra_chk=eg:IsExists(s.getmats,1,nil,tp) and eg:GetFirst():IsPreviousLocation(LOCATION_EXTRA)
	local synchro_chk,xyz_chk,link_chk,fusion_chk,special_chk=false,false,false,false,false
	if not (tribute_chk or ritual_chk or extra_chk) then return end
	if extra_chk or extra_chk~=false then
		-- Extra Deck Mechanics
		synchro_chk= eg:GetFirst():IsSummonType(SUMMON_TYPE_SYNCHRO)
		xyz_chk=eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ)
		link_chk=eg:GetFirst():IsSummonType(SUMMON_TYPE_LINK)
		fusion_chk=eg:GetFirst():IsSummonType(SUMMON_TYPE_FUSION)
		-- Contact Fusion
		if not fusion_chk and eg:GetFirst():IsType(TYPE_FUSION) then
			fusion_chk=extra_chk
		end
		-- Special Summon from Extra Deck using Zefras as fodders
		if not synchro_chk and eg:GetFirst():IsType(TYPE_SYNCHRO) then
			synchro_chk=extra_chk
		end
		if not xyz_chk and eg:GetFirst():IsType(TYPE_XYZ) then
			xyz_chk=extra_chk
		end
		if not link_chk and eg:GetFirst():IsType(TYPE_LINK) then
			link_chk=extra_chk
		end
		-- Zefraath / Zefratorah Metaltron / Odd-Eyes Raging Dragon Tyrant / etc...
		-- 		Main Deck Pendulum Monsters that are Special Summoned from the Extra Deck 
		if not fusion_chk and not synchro_chk and not xyz_chk and not link_chk then
			special_chk=extra_chk
		end
	end
	return tribute_chk or ritual_chk or special_chk
		or fusion_chk or synchro_chk or xyz_chk or link_chk
end
function s.tgfilter(c,tp)
	return c:IsSetCard(SET_ZEFRA) 
		and c:IsType(TYPE_PENDULUM)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local chk=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local ct=aux.GetPendulumZoneCount(tp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g<1 and ct>0 and chk then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sg=g:Select(tp,1,ct,nil)
	for tc in aux.Next(sg) do
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsType(TYPE_PENDULUM) and not c:IsSetCard(SET_ZEFRA) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end	
end