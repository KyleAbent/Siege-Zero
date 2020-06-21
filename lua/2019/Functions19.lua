--Kyle Abent :P 
--Here I try to write "English" translition to LUA that make code readable 
--I don't think this is case of "Not Invented Here Syndrome" 
--Alot of these functions mimic NS2Utility by having global functions to use
function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end
function GetIsOriginInHiveRoom(point)  
 local location = GetLocationForPoint(point)
 local hivelocation = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999)
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
     local hive = hives[i]
     hivelocation = GetLocationForPoint(hive:GetOrigin())
     break
     end
     
     if location == hivelocation then return true end
     
     return false
     
end
function GetPossibleAlienResRoomNode()
    //if one res point has about 4 others in close radius?
    local possible = {}
    local count = 5
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
            local resnodes = GetEntitiesWithinRange("ResourcePoint", respoint:GetOrigin(), 20) //try catch in the function calling
            for i = 1, #resnodes do 
                local resnode = resnodes[i]
                if GetLocationForPoint(resnode:GetOrigin()) == GetLocationForPoint(respoint:GetOrigin()) then
                    count = count + 1
                    if count >= 5 then
                        table.insert(possible, GetPowerPointForLocation( GetLocationForPoint( respoint:GetOrigin() ).name ) )
                        break
                    end
                end
            end
  end
  
  return possible
  
end
function SetDirectorLockedOnEntity(ent)
    if ent ~= nil then 
        for _, director in ientitylist(Shared.GetEntitiesWithClassname("AvocaSpectator")) do
            if director:CanChange() then // well this is messy haha , why not have an active table? although would be constantly transition invalid and valid
                 local viporigin = ent:GetOrigin()
                 director:SetOrigin(viporigin)
                 //director:SetOffsetAngles(ent:GetAngles()) //if iscam
                 //local dir = GetNormalizedVector(viporigin - director:GetOrigin())
                 //local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
                 //director:SetOffsetAngles(angles)
                 director:SetLockOnTarget(ent:GetId())
            end
        end
     end
end
function GetRandomConstructEntityNearMostRecentPlacedCyst()
   local conductor = GetConductor()
   local nearestof = GetNearestMixin(conductor:GetMostRecentCystOrigin(), "Construct", 2, function(ent) return ent:GetIsAlive() end)
   if nearestof then
     return nearestof
   end
end
function FindNonBusyRoboticsFactory()
    local count = 0
    robos = {}
    for index, robofa in ipairs(GetEntitiesForTeam("RoboticsFactory", 1)) do
        if  robofa:GetIsBuilt() and not robofa:GetIsResearching() and not robofa.open then 
            table.insert(robos,  robofa)
        end
    end
    if count >= 1 then
        return table.random(robofa)
    end
    return false
end
function GetHasOneBuiltHive()
    local count = 0
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
        if hive:GetIsBuilt() then 
            count = count + 1
        end
    end
    if count >= 1 then
        return true
    end
    return false
end
function GetHasThreeBuiltHives()
    local count = 0
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
        if hive:GetIsBuilt() then 
            count = count + 1
        end
    end
    if count >= 3 then
        return true
    end
    return false
end
function GetIsPointWithinChairRadius(point)     
  
   local cc = GetEntitiesWithinRange("CommandStation", point, ARC.kFireRange)
   if #cc >= 1 then return true end

   return false
end

function GetHasBatteryInRoom(where)

    local batteries = GetEntitiesForTeamWithinRange("SentryBattery", 1, where, 999999)
    if #batteries == 0 then return false end
    for i = 1, #batteries do
        local ent = batteries[i]//match name? 
        if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
    end

    return false  
                
end

function GetHasChairInRoom(where)

    local ccs = GetEntitiesForTeamWithinRange("CommandStation", 1, where, 999999)
    if #ccs == 0 then return false end
    for i = 1, #ccs do
        local ent = ccs[i]//match name? 
        if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
    end

    return false  
                
end
function GetFrontDoorRoomForAlien()
--Power Off room closest to door 
end
function GetFrontDoorRoomForMarine()
--Power On room closest to door 
end
function GetIsInFrontDoorRoom(who)

    local door = GetNearest(who:GetOrigin(), "FrontDoor", nil,  function(ent) return ent:isa("FrontDoor") and GetLocationForPoint(who:GetOrigin()) == GetLocationForPoint(ent:GetOrigin()) end ) // or within range a room over?
    if door then
        return true
    end

    return false 
                
end

function GetFrontDoor()

    local ccs = {}
    for _, cc in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
        if cc then table.insert(ccs,cc) end
    end
    return table.random(ccs)
                
end

function GetHasFourTunnelInHiveRoom()

    local tunnels = GetEntitiesForTeamWithinRange("TunnelEntrance", 2, GetRandomHive():GetOrigin(), 999999) //try catch in the function calling
    if #tunnels == 0 then return false end
    local count = 0
    for i = 1, #tunnels do
        local ent = tunnels[i]
        if GetIsOriginInHiveRoom(ent:GetOrigin()) then
           count = count + 1
        end
    end

    return count == 4  
                
end

function GetHasTunnelInRoom(where)

    local tunnels = GetEntitiesForTeamWithinRange("TunnelEntrance", 2, where, 999999)
    if #tunnels == 0 then return false end
    for i = 1, #tunnels do
        local ent = tunnels[i]
        if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
    end

    return false  
                
end

function GetHasPGInRoom(where)

    local pgs = GetEntitiesForTeamWithinRange("PhaseGate", 1, where, 999999)
    if #pgs == 0 then return false end
    for i = 1, #pgs do
        local ent = pgs[i]
        if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
    end

    return false  
                
end

function GetDrifterBuff()
    local buffs = {}
    if GetHasShadeHive()  then table.insert(buffs,kTechId.Hallucinate) end
    if GetHasCragHive()  then table.insert(buffs,kTechId.MucousMembrane) end
    if GetHasShiftHive()  then table.insert(buffs,kTechId.EnzymeCloud) end
    return table.random(buffs)
end
function UpdateTypeOfHive(who)
    local techids = {}
    if GetHasCragHive() == false then table.insert(techids, kTechId.CragHive) end
    if GetHasShadeHive() == false then table.insert(techids, kTechId.ShadeHive) end
    if GetHasShiftHive() == false then table.insert(techids, kTechId.ShiftHive) end

    if #techids == 0 then return end 
    for i = 1, #techids do
        local current = techids[i]
        if who:GetTechId() == techid then
            table.remove(techids, current)
        end
    end

    local random = table.random(techids)

    who:UpgradeToTechId(random) 
    who:GetTeam():GetTechTree():SetTechChanged()

end

local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels
function isPathable(position)
--Gorgetunnelability local function
    if position == nil then print("isPathable pos is nil???") return false end
    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end
function TresCheck(team, cost)//True if setup ???
    if team == 1 then
        return GetGamerules().team1:GetTeamResources() >= cost
    elseif team == 2 then
        return GetGamerules().team2:GetTeamResources() >= cost
    end
end
function GetRandomCC()
    local ccs = {}
    for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        if cc and cc:GetIsBuilt() then table.insert(ccs,cc) end
    end
    return table.random(ccs)
end

function GetRandomDisabledPower()
    local powers = {}
    local isSetup = not GetSetupConcluded()
    for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsDisabled() and not GetIsInSiege(power) then
            if isSetup then // I don't want rooms be built which are yet to be undetermined in setup. ugh. players mark ownership by entering room. then spawn.
                if power:GetHasBeenToggledDuringSetup() then
                    table.insert(powers,power)
                end
            else
                table.insert(powers,power)
            end
        end
    end
    if #powers == 0 then return nil end
    local power = table.random(powers)
    return  power
end
function GetRandomConnectedCyst()
    local cysts = {}
    for _, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
        if  cyst:GetIsBuilt() and cyst:GetIsActuallyConnected() then
          table.insert(cysts,cyst)
        end
    end
    if #cysts == 0 then return nil end
    local cyst = table.random(cysts)
    return  cyst
end
function FindArcHiveSpawn(where)    
    for index = 1, 24 do
        local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, 2, 18, EntityFilterAll())
        local inradius = false

        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
            inradius = #GetEntitiesWithinRange("Hive", spawnPoint, ARC.kFireRange) >= 1
        end
         Print("FindArcHiveSpawn inradius is %s", inradius)
        local sameLocation = spawnPoint ~= nil and GetWhereIsInSiege(spawnPoint)
         Print("FindArcHiveSpawn sameLocation is %s", sameLocation)

        if spawnPoint ~= nil and sameLocation and inradius then
            return spawnPoint
        end
    end
     Print("No valid spot found for FindArcHiveSpawn")
    return nil --FindFreeSpace(where, .5, 48)
end

function GetASiegeLocation()
    local siegeloc = nil

    for _, loc in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if string.find(loc.name, "siege") or string.find(loc.name, "Siege") and GetPowerPointForLocation(loc.name) ~= nil then
        siegeloc = loc
        end
    end

    if siegeloc then 
        return siegeloc
    end

    return nil
end
function getHasCystNear(where)
   local cyst = GetEntitiesWithinRange("Cyst", where, kCystMaxParentRange/2)
   if #cyst >= 1 then return true end
   return false
end
function getIsNearHive(where)
   local hive = GetEntitiesWithinRange("Hive", where, kHiveCystParentRange - 3)
   if #hive >= 1 then return true end
   return false
end
function doChain(entity) 
    //print("UHHH")
    local where = entity:GetOrigin()
    //if not entity:isa("Contamination") and GetIsPointOnInfestation(where) then return end
    local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
    if (#cyst >=1) then return end
    local conductor = GetConductor()

    local splitPoints = GetCystPoints(entity:GetOrigin(), true, 2)
    for i = 1, #splitPoints do
        //if getIsNearHive(splitPoints[i]) or ( not getHasCystNear(splitPoints[i]) and not GetIsPointOnInfestation(splitPoints[i]) ) then
            local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
            if not (#cyst >=1) then 
            local csyt = CreateEntity(Cyst.kMapName,splitPoints[i],2) //FindFreeSpace(splitPoints[i], 1, 7), 2)
            if not GetSetupConcluded() then csyt:SetConstructionComplete() end
            if i == #splitPoints then //last one
                //conductor:SetMostRecentCyst(cyst:GetId())
                Print("Setting Conductor most recent cyst origin")
                conductor:SetMostRecentCystOrigin(splitPoints[i])
            end 
        end
    end
end
function GetIsPointWithinTechPointRadius(point)     
  
   local tp = GetEntitiesWithinRange("TechPoint", point, ARC.kFireRange)
   if #tp >= 1 then return true end

   return false
end
function GetIsPointWithinHiveRadius(point)     
   local hive = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
   if #hive >= 1 then return true end
   return false
end
function GetIsPointWithinHiveRadiusForHealWave(point)     
   local hive = GetEntitiesWithinRange("Hive", point, Crag.kHealRadius)
   if #hive >= 1 then return true end
   return false
end
function GetIsScanWithinRadius(point)     
   local scan = GetEntitiesWithinRange("Scan", point, kScanRadius)
   if #scan >= 1 then return true end
   return false
end
function GetIsImaginatorMarineEnabled(point)     
   local imaginator = GetImaginator()
   if imaginator then
    return imaginator:GetIsMarineEnabled()
   end
   return false
end
function GetIsImaginatorAlienEnabled(point)     
   local imaginator = GetImaginator()
   if imaginator then
    return imaginator:GetIsAlienEnabled()
   end
   return false
end
function FindFreeSpace(where, mindistance, maxdistance, infestreq)    
     if not mindistance then mindistance = 2 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, 50 do //#math.random(4,8) do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           //local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, mindistance, maxdistance, EntityFilterAll())
           local spawnPoint = GetRandomPointsWithinRadius(GetGroundAtPosition(where, nil, PhysicsMask.AllButPCs, extents), mindistance, maxdistance, 20, 1, 1, nil, validationFunc)
            if #spawnPoint == 1 then
                spawnPoint = spawnPoint[1]
           end
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation.name or nil
           local sameLocation = spawnPoint ~= nil and locationName == wherelocation
           
           if infestreq then
             sameLocation = sameLocation and GetIsPointOnInfestation(spawnPoint)
           end
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
--           Print("No valid spot found for FindFreeSpace")
         -- if infestreq and not GetIsPointOnInfestation(where) then
            -- if Server then CreateEntity(Cyst.kMapName, FindFreeSpace(where,1, 6),  2) end
             --For now anyway, bite me. Remove later? :X or tres spend. Who knows right now. I wanna see this in action.
        --  end
          
           return where
end
function FindArcSpace(where)    
    for index = 1, 12 do
        local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, ARC.kFireRange - 8, 24, EntityFilterAll())

        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end

        if spawnPoint ~= nil and GetIsPointWithinHiveRadius(spawnPoint) then
            return spawnPoint
        end
    end
    Print("No valid spot found for FindArcHiveSpawn")
    return nil
end

function GetClosestHiveFromCC(point)
    --Want this to be the closest hive to the current chair
    local cc = GetNearest(point, "CommandStation", 1)  
    local nearesthivetocc = GetNearest(cc:GetOrigin(), "Hive", 2) 
   return nearesthivetocc  
  
end
function GetRandomHive() 
    local hives = {}
    for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do 
        table.insert(hives, hive)
    end
    if #hives == 0 then return nil end
    return table.random(hives)
end

/*
function FindPosition(location, searchEnt, teamnum)

    if not location or #location == 0  then
        return
    end

    local origin = nil
    local where = {}
    for i = 1, #location do
        local location = location[i]
        local ents = location:GetEntitiesInTrigger()
        local potential = InsideLocation(ents, teamnum)
        if potential ~= nil then
            table.insert(where, potential )
        end
    end

    for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Construct", teamnum, searchEnt:GetOrigin(), 24) ) do
        if  GetLocationForPoint(entity:GetOrigin()) ==  GetLocationForPoint(searchEnt:GetOrigin()) then
            table.insert(where, entity:GetOrigin() )
        end
    end

    if #where == 0 then
     return nil
    end

    local random = table.random(where)
    local actualWhere = FindFreeSpace(random)
    if random == actualWhere then
        return nil
    end -- ugh

    return actualWhere
 end
  */
  
  
function GetHasThreeChairs()
    local CommandStations = #GetEntitiesForTeam( "CommandStation", 1 )
    if CommandStations >= 3 then
        return true
    end
    return false
end

function GetHasThreeHives()
    local Hives = #GetEntitiesForTeam( "Hive", 2 )
    if Hives >= 3 then
     return true
    end
    return fasle
end

function GetHasAdvancedArmory()
    for index, armory in ipairs(GetEntitiesForTeam("Armory", 1)) do
        if armory:GetTechId() == kTechId.AdvancedArmory then return true end
    end
    return false
end
function InsideLocation(ents, teamnum)
    local origin = nil
    if #ents == 0  then return origin end
    for i = 1, #ents do
        local entity = ents[i]   
            if teamnum == 2 then
                if entity:isa("Alien") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then
                    return FindFreeSpace(entity:GetOrigin(), math.random(2, 4), math.random(8,24), true)
                end
            elseif teamnum == 1 then
                if entity:isa("Marine") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then
                    return FindFreeSpace(entity:GetOrigin(), math.random(2,4), math.random(8,24), false )
                end
            end 
    end
    return origin
end
function GetRandomActivePower()//bool notSiege, if notSiege true then.. prevent grabbing siege powerpoint..?
      local powers = {}
      for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
         if power:GetIsBuilt() and not power:GetIsDisabled() then
                if isSetup then // I don't want rooms be built which are yet to be undetermined in setup. ugh. players mark ownership by entering room. then spawn.
                    if power:GetHasBeenToggledDuringSetup() then
                        table.insert(powers,power)
                    end
                else
                     table.insert(powers,power) //and not in siege ? Hm?
                end
          end
        end
        return table.random(powers)
end
function GetRandomActivePowerWithoutPGInRoom()//bool notSiege, if notSiege true then.. prevent grabbing siege powerpoint..?
 //Insert headache here
end
function GetRandomActivePowerWithoutBatteryInRoom()//bool notSiege, if notSiege true then.. prevent grabbing siege powerpoint..?
    //Insert headache here
end
function GetAllLocationsWithSameName(origin)
    local location = GetLocationForPoint(origin)
    if not location then return end
    local locations = {}
    local name = location.name
    for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location.name == name then table.insert(locations, location) end
    end
    return locations
end
function GetHasCragHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.CragHive then return true end
    end
    return false
end
 function GetHasShiftHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.ShiftHive then return true end
    end
    return false
end
 function GetHasShadeHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetIsBuilt() and hive:GetTechId() == kTechId.ShadeHive then return true end//only way for it to be shadehive is for it to be built eh?
    end
    return false
end
function GetNearestMixin(origin, mixinType, teamNumber, filterFunc)
    assert(type(mixinType) == "string")
    local nearest = nil
    local nearestDistance = 0
    for index, ent in ientitylist(Shared.GetEntitiesWithTag(mixinType)) do
        if not filterFunc or filterFunc(ent) then
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                    nearest = ent
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest
end
function GetIsRoomPowerUp(who)
    local location = GetLocationForPoint(who:GetOrigin())
    if not location then return false end
    local powernode = GetPowerPointForLocation(location.name)
    if powernode and powernode:GetIsBuilt() and not powernode:GetIsDisabled()  then return true end
    return false
end
function GetRoomPower(who)
    local location = GetLocationForPoint(who:GetOrigin())
    if not location then return false end
    local powernode = GetPowerPointForLocation(location.name)
    if powernode then 
        return powernode
    end
    return false
end
function GetRoomPowerTryEnsureSetupAlienOwned(who)
    local location = GetLocationForPoint(who:GetOrigin())
    if not location then return false end
    local powernode = GetPowerPointForLocation(location.name) //probably GetNearestPowerPoint .. 
    if powernode and powernode:GetIsDisabled() and powernode:GetHasBeenToggledDuringSetup() then ////HHMMMMM?? 
        return powernode
    end
    return false
end
function GetSiegeLocation(where)
--local locations = {}

 local siegeloc = nil

  siegeloc = GetNearest(where, "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)
 
if siegeloc then return siegeloc end
 return nil
end

function GetOriginInHiveRoom(point)  
 local location = GetLocationForPoint(point)
 local hivelocation = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999)
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
     local hive = hives[i]
     hivelocation = GetLocationForPoint(hive:GetOrigin())
     break
     end
     
     if location == hivelocation then return true end
     
     return false
     
end
function GetHiveRoomPower(point)  
 local hivelocation = nil
  local hivepower = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999) //well this may not be the main room we want if the hive is not in the initia lhive room.. like trainsiege/domesiege 4th tech point. but w/e
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
         local hive = hives[i]
         hivelocation = GetLocationForPoint(hive:GetOrigin())
         break
     end
     
     if hivelocation then
        return GetPowerPointForLocation(hivelocation.name)
     end
end
function GetIsTimeUp(timeof, timelimitof)
 local time = Shared.GetTime()
 local boolean = (timeof + timelimitof) < time
 --Print("timeof is %s, timelimitof is %s, time is %s", timeof, timelimitof, time)
 -- if boolean == true then Print("GetTimeIsUp boolean is %s, timelimitof is %s", boolean, timelimitof) end
 return boolean
end

function GetSetupConcluded()
return GetFrontDoorOpen()
end
function GetFrontDoorOpen()
   return GetTimer():GetFrontOpenBoolean()
end
function GetSiegeDoorOpen()
   local boolean = GetTimer():GetSiegeOpenBoolean()
   return boolean
end

function GetSiegeDoor() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SiegeDoor")
    if entityList:GetSize() > 0 then
                 local siegedoor = entityList:GetEntityAtIndex(0) 
                 return siegedoor
    end    
    return nil
end

function GetImaginator() --it's fake
    local entityList = Shared.GetEntitiesWithClassname("Imaginator")
    if entityList:GetSize() > 0 then
                 local timer = entityList:GetEntityAtIndex(0) 
                 return timer
    end    
    return nil
end

function GetConductor() --it's in time
    local entityList = Shared.GetEntitiesWithClassname("Conductor")
    if entityList:GetSize() > 0 then
                 local timer = entityList:GetEntityAtIndex(0) 
                 return timer
    end    
    return nil
end

function GetTimer() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("Timer")
    if entityList:GetSize() > 0 then
                 local timer = entityList:GetEntityAtIndex(0) 
                 return timer
    end    
    return nil
end

function GetGameStarted()
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   return gamestarted
end
function GetIsInSiege(who)
local locationName = GetLocationForPoint(who:GetOrigin())
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if locationName and string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end

function GetWhereIsInSiege(where)
local locationName = GetLocationForPoint(where)
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end
