Pendulum.PseudoAddProc = aux.FunctionWithNamedArgs(
function(c,desc,lscale,rscale)
	local e1=Effect.CreateEffect(c)
		if desc then
			e1:SetDescription(desc)
		else
			e1:SetDescription(1074)
		end
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
		e1:SetTarget(Pendulum.PseudoTarget())
		e1:SetOperation(Pendulum.PseudoOperation(lscale,rscale))
	c:RegisterEffect(e1)
end,"handler","desc","lscale","rscale")
function Pendulum.PseudoTarget()
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then 
			return Duel.CheckLocation(tp,LOCATION_PZONE,0) 
				or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
		end
	end
end
function Pendulum.PseudoOperation(lscale,rscale)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
		local c=e:GetHandler()
		local fid=e:GetHandler():GetFieldID()
		local nseq=(0xff^2)+16
		if c:IsRelateToEffect(e) then
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true,nseq)
			-- Pendulum Summon
			local r1=Effect.CreateEffect(e:GetHandler())
				r1:SetDescription(1163)
				r1:SetType(EFFECT_TYPE_FIELD)
				r1:SetCode(EFFECT_SPSUMMON_PROC_G)
				r1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
				r1:SetRange(LOCATION_PZONE)
				r1:SetCondition(Pendulum.Condition())
				r1:SetOperation(Pendulum.Operation())
				r1:SetValue(SUMMON_TYPE_PENDULUM)
				r1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(r1)
			--set left scale
			local r2=Effect.CreateEffect(c)
				r2:SetType(EFFECT_TYPE_SINGLE)
				r2:SetCode(EFFECT_CHANGE_LSCALE)
				r2:SetValue(lscale)
				r2:SetReset(RESET_EVENT+0x1fe0000)
			c:RegisterEffect(r2)
			local r3=Effect.CreateEffect(c)
				r3:SetType(EFFECT_TYPE_SINGLE)
				r3:SetCode(EFFECT_CHANGE_RSCALE)
				r3:SetValue(rscale)
				r3:SetReset(RESET_EVENT+0x1fe0000)
			c:RegisterEffect(r3)
			--destroy during the end phase
			local fid=e:GetHandler():GetFieldID()
			c:RegisterFlagEffect(e:GetHandler():GetCode(),RESET_EVENT+0x1fe0000,0,1,fid)
			local r5=Effect.CreateEffect(c)
				r5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				r5:SetCode(EVENT_PHASE+PHASE_END)
				r5:SetCountLimit(1)
				r5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				r5:SetLabel(fid)
				r5:SetLabelObject(c)
				r5:SetCondition(Pendulum.PseudoUpkeepCondition())
				r5:SetOperation(Pendulum.PseudoUpkeepOperation())
			Duel.RegisterEffect(r5,tp)
		end
	end
end
function Pendulum.PseudoUpkeepCondition()
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tc=e:GetLabelObject()
		if tc:GetFlagEffectLabel(e:GetHandler():GetCode())~=e:GetLabel() then
			e:Reset()
			return false
		else 
			return true 
		end
	end
end
function Pendulum.PseudoUpkeepOperation()
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
	end
end
