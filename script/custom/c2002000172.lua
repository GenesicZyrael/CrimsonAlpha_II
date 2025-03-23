--Substifusion
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,nil,nil,s.fextra)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.exfilter0(c,e)
	if c:IsPublic() then
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
		e1:SetCondition(s.subcon)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1)
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(id)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
	return c:IsPublic()
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE,0,nil,e)
	if #eg>0 then
		return Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE,0,nil,e)
	end
	return nil
end