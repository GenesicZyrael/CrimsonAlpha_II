--Dimension Dice Magician
Duel.LoadScript("_load_.lua")
local s,id=GetID()
local sid=300102004
function s.initial_effect(c)
	c:SetUniqueOnField(1,1,id)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
	--addtohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--chooose die result
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_TOSS_DICE_CHOOSE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation("dice",Duel.GetDiceResult,Duel.SetDiceResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(sid,3)) return Duel.AnnounceNumber(tp,1,2,3,4,5,6) end))
	c:RegisterEffect(e2)
	--choose coin result
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TOSS_COIN_CHOOSE)
	e3:SetOperation(s.operation("coin",Duel.GetCoinResult,Duel.SetCoinResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(sid,4)) return Duel.AnnounceCoin(tp) end))
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c.roll_dice or c.toss_coin and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.matfilter(c)
	return c.roll_dice or c.toss_coin
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)==0 
		and ep==tp
end
function s.operation(typ,func1,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local dc={func1()}
		local ct=(ev&0xff)+(ev>>16)
		local val=2
		local idx=1
		local tab={}
		if Duel.GetFlagEffect(ep,id)>0 then return end
		if Duel.SelectEffectYesNo(ep,e:GetHandler()) then
			Duel.Hint(HINT_CARD,0,id)
			Duel.SetLP(ep,Duel.GetLP(ep)-2000)
			Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
			if ct>1 then
				if typ=="dice" then
					Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(sid,1))
					val=6
				else
					Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(sid,2))
				end
				for i=1,ct do
					table.insert(tab,aux.Stringid(id,i))
				end
				-- for i=1,val do
					-- dc[i]=math.abs(math.random(val))
				-- end
				idx=Duel.SelectOption(ep,table.unpack(tab))
				idx=idx+1
			end
			dc[idx]=func3(ep)
			func2(table.unpack(dc))
		else
			if typ=="dice" then
				val=6
				idx=0
			end
			for i=1,val do
				max_val=math.abs(math.random(val))-idx
			end
			-- -- func2(table.unpack(val))
			func2(max_val)
		end
	end
end