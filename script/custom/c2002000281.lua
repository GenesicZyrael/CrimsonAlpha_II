--Tianniu, the Genex Dracomet
-- Tianniu, the Genex Dracomet
local s,id=GetID()
function s.initial_effect(c)
    -- Enable Pendulum mechanics
    Pendulum.AddProcedure(c)
    -- [Pendulum Effect] Special Summon, name change, and level reduction
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    -- e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
-- [Monster Effect 1] Tribute to Special Summon "Genex Controller"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    -- [Monster Effect 2] Place in Pendulum Zone when Synchro Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE+LOCATION_EXTRA)
    -- e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.pzcon)
    e3:SetTarget(s.pztg)
    e3:SetOperation(s.pzop)
    c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s.tianniu_attr={}
		s.tianniu_attr[0]=0
		s.tianniu_attr[1]=0
		aux.AddValuesReset(function()
			s.tianniu_attr[0]=0
			s.tianniu_attr[1]=0
		end)
	end)
end
s.listed_names={68505803}
-- ==========================================
-- Pendulum Effect: Special Summon & Level Mod
-- ==========================================
function s.pzfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(SET_GENEX) and not c:IsType(TYPE_TUNER) and c:HasLevel()
		and (c:GetAttribute()&~s.tianniu_attr[tp])>0 
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	-- local att=re:GetHandler():GetAttribute()
	-- Debug.Message(att)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.pzfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingTarget(s.pzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.pzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	s.tianniu_attr[tp]=s.tianniu_attr[tp]|g:GetFirst():GetAttribute()
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- This card becomes a DARK monster
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(ATTRIBUTE_DARK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        -- Its name becomes "Genex Controller"
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(68505803)
        c:RegisterEffect(e2)
        local tc=Duel.GetFirstTarget()
        -- Ensure this card has a level greater than 1 to be reduced
        if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:HasLevel() and c:GetLevel()>1 then
            -- Calculate maximum allowed reduction (capped by either target's level or keeping this card at min level 1)
            local max_reduce = math.min(c:GetLevel() - 1, tc:GetLevel())
            if max_reduce > 0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.BreakEffect()
                local t={}
                for i=1, max_reduce do
                    table.insert(t, i)
                end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
                local reduce = Duel.AnnounceNumber(tp, table.unpack(t))
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_UPDATE_LEVEL)
                e3:SetValue(-reduce)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
                c:RegisterEffect(e3)
            end
        end
    end
end

-- ==========================================
-- Monster Effect 1: Special Summon Genex Controller
-- ==========================================
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
    return c:IsCode(68505803) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ==========================================
-- Monster Effect 2: Place in Pendulum Zone
-- ==========================================
function s.synfilter(c,tp)
    if not (c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsControler(tp)) then return false end
    local mg=c:GetMaterial()
    return mg and mg:IsExists(Card.IsSetCard,1,nil,SET_GENEX)
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.synfilter,1,nil,tp)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()) 
            and Duel.CheckPendulumZones(tp) 
    end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckPendulumZones(tp) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
