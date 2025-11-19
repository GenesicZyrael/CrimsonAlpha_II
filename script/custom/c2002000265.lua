--Crusadia Dragoon
local s,id=GetID()
function s.initial_effect(c)	
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.NOT(Card.IsLinkMonster)),1,99,aux.FilterBoolFunction(Card.IsLinkMonster))
	c:EnableReviveLimit()
	--For this card's Synchro Summon, you can treat 1 "Crusadia" Link monster you control 
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0a:SetCode(EFFECT_SYNCHRO_LEVEL)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0a:SetTarget(s.syntg(1))
	e0a:SetValue(s.synval(1))
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetTarget(s.syntg(2))
	e0b:SetValue(s.synval(2))
	c:RegisterEffect(e0b)
	local e0c=e0a:Clone()
	e0c:SetTarget(s.syntg(3))
	e0c:SetValue(s.synval(3))
	c:RegisterEffect(e0c)
	local e0d=e0a:Clone()
	e0d:SetTarget(s.syntg(4))
	e0d:SetValue(s.synval(4))
	c:RegisterEffect(e0d)
	local e0e=e0a:Clone()
	e0e:SetTarget(s.syntg(5))
	e0e:SetValue(s.synval(5))
	c:RegisterEffect(e0e)
	local e0f=e0a:Clone()
	e0f:SetTarget(s.syntg(6))
	e0f:SetValue(s.synval(6))
	c:RegisterEffect(e0f)
	local e0g=e0a:Clone()
	e0g:SetTarget(s.syntg(7))
	e0g:SetValue(s.synval(7))
	c:RegisterEffect(e0g)
	local e0h=e0a:Clone()
	e0h:SetTarget(s.syntg(8))
	e0h:SetValue(s.synval(8))
	c:RegisterEffect(e0h)
	local e0z=e0a:Clone()
	e0z:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0z:SetValue(function(e,sc) return sc and not sc:IsSetCard(SET_CRUSADIA) end)
	c:RegisterEffect(e0z)
	--Change original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--pos
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)	
end
s.listed_series={SET_CRUSADIA}
function s.syntg(val)
	return function(e,c)
		return c:IsLinkMonster() and c:IsSetCard(SET_CRUSADIA) and c:IsLink(val)
	end
end
function s.synval(val)
	return function(e,sc)
		return sc:IsSetCard(SET_CRUSADIA) and val or -1
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local atk=0
	local def=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		if tc:IsSetCard(SET_CRUSADIA) then
			local a=tc:GetAttack()
			local b=tc:GetDefense()
			if a<0 then a=0 end
			if b<0 then b=0 end
			atk=atk+a
			def=def+b
		end
	end
	if atk>3000 then atk=3000 end
	if def>3000 then def=3000 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(def)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsNegatableMonster() or aux.nzatk(c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,1-tp,LOCATION_MZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(0)
		e2:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		tc:RegisterEffect(e2)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		tc:RegisterEffect(e4)
	end
end