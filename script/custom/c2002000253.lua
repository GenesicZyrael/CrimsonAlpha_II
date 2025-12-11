--El Shaddoll Zefracoreaver
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Fusion
	Fusion.AddProcMixN(c,true,true,s.ffilter1,1,s.ffilter2,1,s.ffilter3,1)
	c:AddMustFirstBeFusionSummoned()
	--Negate 1 face-up card, then change the scales of your "Zefra" cards in the Pendulum Zone to 0 & 12
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Lingering Floodgate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.Condition)
	e2:SetTarget(s.Target)
	e2:SetOperation(s.Operation)
	c:RegisterEffect(e2)
	--Set 1 "Shaddoll" or "Zefra" Spell/Trap, then place this card in the Pendulum Zone
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_TO_DECK)
	e3a:SetRange(LOCATION_EXTRA)
	-- e3a:SetCountLimit(1,{id,2})
	e3a:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
	e3a:SetTarget(s.plctg)
	e3a:SetOperation(s.plcop)
	c:RegisterEffect(e3a)
	-- local e3b=e3a:Clone()
	-- e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- e3b:SetRange(LOCATION_MZONE)
	-- e3b:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	-- c:RegisterEffect(e3b)
end
s.listed_series={SET_SHADDOLL,SET_ZEFRA}
--Material Check
function s.ffilter1(c,fc,sumtype,sp,sub,mg,sg,set)
	return c:IsSetCard(SET_SHADDOLL,fc,sumtype,sp) 
		and (not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp))
end 
function s.ffilter2(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsSetCard(SET_ZEFRA,fc,sumtype,sp) 
		and (not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp))
end
function s.ffilter3(c,fc,sumtype,sp,sub,mg,sg)
	return (not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp))
end
--E1: Negate 1 face-up card, then change the scales of your "Zefra" cards in the Pendulum Zone to 0 & 12
function s.disfilter(c)
	return c:IsSetCard({SET_SHADDOLL,SET_ZEFRA}) and c:IsMonster() and c:IsReason(REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.disfilter,1,nil) 
end
function s.distgfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.distgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.distgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.distgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() and tc:IsControler(1-tp) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CHANGE_LSCALE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_PZONE,0)
		e3:SetValue(s.scval(0))
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CHANGE_RSCALE)
		e4:SetValue(s.scval(12))
		Duel.RegisterEffect(e4,tp)
	end
end
function s.scval(val)
	return function(e,c)
		local tp=e:GetHandler():GetControler()
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ZEFRA),tp,LOCATION_PZONE,0,nil)
		if ct==2 and not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then 
			return val 
		else
			if val==1 and not Duel.CheckLocation(tp,LOCATION_PZONE,0) then 
				return Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()
			end
			if val==9 and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then 
				return Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale()
			end
		end
	end
end
--E2: Lingering Floodgate
function s.mtfilter(c)
	return c:IsSetCard(SET_ZEFRA) 
		and c:IsType(TYPE_MONSTER)
end
function s.getmats(c,tp)
	return c:GetMaterial():IsExists(s.mtfilter,1,nil) and c:GetControler()==tp
end
function s.Condition(e,tp,eg,ep,ev,re,r,rp)
	if not eg:IsExists(s.getmats,1,nil,tp) or eg:IsContains(e:GetHandler()) then return end
	local ritual_chk=eg:IsExists(s.getmats,1,nil,tp) and eg:GetFirst():IsSummonType(SUMMON_TYPE_RITUAL)
	local extra_chk=eg:IsExists(s.getmats,1,nil,tp) and eg:GetFirst():IsPreviousLocation(LOCATION_EXTRA)
	local synchro_chk,xyz_chk,link_chk,fusion_chk,special_chk=false,false,false,false,false
	if not (ritual_chk or extra_chk) then return end
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
		-- Zefraath / Zefratorah Metaltron / Odd-Eyes Raging Dragon Tyrant / etc...
		-- 		Main Deck Pendulum Monsters that are Special Summoned from the Extra Deck 
		if not fusion_chk and not synchro_chk and not xyz_chk and not link_chk then
			special_chk=extra_chk
		end
	end
	return ritual_chk or special_chk
		or fusion_chk or synchro_chk or xyz_chk or link_chk
end
function s.tgfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsPublic() and c:IsMonster())) 
		and (c:IsSetCard(SET_ZEFRA) or c:IsSetCard(SET_SHADDOLL)) and c:IsAbleToGrave() 
end
function s.Target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		local ctype=nil
		local sid=0
		if eg:GetFirst():IsType(TYPE_RITUAL)  then sid=4 ctype=TYPE_RITUAL	end
		if eg:GetFirst():IsType(TYPE_FUSION)  then sid=5 ctype=TYPE_FUSION	end
		if eg:GetFirst():IsType(TYPE_SYNCHRO) then sid=6 ctype=TYPE_SYNCHRO	end
		if eg:GetFirst():IsType(TYPE_XYZ) 	  then sid=7 ctype=TYPE_XYZ  	end
		if eg:GetFirst():IsType(TYPE_LINK)	  then sid=8 ctype=TYPE_LINK 	end
		if ctype~=nil then
			--Cannot Special Summon monsters of the declared type
			local r1=Effect.CreateEffect(c)
			r1:SetDescription(aux.Stringid(id,sid))
			r1:SetType(EFFECT_TYPE_FIELD)
			r1:SetRange(LOCATION_MZONE)
			r1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			r1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			r1:SetTargetRange(0,1)
			r1:SetTarget(s.sumlimit(ctype))
			r1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_STANDBY,2)
			c:RegisterEffect(r1)
		end
	end
end
function s.sumlimit(ctype)
	return function(e,c,sump,sumtype,sumpos,targetp)
		if c:IsMonster() then
			return c:IsType(ctype)
		else
			return c:IsOriginalType(ctype)
		end
	end
end
--E3: Set 1 "Shaddoll" or "Zefra" Spell/Trap, then place this card in the Pendulum Zone
function s.plcfilter(c,tp)
	return c:IsSetCard({SET_SHADDOLL,SET_ZEFRA}) and c:IsSpellTrap() and c:IsSSetable()
end
function s.plctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.plcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.plcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 then
		if aux.GetPendulumZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			Duel.BreakEffect()
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end
	end
end