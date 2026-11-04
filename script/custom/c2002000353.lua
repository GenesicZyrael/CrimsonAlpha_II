-- Doriado, Elemental Divinity of the Voiceless Voice
local s,id=GetID()
local CARD_BENEVOLENCE = 2002000354
local CARD_LO = 25801745
function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    -- 1. Becomes a Warrior while in hand or GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetRange(LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
    e2:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e2)
    -- 2. Quick Effect: Declare Attributes
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.atttg)
    e3:SetOperation(s.attop)
    c:RegisterEffect(e3)
    -- 3a. Trigger Effect: ATK/DEF 0 and Negate on Special Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.discon)
    e4:SetTarget(s.distg)
    e4:SetOperation(s.disop)
    c:RegisterEffect(e4)
	-- 3b. Trigger Effect: ATK/DEF 0 and Negate on Effect Activation
    local e5=e4:Clone()
    e5:SetCode(EVENT_CHAINING)
    e5:SetCondition(s.discon2)
    e5:SetTarget(s.distg2)
    e5:SetOperation(s.disop2)
    c:RegisterEffect(e5)
end
s.listed_names={CARD_BENEVOLENCE,CARD_LO}
s.listed_series={SET_VOICELESS_VOICE}

function s.plcfilter1(c)
	return c:IsCode(CARD_BENEVOLENCE)
end
function s.plcfilter2(c)
	return c:IsSetCard(SET_VOICELESS_VOICE) and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS)
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(s.plcfilter1,1,nil) and sg:IsExists(s.plcfilter2,1,nil))
end
function s.penfilter(c)
    return c:IsAbleToDeck() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
		return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,c)
			and ((Duel.IsExistingMatchingCard(s.plcfilter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
				and not Duel.GetFieldCard(tp,LOCATION_FZONE,0))
				or Duel.IsExistingMatchingCard(s.plcfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)) 
		end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,1,c)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plcfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plcfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		if not Duel.GetFieldCard(tp,LOCATION_FZONE,0) then g1:Merge(g2) else g1=g2 end
		if #g1>0 then 
			local tg=aux.SelectUnselectGroup(g1,e,tp,1,2,s.rescon,1,tp,HINTMSG_TOFIELD)
			local tc=tg:GetFirst()
			for tc in aux.Next(tg) do
				if tc:IsCode(CARD_BENEVOLENCE) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) then 
					Duel.PlaceFieldSpell(tc,tp) 
				else
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
				end
			end
			if c:IsRelateToEffect(e) then
				Duel.Destroy(c,REASON_EFFECT)
			end
        end
    end
end

function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LO),tp,LOCATION_ONFIELD,0,1,nil)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.stfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_VOICELESS_VOICE) and c:IsSpellTrap()
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_SZONE,0,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    -- Count face-up Voiceless Voice Spells/Traps
    local ct=Duel.GetMatchingGroupCount(s.stfilter,tp,LOCATION_SZONE,0,nil)
    if ct>0 then
		for i=1,ct,1 do 
			local att=c:AnnounceAnotherAttribute(tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_ATTRIBUTE)
			e1:SetValue(att)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
		end
    end
end

function s.lofilter(c)
    return c:IsFaceup() and c:IsCode(CARD_LO)
end
function s.apply_debuff(c,tc)
	-- ATK/DEF become 0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	tc:RegisterEffect(e2)
	-- Negate effects
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	e4:SetValue(RESET_TURN_SET)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e4)
end

function s.sumfilter(c,att,tp)
    return c:IsControler(1-tp) and (c:GetAttribute()& att)~=0
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local att=c:GetAttribute()
    return Duel.IsExistingMatchingCard(s.lofilter,tp,LOCATION_ONFIELD,0,1,nil)
        and eg:IsExists(s.sumfilter,1,nil,att,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end 
    local c=e:GetHandler()
    local att=c:GetAttribute()
    local g=eg:Filter(s.sumfilter,nil,att,tp)
    Duel.SetTargetCard(g)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    local c=e:GetHandler()
    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsCode(id) then
			s.apply_debuff(c,tc)
        end
    end
end

function s.discon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    local att=c:GetAttribute()
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE)
        and (rc:GetAttribute() & att)~=0
        and Duel.IsExistingMatchingCard(s.lofilter,tp,LOCATION_ONFIELD,0,1,nil)
		and not rc:IsCode(id) 
end
function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetCard(re:GetHandler())
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        s.apply_debuff(c,tc)
    end
end