-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/
if Server then
    function Conductor:CountUnBuiltNodes()
        local unbuilt = 0
            for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                if powerpoint:GetIsBuilt() and powerpoint:GetIsDisabled() then
                    unbuilt = unbuilt + 1
                end
            end
        return unbuilt
    end

    function Conductor:FirePhaseCannons(powerpoint)

        if not GetHasThreeHives() or not GetFrontDoorOpen() then
            return
        end -- although not requiring biomass. Maybe later.

        local origin = FindFreeSpace(powerpoint:GetOrigin())
        CreateEntity(Contamination.kMapName, FindFreeSpace(origin, 1, 8), 2)
        local egg = CreateEntity(Egg.kMapName, FindFreeSpace(origin, 1, 8), 2)
        egg:SetHive(GetRandomHive())

        if GetSiegeDoorOpen() then
            local random = math.random(1,100)
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
                random = math.random(1,2)
            end
            if random == 1 then
                PackRulesHere(who, who:GetOrigin(), kTechId.CatPack, self)
            else
                who:ActivateNanoShield()
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