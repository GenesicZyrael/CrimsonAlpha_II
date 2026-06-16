-- Elemental HERO Fusion
local s,id=GetID()
function s.initial_effect(c)
    -- This card's name is always treated as "Polymerization"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(CARD_POLYMERIZATION)
	c:RegisterEffect(e0)
    -- Activate: Fusion Summon 1 "Elemental HERO"
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_ELEMENTAL_HERO),nil,s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
end
s.listed_names={20721928,21844576,79979666,84327329,89252153,58932615}
s.listed_series={SET_ELEMENTAL_HERO}
function s.fcheck(tp,sg,fc)
	local matcount=0
	local mats=fc.material
	if not mats then return false end
    for _,code in ipairs(mats) do
		if sg:IsExists(Card.IsCode,1,nil,code) then 
			matcount = matcount+1
		end
    end
	return fc:IsSetCard(SET_ELEMENTAL_HERO) 
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=2
		and matcount == #mats
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
	if eg and #eg>0 then
		return eg,s.fcheck
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:IsSetCard(SET_ELEMENTAL_HERO)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local off=1
		local ops={}
		local opval={}
		local mats=tc:GetMaterial()
		local code=nil
		if not mats then return false end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then 
			ops[off]=aux.Stringid(id,1)
			opval[off-1]=1
			off=off+1
		end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) then 
			ops[off]=aux.Stringid(id,2)
			opval[off-1]=2
			off=off+1
		end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then 
			ops[off]=aux.Stringid(id,3)
			opval[off-1]=3
			off=off+1
		end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then 
			ops[off]=aux.Stringid(id,4)
			opval[off-1]=4
			off=off+1
		end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) then 
			ops[off]=aux.Stringid(id,5)
			opval[off-1]=5
			off=off+1
		end
		if mats:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) then 
			ops[off]=aux.Stringid(id,6)
			opval[off-1]=6
			off=off+1
		end
		if off==1 then return end
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			code=21844576
		elseif opval[op]==2 then
			code=58932615
		elseif opval[op]==3 then
			code=79979666
		elseif opval[op]==4 then
			code=84327329
		elseif opval[op]==5 then
			code=20721928
		elseif opval[op]==6 then
			code=89252153
		end
		if not code then return false end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
