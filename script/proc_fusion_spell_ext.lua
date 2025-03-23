local geff=Effect.GlobalEffect()
geff:SetType(EFFECT_TYPE_FIELD)
geff:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
geff:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
geff:SetTargetRange(0xff,0xff)
geff:SetTarget(function(e,c)
	return Fusion.ExtraGroup and Fusion.ExtraGroup:IsContains(c)
end)
geff:SetValue(aux.TRUE)
Duel.RegisterEffect(geff,0)

--Returns the first EFFECT_EXTRA_FUSION_MATERIAL applied on Card c.
--If fc is provided, it will also check if the effect's value function applies to that card.
--Card.IsHasEffect alone cannot be used because it would return the above effect as well.
local function GetExtraMatEff(c,fc)
	local effs={c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
	for _,eff in ipairs(effs) do
		if eff~=geff then
			if not fc then
				return eff
			end
			local val=eff:GetValue()
			if (type(val)=="function" and val(eff,fc)) or val==1 then
				return eff
			end
		end
	end
end
--Once per turn check for EFFECT_EXTRA_FUSION_MATERIAL effects.
--Removes cards from the material pool group if the OPT of the
--EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
--Returns the main material group and the extra material group separately, both
--of which are then passed to Fusion.SummonEffFilter.
local function ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst())
		--Check if you need to remove materials from the pool if count limit has been used
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			--If "extrafil" exists and it doesn't return anything in
			--the GY (so that effects like "Dragon's Mirror" are excluded),
			--remove all the EFFECT_EXTRA_FUSION_MATERIAL cards
			--that are in the GY from the material group.
			--Hardcoded to LOCATION_GRAVE since it's currently
			--impossible to get the TargetRange of the
			--EFFECT_EXTRA_FUSION_MATERIAL effect (but the only OPT effect atm uses the GY).
			local extra_feff_loc=extra_feff:GetTargetRange()
			if extrafil then
				local extrafil_g=extrafil(e,tp,mg1)
				if extrafil_g and #extrafil_g>0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff_loc) then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				elseif not extrafil_g then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				end
			--If "extrafil" doesn't exist then remove all the
			--EFFECT_EXTRA_FUSION_MATERIAL cards from the material group.
			--A more complete implementation would check for cases where the
			--Fusion Summoning effect can use the whole field (including LOCATION_SZONE),
			--but it's currently not possible to know if that is the case
			--(only relevant for "Fullmetalfoes Alkahest" atm, but he's not OPT).
			else
				mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
				efmg:Clear()
			end
		end
	elseif #efmg>0 then
		local extra_feff=GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
end

--[[
Structure: 
Fusion.PseudoMaterials = {{[tp] = {[uid] = {[eff_id] = {pseudo_cards}}}}, {[tp] = {[uid] = {[fusion_card_id] = {pseudo_cards}}}}}

A nested table that stores and manages two types of pseudo materials for Fusion summoning:
Index 1: Stores pseudo materials generated from cards with EFFECT_FUSION_MATERIAL_COUNT
Index 2: Stores pseudo materials generated from Fusion cards that allow additional materials

Structure Breakdown:
- [tp]: Player index/controller
- [uid]: Unique identifier of the original card
- [eff_id]: Effect ID of the EFFECT_FUSION_MATERIAL_COUNT effect (Index 1)
- [fusion_card_id]: Card ID of the Fusion card that allows additional materials (Index 2)
- {pseudo_cards}: Array of generated pseudo cards
--]]
Fusion.PseudoMaterials={{},{}}

--[[
Structure:
Fusion.PseudoMaterialCountAndCondition = {{fusion_card_tables}, {[fusion_card_id] = fusion_card_table}}

A table that stores information about Fusion cards that allow additional materials:
Index 1: Array of fusion card tables {fusion_card_id, count, condition}
Index 2: Lookup table mapping Fusion card IDs to their tables

Structure Breakdown:
- fusion_card_table: {fusion_card_id, count, condition}
  - fusion_card_id: ID of the Fusion card that allows additional materials
  - count: Number of additional materials allowed
  - condition: Optional condition function
--]]
Fusion.PseudoMaterialCountAndCondition={{},{}}

--[[
Creates pseudo materials for fusion summoning by:
1. Processing cards with EFFECT_FUSION_MATERIAL_COUNT to generate additional materials
2. Processing cards that can be used as additional materials based on the Fusion card's allowance

For each eligible card:
- Generates N-1 pseudo copies (where N is the material count)
- Marks original card with NOT_PSEUDO_CARD_FLAG
- Marks pseudo copies with PSEUDO_CARD_FLAG and other relevant flags
- Stores pseudo materials in appropriate subtables of Fusion.PseudoMaterials
--]]
function Fusion.CreatePseudoMaterials(e,tp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ALL,LOCATION_ALL,nil)
	for c in g:Iter() do
		local tp=c:GetControler()
		local uid=c:GetFieldID()
		if not Fusion.PseudoMaterials[1][tp] then
			Fusion.PseudoMaterials[1][tp]={}
		end
		if not Fusion.PseudoMaterials[1][tp][uid] then
			Fusion.PseudoMaterials[1][tp][uid]={}
		end
		if not Fusion.PseudoMaterials[2][tp] then
			Fusion.PseudoMaterials[2][tp]={}
		end
		if not Fusion.PseudoMaterials[2][tp][uid] then
			Fusion.PseudoMaterials[2][tp][uid]={}
		end
		local effs={c:IsHasEffect(EFFECT_FUSION_MATERIAL_COUNT)}
		if #effs>0 then
			for _,eff in ipairs(effs) do
				local ct=eff:GetLabel()
				local eff_id=eff:GetFieldID()
				if ct>1 and eff:GetType()&EFFECT_TYPE_FIELD>0 and not Fusion.PseudoMaterials[1][tp][uid][eff_id] then
					Fusion.PseudoMaterials[1][tp][uid][eff_id]={}
					local location=eff:GetTargetRange()
					if not c:HasFlagEffect(ORIGINAL_CARD_UID_FLAG) then
						c:RegisterFlagEffect(ORIGINAL_CARD_UID_FLAG,0,0,0,uid)
						c:RegisterFlagEffect(NOT_PSEUDO_CARD_FLAG,0,0,0,uid)
					end
					local pseudo_cards={}
					for _=1,ct-1 do
						local pseudo_card=Duel.CreateToken(tp,c:GetCode())
						pseudo_card:RegisterFlagEffect(MATERIAL_COUNT_LOCATION_FLAG,0,0,0,location)
						pseudo_card:RegisterFlagEffect(MATERIAL_COUNT_FLAG,0,0,0,ct)
						pseudo_card:RegisterFlagEffect(ORIGINAL_CARD_UID_FLAG,0,0,0,uid)
						pseudo_card:RegisterFlagEffect(PSEUDO_CARD_FLAG,0,0,0)
						table.insert(pseudo_cards,pseudo_card)
					end
					Fusion.PseudoMaterials[1][tp][uid][eff_id]=pseudo_cards
				end
			end
		end
		if not Fusion.PseudoMaterials[2][tp][uid][id] and (c:IsLocation(LOCATION_HAND|LOCATION_MZONE) or GetExtraMatEff(c)) then
			for _,tab in ipairs(Fusion.PseudoMaterialCountAndCondition[1]) do
				local id=tab[1]
				local ct=tab[2]
				if id and ct then
					if not c:HasFlagEffect(ORIGINAL_CARD_UID_FLAG) then
						c:RegisterFlagEffect(ORIGINAL_CARD_UID_FLAG,0,0,0,uid)
						c:RegisterFlagEffect(NOT_PSEUDO_CARD_FLAG,0,0,0,uid)
					end
					local pseudo_cards={}
					for _=1,ct-1 do
						local pseudo_card=Duel.CreateToken(tp,c:GetCode())
						pseudo_card:RegisterFlagEffect(MATERIAL_COUNT_LOCATION_FLAG,0,0,0,c:GetLocation())
						pseudo_card:RegisterFlagEffect(ORIGINAL_CARD_UID_FLAG,0,0,0,uid)
						pseudo_card:RegisterFlagEffect(PSEUDO_CARD_FLAG,0,0,0)
						pseudo_card:RegisterFlagEffect(id,0,0,0)
						table.insert(pseudo_cards,pseudo_card)
					end
					Fusion.PseudoMaterials[2][tp][uid][id]=pseudo_cards
				end
			end
		end
	end
end

--[[
Registers a Fusion card's ability to allow additional materials for fusion summoning.
Used for Fusion cards that allow materials to be treated as multiple materials,
rather than effects on the materials themselves (EFFECT_FUSION_MATERIAL_COUNT).

Parameters:
- id: Fusion card ID (must be number)
- ct: Number of copies each material can be treated as (defaults to 2 if invalid)
- cond: Optional condition function (defaults to aux.TRUE)

The registered information is stored in PseudoMaterialCountAndCondition and used
when that specific Fusion card performs a fusion summon.
--]]
function Fusion.ApplyAdditionalMaterials(id,ct,cond)
	if type(cond)~="function" then cond=aux.TRUE end
	if type(id)~="number" then
		error("Parameter 1 should be \"number\"",2)
	end
	if (type(ct)~="number" or ct and ct<=1) then
		ct=2
	end
	local existed=Fusion.PseudoMaterialCountAndCondition[2][id]
	if existed then return end
	local tab={id,ct,cond}
	table.insert(Fusion.PseudoMaterialCountAndCondition[1],tab)
	Fusion.PseudoMaterialCountAndCondition[2][id]=tab
end


local geff2=Effect.GlobalEffect()
geff2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
geff2:SetCode(EVENT_ADJUST)
geff2:SetOperation(Fusion.CreatePseudoMaterials)
Duel.RegisterEffect(geff2,0)

local function GetFusionMaterialCountEffect(c,fc)
	if not c then return end
	local effs={c:IsHasEffect(EFFECT_FUSION_MATERIAL_COUNT)}
	local results={}
	for _,eff in ipairs(effs) do
		local ct=eff:GetLabel()
		if ct and ct>1 then
			if not fc then
				return eff,ct
			end
			local val=eff:GetValue()
			if (type(val)=="function" and val(eff,fc)) or val then
				return eff,ct
			end
		end
	end
end
--Retrieves the group of pseudo-cards generated for multi-material treatment
--c: The original card being checked
--fc: The card being Fusion Summoned
--tp: Controlling player
--return Group containing generated pseudo-cards (excluding original card) | Empty Group
function Fusion.GetPseudoFusionMaterialGroup(c,fc,tp,e)
	local g=Group.CreateGroup()
	if (not c or not c:HasFlagEffect(NOT_PSEUDO_CARD_FLAG)) then return g end
	local id=e:GetHandler():GetCode()
	local tab=Fusion.PseudoMaterialCountAndCondition[2][id]
	if not tab then return g end
	local p=c:GetControler()
	local ct=tab[2]
	local cond=tab[3]
	if ct>fc.max_material_count or not cond(e,tp,c,fc) then return g end
	local pseudo_cards=Fusion.PseudoMaterials[2][p][c:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)][id]
	for i=1,#pseudo_cards do
		local pc=pseudo_cards[i]
		pc:ResetFlagEffect(MATERIAL_COUNT_LOCATION_FLAG)
		pc:ResetFlagEffect(MATERIAL_COUNT_FLAG)
		pc:RegisterFlagEffect(MATERIAL_COUNT_LOCATION_FLAG,0,0,0,c:GetLocation())
		pc:RegisterFlagEffect(MATERIAL_COUNT_FLAG,0,0,0,ct)
		g:AddCard(pc)
	end
	
	return g
end
function Fusion.GetPseudoFusionMaterialEffectGroup(c,fc,tp,e)
	local g=Fusion.GetPseudoFusionMaterialGroup(c,fc,tp,e)
	if not c then return g end
	local p=c:GetControler()
	local eff,ct=GetFusionMaterialCountEffect(c,fc)
	if not (c:HasFlagEffect(ORIGINAL_CARD_UID_FLAG) and
			eff and
			eff:CheckCountLimit(tp) and
			type(fc.max_material_count)=="number" and
			ct<=fc.max_material_count) then
		return g
	end

	local eff_id=eff:GetFieldID()
	local pseudo_cards=Fusion.PseudoMaterials[1][p][c:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)][eff_id]
	for i=1,#pseudo_cards do
		g:AddCard(pseudo_cards[i])
	end
	return g
end
local function FusionMaterialCountCheck(tp,sg,fc)
	for c in sg:Iter() do
		if c:HasFlagEffect(PSEUDO_CARD_FLAG) then
			local uid=c:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)
			local matct=c:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
			local ct=sg:FilterCount(function(sc) return sc:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)==uid and sc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)==matct end,nil)
			if (ct~=matct and not sg:IsExists(Card.IsNotPseudo,1,nil,uid))
				or matct>fc.max_material_count then
				return false
			end
		end
	end
	return true
end
function Fusion.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos,efmg)
	if not (c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c,tp)) and (nosummoncheck or c:IsCanBeSpecialSummoned(e,value,tp,sumlimit,false,sumpos))) then return false end
	--efmg is the group of Fusion Materials with an EFFECT_EXTRA_FUSION_MATERIAL effect.
	--If any materials in that group with that effect are valid materials for Card c
	--then merge those into mg before performing the check below.
	--Attempt to fix the interaction between an EFFECT_EXTRA_FUSION_MATERIAL effect
	--and Fusion Summoning effects that normally allow you to only use a single location
	--(e.g. with "Flash Fusion" you can normally only use monsters on your field).
	if efmg then
		mg:Merge(efmg:Filter(GetExtraMatEff,nil,c))
	end
	local pg=Group.CreateGroup()
	local uids={}
	for mc in mg:Iter() do
		pg:Merge(Fusion.GetPseudoFusionMaterialEffectGroup(mc,c,tp,e))
		if mc:HasFlagEffect(NOT_PSEUDO_CARD_FLAG) then
			table.insert(uids,mc:GetFlagEffectLabel(NOT_PSEUDO_CARD_FLAG))
		end
	end
	mg:Merge(pg)
	for _,uid in ipairs(uids) do
		local temp_pg=mg:Filter(Card.IsPseudo,nil,uid)
		for pc in temp_pg:Iter() do
			local ct=pc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
			if mg:FilterCount(function(pcc) return pcc:IsPseudo(uid) and pcc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)==ct end,nil)>(ct-1) then
				mg:Sub(pc)
			end
		end
		
	end
	return c:CheckFusionMaterial(mg,gc,chkf)
end
Fusion.SummonEffTG = aux.FunctionWithNamedArgs(
function(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location=location or LOCATION_EXTRA
				if not chkf or ((chkf&PLAYER_NONE)~=PLAYER_NONE) then
					chkf=chkf and chkf|tp or tp
				end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				value = value|MATERIAL_FUSION
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				if chk==0 then
					--Separate the Fusion Materials filtered by matfilter
					--and the ones with an EFFECT_EXTRA_FUSION_MATERIAL effect.
					--Both will be passed to Fusion.SummonEffFilter later.
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) else Fusion.CheckAdditional=FusionMaterialCountCheck end
					if #efmg>0 then
						local extra_feff=GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							-- no extrafil (Poly):
							if not extrafil then
								local ret = {repl_function[1](e,tp,mg1)}
								if ret[1] then
									ret[1]:Match(matfilter,nil,e,tp,0)
									if repl_function[2] then
										ret[1]:Match(repl_function[2],nil,e,tp)
										efmg:Match(repl_function[2],nil,e,tp)
									end
									Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								checkAddition=ret[2]
							-- extrafil but no fcheck (Shaddoll Fusion):
							elseif extrafil then
								local ret = {extrafil(e,tp,mg1)}
								local repl={repl_function[1](e,tp,mg1)}
								if ret[1] then
									repl[1]:Match(matfilter,nil,e,tp,0)
									ret[1]:Merge(repl[1])
									Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								if ret[2] then
									-- extrafil and fcheck (Cynet Fusion):
									checkAddition=aux.AND(ret[2],repl[2])
								else
									checkAddition=repl[2]
								end
							end
						end
					end
					if not repl_flag and extrafil then
						local ret = {extrafil(e,tp,mg1)}
						if ret[1] then
							Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) else Fusion.CheckAdditional=FusionMaterialCountCheck end
					mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					--Adjust the main material group and the extra material group accordingly
					--if an OPT EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
					--Both will be passed to Fusion.SummonEffFilter later.
					mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
					Fusion.CheckAdditional=nil
					Fusion.ExtraGroup=nil
					if not res and not notfusion then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp,value)
							if #mg>0 and (not Fusion.CheckExact or #mg==Fusion.CheckExact) and (not Fusion.CheckMin or #mg>=Fusion.CheckMin) then
								local mf=ce:GetValue()
								local fcheck=nil
								if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) end
								if fcheck then
									if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=aux.AND(fcheck,FusionMaterialCountCheck) end
								end
								Fusion.ExtraGroup=mg
								if Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
									res=true
									Fusion.CheckAdditional=nil
									Fusion.ExtraGroup=nil
									break
								end
								Fusion.CheckAdditional=nil
								Fusion.ExtraGroup=nil
							end
						end
					end
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end,"fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","preselect","nosummoncheck","extratg","mincount","maxcount","sumpos")
Fusion.SummonEffOP = aux.FunctionWithNamedArgs(
function (fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				--Make sure there are always pseudo materials, because EVENT_ADJUST sometimes doesn't get raised right away when a new EFFECT_FUSION_MATERIAL_COUNT is applied
				Fusion.CreatePseudoMaterials(e,tp)
				location=location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				if not preselect then chkf=chkf|FUSPROC_CANCELABLE end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				local checkAddition
				--Same as line 167 above
				local fmg_all=Duel.GetFusionMaterial(tp)
				local mg1=fmg_all:Filter(matfilter,nil,e,tp,1)
				local efmg=fmg_all:Filter(GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				if #efmg>0 then
					local extra_feff=GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						-- no extrafil (Poly):
						if not extrafil then
							local ret = {repl_function[1](e,tp,mg1)}
							if ret[1] then
								ret[1]:Match(matfilter,nil,e,tp,1)
								if repl_function[2] then
									ret[1]:Match(repl_function[2],nil,e,tp)
									efmg:Match(repl_function[2],nil,e,tp)
								end
								Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							checkAddition=ret[2]
						-- extrafil but no fcheck (Shaddoll Fusion):
						elseif extrafil then
							local ret = {extrafil(e,tp,mg1)}
							local repl={repl_function[1](e,tp,mg1)}
							if ret[1] then
								repl[1]:Match(matfilter,nil,e,tp,1)
								ret[1]:Merge(repl[1])
								Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							if ret[2] then
								-- extrafil and fcheck (Cynet Fusion):
								checkAddition=aux.AND(ret[2],repl[2])
							else
								checkAddition=repl[2]
							end
						end
					end
				end
				if not repl_flag and extrafil then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then
					Fusion.ExtraGroup=nil
					return false
				end
				Fusion.CheckExact=exactcount
				Fusion.CheckMin=mincount
				Fusion.CheckMax=maxcount
				if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) else Fusion.CheckAdditional=FusionMaterialCountCheck end
				local effswithgroup={}
				--Same as line 191 above
				mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
				if #sg1>0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.ExtraGroup=nil
				Fusion.CheckAdditional=nil
				if not notfusion then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) and (not Fusion.CheckMin or #mg2>=Fusion.CheckMin) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) end
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=aux.AND(fcheck,FusionMaterialCountCheck) end
							end
							Fusion.ExtraGroup=mg2
							local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
							Fusion.ExtraGroup=nil
						end
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					local mat1=Group.CreateGroup()
					local sel=nil
					local backupmat=nil
					local tc=nil
					local ce=nil
					while #mat1==0 do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						tc=sg:Select(tp,1,1,nil):GetFirst()
						if preselect and preselect(e,tc)==false then
							return
						end
						
						sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
						if sel[1]==e then
							if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) else Fusion.CheckAdditional=FusionMaterialCountCheck end
							Fusion.ExtraGroup=extragroup
							mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						else
							ce=sel[1]
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,FusionMaterialCountCheck) end
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=aux.AND(fcheck,FusionMaterialCountCheck) end
							end
							Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
							mat1=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						end
						
					end
					if sel[1]==e then
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						if not notfusion then
							tc:SetMaterial(mat1)
						end
						--Checks for the case that the Fusion Summoning effect has an "extraop"
						local extra_feff_mg=mat1:Filter(GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 and extraop then
							local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								--If the operation of the EFFECT_EXTRA_FUSION_MATERIAL effect is different than "extraop",
								--it's not OPT or it hasn't been used yet, and the player
								--chooses to apply the effect, then select which cards
								--the effect will be applied to and execute its operation.
								if extra_feff_op and extraop~=extra_feff_op and extra_feff:CheckCountLimit(tp) then
									local flag=nil
									if extrafil then
										local extrafil_g=extrafil(e,tp,mg1)
										if #extrafil_g>=0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff:GetTargetRange()) then
											--The Fusion effect by default does not use the GY
											--so the player is forced to apply this effect.
											mat1:Sub(extra_feff_mg)
											extra_feff_op(e,tc,tp,extra_feff_mg)
											flag=true
										elseif #extrafil_g>=0 and Duel.SelectEffectYesNo(tp,extra_feff:GetHandler()) then
											--Select which cards you'll apply the
											--EFFECT_EXTRA_FUSION_MATERIAL effect to
											--and execute its operation.
											Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
											local g=extra_feff_mg:Select(tp,1,#extra_feff_mg,nil)
											if #g>0 then
												mat1:Sub(g)
												extra_feff_op(e,tc,tp,g)
												flag=true
											end
										end
									else
										--The Fusion effect by default does not use the GY
										--so the player is forced to apply this effect.
										mat1:Sub(extra_feff_mg)
										extra_feff_op(e,tc,tp,extra_feff_mg)
										flag=true
									end
									--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
									--then "use" its count limit.
									if flag and extra_feff:CheckCountLimit(tp) then
										extra_feff:UseCountLimit(tp,1)
									end
								end
							end
						end
						local pg=mat1:Filter(Card.HasFlagEffect,nil,PSEUDO_CARD_FLAG)
						local id=e:GetHandler():GetCode()
						local registered=false
						for pc in pg:Iter() do
							local oc=mat1:Filter(Card.IsNotPseudo,nil,pc:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)):GetFirst()
							local mat_count_eff=GetFusionMaterialCountEffect(oc,tc)
							if mat_count_eff and mat_count_eff:CheckCountLimit(tp) then
								mat_count_eff:UseCountLimit(tp,1)
							end
							if pc:HasFlagEffect(id) and not registered then
								Duel.RegisterFlagEffect(tp,id+EFFECT_FUSION_MATERIAL_COUNT,RESET_PHASE|PHASE_END,0,1)
								registered=true
							end
						end
						mat1:Sub(pg)
						if extraop then
							if extraop(e,tc,tp,mat1)==false then return end
						end
						if #mat1>0 then
							--Split the group of selected materials to
							--"extra_feff_mg" and "normal_mg", send "normal_mg"
							--to the GY, and execute the operation of the
							--EFFECT_EXTRA_FUSION_MATERIAL effect, if it exists.
							--If it doesn't exist then send the extra materials to the GY.
							local extra_feff_mg,normal_mg=mat1:Split(GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 and (not extra_feff or extra_feff:GetLabel()~=160018042) then
								normal_mg=normal_mg:AddMaximumCheck()
								Duel.SendtoGrave(normal_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									extra_feff_mg=extra_feff_mg:AddMaximumCheck()
									Duel.SendtoGrave(extra_feff_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
								end
								--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
								--then "use" its count limit.
								if extra_feff:CheckCountLimit(tp) then
									extra_feff:UseCountLimit(tp,1)
								end
							end
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,sumlimit,false,sumpos)
					else
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat1,value,nil,sumpos)
						backupmat=tc:GetMaterial():Clone()
					end
					stage2(e,tc,tp,backupmat,0)
					Duel.SpecialSummonComplete()
					stage2(e,tc,tp,backupmat,3)
					if (chkf&FUSPROC_NOTFUSION)==0 then
						tc:CompleteProcedure()
					end
					stage2(e,tc,tp,backupmat,1)
				end
				stage2(e,nil,tp,nil,2)
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
			end
end,"fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","preselect","nosummoncheck","mincount","maxcount","sumpos")