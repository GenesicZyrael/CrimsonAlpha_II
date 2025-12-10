--Zefratellarknight Sefer Draxciton
local s,id=GetID()
function s.initial_effect(c)	
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats,nil,nil,s.xyzcheck)
	c:AddMustFirstBeXyzSummoned()	
	--Treat "tellarknight" & "Zefra" monsters as Level 8 for this card's Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsLevelBelow(6) and c:IsSetCard({SET_TELLARKNIGHT,SET_ZEFRA}) end)
	e0:SetValue(s.lvval)
	c:RegisterEffect(e0)
	--When detaching a card: return cards on field and GY to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Destroy all other cards your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_SPSUMMON,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(aux.CostWithReplace(Cost.DetachFromSelf(2),CARD_CONSTELLARKNIGHT_TROIVERNUM))
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--place in Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.listh_series={SET_TELLARKNIGHT,SET_ZEFRA}
function s.xyzfilter(c,xyz,tp)
	return c:IsSetCard({SET_TELLARKNIGHT,SET_ZEFRA})
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT) end,nil)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc:IsCode(id) then
		return 8
	else
		return lv
	end
end
function s.thfilter(c,re,tp)
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY) and c:IsSetCard({SET_TELLARKNIGHT,SET_ZEFRA})
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thfilter,1,nil,re,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and c:IsRelateToEffect(e) then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsXyzSummoned()
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