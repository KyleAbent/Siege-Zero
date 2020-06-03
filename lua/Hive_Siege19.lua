/*
breaks cysts
if Server then

local orig = Hive.OnInitialized
function Hive:OnInitialized()
orig(self)
    local origin = self:GetOrigin()
    local nearest = GetNearest(self:GetOrigin(), "TechPoint" ) //nearest should be alien tech not marine :P
    //  Print("Eh? 1")
    if nearest then
  //  Print("Eh? 2")
        origin = origin + Vector(0,nearest.height,0)
        self:SetOrigin(origin)
    end
    
end
end

*/

if Server then

local kEggMinRange = 4
local kEggMaxRange = 22

function Hive:DoOriginal()
PROFILE("Hive:GenerateEggSpawns")



    local origin = self:GetModelOrigin()

    for _, eggSpawn in ipairs(Server.eggSpawnPoints) do
        if (eggSpawn - origin):GetLength() < kEggMaxRange then
            table.insert(self.eggSpawnPoints, eggSpawn)
        end
    end

    local minNeighbourDistance = 1.5
    local maxEggSpawns = 20
    local maxAttempts = maxEggSpawns * 10

    ///if #self.eggSpawnPoints >= maxEggSpawns then return end

    local extents = LookupTechData(kTechId.Egg, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- pre-generate maxEggSpawns, trying at most maxAttempts times
    for index = 1, maxAttempts do
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kEggMinRange, kEggMaxRange, EntityFilterAll())

        if spawnPoint then
            -- Prevent an Egg from spawning on top of a Resource Point.
            local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) == 0

            if notNearResourcePoint then
                spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
            else
                spawnPoint = nil
            end
        end

        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""

        local sameLocation = true //spawnPoint ~= nil //and locationName == hiveLocationName //Not true but get location name and match it. this is lazy for now. haha.

        if spawnPoint ~= nil and sameLocation then

            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do

                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then

                    tooCloseToNeighbor = true
                    break

                end

            end

            if not tooCloseToNeighbor then

                table.insert(self.eggSpawnPoints, spawnPoint)
                //if #self.eggSpawnPoints >= maxEggSpawns then
                    //break
                //end

            end

        end

    end

   // if #self.eggSpawnPoints < kAlienEggsPerHive * 2 then
     //   Print("Hive in location \"%s\" only generated %d egg spawns (needs %d). Place some egg enteties.", GetLocationForPoint(self:GetOrigin()).name, table.icount(self.eggSpawnPoints), kAlienEggsPerHive)
   // end
end

function Hive:DoNew() 
    local power = GetRandomConnectedCyst() //GetRandomDisabledPower()
    if not power then
        print("Hive DoNew power not found???")
        return
    end
    local origin = power:GetOrigin()
    local minNeighbourDistance = 1.5
    local maxEggSpawns = 20
    local maxAttempts = maxEggSpawns * 10

    ///if #self.eggSpawnPoints >= maxEggSpawns then return end

    local extents = LookupTechData(kTechId.Egg, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- pre-generate maxEggSpawns, trying at most maxAttempts times
    for index = 1, maxAttempts do
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kEggMinRange, kEggMaxRange, EntityFilterAll())

        if spawnPoint then
            -- Prevent an Egg from spawning on top of a Resource Point.
            local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) == 0

            if notNearResourcePoint then
                spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
            else
                spawnPoint = nil
            end
        end

        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""

        local sameLocation = true //spawnPoint ~= nil and locationName == hiveLocationName //Not true but get location name and match it. this is lazy for now. haha.

        if spawnPoint ~= nil and sameLocation then

            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do

                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then

                    tooCloseToNeighbor = true
                    break

                end

            end

            if not tooCloseToNeighbor then

                table.insert(self.eggSpawnPoints, spawnPoint)
                //if #self.eggSpawnPoints >= maxEggSpawns then
                   // break
                //end

            end

        end

    end

    //if #self.eggSpawnPoints < kAlienEggsPerHive * 2 then
   //     Print("Power in location \"%s\" only generated %d egg spawns (needs %d). Place some egg enteties.", GetLocationForPoint(power).name, table.icount(self.eggSpawnPoints), kAlienEggsPerHive)
   // end
end
function Hive:GenerateEggSpawnsModified()
    //lets see how much it drains perf to recalculate egg spawns. With limit beyond the count/clamp. heh.ActualAlienFormula
    print("Hive GenerateEggSpawnsModified")
    self.eggSpawnPoints = { }
    self:DoOriginal()
    self:DoNew()
    //Better way? Onhive init, generate egg spawns for every room and only allow spawning in disabled power
    //Or just have the old egg spawns and add new ones to it
end


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
        local position = table.random(self.eggSpawnPoints)

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
                //table.remove(self.eggSpawnPoints, position) //so remove it from table ugh
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

