--True King Cytopathy
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfil,desc=aux.Stringid(id,0)})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e2=Ritual.AddProcGreater({handler=c,filter=s.ritualfil,desc=aux.Stringid(id,1),extrafil=s.extrafil})
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
s.listed_series={0xda}
s.fit_monster={98287529}
s.listed_names={98287529}

function s.costfilter(c)
	return c:IsCode(98287529) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	if Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.ritualfil(c)
	return c:IsSetCard(0xda)
end
function s.mfilter(c,e)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsImmuneToEffect(e) 
		and c:IsReleasable()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.mfilter,tp,0,LOCATION_MZONE,1,nil,e) 
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end