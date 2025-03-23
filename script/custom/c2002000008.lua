--Aussa the Terrene Charmer
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xbf),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,aux.TRUE,1)

end
s.material_setcode={0xbf}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCostAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,nil,nil,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

