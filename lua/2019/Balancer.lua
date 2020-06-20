-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/
if Server then
    
local function On_Contam_chanceWhip(origin,imaginator)
    //for loop 3x? lol
    random = math.random(1,100)
    if random <= 10 then
        if imaginator.activeWhips < 13 then
            local entity = CreateEntityForTeam(kTechId.Whip, origin, 2)
            random = math.random(1,100)
            if random <= 50 then
                entity:SetConstructionComplete()
                //doChain(entity)
            end
        else
            local whip = GetNearest(origin, "Whip", 2, function(ent) return not ent:GetIsInCombat() end)
            if whip  then 
                whip:SetOrigin(origin)
                //doChain(whip)
                return 
            end
        end
    end
end
local function On_Contam_chanceShift(origin,imaginator)
    random = math.random(1,100)
    if random <= 10 then
        if imaginator.activeShifts < 14 then
            local entity = CreateEntityForTeam(kTechId.Shift, origin, 2)
            random = math.random(1,100)
            if random <= 50 then
                entity:SetConstructionComplete()
                //doChain(entity)
            end
        else
            local shift = GetNearest(origin, "Shift", 2, function(ent) return not ent:GetIsInCombat() end)
            if shift then 
                shift:SetOrigin(origin)
                //doChain(shift)
                return 
            end
        end
     end
end
local function On_Contam_chanceShade(origin,imaginator)
    random = math.random(1,100)
    if random <= 10 then
        if imaginator.activeShades < 13 then
            local entity = CreateEntityForTeam(kTechId.Shade, origin, 2)
            random = math.random(1,100)
            if random <= 50 then
                entity:SetConstructionComplete()
                //doChain(entity)
            end
        else
            local shade = GetNearest(origin, "Shade", 2, function(ent) return not ent:GetIsInCombat() and not (GetSiegeDoorOpen() and GetIsPointWithinHiveRadius(ent:GetOrigin()) ) end)
            if shade then 
                shade:SetOrigin(origin)
                //doChain(shade)
                return 
            end
        end
    end
end
local function On_Contam_chanceCrag(origin,imaginator)
    random = math.random(1,100)
    if random <= 10 then
        if imaginator.activeCrags < 13 then
            local entity = CreateEntityForTeam(kTechId.Crag, origin, 2)
            random = math.random(1,100)
            if random <= 50 then
                entity:SetConstructionComplete()
                doChain(entity)
            end
        else
            local crag = GetNearest(origin, "Crag", 2, function(ent) return not ent:GetIsInCombat() and not (GetSiegeDoorOpen() and GetIsPointWithinHiveRadius(ent:GetOrigin()) ) end)
            if crag then 
                crag:SetOrigin(origin)
                doChain(crag)
                return 
            end
        end
    end
end
local function On_Contam_chanceHydra(origin)
    random = math.random(1,100)
    if random <= 10 then
        local hydras = #GetEntitiesForTeam( "Hydra", 2 )
        if hydras < 13 then
            local entity = CreateEntityForTeam(kTechId.Hydra, origin, 2)
        end
    end
end
local function On_Contam_chanceRupture(origin)
    random = math.random(1,100)
    if random <= 30 then
       local entity = CreateEntityForTeam(kTechId.Rupture, origin, 2)
    end
end
    function Conductor:SpawnContamination(powerpoint)
            //HasThreeHives is true if 2 are built and 1 is unbuilt. Hmm?
        --if not GetHasThreeHives() or not GetFrontDoorOpen() then
        if not GetFrontDoorOpen() or not GetHasThreeBuiltHives() then
            return
        end -- although not requiring biomass. Maybe later.

        local origin = FindFreeSpace(powerpoint:GetOrigin())
        local contam = CreateEntity(Contamination.kMapName, FindFreeSpace(origin, 1, 8), 2)
        //doChain(contam)
        CreatePheromone(kTechId.ThreatMarker,contam:GetOrigin(), 2)
        //if not bot :getisincombat then setorigin
        SetDirectorLockedOnEntity(contam)
        //local egg = CreateEntity(Egg.kMapName, FindFreeSpace(origin, 1, 8), 2)
        //egg:SetHive(GetRandomHive())

        local imaginator = GetImaginator()
        //On_Contam_chanceWhip(origin,imaginator)
        //On_Contam_chanceShift(origin,imaginator)
        //On_Contam_chanceShade(origin,imaginator)
        //On_Contam_chanceCrag(origin,imaginator)
        On_Contam_chanceHydra(origin)
        On_Contam_chanceRupture(origin)
       
        
        local random = math.random(1,100)
        if GetSiegeDoorOpen() or random <= 10 then
            random = math.random(1,100)
            if random <= 10 then
                --chance it?
                for index, bot in ipairs(GetEntitiesForTeam("Player", 2)) do
                    local client = bot:GetClient()
                    if client and client:GetIsVirtual() then
                        if bot:GetIsAlive() and (bot.GetIsInCombat and not bot:GetIsInCombat()) then
                            bot:SetOrigin(FindFreeSpace(origin))
                        end
                    end
                end
            end
        end
        
    end

    local function GetDroppackSoundName(techId)

        if techId == kTechId.MedPack then
            return MedPack.kHealthSound
        elseif techId == kTechId.AmmoPack then
            return AmmoPack.kPickupSound
        elseif techId == kTechId.CatPack then
            return CatPack.kPickupSound
        end

    end
    local function PackRulesHere(who, origin, techId, self)
        local mapName = LookupTechData(techId, kTechDataMapName)
        if mapName then
            local desired = FindFreeSpace(origin, 0, 4)
             if desired ~= nil then
                position = desired
             end
            local droppack = CreateEntity(mapName, position, 1)
        end
    end
    
    local function PackQualificationsHere(who, self)
        local weapon = who:GetActiveWeapon()
        local medpacks = GetEntitiesForTeamWithinRange("MedPack", 1, who:GetOrigin(), 8)//Greater distance?
        local ammopacks = GetEntitiesForTeamWithinRange("AmmoPack", 1, who:GetOrigin(), 8)
        local random = -1
            if who:GetHealth() <= 90 and #medpacks <= 4 then
                PackRulesHere(who, who:GetOrigin(), kTechId.MedPack, self)
            elseif  weapon and weapon.GetAmmoFraction and weapon:GetAmmoFraction() <= .65 and #ammopacks <= 4  then
                PackRulesHere(who, who:GetOrigin(), kTechId.AmmoPack, self)
            elseif who:GetIsInCombat() then
                random = math.random(1,3)//from 2 to 3
            end
            if random == 1 then
                PackRulesHere(who, who:GetOrigin(), kTechId.CatPack, self)
            elseif random == 2 then//from else to if random == 2 (trying this instead of having a break (This currently does all marines at once lol) )
                who:ActivateNanoShield()
                SetDirectorLockedOnEntity(who)
            end
    end
    
    function Conductor:HandoutMarineBuffs()
                for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
                if marine:GetIsAlive() and not marine:isa("Commander") then
                     PackQualificationsHere(marine, self)
                    end
                 end
                 return true
    end
end //of server