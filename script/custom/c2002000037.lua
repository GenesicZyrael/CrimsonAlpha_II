--Proto Aquamirror
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.GetLevelRankLink(c)
	local lv,rk,lr=c:GetControler()==1 and c:GetLevel() or 0,c:GetControler()==1 and c:GetRank() or 0,c:GetControler()==1 and c:GetLink() or 0
	return lv+rk+lr
end
function s.forcedselection(entire)
	return function(e,tp,sg,sc)
		return #sg==1 and sg:IsContains(entire)
	end
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(function(c) return c:IsControler(1-tp) and eg:IsContains(c) end,tp,0,LOCATION_MZONE,nil)
end
function s.entirefilter(c,e,tp,eg,ep,ev,re,r,rp)
	local params={handler=e:GetHandler(),_type=RITPROC_EQUAL,lv=s.GetLevelRankLink,location=LOCATION_HAND|LOCATION_GRAVE,extrafil=s.extramat,requirementfunc=s.GetLevelRankLink}
	local e1=Ritual.AddWholeLevelTribute(c,aux.TRUE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	params["forcedselection"]=s.forcedselection(c)
	local res=Ritual.Target(params)(e,tp,eg,ep,ev,re,r,rp,0)
	e1:Reset()
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and res
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.entirefilter,1,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local entire=eg:FilterSelect(tp,s.entirefilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	if not entire then return end
	local c=e:GetHandler()
	local params={handler=c,_type=RITPROC_EQUAL,lv=s.GetLevelRankLink,location=LOCATION_HAND|LOCATION_GRAVE,extrafil=s.extramat,requirementfunc=s.GetLevelRankLink}
	local e1=Ritual.AddWholeLevelTribute(entire,aux.TRUE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	params["forcedselection"]=s.forcedselection(entire)
	Ritual.Operation(params)(e,tp,eg,ep,ev,re,r,rp)
	e1:Reset()
end