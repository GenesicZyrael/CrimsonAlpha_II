-- Oukarmada - Hiryuu Kai
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon (Alternative procedure on Hiryuu)
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.mfilter,8,Xyz.InfiniteMats,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)

    -- Must be Xyz Summoned this way
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)
    -- Continuous: Indestructible once per turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetCountLimit(1)
    e1:SetValue(s.valcon)
    c:RegisterEffect(e1)
    -- Ignition: Declare type, reveal, and apply
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetTarget(s.efftg)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_OUKARMADA}
s.listed_names={2002000297, id}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,2002000297)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end
function s.valcon(e,re,r,rp)
    return (r&REASON_BATTLE)~=0 or ((r&REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer())
end

function s.cpfilter(c)
	return c:IsSetCard(SET_OUKARMADA) and c:IsSpellTrap() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
    local declared_type=Duel.AnnounceType(tp)
	-- if declared_type~=0 then 
		-- local g=Duel.GetDecktopGroup(tp,1):Filter(s.cpfilter, nil)
		-- if #g>0 then
			-- -- Duel.SetTargetParam(declared_type)
		-- end
	-- else
		-- -- Duel.SetTargetParam(declared_type)
	-- end
	Duel.SetTargetParam(declared_type)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local declared_type=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    local g=Duel.GetDecktopGroup(tp,1)
    if #g>0 then
        Duel.ConfirmCards(1-tp,g)
        local tc=g:GetFirst()
        local type_match=false
        if declared_type==0 and tc:IsType(TYPE_MONSTER) then type_match=true
        elseif declared_type==1 and tc:IsType(TYPE_SPELL) then 
			type_match=true
        elseif declared_type==2 and tc:IsType(TYPE_TRAP) then 
			type_match=true 
		end


        if tc:IsSetCard(SET_OUKARMADA) and type_match then
            if tc:IsType(TYPE_MONSTER) then
                local b1=tc:IsAbleToHand()
                local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
                if b1 or b2 then
                    local op=0
                    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
                    elseif b1 then op=0
                    else op=1 end
                    if op==0 then
                        Duel.SendtoHand(tc,nil,REASON_EFFECT)
                        Duel.ConfirmCards(1-tp,tc)
                    else
                        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
                    end
                end
            elseif tc:IsType(TYPE_SPELL|TYPE_TRAP) then
				local b1=tc:IsAbleToHand()
                local b2=tc:IsSSetable()
                if b1 or b2 then
                    local op=0
                    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))
                    elseif b1 then op=0
                    else op=1 end
                    if op==0 then
                        Duel.SendtoHand(tc,nil,REASON_EFFECT)
                        Duel.ConfirmCards(1-tp,tc)
                    else
                        Duel.SSet(tp,tc)
                    end
                end
            end
        else
            Duel.ShuffleDeck(tp)
        end
    end
end