--バスター・モード
--Modified for CrimsonAlpha

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=AssaultMode.CreateProc(c,LOCATION_DECK)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
s.listed_series={0x104f}