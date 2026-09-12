-- local ForcedUseZone=nil
-- local function GetForcedZone(chkfnf)
	-- local zone=(chkfnf>>40)&0xff
	-- if zone==0 then zone=0xff end
	-- return zone
-- end
-- --Ensure that when a pseudo material is selected, `sg` must have the sum of pseudo materials+original card with the same uid equal to the material count
-- local function FusionMaterialCountCheck(tp,sg,fc)
	-- for c in sg:Iter() do
		-- if c:HasFlagEffect(PSEUDO_CARD_FLAG) then
			-- local uid=c:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)
			-- local matct=c:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
			-- local ct=sg:FilterCount(function(sc) return sc:IsPseudo(uid) and sc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)==matct end,nil)+sg:FilterCount(Card.IsNotPseudo,nil,uid)
			-- if ct~=matct then
				-- return false
			-- end
		-- end
	-- end
	-- return true
-- end
-- --When a pseudo material is selected, all materials with the same uid will be added to `sg`.
-- --When a non-pseudo material is unselected, all pseudo materials with the uid of that non-pseudo material will be unselected.
-- local function AddOrRemove(tc,sg,mg)
	-- local operation=sg:IsContains(tc) and Group.Sub or Group.Merge
	-- if tc:HasFlagEffect(ORIGINAL_CARD_UID_FLAG) then
		-- local uid=tc:GetFlagEffectLabel(ORIGINAL_CARD_UID_FLAG)
		-- local ct=tc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
		-- local pg=Group.CreateGroup()
		-- if tc:IsPseudo() or (tc:IsNotPseudo() and sg:IsContains(tc)) then
			-- pg=mg:Filter(Card.IsPseudo,nil,uid)
			-- if sg:IsExists(Card.IsNotPseudo,0,nil,uid) then
				-- local og=mg:Filter(Card.IsNotPseudo,nil,uid)
				-- pg:Merge(og)
			-- end
		-- end
		-- if tc:IsNotPseudo() and sg:IsContains(tc) then
			-- pg:Merge(tc)
		-- elseif tc:IsNotPseudo() then
			-- sg:AddCard(tc)
		-- end
		-- operation(sg,pg)
	-- else
		-- operation(sg,tc)
	-- end
-- end
-- --[[
-- Normalizes the count of pseudo materials to prevent over-counting when multiple effects are applied.
-- For each original card (marked with NOT_PSEUDO_CARD_FLAG), this function:
-- - Finds all its associated pseudo cards
-- - Ensures only the pseudo cards from the effect with highest material count are kept
-- - Maintains the correct number of pseudo cards according to the material count

-- Example:
-- If a card has two effects that treat it as 3 materials each:
-- - Without normalization: Could be treated as 6 materials (incorrect)
-- - With normalization: Will be treated as 3 materials (correct)
-- --]]
-- local function NormalizePseudoMaterialCount(tp,mg,mg_clone,fc)
	-- for mc in mg:Iter() do
		-- if mc:HasFlagEffect(NOT_PSEUDO_CARD_FLAG) then
			-- local uid=mc:GetFlagEffectLabel(NOT_PSEUDO_CARD_FLAG)
			-- local temp_pg=mg:Filter(Card.IsPseudo,nil,uid)
			-- local _,maxct=temp_pg:GetMaxGroup(function(c)
				-- local ct=c:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
				-- return ct<=fc.max_material_count and ct or 0
			-- end,nil)
			-- for pc in temp_pg:Iter() do
				-- local matct=pc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)
				-- if matct~=maxct or matct==maxct and mg_clone:FilterCount(function(sc) return sc:IsPseudo(uid) and sc:GetFlagEffectLabel(MATERIAL_COUNT_FLAG)==matct end,nil)>maxct then
					-- mg_clone:RemoveCard(pc)
				-- end
			-- end
		-- end
	-- end
-- end
-- function Fusion.OperationMix(insf,sub,...)
	-- local funs={...}
	-- return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf,summonEff)
				-- Fusion.SummonEffect=summonEff
				-- local chkf=chkfnf&0xff
				-- ForcedUseZone=GetForcedZone(chkfnf)
				-- local c=e:GetHandler()
				-- local tp=c:GetControler()
				-- local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				-- local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				-- local cancelable=(chkfnf&(FUSPROC_CONTACTFUS|FUSPROC_CANCELABLE))~=0
				-- local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				-- local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				-- if listedmats then
					-- sumtype=0
				-- elseif contact or notfusion then
					-- sumtype=MATERIAL_FUSION
				-- end
				-- local matcheck=e:GetValue()
				-- local sub=not listedmats and (sub or notfusion) and not contact
				-- local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,table.unpack(funs))
				-- local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				-- if contact then mustg:Clear() end
				-- local sg=Group.CreateGroup()
				-- if gc then
					-- mustg:Merge(gc)
				-- end
				-- for tc in aux.Next(mustg) do
					-- sg:AddCard(tc)
					-- if not contact and tc:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
						-- local eff={gc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
						-- for i=1,#eff do
							-- local f=eff[i]:GetValue()
							-- mg:Match(Auxiliary.HarmonizingMagFilter,tc,eff[i],f)
						-- end
					-- end
				-- end
				-- local p=tp
				-- local sfhchk=false
				-- if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					-- p=1-tp
					-- Duel.ConfirmCards(1-tp,mg)
					-- if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				-- end
				-- local mg_clone=mg:Clone()
				-- NormalizePseudoMaterialCount(tp,mg,mg_clone,c)
				-- while #sg<#funs do
					-- local cg=mg_clone:Filter(Fusion.SelectMix,sg,tp,mg,sg,mustg:Filter(aux.TRUE,sg),c,sub,sub,contact,sumtype,chkf,table.unpack(funs))
					-- Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					-- local tc=Group.SelectUnselect(cg,sg,p,false,cancelable and #sg==0,#funs,#funs)
					-- if not tc then break end
					-- if #mustg==0 or not mustg:IsContains(tc) then
						-- AddOrRemove(tc,sg,mg_clone)
					-- end
				-- end
				-- if sfhchk then Duel.ShuffleHand(tp) end
				-- Duel.SetFusionMaterial(sg)
				-- Fusion.SummonEffect=nil
			-- end
-- end
-- function Fusion.OperationMixRep(insf,sub,fun1,minc,maxc,...)
	-- local funs={...}
	-- return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf,summonEff)
				-- Fusion.SummonEffect=summonEff
				-- local chkf=chkfnf&0xff
				-- ForcedUseZone=GetForcedZone(chkfnf)
				-- local c=e:GetHandler()
				-- local tp=c:GetControler()
				-- local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				-- local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				-- local cancelable=(chkfnf&(FUSPROC_CONTACTFUS|FUSPROC_CANCELABLE))~=0
				-- local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				-- local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				-- if listedmats then
					-- sumtype=0
				-- elseif contact or notfusion then
					-- sumtype=MATERIAL_FUSION
				-- end
				-- local matcheck=e:GetValue()
				-- local sub=not listedmats and (sub or notfusion) and not contact
				-- local sg=Group.CreateGroup()
				-- local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,fun1,table.unpack(funs))
				-- local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				-- if contact then mustg:Clear() end
				-- if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c,sumtype) then return returnAndClearSummonEffect(false) end
				-- if gc then
					-- mustg:Merge(gc)
				-- end
				-- sg:Merge(mustg)
				-- local p=tp
				-- local sfhchk=false
				-- if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					-- p=1-tp
					-- Duel.ConfirmCards(1-tp,mg)
					-- if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				-- end
				-- local mg_clone=mg:Clone()
				-- NormalizePseudoMaterialCount(tp,mg,mg_clone,c)
				-- while #sg<maxc+#funs do
					-- local cg=mg_clone:Filter(Fusion.SelectMixRep,sg,tp,mg_clone,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
					-- if #cg==0 then break end
					-- local finish=Fusion.CheckMixRepGoal(tp,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs)) and not Fusion.CheckExact and not (Fusion.CheckMin and #sg<Fusion.CheckMin)
					-- finish=finish and FusionMaterialCountCheck(tp,sg,c)
					-- local cancel=(cancelable and #sg==0)
					-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					-- local tc=Group.SelectUnselect(cg,sg,p,finish,cancel)
					-- if not tc then break end
					-- if #mustg==0 or not mustg:IsContains(tc) then
						-- AddOrRemove(tc,sg,mg_clone)
					-- end
				-- end
				-- if sfhchk then Duel.ShuffleHand(tp) end
				-- Duel.SetFusionMaterial(sg)
				-- Fusion.SummonEffect=nil
			-- end
-- end

-- function Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
    -- local g=Group.CreateGroup()
    -- local res = sg:IsExists(Fusion.CheckMix,1,nil,sg,g,fc,sub,sub2,contact,sumtype,tp,...) and
        -- (chkf==PLAYER_NONE or (fc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(chkf,tp,sg,fc,ForcedUseZone) or Duel.GetMZoneCount(chkf,sg,tp))>0)
        -- and (not Fusion.CheckAdditional or Fusion.CheckAdditional(tp,sg,fc,sumtype,tp))
    -- -- CUSTOM INJECTION: Check for any card with EFFECT_FUSION_MATERIAL_CUSTOM
    -- if res and EFFECT_FUSION_MATERIAL_CUSTOM then
        -- local custom_mats = Duel.GetMatchingGroup(Card.IsHasEffect, tp, LOCATION_MZONE, 0, nil, EFFECT_FUSION_MATERIAL_CUSTOM)
        -- local test_needed = false
        -- for tc in aux.Next(custom_mats) do
            -- if not sg:IsContains(tc) then
                -- -- Temporarily flag this specific card to disable its buffs
                -- tc:RegisterFlagEffect(EFFECT_FUSION_MATERIAL_CUSTOM, 0, 0, 1)
                -- test_needed = true
            -- end
        -- end
        -- -- If any custom providers were left out, re-verify the math without their buffs
        -- if test_needed then
            -- local g2 = Group.CreateGroup()
            -- local valid_without_buff = sg:IsExists(Fusion.CheckMix,1,nil,sg,g2,fc,sub,sub2,contact,sumtype,tp,...)
            -- -- Clean up the flags
            -- for tc in aux.Next(custom_mats) do
                -- tc:ResetFlagEffect(EFFECT_FUSION_MATERIAL_CUSTOM)
            -- end
            -- if not valid_without_buff then return false end
        -- end
    -- end
    -- return res
-- end
-- function Fusion.CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
    -- if #sg<minc+#{...} or #sg>maxc+#{...} then return false end
    -- local g=Group.CreateGroup()
    -- local res = Fusion.CheckMixRep(sg,g,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,...) 
		-- and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(chkf,tp,sg,fc,ForcedUseZone)>0)
        -- and (not Fusion.CheckAdditional or Fusion.CheckAdditional(tp,sg,fc,sumtype,tp))
	-- -- CUSTOM INJECTION: Check for any card with EFFECT_FUSION_MATERIAL_CUSTOM
    -- if res and EFFECT_FUSION_MATERIAL_CUSTOM then
        -- local custom_mats = Duel.GetMatchingGroup(Card.IsHasEffect, tp, LOCATION_MZONE, 0, nil, EFFECT_FUSION_MATERIAL_CUSTOM)
        -- local test_needed = false
        -- for tc in aux.Next(custom_mats) do
            -- if not sg:IsContains(tc) then
                -- tc:RegisterFlagEffect(EFFECT_FUSION_MATERIAL_CUSTOM, 0, 0, 1)
                -- test_needed = true
            -- end
        -- end
        -- if test_needed then
            -- local g2 = Group.CreateGroup()
            -- local valid_without_buff = Fusion.CheckMixRep(sg,g2,fc,sub,sub2,contact,sumtype,chkf,tp,fun1,minc,maxc,...)
            -- for tc in aux.Next(custom_mats) do
                -- tc:ResetFlagEffect(EFFECT_FUSION_MATERIAL_CUSTOM)
            -- end
            -- if not valid_without_buff then return false end
        -- end
    -- end
    -- return res
-- end

--[[
CUSTOM LIBRARY FOR IMPLEMENTATION OF EFFECT_FUSION_MATERIAL_CUSTOM
Script and docs by Glitchy (XGlitchy30)

EFFECT_FUSION_MATERIAL_CUSTOM is an EFFECT_TYPE_SINGLE effect registered on a monster (the effect's handler).

It models effects of the form:
    If this card is used as Fusion Material for the Fusion Summon of a (filter1) Fusion Monster,
	you can treat (filter2) monsters as (filter3) monsters for that Fusion Summon.

The effect structure accepts the following slots:
- SetValue -> filter1 (optional)
    Accepts two types of input
        - 0 (unset) or 1: Means the effect is applicable to proper Fusion Summons only (no Contact Fusions, no procedures flagged FUSPROC_NOTFUSION)
        - function: value(e,fc,sumtype,tp,contact) -> bool
            If a function is passed, it decides for which summon types and for which Fusion Monsters the effect is applicable

- SetOperation -> filter2 + filter3 (MANDATORY)
    Accepts only a function as input: operation(e,fc,g,sumtype,tp,contact) -> affected, outfit
    
    Parameters:
        - e         :   The EFFECT_FUSION_MATERIAL_CUSTOM itself
        - fc        :   The Fusion Monster whose procedure is being checked
        - g         :   The group representing the whole Fusion material pool of the current procedure call
        - sumtype   :   The summon type of the procedure
        - tp        :   The player performing the procedure
        - contact   :   True if the summon is a Contact Fusion
    
    Must output two values:
        - affected  :   Must be a Group (subset of g), a filter (function(c,te,fc,sumtype,tp,contact)->bool, will be applied to the cards of g), or nil (= all of g)
        - outfit    :   The alternative "outfit" that disguises the materials for that Fusion Summon. Three forms are supported
            -- (a) DESCRIPTOR TABLE (the procedure will build the core effects automatically)
                {   change_attribute=ATTRIBUTE_X,       -- replaces the Attribute       (EFFECT_CHANGE_ATTRIBUTE)
                    add_attribute=ATTRIBUTE_X,          -- adds an Attribute            (EFFECT_ADD_ATTRIBUTE)
                    change_race=RACE_X,                 -- replaces the monster Type    (EFFECT_CHANGE_RACE)      
                    add_race=RACE_X,                    -- adds a monster Type          (EFFECT_ADD_RACE)
                    add_setcode=SET_X or {SET_X,...},   -- adds archetype(s)            (EFFECT_ADD_SETCODE, one effect per archetype)
                    change_setcode=SET_X or {...},      -- replaces archetype           (EFFECT_CHANGE_SETCODE, then EFFECT_ADD_SETCODE if it assigns multiple archetypes)
                    add_code=CODE or {CODE,...},        -- adds name(s)                 (EFFECT_ADD_CODE, one effect per name)
                    change_code=CODE,                   -- replaces the name            (EFFECT_CHANGE_CODE)
                    add_type=TYPE_X,                    -- add card type                (EFFECT_ADD_TYPE)
                    change_type=TYPE_X                  -- change card type             (EFFECT_CHANGE_TYPE),
                    ...I left out levels and stats but it should be trivial to expand to those as well...
                }

            -- (b) BUILDER FUNCTION: outfit(e,c,fc,sumtype,tp,contact) -> Effect, Effect, ... (or a table of Effects)
                The function must return new, UNREGISTERED effects meant for card "c".
                The procedure installs their gate, registers them and resets them when the procedure ends
            
            -- (c) EFFECT TEMPLATES
                A table of unregistered template Effects. Each template is cloned per affected card.

- SetCondition -> optional external condition function: condition(e)

- SetCountLimit -> optional.
    The count is consumed only when the outfit turns out to be NECESSARY for the final Fusion Material group
    (see OPTIONALITY)

######################################################################################################
MECHANIC

- At the beginning of every Fusion Procedure call (condition and operation of EFFECT_FUSION_MATERIAL), the
applicable handlers present in the material pool are collected (Fusion.CustomMaterialBegin), their outfit
effects are registered ONCE on every potentially affected card, and each of those effs is gated by a
closure that is true only while the handler's entry is "active" and scard==fc.
- Every registered effect is reset when the procedure call ends (Fusion.CustomMaterialEnd).
- Cards that are immune to the handler's effect (Card.IsImmuneToEffect) are not affecetd; the handler itself
is exempt from this check though.
- The outfits do not persist past Duel.SetFusionMaterial, so EFFECT_MATERIAL_CHECK will NOT see them.

######################################################################################################
OPTIONALITY

- A candidate group of Fusion Materials is legal if it is legal under some subset S of the valid outfits 
(an outfit is valid if its EFFECT_FUSION_MATERIAL_CUSTOM handler belong to the group)
- Every subset of outfits is tried: all-on first, none last, bounded by Fusion.CustomMaterialMaxSubsets
(above that bound only three options are tried: all-on, every single outfit, and none)
- Once the player has finished selecting, Fusion.CustomMaterialResolve looks for the cheapest subset
(none first, then by increasing size) under which the final group is legal, and only for that subset it
consumes the count limits and shows the handler with HINT_CARD.

######################################################################################################
LIMITS
- Multiple handlers whose replacing outfits target the same property are order-dependent in the core, which means
the last evaluated EFFECT_CHANGE_* always wins (for a specific property); the subset enumeration still finds a
legal configuration when one exists, but which handler "wins" for a given card depends on the registration order.
- Did not implement a "mandatory" counterpart of this effect (like Chlamydosundew).

######################################################################################################
THANKS FOR YOUR ATTENTION.

Signed,
Glitchy
                                                         
                           =@@@%                         
                         +%@@@@@%*                       
                         *@@@@@@@%                       
                         *@@@@@@@%                       
            %@@@@@=      *@@@@@@@%      .%@@@@@:         
            %@@@@@@@*    *@@@@@@@%    :@@@@@@@@:         
            %@@@@@@@@@%    =@@@%    +@@@@@@@@@@:         
            %@@@@@@@@@%             +@@@@@@@@@@:         
             :%@@@@@@@%             +@@@@@@@@-.          
              -+++++++=             :+++++++=            
     *@@@@@%                                   =@@@@@%   
     *@@@@@@@@@@                           %@@@@@@@@@%   
     *@@@@@@@@@@@@=                      %@@@@@@@@@@@%   
     *@@@@@@@@@@@@=                      %@@@@@@@@@@@%   
     *@@@@@@@@@@@@#=:                  =*@@@@@@@@@@@@%   
     *@@@@@@@@@@@@@@*                 :@@@@@@@@@@@@@@%   
     +%@@@@@@@@@@@@@*                 :@@@@@@@@@@@@@%*   
       =@@@@@@@@@@@@*                 :@@@@@@@@@@@@#     
          @@@@@@@@@@*                 :@@@@@@@@@@=       
              %@@@@@*                 :@@@@@@            
               .....                   ......            
                                                         
                     %%             *@-                  
                     %@@@@@@@@@@@@@@@@-                  
                       %@@@:    %@@@                     
                       %@@@:    %@@@                     
                        :%@:    %@:.                     
                         -=     ==                       
                                                         

]]
-- Debug.Message("Glitchy's library was loaded correctly! Feel free to delete this debug message later (line 125 of fusion_material_custom.lua)")

--Stuff borrowed from proc_fusion.lua
local ForcedUseZone=nil
local function GetForcedZone(chkfnf)
	local zone=(chkfnf>>40)&0xff
	if zone==0 then zone=0xff end
	return zone
end
local function returnAndClearSummonEffect(value)
	Fusion.SummonEffect=nil
	return value
end


--I guess Predaplant Chlamydosundew (89181134) is the closest thing to this so it deserves to claim the constant valu as an easter egg :-)
-- EFFECT_FUSION_MATERIAL_CUSTOM = EFFECT_FUSION_MATERIAL_CUSTOM or (89181134+TYPE_FUSION)

--Per-procedure-call state. Is nil whenever the current procedure call has no applicable handler.
--Fields: fc, tp, sumtype, contact, entries (list), locked (bool).
--Each entry: handler (Card), eff (the EFFECT_FUSION_MATERIAL_CUSTOM effect), affected (Group), effects (list of registered outfit effects), active (bool).
Fusion.CustomMaterialState = nil

--Above this many candidate outfits the subset enumeration is replaced by a simple {all-on, each single, none}.
--I do not expect many instances of these EFFECT_FUSION_MATERIAL_CUSTOM effects to apply at the same time; 4 seems reasonable to handle virtually all gamestates
--Might cause lag if set too high. Change as required...
Fusion.CustomMaterialMaxSubsets=4

--Stack of saved states, so that a Fusion procedure call started while another one is still running does not clobber the outer state
local CustomMaterialStack={}

--Default applicability (no SetValue, or SetValue is 1) = proper Fusion Summons only
local function CustomMaterialDefaultApplicable(sumtype,contact)
    return (sumtype&SUMMON_TYPE_FUSION)~=0 and not contact
end


--[[
Builds a value function (filter1) for EFFECT_FUSION_MATERIAL_CUSTOM.
- fusfilter         :   optional function(fc,e,tp) restricting the Fusion Monsters the effect applies to.
- allow_contact     :   set to true to also apply to Contact Fusions (FUSPROC_CONTACTFUS)
- allow_notfusion   :   set to true to also apply to non-Fusion procedures that still treat cards as Fusion Materials (FUSPROC_NOTFUSION)
]]
function Fusion.CustomMaterialValue(fusfilter,allow_contact,allow_notfusion)
    return  function(e,fc,sumtype,tp,contact)
                if fusfilter and not fusfilter(fc,e,tp) then return false end
                if contact then return allow_contact==true end
                if sumtype&SUMMON_TYPE_FUSION~=0 then return true end
                if sumtype==MATERIAL_FUSION then return allow_notfusion==true end
                return false
            end
end

--Returns true if the EFFECT_FUSION_MATERIAL_CUSTOM effect 'te' applies to the summon of 'fc' in the current procedure
function Fusion.IsCustomMaterialApplicable(te,fc,sumtype,tp,contact)
    local val=te:GetValue()
    if type(val)=='function' then
        return val(te,fc,sumtype,tp,contact) and true or false
    end
    if val==0 or val==1 then
        return CustomMaterialDefaultApplicable(sumtype,contact)
    end
    return false
end

--Creates one unregistered outfit effect owned by the handler
local function CustomMaterialMakeEffect(handler,code,val)
    local oe=Effect.CreateEffect(handler)
    oe:SetType(EFFECT_TYPE_SINGLE)
    oe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
    oe:SetCode(code)
    oe:SetValue(val)
    return oe
end
local function CustomMaterialAsList(v)
    if v==nil then return {} end
    if type(v)=='table' then return v end
    return {v}
end

--Builds the list of unregistered outfit effects for card 'tc' from 'outfit'
function Fusion.CustomMaterialBuildOutfit(outfit,te,tc,fc,sumtype,tp,contact)
    local handler=te:GetHandler()
    local list={}
    local type_outfit=type(outfit)
    if type_outfit=='function' then
        --(b) Builder function: returns new unregistered effects
        local rets={outfit(te,tc,fc,sumtype,tp,contact)}
        if #rets==1 and type(rets[1])=='table' then rets=rets[1] end
        for _,oe in ipairs(rets) do
            if type(oe)=='Effect' then table.insert(list,oe) end
        end
    
    elseif type_outfit=='table' and #outfit>0 and type(outfit[1])=='Effect' then
        --(c) Effect Templates: cloned per affected card
        for _,tmpl in ipairs(outfit) do
            table.insert(list,tmpl:Clone())
        end
    
    elseif type_outfit=='table' then
        --(a) Descriptor table
        ----Attribute. Monster type, Card type
        if outfit.change_attribute then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_CHANGE_ATTRIBUTE,outfit.change_attribute)) end
        if outfit.add_attribute then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_ADD_ATTRIBUTE,outfit.add_attribute)) end
        if outfit.change_race then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_CHANGE_RACE,outfit.change_race)) end
        if outfit.add_race then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_ADD_RACE,outfit.add_race)) end
        if outfit.change_type then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_CHANGE_TYPE,outfit.change_type)) end
        if outfit.add_type then table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_ADD_TYPE,outfit.add_type)) end
        
        ----Archetypes
        local chg=CustomMaterialAsList(outfit.change_setcode)
        for i,set in ipairs(chg) do
            table.insert(list,CustomMaterialMakeEffect(handler,i==1 and EFFECT_CHANGE_SETCODE or EFFECT_ADD_SETCODE,set))
        end
        local add=CustomMaterialAsList(outfit.add_setcode)
        for _,set in ipairs(add) do
            table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_ADD_SETCODE,set))
        end

        ----Names
        local chg=CustomMaterialAsList(outfit.change_code)
        for i,code in ipairs(chg) do
            table.insert(list,CustomMaterialMakeEffect(handler,i==1 and EFFECT_CHANGE_CODE or EFFECT_ADD_CODE,code))
        end
        local add=CustomMaterialAsList(outfit.add_code)
        for _,code in ipairs(add) do
            table.insert(list,CustomMaterialMakeEffect(handler,EFFECT_ADD_CODE,code))
        end
    end

    return list
end

--Builds one entry for handler 'hc' / effect 'te': evaluates the operation on the pool, registers the outfit effects on every affected card
--Returns nil if the effect has no operation or if no outfit was specified.
local function CustomMaterialBuildEntry(st,te,hc,fc,pool,sumtype,tp,contact)
    local op=te:GetOperation()
    if not op then return nil end
    local affected,outfit=op(te,fc,pool,sumtype,tp,contact)
    if outfit==nil then return nil end

    if affected==nil then
        affected=pool:Clone()
    elseif type(affected)=='function' then
        affected=pool:Filter(affected,nil,te,fc,sumtype,tp,contact)
    else
        affected=affected:Filter(function(c) return pool:IsContains(c) end, nil)
    end
    --cards immune to the handler's effect cannot be disguised (handler is exempt from this check)
    affected:Remove(function(c) return c~=hc and c:IsImmuneToEffect(te) end, nil)

    local entry = {
        handler=hc,
        eff=te,
        affected=affected,
        effects={},
        active=false
    }
    local gate = function(scard,st_sumtype,st_tp)
        return entry.active and scard==fc and st_sumtype&MATERIAL_FUSION~=0
    end

    for tc in affected:Iter() do
        for _,oe in ipairs(Fusion.CustomMaterialBuildOutfit(outfit,te,tc,fc,sumtype,tp,contact)) do
            oe:SetOperation(gate)
            oe:SetReset(RESET_EVENT|RESETS_STANDARD_PHASE_END|RESET_CHAIN)  --safety net in case the proc is aborted by an error before Fusion.CustomMaterialEnd
            if tc:RegisterEffect(oe,true) then
                table.insert(entry.effects,oe)
            end
        end
    end
    return entry
end

--[[
Called at the beginning of every Fusion procedure call (condition and operation of EFFECT_FUSION_MATERIAL_CUSTOM)
MUST be paired with Fusion.CustomMaterialEnd on every exit path
- fc        :   the Fusion Monster being Summoned
- pool      :   the material pool passed by the core
- gc        :   forced materials (may be nil)
- tp        :   the summoning player
- sumtype   :   the summon type
- contact   :   FUSPROC_CONTACTFUS flag
]]
function Fusion.CustomMaterialBegin(fc,pool,gc,tp,sumtype,contact)
    table.insert(CustomMaterialStack,Fusion.CustomMaterialState or false)   --stack of previous states
    Fusion.CustomMaterialState=nil
    if not pool or sumtype==0 then return end
    
    local st={
        fc=fc,
        tp=tp,
        sumtype=sumtype,
        contact=contact,
        entries={},
        locked=false
    }

    local scan=pool:Clone()
    if gc then scan:Merge(gc) end
    for hc in scan:Iter() do
        local effs={hc:GetCardEffect(EFFECT_FUSION_MATERIAL_CUSTOM)}
        if #effs>0 and hc:IsCanBeFusionMaterial(fc,sumtype) then
            for _,te in ipairs(effs) do
                if te:CheckCountLimit(tp) and Fusion.IsCustomMaterialApplicable(te,fc,sumtype,tp,contact) then
                    local entry=CustomMaterialBuildEntry(st,te,hc,fc,scan,sumtype,tp,contact)
                    if entry then table.insert(st.entries,entry) end
                end
            end
        end
    end
    if #st.entries>0 then
        Fusion.CustomMaterialState=st
    end
end

--Resets every registered outfit effect of the current procedure call and restores the previous state
function Fusion.CustomMaterialEnd()
    local st=Fusion.CustomMaterialState
    if st then
        for _,entry in ipairs(st.entries) do
            entry.active=false
            for _,oe in ipairs(entry.effects) do
                oe:Reset()
            end
        end
    end
    local prev=table.remove(CustomMaterialStack)
    Fusion.CustomMaterialState=prev or nil
end

--Returns entries whose handler belongs to 'g'
function Fusion.CustomMaterialEntriesIn(g)
    local st=Fusion.CustomMaterialState
    if not st then return nil end
    local t={}
    for _,entry in ipairs(st.entries) do
        if g:IsContains(entry.handler) then
            table.insert(t,entry)
        end
    end
    return t
end

--Enforces the goal-side consistency check: an active outfit requires its handler among the materials of 'g'
function Fusion.CustomMaterialHandlersIn(g)
    local st=Fusion.CustomMaterialState
    if not st then return true end
    for _,entry in ipairs(st.entries) do
        if entry.active and not g:IsContains(entry.handler) then
            return false
        end
    end
    return true
end

--evil bit helpers
--bitmasks here represent every combination of active/inactive outfit effects (0 = inactive, 1=active)
--Apply the chosen 'mask' and disable/enable the corresponding outfit effects
local function CustomMaterialSetMask(entries,mask)
    for i,entry in ipairs(entries) do
        entry.active=((mask>>(i-1))&1)==1
    end
end
--Returns how many outfit effects are active in the specific 'mask'
local function CustomMaterialPopcount(mask)
    local n=0
    while mask>0 do
        n=n+(mask&1)
        mask=mask>>1
    end
    return n
end

--[[
Returns the list of activation masks to try for 'k' entries.
- descending=true: all-on first, none last (used in legality check, the "with outfit" case is somewhat the likely one if the player decided to play the card)
- descending=false: none first, then by increasing size (used on resolution to not consume count limits needlessly)
]]
local function CustomMaterialMasks(k,descending)
    local masks={}
    if k<=Fusion.CustomMaterialMaxSubsets then
        for m=0,(1<<k)-1 do
            table.insert(masks,m)
        end
    else
        table.insert(masks,0)
        for i=1,k do
            table.insert(masks,1<<(i-1))
        end
        table.insert(masks,(1<<k)-1)
    end

    table.sort(masks,function(a,b)
        local pa,pb=CustomMaterialPopcount(a),CustomMaterialPopcount(b)
        if pa~=pb then
            if descending then return pa>pb else return pa<pb end
        end
        return a<b
    end)
    return masks
end

--[[
Runs the boolean check 'fn()' under every activation subset of 'entries' (nil=every entry of current state) until one succeeds.
Returns fn's result of the successful run, or false.
If there is no state, or if an enclosing loop owner is already enumerating (locked), 'fn()' runs once under the current activation mask
]]
function Fusion.CustomMaterialTryAny(entries,fn)
    local st=Fusion.CustomMaterialState
    if not st or st.locked then return fn() end

    entries=entries or st.entries
    local k=#entries
    if k==0 then return fn() end

    st.locked=true
    local res=false
    for _,mask in ipairs(CustomMaterialMasks(k,true)) do
        CustomMaterialSetMask(entries,mask)
        res=fn()
        if res then break end
    end
    CustomMaterialSetMask(entries,0)
    st.locked=false
    return res
end

--[[
Operation-side resolution.
- sg                :   The group the player finally selected
- tp                :   The summoning player
- completeCheck     :   A function. completeCheck() must return true iff 'sg' is legal under the CURRENT activation mask.
                        The cheapest subset (none first) that makes 'sg' legal is chosen; for its handlers the count limit is consumed
                        and a HINT_CARD is shown
The outfit effects are reset by Fusion.CustomMaterialEnd right after Duel.SetFusionMaterial
]]
function Fusion.CustomMaterialResolve(sg,tp,completeCheck)
    local st=Fusion.CustomMaterialState
    if not st then return end
    local entries=Fusion.CustomMaterialEntriesIn(sg)
    if #entries==0 then return end

    local was_locked=st.locked
    st.locked=true
    local chosen=nil
    for _,mask in ipairs(CustomMaterialMasks(#entries,false)) do
        CustomMaterialSetMask(entries,mask)
        if completeCheck() then
            chosen=mask
            break
        end
    end

    CustomMaterialSetMask(entries,chosen or 0)
    st.locked=was_locked
    if chosen and chosen~=0 then
        for i,entry in ipairs(entries) do
            if ((chosen>>(i-1))&1)==1 then
                entry.eff:UseCountLimit(tp)
                Duel.Hint(HINT_CARD,tp,entry.handler:GetOriginalCode())
            end
        end
    end
end

--#######################################################
--MODIFIED proc_fusion.lua FUNCTIONS
--#######################################################


--=========================
--SIMPLE MIX FAMILY
--=========================
local _ConditionMix, _OperationMix, _ConditionFilterMix, _CheckMixGoal =
Fusion.ConditionMix, Fusion.OperationMix, Fusion.ConditionFilterMix, Fusion.CheckMixGoal

function Fusion.ConditionMix(insf,sub,...)
    local ogfunc=_ConditionMix(insf,sub,...)
	local funs={...}
	return	function(e,g,gc,chkfnf,summonEff)
				local mustg=nil
				local c=e:GetHandler()
				local tp=c:GetControler()
				local chkf=chkfnf&0xff
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if listedmats then
					sumtype=0
				elseif contact or notfusion then
					sumtype=MATERIAL_FUSION
				end

                --EFFECT_FUSION_MATERIAL_CUSTOM: collect the applicable handlers of the pool and register their
                --outfit effs
                Fusion.CustomMaterialBegin(c,g,gc,tp,sumtype,contact)
                local res=ogfunc(e,g,gc,chkfnf,summonEff)
                Fusion.CustomMaterialEnd()
				return res
			end
end
function Fusion.OperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf,summonEff)
				Fusion.SummonEffect=summonEff
				local chkf=chkfnf&0xff
				ForcedUseZone=GetForcedZone(chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local cancelable=(chkfnf&(FUSPROC_CONTACTFUS|FUSPROC_CANCELABLE))~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if listedmats then
					sumtype=0
				elseif contact or notfusion then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				--EFFECT_FUSION_MATERIAL_CUSTOM: same set-up as in the condition (the operation receives the pool as eg)
				Fusion.CustomMaterialBegin(c,eg,gc,tp,sumtype,contact)
				local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,table.unpack(funs))
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				local sg=Group.CreateGroup()
				if gc then
					mustg:Merge(gc)
				end
				for tc in aux.Next(mustg) do
					sg:AddCard(tc)
					if not contact and tc:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
						local eff={gc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
						for i=1,#eff do
							local f=eff[i]:GetValue()
							mg:Match(Auxiliary.HarmonizingMagFilter,tc,eff[i],f)
						end
					end
				end
				local p=tp
				local sfhchk=false
				if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp
					Duel.ConfirmCards(1-tp,mg)
					if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				while #sg<#funs do
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_FMATERIAL)
					local tc=Group.SelectUnselect(mg:Filter(Fusion.SelectMix,sg,tp,mg,sg,mustg:Filter(aux.TRUE,sg),c,sub,sub,contact,sumtype,chkf,table.unpack(funs)),sg,p,false,cancelable and #sg==0,#funs,#funs)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				--EFFECT_FUSION_MATERIAL_CUSTOM: settle which outfits (if any) the selected group actually needs;
				--count limits are consumed only for those.
				Fusion.CustomMaterialResolve(sg,tp,function()
					return #sg==#funs and sg:Includes(mustg)
						and Fusion.CheckMixGoal(tp,sg,c,sub,sub,contact,sumtype,chkf,table.unpack(funs))
				end)
				Duel.SetFusionMaterial(sg)
				Fusion.CustomMaterialEnd()
				Fusion.SummonEffect=nil
			end
end
function Fusion.ConditionFilterMix(c,fc,sub,sub2,contact,sumtype,matcheck,tp,...)
    --EFFECT_FUSION_MATERIAL_CUSTOM: A card stays in the pool if it meets a requirement under SOME outfit
    --configuration (including 'no outfit'). Which config is actually usable is settled by the group checks,
    --where the handler's presence among the mats is enforced
    local funs={...}
    return Fusion.CustomMaterialTryAny(nil,function()
        return _ConditionFilterMix(c,fc,sub,sub2,contact,sumtype,matcheck,tp,table.unpack(funs))
    end)
end
function Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
    --EFFECT_FUSION_MATERIAL_CUSTOM: The group is legal if it is legal under some subset of the outfits
    --whose handlers are in 'sg'
    local funs={...}
    return Fusion.CustomMaterialTryAny(Fusion.CustomMaterialEntriesIn(sg),function()
        if not Fusion.CustomMaterialHandlersIn(sg) then return false end
        return _CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,table.unpack(funs))
    end)
end

--=========================
--MIXREP FAMILY
--=========================

local _ConditionMixRep, _OperationMixRep, _CheckMixRepGoal, _CheckSelectMixRep, _SelectMixRep =
Fusion.ConditionMixRep, Fusion.OperationMixRep, Fusion.CheckMixRepGoal, Fusion.CheckSelectMixRep, Fusion.SelectMixRep

function Fusion.ConditionMixRep(insf,sub,fun1,minc,maxc,...)
    local ogfunc=_ConditionMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf,summonEff)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local chkf=chkfnf&0xff
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if listedmats then
					sumtype=0
				elseif contact or notfusion then
					sumtype=MATERIAL_FUSION
				end
                --EFFECT_FUSION_MATERIAL_CUSTOM: collect the applicable handlers of the pool and register their outfit effects
				Fusion.CustomMaterialBegin(c,g,gc,tp,sumtype,contact)
                local res=ogfunc(e,g,gc,chkfnf,summonEff)
                Fusion.CustomMaterialEnd()
				return res
			end
end

function Fusion.OperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf,summonEff)
				Fusion.SummonEffect=summonEff
				local chkf=chkfnf&0xff
				ForcedUseZone=GetForcedZone(chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
				local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
				local cancelable=(chkfnf&(FUSPROC_CONTACTFUS|FUSPROC_CANCELABLE))~=0
				local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
				local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
				if listedmats then
					sumtype=0
				elseif contact or notfusion then
					sumtype=MATERIAL_FUSION
				end
				local matcheck=e:GetValue()
				local sub=not listedmats and (sub or notfusion) and not contact
				--EFFECT_FUSION_MATERIAL_CUSTOM: same set-up as in the condition (the operation receives the pool as eg)
				Fusion.CustomMaterialBegin(c,eg,gc,tp,sumtype,contact)
				local sg=Group.CreateGroup()
				local mg=eg:Filter(Fusion.ConditionFilterMix,c,c,sub,sub,contact,sumtype,matcheck,tp,fun1,table.unpack(funs))
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
				if contact then mustg:Clear() end
				if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c,sumtype) then
					Fusion.CustomMaterialEnd()
					return returnAndClearSummonEffect(false)
				end
				if gc then
					mustg:Merge(gc)
				end
				sg:Merge(mustg)
				local p=tp
				local sfhchk=false
				if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
					p=1-tp
					Duel.ConfirmCards(1-tp,mg)
					if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then sfhchk=true end
				end
				while #sg<maxc+#funs do
					local cg=mg:Filter(Fusion.SelectMixRep,sg,tp,mg,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local finish=Fusion.CheckMixRepGoal(tp,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs)) and not Fusion.CheckExact and not (Fusion.CheckMin and #sg<Fusion.CheckMin)
					local cancel=(cancelable and #sg==0)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,p,finish,cancel)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sfhchk then Duel.ShuffleHand(tp) end
				--EFFECT_FUSION_MATERIAL_CUSTOM: settle which outfits (if any) the selected group actually needs;
				--count limits are consumed only for those.
				Fusion.CustomMaterialResolve(sg,tp,function()
					return sg:Includes(mustg)
						and Fusion.CheckMixRepGoal(tp,sg,mustg,c,sub,sub,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
				end)
				Duel.SetFusionMaterial(sg)
				Fusion.CustomMaterialEnd()
				Fusion.SummonEffect=nil
			end
end
function Fusion.CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
    --EFFECT_FUSION_MATERIAL_CUSTOM: inside SelectMixRep, it runs
    --under the activation mask chosen by that loop
    local funs={...}
    return Fusion.CustomMaterialTryAny(Fusion.CustomMaterialEntriesIn(sg),function()
        if not Fusion.CustomMaterialHandlersIn(sg) then return false end
        return _CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
    end)
end
function Fusion.CheckSelectMixRep(tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
    --EFFECT_FUSION_MATERIAL_CUSTOM: goal acceptance also requires every active handler to be among the materials
	local ogres=_CheckSelectMixRep(tp,mg,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
    return ogres and Fusion.CustomMaterialHandlersIn(g)
end
function Fusion.SelectMixRep(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,...)
	local mg2=mg:Clone()
	local totalcount=#{...}
	local mustgcount=#mustg
	-- local rg=Group.CreateGroup()
	if Fusion.CheckExact then
		if Fusion.CheckExact<(minc+totalcount) or mustgcount>Fusion.CheckExact then return false end
		maxc=Fusion.CheckExact-totalcount
		minc=Fusion.CheckExact-totalcount
	end
	if Fusion.CheckMax then
		if Fusion.CheckMax<(minc+totalcount) or mustgcount>Fusion.CheckMax then return false end
		maxc=math.min(maxc,Fusion.CheckMax-totalcount)
	end
	if Fusion.CheckMin then
		if Fusion.CheckMin>(maxc+totalcount) then return false end
		minc=math.max(minc,Fusion.CheckMin-totalcount)
	end
	--c has the fusion limit
	if not contact and c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
		for i,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
				-- mg:Merge(rg)
				return false
			end
			local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			-- rg:Merge(sg2)
			mg2:Sub(sg2)
			if mustgcount>0 and not mg2:Includes(mustg) then
				return false
			end
		end
	end
	--A card in the selected group has the fusion lmit
	if not contact then
		local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					-- mg:Merge(rg)
					return false
				end
			end
		end
	end
	sg:AddCard(c)

    --EFFECT_FUSION_MATERIAL_CUSTOM: merge checks
    local funs={...}
	local res=Fusion.CustomMaterialTryAny(nil,function()
        if Fusion.CheckAdditional and not Fusion.CheckAdditional(tp,sg,fc,sumtype,tp) then
            return false
        elseif Fusion.CheckMixRepGoal(tp,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs)) then
            return true
        else
            local g=Group.CreateGroup()
            res=sg:IsExists(Fusion.CheckMixRepSelected,1,nil,tp,mg2,sg,mustg,g,fc,sub,sub2,contact,sumtype,chkf,fun1,minc,maxc,table.unpack(funs))
        end
    end)
	sg:RemoveCard(c)
	-- mg:Merge(rg)
	return res
end

--=========================
--MIXREPUNFIX FAMILY (no script uses these so I did not implement the custom procedures there as there's no point)
--=========================