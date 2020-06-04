if Server then



-- overwrite get rid of scale with player count

function Hive:UpdateSpawnEgg()

    local success = false
    local egg

    local eggCount = self:GetNumEggs()
    if eggCount < kAlienEggsPerHive then

        egg = self:SpawnEgg(false)
        success = egg ~= nil

    end

    return success, egg

end

function Hive:HatchEggs() --overwrite get rid of scaleplayer
    local amountEggsForHatch = kEggsPerHatch
    local eggCount = 0
    for i = 1, amountEggsForHatch do
        local egg = self:SpawnEgg(true)
        if egg then eggCount = eggCount + 1 end
    end

    if eggCount > 0 then
        self:TriggerEffects("hatch")
        return true
    end

    return false
end

function Hive:GetNumEggs() --Well all 3 hives in same location, and if each hive is suppose to have X eggs then assign them the hive id via egg

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())

    for index, egg in ipairs(eggs) do

        if self == egg:GetHive() and egg:GetIsAlive() and egg:GetIsFree() and not egg.manuallySpawned then
            numEggs = numEggs + 1
        end

    end

    return numEggs

end


//override for slight variation heh from specified spawnpoint to randomized spawnpoint
//and to remove it from table now that its updated frequently

function Hive:SpawnEgg(manually)
    if self.eggSpawnPoints == nil or #self.eggSpawnPoints == 0 then

        --Print("Can't spawn egg. No spawn points!")
        return nil

    end


    local maxAvailablePoints = #self.eggSpawnPoints
    for i = 1, maxAvailablePoints do

        //local position = self.eggSpawnPoints[j] the only change lol
        local which = math.random(1,2)
        local position = nil
        if which == 1 then
            position = table.random(self.eggSpawnPoints)
        elseif which == 2 then
            local power = GetRandomDisabledPower()
            if power then
                position = power:GetRandomSpawnPoint() //that is infested
            end
        end


        -- Need to check if this spawn is valid for an Egg and for a Skulk because
        -- the Skulk spawns from the Egg.
        local validForEgg = position and GetCanEggFit(position)

        if validForEgg then

            local egg = CreateEntity(Egg.kMapName, position, self:GetTeamNumber())

            if egg then
                egg:SetHive(self)


                -- Randomize starting angles
                local angles = self:GetAngles()
                angles.yaw = math.random() * math.pi * 2
                egg:SetAngles(angles)

                -- To make sure physics model is updated without waiting a tick
                egg:UpdatePhysicsModel()

                self.timeOfLastEgg = Shared.GetTime()

                if manually then
                    egg.manuallySpawned = true
                end
                return egg

            end

        end


    end

    return nil
end


end --server



local orig_Hive_OnConstructionComplete = Hive.OnConstructionComplete
function Hive:OnConstructionComplete()
    orig_Hive_OnConstructionComplete(self)
    local imaginator = GetImaginator()
    if imaginator and ( imaginator:GetIsAlienEnabled() or not GetGameStarted() ) then
       // self.bioMassLevel = 3
        UpdateTypeOfHive(self) //delay?
    end
end

/*
local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete()
    orig_Hive_OnResearchComplete(self)
    //if self.bioMassLevel == 3 then return end
    local imaginator = GetImaginator()
    if imaginator:GetIsAlienEnabled() then
       // self.bioMassLevel = 3
        UpdateTypeOfHive(self)
    end
end

*/

