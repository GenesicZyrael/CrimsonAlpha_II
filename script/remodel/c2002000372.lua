--Assault Overload (Custom)
--バスター・バースト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ASSAULT_MODE}
s.listed_names={CARD_ASSAULT_MODE}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,nil,SET_ASSAULT_MODE) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,nil,SET_ASSAULT_MODE)
	e:SetLabel(g:GetFirst():GetLevel()*200)
	Duel.Release(g,REASON_COST)
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_ASSAULT_MODE) and c:HasLevel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res 
		`	and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) 
	end
	-- "If you have 'Assault Mode Activate' in your GY, neither player can activate cards and effects..."
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_ASSAULT_MODE) then
        Duel.SetChainLimit(aux.FALSE)
    end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,e:GetLabel())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local lvl=tc:GetLevel()
        if Duel.Destroy(tc,REASON_EFFECT)>0 and lvl>0 then
            Duel.Damage(tp,lvl*200,REASON_EFFECT,true)
            Duel.Damage(1-tp,lvl*200,REASON_EFFECT,true)
            Duel.RDComplete()
        end
    end
end