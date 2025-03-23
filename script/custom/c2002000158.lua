--Grim Pact with Exodia
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c) 
	local e1=Ritual.AddProcGreater{handler=c,
								   filter=aux.FilterBoolFunction(Card.IsCode,2002000171),
								   extrafil=s.extrafil,
								   stage2=s.stage2,
								   -- extraop=s.extraop,
								   forcedselection=s.rcheck,
								   location=LOCATION_HAND|LOCATION_GRAVE,
								   extratg=s.extratg}						   
end
s.listed_names={2002000171}
s.listed_series={SET_FORBIDDEN_ONE,SET_EXODIA}
function s.lvtg(e,c)
	return c:IsLevelAbove(1) 
		and c:IsOriginalSetCard(SET_FORBIDDEN_ONE)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	local tp=e:GetHandler():GetControler()
	if Duel.IsPlayerAffectedByEffect(tp,id) then
		return 2<<16|lv
	else
		return lv
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.fexfilter(c)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsAbleToGrave() 
end
function s.rcheck(e,tp,sg,fc)
	local c=e:GetHandler()
	local i=Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)
	if Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)>=2 then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=i
	end
	return 0
end
function s.extrafil(e,tp,mg)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)>=2 then
		local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg
		end
	end
	return nil
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp,sc)
	local matk=mg:Filter(Card.IsOriginalSetCard,nil,SET_FORBIDDEN_ONE)
	local atk=0
	for tc in aux.Next(matk) do
		local catk=tc:GetTextAttack()
		-- local cdef=tc:GetTextDefense()
		atk=atk+(catk>=0 and catk or 0)
			   -- +(cdef>=0 and cdef or 0)
	end
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	sc:RegisterEffect(e1)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
		c:SetCardTarget(tc)
		--Cannot Special Summon from the Extra Deck, except "Exodia" monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(_,c) return not c:IsSetCard(SET_EXODIA) and c:IsLocation(LOCATION_EXTRA) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--Clock Lizard check
		aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsSetCard(SET_EXODIA) end)
	end
end