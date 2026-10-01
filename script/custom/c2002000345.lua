-- Majestic Black Dragon
local s,id=GetID()
local CARD_MAJESTIC_DRAGON = 21159309
local CARD_BLACK_WINGED_DRAGON = 9012916
local COUNTER_BLACK_FEATHER = 0x1000+COUNTER_FEATHER
function s.initial_effect(c)
    -- Synchro Summon Procedure
    c:EnableReviveLimit()
    Synchro.AddMajesticProcedure(c,aux.FilterBoolFunction(Card.IsCode,CARD_MAJESTIC_DRAGON),true,aux.FilterBoolFunction(Card.IsCode,CARD_BLACK_WINGED_DRAGON),true,Synchro.NonTuner(nil),false)
	-- Place Black Feather Counters on Synchro Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.ctcon)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
    -- ATK reduction
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    -- Negate effects if ATK/DEF becomes 0
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetTarget(s.distg)
    c:RegisterEffect(e3)
    -- End Phase: Return to Extra Deck, Special Summon, and Burn
    aux.EnableMajesticReturn(c,CATEGORY_DAMAGE,s.burntg,s.burnop,nil)
end
-- Necessary for the Majestic Return helper to identify the base Dragon
s.material={CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.listed_names={CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.synchro_nt_required=1
s.counter_list={COUNTER_FEATHER}
s.counter_place_list={COUNTER_FEATHER}
-- Counter
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end -- Mandatory effect
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_BLACK_FEATHER)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local ct=#g
    if ct>0 then
        for tc in aux.Next(g) do
            tc:AddCounter(COUNTER_BLACK_FEATHER,ct)
        end
    end
end
-- Stat Reduction 
function s.atkval(e,c)
    return c:GetCounter(COUNTER_BLACK_FEATHER)*-700
end
-- Negation 
function s.distg(e,c)
    return c:GetCounter(COUNTER_BLACK_FEATHER)>0 and c:GetAttack()==0
end
-- Return Burn 
function s.cfilter(c)
	return c:GetCounter(COUNTER_BLACK_FEATHER)
end
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for tc in Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Iter() do
		count=count+tc:GetCounter(COUNTER_BLACK_FEATHER)
		tc:RemoveAllCounters()
	end
	if count>0 then
		Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+COUNTER_BLACK_FEATHER,e,REASON_EFFECT,tp,tp,count)
		Duel.Damage(1-tp,count*700,REASON_EFFECT)
	end
end