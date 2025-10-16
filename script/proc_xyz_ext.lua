-- Decade, you can change this to other ID

function Xyz.MatFilter2(c,f,lv,xyz,tp)
    if f and not f(c,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp) then return false end
    if not c:HasLevel() and not c:IsHasEffect(EFFECT_XYZ_LEVEL) then return fasle end
    if lv then
        local effectivelvl=c:GetLevel()
        local mg=Xyz.GetMaterials(tp,xyz)
        for tc in mg:Iter() do
            local effs={tc:IsHasEffect(EFFECT_XYZ_MATERIAL_CUSTOM)}
            for _,te in ipairs(effs) do
                local val=te:GetValue()
                if type(val)=="function" then
                    local newLv=val(te,xyz)
                    if newLv then
                        effectivelvl=newLv
                        break
                    end
                elseif type(val)=="number" then
                    effectivelvl=val
                    break
                end
            end
        end
        if not (xyz:GetRank()==effectivelvl or c:IsXyzLevel(xyz,lv)) then return false end   
    end
    return c:IsCanBeXyzMaterial(xyz,tp)
end

function Xyz.HasLevelChangeEffect(c,xyz,sg,xyzlv)
	local effs={c:IsHasEffect(EFFECT_XYZ_MATERIAL_CUSTOM)}
	local lv=nil
	for _,eff in ipairs(effs) do
		local val=eff:GetValue()
		if val and type(val)=="function" then
			local vlv=val(eff,xyz,sg)
			lv=vlv and vlv
			break
		elseif val and type(val)=="number" then
			lv=val
			break
		end
	end
	return lv and lv>0 and (not xyzlv or xyzlv and xyzlv==lv)
end

function Xyz.RecursionChk(c,mg,xyz,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse)
	local addToMatg=true
	if eqmg and eqmg:IsContains(c) then
		if not sg:IsContains(c:GetEquipTarget()) then return false end
		addToMatg=false
	end
	local xct=ct
	local rg=Group.CreateGroup()
	if not c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
		xct=xct+1
	else
		addToMatg=true
	end
	local xmatct=matct+1
	if (max and xct>max) or (maxc~=infToken and xmatct>maxc) then mg:Merge(rg) return false end
	
	for i,f in ipairs({c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	for tc in sg:Iter() do
		for i,f in ipairs({tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	
	if addToMatg then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local mustContainLevelChange=false
		
	if lv and not c:IsXyzLevel(xyz,lv) then
		local sgc=sg:Clone()
		for sc in sgc:Iter() do
			local result=Xyz.HasLevelChangeEffect(sc,xyz,sg,lv)
			if result then
				mustContainLevelChange=result
			end
		end
	end
	
	if lv and not c:HasLevel() and c:IsHasEffect(EFFECT_XYZ_LEVEL) and not c:IsXyzLevel(xyz,lv) then
		mg:Sub(c)
	end
	
	local eqg=nil
	local res=(function()
		if (xct>=min and xmatct>=minc) and Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv) then return true end
		if equips_inverse then
			eqg=equips_inverse[c]
			if eqg then
				mg:Merge(eqg)
			end
		end
		if mg:IsExists(Xyz.RecursionChk,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse) then return true end
		if not mustbemat then
			local retchknum={}
			for i,te in ipairs({c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL,tp)}) do
				local tgf=te:GetOperation()
				local val=te:GetValue()
				if val>0 and not retchknum[val] and (not maxc or maxc==infToken or xmatct+val<=maxc) and (not tgf or tgf(te,xyz,matg)) then
					retchknum[val]=true
					te:UseCountLimit(tp)
					local chk=(xct+val>=min and xmatct+val>=minc and Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv))
								or mg:IsExists(Xyz.RecursionChk,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct+val,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse)
					te:RestoreCountLimit(tp)
					if chk then return true end
				end
			end
		end
		return false
	end)()
	
	if addToMatg then
		matg:RemoveCard(c)
	end
	sg:RemoveCard(c)
	if eqg then
		mg:Sub(eqg)
	end
	mg:Merge(rg)
	
	
	return res and (c:IsXyzLevel(xyz,lv) or mustContainLevelChange) 
end