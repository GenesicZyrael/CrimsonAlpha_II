-- Clear Wing Pendulum Dragon
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
    -- Continuous: Grant Level 3 Synchro option
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_SINGLE)
	-- e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	-- e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetOperation(s.synop)
	-- c:RegisterEffect(e2)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
    -- Ignition: Special Summon, Negate, and gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

end
s.listed_series={SET_ODD_EYES,SET_CLEAR_WING,SET_SPEEDROID}

function s.pcfilter(c,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SYNCHRO) 
        and (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_CLEAR_WING) or c:IsSetCard(SET_SPEEDROID))
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

function s.synop(e,tg,ntg,sg,lv,sc,tp)
    local c=e:GetHandler()
    local mat={}
    for tc in sg:Iter() do
        table.insert(mat,tc)
    end
    
    -- Recursive function to test every valid level combination
    local function check_level(index, current_sum)
        if index > #mat then
            return current_sum == lv
        end
        
        local tc = mat[index]
        local slv = tc:GetSynchroLevel(sc)
        local l1 = slv & 0xffff -- Base Level
        local l2 = slv >> 16    -- Secondary Level (if it already has another alternate level effect)
        
        local is_valid_target = (tc==c) or tc:IsSetCard(SET_ODD_EYES) or tc:IsSetCard(SET_CLEAR_WING) or tc:IsSetCard(SET_SPEEDROID)
        
        -- Try its original level(s)
        if check_level(index + 1, current_sum + l1) then return true end
        if l2 > 0 and check_level(index + 1, current_sum + l2) then return true end
        
        -- If it is a valid archetype (or this card), try treating it as 3 or 4
        if is_valid_target then
            if check_level(index + 1, current_sum + 3) then return true end
            if check_level(index + 1, current_sum + 4) then return true end
        end
        
        return false
    end
    
    -- Returns the boolean result, and 'true' to tell the engine we bypassed the default check
    return check_level(1, 0), true
end

function s.negfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then 
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) 
			and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) 
	end
    local c=e:GetHandler()
    if chk==0 then 
        local loc_chk = false
        if c:IsLocation(LOCATION_EXTRA) then
            loc_chk = c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        else
            loc_chk = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        end
        return loc_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_EFFECT) and not tc:IsDisabled() then
            -- Negate Target
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
            -- Gain ATK
            local atk=tc:GetBaseAttack()
            if atk>0 then
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_UPDATE_ATTACK)
                e3:SetValue(atk)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e3)
            end
        end
    end
end
