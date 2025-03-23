Duel.GetFusionMaterial=(function()
	local oldfunc=Duel.GetFusionMaterial
	return function(tp)
		local res=oldfunc(tp)
		local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_DECK,0,nil,EFFECT_EXTRA_FUSION_MATERIAL)
		if #g>0 then
			res:Merge(g)
		end
		return res
	end
end)()

Duel.ConfirmDecktop=(function()
	local oldfunc=Duel.ConfirmDecktop
	return function(tp,count)
		local res=oldfunc(tp,count)
		local deckg=Duel.GetDecktopGroup(tp,count)
		local eg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,nil,EVENT_DECKTOP_CONFIRM)
		if #deckg>0 then
			for tc in deckg:Iter() do
				Duel.RegisterFlagEffect(tp,tc:GetCode()+EVENT_CUSTOM,RESET_PHASE|PHASE_END,0,1)
			end
			eg:Merge(deckg)
			Duel.RaiseEvent(eg,EVENT_DECKTOP_CONFIRM,nil,0,tp,tp,0)
		end
		return deckg
	end
end)()

Card.GetLocation=(function()
	local oldf=Card.GetLocation
	return function(c)
		if c:HasFlagEffect(PSEUDO_CARD_FLAG) then
			return c:GetFlagEffectLabel(MATERIAL_COUNT_LOCATION_FLAG)
		end
		return oldf(c)
	end
end)()
Card.IsLocation=(function()
	local oldf=Card.IsLocation
	return function(c,location)
		if c:HasFlagEffect(PSEUDO_CARD_FLAG) then
			return c:GetFlagEffectLabel(MATERIAL_COUNT_LOCATION_FLAG)&location>0
		end
		return oldf(c,location)
	end
end)()

regeff_list={}
regeff_list[REGISTER_FLAG_DETACH_XMAT]=511002571
regeff_list[REGISTER_FLAG_CARDIAN]=511001692
regeff_list[REGISTER_FLAG_THUNDRA]=12081875
regeff_list[REGISTER_FLAG_ALLURE_LVUP]=511310036
regeff_list[REGISTER_FLAG_TELLAR]=58858807
regeff_list[REGISTER_FLAG_DRAGON_RULER]=101208047

regeff_list[CUSTOM_REGISTER_FLIP]=TYPE_FLIP
regeff_list[CUSTOM_REGISTER_LIMIT]=EFFECT_UNIQUE_CHECK
regeff_list[CUSTOM_REGISTER_ZEFRA]=2002000083
Card.RegisterEffect=(function()
	local oldf=Card.RegisterEffect
	return function(c,e,forced,...)
		local reg_e=oldf(c,e,forced)
		if not reg_e or reg_e<=0 then return reg_e end
		local resetflag,resetcount=e:GetReset()
		for _,val in ipairs{...} do
			local code=regeff_list[val]
			if code then
				local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
				if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
				e2:SetCode(code)
				e2:SetLabelObject(e)
				e2:SetLabel(c:GetOriginalCode())
				if resetflag and resetcount then
					e2:SetReset(resetflag,resetcount)
				elseif resetflag then
					e2:SetReset(resetflag)
				end
				c:RegisterEffect(e2)
			end
		end
		return reg_e
	end
end)()
