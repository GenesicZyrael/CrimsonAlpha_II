-- Starving Venom Pendulum Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Enable Pendulum mechanics
    Pendulum.AddProcedure(c)
    -- Trigger: Special Summon from P-Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.pencon)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    -- Continuous: Grant Setcodes and Attribute for Fusion Materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_MATERIAL_CUSTOM)
	e2:SetValue(s.value)			--Define the function that restricts the Fusion Monsters and/or summon types for which the eff is applicable
	e2:SetOperation(s.operation)	--Define the materials that can be "disguised" and the "outfit"		
	c:RegisterEffect(e2)
	-- local e2a = Effect.CreateEffect(c)
	-- e2a:SetType(EFFECT_TYPE_SINGLE)
	-- e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- e2a:SetCode(EFFECT_FUSION_MATERIAL_CUSTOM)
	-- c:RegisterEffect(e2a)
    -- local e2b=Effect.CreateEffect(c)
    -- e2b:SetType(EFFECT_TYPE_FIELD)
    -- e2b:SetCode(EFFECT_ADD_SETCODE)
    -- e2b:SetRange(LOCATION_MZONE)
    -- e2b:SetTargetRange(LOCATION_MZONE,0)
    -- e2b:SetTarget(s.mattg)
    -- e2b:SetValue(SET_ODD_EYES)
    -- e2b:SetOperation(s.chngcon)
    -- c:RegisterEffect(e2b)
    -- local e3=e2b:Clone()
    -- e3:SetValue(SET_STARVING_VENOM)
    -- c:RegisterEffect(e3)
    -- local e4=e2b:Clone()
    -- e4:SetValue(SET_PREDAPLANT)
    -- c:RegisterEffect(e4)
    -- local e5=e2b:Clone()
    -- e5:SetCode(EFFECT_ADD_ATTRIBUTE)
    -- e5:SetValue(ATTRIBUTE_DARK )
    -- c:RegisterEffect(e5)
    -- Ignition: Special Summon (Hand/GY/Extra) and Destroy
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
    e6:SetCountLimit(1,{id,2})
    e6:SetCost(s.spcost)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)

end

s.listed_series={SET_ODD_EYES, SET_PREDAPLANT, SET_STARVING_VENOM}

-- PENDULUM EFFECT
function s.pcfilter(c,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_FUSION) 
        and (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_STARVING_VENOM) or c:IsSetCard(SET_PREDAPLANT))
        and c:IsPreviousControler(tp)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.pcfilter,1,nil,tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- MONSTER EFFECT 1: Property granting 
-- function s.mattg(e,c)
    -- -- local handler = e:GetHandler()
    -- -- if c == handler then return true end
    -- -- -- If the fusion engine is temporarily testing the group without buffs, turn them off
    -- -- if handler:GetFlagEffect(id) > 0 then return false end
    -- -- -- Prevent infinite recursion loops during standard engine checks
    -- -- if c:GetFlagEffect(id+1) > 0 then return false end
    -- -- c:RegisterFlagEffect(id+1,0,0,0)
    -- -- local res = c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_STARVING_VENOM) or c:IsSetCard(SET_PREDAPLANT)
    -- -- c:ResetFlagEffect(id+1)
    -- -- return res
	-- local handler = e:GetHandler()
    -- if c == handler then return true end
    -- -- IMPORTANT: If the engine is currently testing the math without this card, turn the buffs off!
    -- if handler:GetFlagEffect(EFFECT_FUSION_MATERIAL_CUSTOM) > 0 then return false end
    -- -- Standard infinite recursion protection
    -- if c:GetFlagEffect(id) > 0 then return false end
    -- c:RegisterFlagEffect(id,0,0,0)
    -- local res = c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_STARVING_VENOM) or c:IsSetCard(SET_PREDAPLANT)
    -- c:ResetFlagEffect(id)
    
    -- return res
-- end
-- function s.chngcon(scard,sumtype,tp)
	-- return (sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0
-- end

--can be applied for any Fusion Monster (filter is nil), allow Fusion Summons and non-Fusion Summons (as long as the summon treats the materials as Fusion Materials)
--(Fusion.CustomMaterialValue(filter,allow_contact,allow_notfusion))
s.value=Fusion.CustomMaterialValue(nil,true,true)

--[[If you want, you can restrict the effect to specific Fusion Monsters only.
For instance, if you want the effect to be: If this card is used as Fusion Material for the Summon of a DARK monster, ...

function s.fusfilter(fc,e,tp)
	return fc:IsAttribute(ATTRIBUTE_DARK)
end
s.value=Fusion.CustomMaterialValue(nil,true,true)
]]

--Filter for the materials that can be "disguised" with the DARK Odd-Eyes/Starving-Venom/Predaplant "outfit"
function s.affectedfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard({SET_ODD_EYES,SET_STARVING_VENOM,SET_PREDAPLANT})
end

--operation(e,fc,g,sumtype,tp,contact) -> affected,outfit
function s.operation(e,fc,g,sumtype,tp,contact)
	local affected=g:Filter(s.affectedfilter,nil,tp)
	affected:AddCard(e:GetHandler())	--include "this card" as well among the materials that can be "disguised"
	local outfit={
		change_attribute=ATTRIBUTE_DARK,
		change_setcode={SET_ODD_EYES,SET_STARVING_VENOM,SET_PREDAPLANT}
	}
	return affected, outfit
end

--[[
Equivalently, you can define the outfit using a custom builder function to have more control over it.
function s.operation(e,fc,g,sumtype,tp,contact)
	local affected=g:Filter(s.affectedfilter,nil,tp)
	affected:AddCard(e:GetHandler())
	return affected,s.outfit
end
function s.outfit(e,c,fc,sumtype,tp,contact)
	local handler=e:GetHandler()
	local list={}
	local o1=Effect.CreateEffect(handler)
	o1:SetType(EFFECT_TYPE_SINGLE)
	o1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	o1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	o1:SetValue(ATTRIBUTE_DARK)
	table.insert(list,o1)
	for i,set in ipairs({SET_ODD_EYES,SET_STARVING_VENOM,SET_PREDAPLANT}) do
		local ecode=i==1 and EFFECT_CHANGE_SETCODE or EFFECT_ADD_SETCODE
		local o2=o1:Clone()
		o2:SetCode(ecode)	--one effect per archetype
		o2:SetValue(set)
		table.insert(list,o2)
	end
	return list
end
]]

-- MONSTER EFFECT 2: Special Summon & Destroy
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_PREDATOR,1,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,COUNTER_PREDATOR,1,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        local loc_chk = false
        if c:IsLocation(LOCATION_EXTRA) then
            loc_chk = c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        else
            loc_chk = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        end
        return loc_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            Duel.HintSelection(sg)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end