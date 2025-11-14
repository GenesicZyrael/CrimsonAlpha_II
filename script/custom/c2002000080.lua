--Nekroz of Ouroboros
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	c:AddMustBeRitualSummoned()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.remcon)
	e2:SetTarget(s.remtg)
	e2:SetOperation(s.remop)
	c:RegisterEffect(e2)
	--place in pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.pzcon)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NEKROZ}
function s.mat_filter(c)
	return c:GetLevel()~=9
end
function s.filter(c,e,tp)
	if not (c:IsSetCard(SET_NEKROZ) and c:IsMonster() and c:IsType(TYPE_RITUAL)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
		and c:IsHasEffect(id) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()) then 
		return false
	end
	local eff={c:GetCardEffect(id)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		local con=te:GetCondition()
		local tg=te:GetTarget()
		if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then return true end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local eff={tc:GetCardEffect(id)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			local con=temp:GetCondition()
			local tg=temp:GetTarget()
			if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
				and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(ac,teh)
				table.insert(acd,temp:GetDescription())
			end
		end
		if #ac==1 then te=ac[1] elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
		-- local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
end

function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #g1>0 and #g2>0 and #g3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg1=g1:RandomSelect(tp,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:Select(tp,1,1,nil)
		Duel.HintSelection(sg1)
		Duel.SendtoGrave(sg1,REASON_EFFECT)
		Duel.HintSelection(sg2)
		Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		Duel.HintSelection(sg3)
		Duel.Remove(sg3,POS_FACEUP,REASON_EFFECT)
	end
end

function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) 
end
function s.tgfilter(c,tp)
	return c:IsSetCard(SET_NEKROZ) 
		and c:IsType(TYPE_PENDULUM)
		and c:IsPublic()
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local chk=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local ct=aux.GetPendulumZoneCount(tp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA,0,nil,tp)
	if #g<1 and ct>0 and chk then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sg=g:Select(tp,1,ct,nil)
	for tc in aux.Next(sg) do
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end	
end