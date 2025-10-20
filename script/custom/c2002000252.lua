--Dark Rebellion Pendulum Dragon
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Special Summon from Pendulum Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DETACH_MATERIAL)
    e1:SetRange(LOCATION_PZONE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
	--Special Summon from hand, GY, or face-up Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Xyz level
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_XYZ_MATERIAL_CUSTOM)
    e4:SetValue(s.val)
    c:RegisterEffect(e4)
end
s.listed_series={SET_ODD_EYES,SET_REBELLION,SET_THE_PHANTOM_KNIGHTS,SET_RANK_UP_MAGIC}
function s.cfilter(c,tp)
    return c:IsControler(tp)
        and (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_REBELLION) or c:IsSetCard(SET_THE_PHANTOM_KNIGHTS)) 
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    -- halve ATK
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(math.floor(tc:GetAttack()/2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        -- -- search Rank-Up-Magic
        -- local sg=Duel.GetMatchingGroup(s.rumfilter,tp,LOCATION_DECK,0,nil)
        -- if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            -- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            -- local tg=sg:Select(tp,1,1,nil)
            -- Duel.SendtoHand(tg,nil,REASON_EFFECT)
            -- Duel.ConfirmCards(1-tp,tg)
        -- end
    end
end
function s.chkval(sg)
	for sc in sg:Iter() do
		if not (sc:IsSetCard(SET_ODD_EYES) or sc:IsSetCard(SET_REBELLION) or sc:IsSetCard(SET_THE_PHANTOM_KNIGHTS)) then
			return false
		end
	end
	return true
end
function s.val(te,xyz,sg)
    --if you want to do something with `sg` later then you must return the expected level if `sg` is nil 
    if not sg then return 4 end
    return s.chkval(sg) and sg and sg:IsContains(te:GetHandler()) and 4 or 0
end
function s.rumfilter(c)
    return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsAbleToHand() 
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.rumfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end