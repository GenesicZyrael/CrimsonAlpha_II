function Link.CheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	filt=filt or {}
	local rg=Group.CreateGroup()
	--c has the link limit
	if c:IsHasEffect(CUSTOM_LINK_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(CUSTOM_LINK_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
			local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg2)
			mg:Sub(sg2)
		end
	end
	--A card in the selected group has the link limit
	local g2=sg:Filter(Card.IsHasEffect,nil,CUSTOM_LINK_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(CUSTOM_LINK_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	sg:AddCard(c)
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3],tp,sg,mg,lc,filt[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			return false
		end
	end
	local res=Link.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
		or (#sg<maxc and mg:IsExists(Link.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
	sg:RemoveCard(c)
	return res
end
function Link.CheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	local rg=Group.CreateGroup()
	--c has the link limit
	if c:IsHasEffect(CUSTOM_LINK_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(CUSTOM_LINK_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
			local sg3=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg3)
			mg:Sub(sg3)
		end
	end
	--A card in the selected group has the fusion lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,CUSTOM_LINK_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(CUSTOM_LINK_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	sg:AddCard(c)
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3],tp,sg,mg,lc,filt[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			return false
		end
	end
	if #(sg2-sg)==0 then
		if secondg and #secondg>0 then
			local res=secondg:IsExists(Link.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		else
			local res=Link.CheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		end
	end
	local res=Link.CheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	sg:RemoveCard(c)
	return res
end
function Link.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
	for _,filt in ipairs(filt) do
		if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),lc,filt[1],1) then
			return false
		end
	end
	return #sg>=minc and sg:CheckWithSumEqual(Link.GetLinkCount,lc:GetLink(),#sg,#sg)
		and (not specialchk or specialchk(sg,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end