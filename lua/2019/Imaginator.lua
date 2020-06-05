-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/
class 'Imaginator' (Entity)
Imaginator.kMapName = "imaginator"

local networkVars =

{
  alienenabled = "private boolean",
  marineenabled = "private boolean",
  lastMarineBeacon =  "private time",
  lasthealwave = "private time",
  activeArms = "integer",
  activeWhips = "integer",
  activeCrags = "integer",
  activeShades = "integer",
  activeShifts = "integer",
  activeTunnels = "integer",
}

function Imaginator:OnCreate()
   self.alienenabled = false
   self.marineenabled = false
   self.activeArmorys = 0
   self.activeRobos = 0
   self.activeIPS = 0
   self.activeBatteries = 0
   self.activeObs = 0
   self.activePGs = 0
   self.activeProtos = 0
   self.activeArms = 0
   self.activeWhips = 0
   self.activeCrags = 0
   self.activeShades = 0
   self.activeShifts = 0
   self.activeTunnels = 0
   for i = 1, 8 do
     Print("Imaginator created")
   end
   self.lasthealwave = 0
   self:SetUpdates(true)
end

local function GetDelay()
  if not GetSetupConcluded() then 
      return 8
   end
  //if not GetSiegeDoorOpen() then 
      return 16
  //end
    //return 24
end

function Imaginator:GuideLostBots()
    //Marines
    local door = GetFrontDoor()
    if not door then return end
                       for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
                        //if not in front room and if client is virtual
                        marine:GiveOrder(kTechId.Move, nil, door:GetOrigin(), nil, false, false) 
                    end
    
    
    //Aliens
        CreatePheromone(kTechId.ThreatMarker,door:GetOrigin(), 2)
end

if Server then
    function Imaginator:OnUpdate(deltatime)

        
        if self.marineenabled and (not  self.timeLastGuideLostBots or self.timeLastGuideLostBots + 30 <= Shared.GetTime() ) then
            if not GetSetupConcluded() then
                self:GuideLostBots()
            end
            self.timeLastGuideLostBots = Shared.GetTime()
        end
        
        if not  self.timeLastImaginations or self.timeLastImaginations + GetDelay() <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
            self:Imaginations()
        end

        if not  self.timeLastConductions or self.timeLastConductions + 16 <= Shared.GetTime() then
            self.timeLastConductions = Shared.GetTime()
            self:Imaginations(true)
        end

    end

end //Server

local function OrganizedEntranceCheck(who,self)


    if not who:GetIsBuilt() then
        return
    end
    
    //in room or in radius?
    

        local hive = GetRandomHive()
        if hive then
            if not GetHasFourTunnelInHiveRoom() then
                local tunnel = CreateEntity(TunnelEntrance.kMapName, FindFreeSpace(hive:GetOrigin(), 4, 20),  2)
            end
        end
    
end

local function DropWeaponsJetpacksExos(who, self)



        //This is bad not to have a cap for spawning haha. Gotta add a limit somewhere. By count in global map as well.ActualAlienFormula
        
    if not who:GetIsBuilt() or not who:GetIsPowered() then
        return
    end
    
    //if has adv armory, if has jp, if has exo.
    local randomize = {}
    
    local exosInRange = GetEntitiesForTeamWithinRange("Exosuit", 1, who:GetOrigin(), 99999999)
    if #exosInRange < 6 then
        table.insert(randomize, kTechId.DropExosuit)
    end
    
    /*
    local SGSInRange = GetEntitiesForTeamWithinRange("Shotgun", 1, who:GetOrigin(), 99999999)
    
    if #SGSInRange < 6 then
        table.insert(randomize, kTechId.Shotgun)
    end
    local hmgsInRange = GetEntitiesForTeamWithinRange("HeavyMachineGun", 1, who:GetOrigin(), 99999999)
    if #hmgsInRange < 6 then
        table.insert(randomize, kTechId.HeavyMachineGun)
    end
    local JPSInRange = GetEntitiesForTeamWithinRange("Jetpack", 1, who:GetOrigin(), 99999999)
    if #JPSInRange < 6 then
        table.insert(randomize, kTechId.Jetpack)
    end
    local GLSInRange = GetEntitiesForTeamWithinRange("GrenadeLauncher", 1, who:GetOrigin(), 99999999)
    if #GLSInRange < 6 then
        table.insert(randomize, kTechId.GrenadeLauncher)
    end

    local flsInRange = GetEntitiesForTeamWithinRange("Flamethrower", 1, who:GetOrigin(), 99999999)
    if #exosInRange < 6  then
        table.insert(randomize, kTechId.Flamethrower)
    end
    */
    
    

    if #randomize == 0 then return end
    
    local entry = table.random(randomize)
    
    entity = CreateEntityForTeam(entry, FindFreeSpace(who:GetOrigin(),4, kInfantryPortalAttachRange), 1)
    
     
end

local function OrganizedIPCheck(who, self)
    if not who:GetIsBuilt() then
        return
    end

    local count = 0
    //local findFree = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
    local ipsInRange = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
    //and activeIPS <= numofChairs*3/4
    if #ipsInRange >= math.random(3,4) then//self.activeIPS >= 8 then //do a check for within range so that each base has its own
     return
    end

    --for i = 1, math.abs( 2 - count ) do --one at a time
    //local cost = 20
    //if TresCheck(1, cost) then
        local where = who:GetOrigin()
        local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
            if origin ~= where then
            local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
            SetDirectorLockedOnEntity(ip)
                if not GetSetupConcluded() then 
                     ip:SetConstructionComplete()
                    //ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
                end
            end
    //end
    
    //May have to re-introduce armslab here if it doesn't spawn fast enough after round start lol
    //Unless the work around to that is the MarineInitialBaseSpawn creating an ArmsLab...
    
      //Bad for if aliens take it down then they get no reward of unpowered marines
      //unless marines dont build it lol
      if self.activeArms <= 1 then
        local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
        local arms = CreateEntity(ArmsLab.kMapName, origin,  1)
        SetDirectorLockedOnEntity(arms)
          if not GetSetupConcluded() then
            arms:SetConstructionComplete()
          end
      end

end
local function OrganizedSentryCheck(who, self)
       if not who or not who:GetIsBuilt() then
        return
    end

    local count = 0
    //local findFree = FindFreeSpace(who:GetOrigin(), 1, 7)//range of battery??
    local sentrysInRange = GetEntitiesForTeamWithinRange("Sentry", 1, who:GetOrigin(), 4)//range of battery??

    if #sentrysInRange >= 4 then//self.activeIPS >= 8 then //do a check for within range so that each base has its own
     return
    end

    --for i = 1, math.abs( 2 - count ) do --one at a time
    //local cost = 20
    //if TresCheck(1, cost) then
        local where = who:GetOrigin()
        local origin = FindFreeSpace(where, 1, 4)//range of battery??
            if origin ~= where then
            local sentry = CreateEntity(Sentry.kMapName, origin, 1)
            SetDirectorLockedOnEntity(sentry)
                if not GetSetupConcluded() then sentry:SetConstructionComplete() end
                    //sentry:GetTeam():SetTeamResources(sentry:GetTeam():GetTeamResources() - cost)
                //end
            end

    //end

end
local function HaveBatteriesCheckSentrys(self)
    local SentryBatterys = GetEntitiesForTeam( "SentryBattery", 1 )
    if not SentryBatterys then
     return
    end
    OrganizedSentryCheck(table.random(SentryBatterys), self)
end

local function HaveHivesCheckEntrances(self)
    local Hives = GetEntitiesForTeam( "Hive", 2 )
    if not Hives then
     return
    end
    OrganizedEntranceCheck(table.random(Hives), self)
end


local function HaveCCsCheckIps(self)
    local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
    if #CommandStations == 0 then
     return
    end
    OrganizedIPCheck(table.random(CommandStations), self)
    local Protos = GetEntitiesForTeam( "PrototypeLab", 1 )
    if #Protos == 0 then
     return
    end
    DropWeaponsJetpacksExos(table.random(Protos), self) // Tune this
end

function Imaginator:ManageMarineBeacons() // Get all Macs, make each mac weld CC?
    local chair = nil

    for _, entity in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        if entity:GetIsBuilt() and entity:GetHealthScalar() <= 0.3 then
            chair = entity
            break
        end
    end

    if not chair then
        return
    end

    local obs = GetNearest(chair:GetOrigin(), "Observatory", 1,  function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(chair:GetOrigin()) and ent:GetIsBuilt() and ent:GetIsPowered()  end )

    if obs then
        obs:TriggerDistressBeacon()
        self.lastMarineBeacon = Shared.GetTime()
    end

end

local function ManageRoboticFactories() //If bad perf can be modified to do one robo a time rather than all heh. Or other ways rather than for looping every. lol.
    local ARCRobo = {} --ugh
    local  macs = GetEntitiesForTeam( "MAC", 1 )
    local isSiege = GetSiegeDoorOpen()

    for index, robo in ipairs(GetEntitiesForTeam("RoboticsFactory", 1)) do
        if robo:GetIsBuilt() and not robo.open and not robo:GetIsResearching() and robo:GetIsPowered() then
            //Prioritize Macs if not siege room open
            if not isSiege and not #macs or #macs <6 then // Make this cost tres?
                 robo:OverrideCreateManufactureEntity(kTechId.MAC)
                //Well the way this is written, if two robos calculate this at once. at 5 macs. <6 .Then both create macs at same time. 7 macs.
                //This can be moved down below with arc spawn.
            else
                if  robo:GetTechId() ~= kTechId.ARCRoboticsFactory then
                    local techid = kTechId.UpgradeRoboticsFactory
                    local techNode = robo:GetTeam():GetTechTree():GetTechNode( techid )
                    robo:SetResearching(techNode, robo)
                end

                if robo:GetTechId() == kTechId.ARCRoboticsFactory then
                    table.insert(ARCRobo, robo)
                end --ugh
           end
         end
    end

    --if ( not GetHasThreeChairs() and not GetFrontDoorOpen() ) then return end

    if table.count(ARCRobo) == 0 then
        return
    end

    ARCRobo = table.random(ARCRobo)

    local ArcCount = #GetEntitiesForTeam( "ARC", 1 )

    if ArcCount < 9 then --and TresCheck(1, kARCCost) then
        -- ARCRobo:GetTeam():SetTeamResources(ARCRobo:GetTeam():GetTeamResources() - kARCCost)
        ARCRobo:OverrideCreateManufactureEntity(kTechId.ARC)
    end

end

local function GetMarineSpawnList(self)
    local tospawn = {}
    local canafford = {}
    local gamestarted = false

    local  CCs = 0
        for index, cc in ipairs(GetEntitiesForTeam("CommandStation", 1)) do
            CCs = CCs + 1
        end

    if CCs < 3  and CCs >= 1 and GetSetupConcluded() then
        return kTechId.CommandStation
    end

    local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
    if CommandStation < 3 then
        table.insert(tospawn, kTechId.CommandStation)
    end
    ----------------------------------------------------------------------------------------------------

    if #tospawn == 0 then
        return nil
    end
    local finalchoice  = table.random(tospawn)

    ---------------------------------------------------------------------------------------------------------
    return finalchoice
    ----------------------------------------------------------------------------------------------------------
end

local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end

function Imaginator:DoConductors(marine, alien)
    local con = GetConductor()
    if marine then
        con:ManageMacs()
        con:ManageArcs()
        con:ManageScans()
    elseif alien then
        con:ManageDrifters() 
        con:ManageShades()
        con:ManageCrags() 
        con:ManageShifts()
        con:ManageWhips()
        con:ManageCysts()
    end
end

function Imaginator:ActualFormulaMarine()


    if  GetIsTimeUp(self.lastMarineBeacon, 30) then
        self:ManageMarineBeacons()
    end

    if GetGamerules():GetGameState() == kGameState.Started then
        gamestarted = true
        HaveCCsCheckIps(self)
        HaveBatteriesCheckSentrys(self)
        ManageRoboticFactories()
    end


    local randomspawn = nil
    local tospawn = GetMarineSpawnList(self) --cost, blah.
    local powerpoint = GetRandomActivePower()
    local success = false
    local entity = nil

    if powerpoint then
        if tospawn == nil then
            tospawn = powerpoint:GetRandomSpawnEntity()
        end
    end
    
    if tospawn then
        local potential = powerpoint:GetRandomSpawnPoint() //hmm?
        if potential == nil then local roll = math.random(1,3)
            if roll == 3 then
                self:ActualFormulaMarine() return
            else
                return
            end
        end
        randomspawn = potential//FindFreeSpace(potential, 2.5)
        if randomspawn then // if randomspawn is within X radius of a construct, find free space.
            if tospawn == kTechId.PhaseGate and GetHasPGInRoom(randomspawn) or tospawn == kTechId.SentryBattery and GetHasBatteryInRoom(randomspawn)
            or ( tospawn == kTechId.CommandStation and not GetSetupConcluded() and GetHasChairInRoom(randomspawn) ) then //Promotion spreading aboot
                return
            end

            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
            SetDirectorLockedOnEntity(entity)
            if not GetSetupConcluded() then 
                entity:SetConstructionComplete() 
            end
            success = true
          end
      end
    return success
end

function Imaginator:MarineConstructs()
       for i = 1, 8 do
         local success = self:ActualFormulaMarine()
         if success == true then break end
       end

return
end
function Imaginator:ShowWarningForToggleMarinesOff(bool)

end
function Imaginator:ShowWarningForToggleAliensOff(bool)

end
function Imaginator:ShowWarningForToggleMarinesOn(bool)

end
function Imaginator:ShowWarningForToggleAliensOn(bool)

end
function Imaginator:Imaginations(doConduct) 
    if not GetGameStarted() then return end
    local Gamerules = GetGamerules()
    local team1Commander = Gamerules.team1:GetCommander()
    local team2Commander = Gamerules.team2:GetCommander()
    
    if not team1Commander and not self.marineenabled then
        self.marineenabled = true
        self:ShowWarningForToggleMarinesOn(true)
    elseif team1Commander and self.marineenabled then
        self.marineenabled = false   
        self:ShowWarningForToggleMarinesOff(false)
    end
    
    if not team2Commander and not self.alienenabled then
        self.alienenabled = true
        self:ShowWarningForToggleAliensOn(true)
    elseif team2Commander and self.alienenabled then
        self.alienenabled = false   
        self:ShowWarningForToggleAliensOff(false)
    end
    
    if self.marineenabled then
        if doConduct then
            self:DoConductors(true,false)
        else
            self:MarineConstructs()
        end
    end
    
    if self.alienenabled then
        if doConduct then
           self:DoConductors(false, true)
        else
            self:AlienConstructs()
        end
    end

    return true

end

local function GetAlienSpawnList(self)

    local tospawn = {}
    
    if GetSiegeDoorOpen() then
        if self.activeCrags < 13 or self.activeShades < 12 then
            if  self.activeCrags < 13 then
                table.insert(tospawn, kTechId.Crag)
            end
            if  self.activeShades < 12 then
                table.insert(tospawn, kTechId.Shade)
            end
            local finalchoice = table.random(tospawn)
            return finalchoice
        end
    end

    if self.activeShifts < 14 then
        table.insert(tospawn, kTechId.Shift)
    end

    if self.activeWhips < 13 then
        table.insert(tospawn, kTechId.Whip)
    end

    if  self.activeCrags < 13 then
        table.insert(tospawn, kTechId.Crag)
    end

    if  self.activeShades < 12 then
        table.insert(tospawn, kTechId.Shade)
    end

    HaveHivesCheckEntrances(self)
    if self.activeTunnels < 4 then //this is only counting ones outside of hive room.
        table.insert(tospawn, kTechId.Tunnel)
    end

    local finalchoice = table.random(tospawn)
    return finalchoice

    --return table.random(tospawn)
end

local function UpgChambers()
    local gamestarted = not GetGameInfoEntity():GetWarmUpActive()

    if not gamestarted then
     return true
    end

    local tospawn = {}
    local canafford = {}


    if GetHasShiftHive() then
          local Spur = #GetEntitiesForTeam( "Spur", 2 )
          if Spur < 3 then
           table.insert(tospawn, kTechId.Spur)
          end
       end

    if GetHasCragHive()  then
        local  Shell = #GetEntitiesForTeam( "Shell", 2 )
        if Shell < 3 then
         table.insert(tospawn, kTechId.Shell) end
        end

    if GetHasShadeHive() then
        local  Veil = #GetEntitiesForTeam( "Veil", 2 )
        if Veil < 3 then
         table.insert(tospawn, kTechId.Veil)
        end
    end

    for _, techid in pairs(tospawn) do
        local cost = 0 //LookupTechData(techid, kTechDataCostKey)
        if not gamestarted or TresCheck(2,cost) then
            table.insert(canafford, techid)
        end
    end

    local finalchoice = table.random(canafford)
    local finalcost = 0 // LookupTechData(finalchoice, kTechDataCostKey)
    //finalcost = 0 //not gamestarted and 0 or finalcost
    --Print("GetAlienSpawnList() UpgChambers() return finalchoice %s, finalcost %s", finalchoice, finalcost)
    return finalchoice, finalcost, gamestarted

end


function Imaginator:DoBetterUpgs()

    if not gamestarted then
     return
    end

    local tospawn, cost, gamestarted = UpgChambers()
    local success = false
    local randomspawn = nil
    local hive = GetRandomHive()

     if hive and tospawn then

        randomspawn = FindFreeSpace( hive:GetOrigin(), 4, 24, true)

        if randomspawn then

            local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
            SetDirectorLockedOnEntity(entity)
            if not GetSetupConcluded() then
             entity:SetConstructionComplete()
            end

            /*
            if gamestarted then
             entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
            end
            */

        end
  end

  return success
end


function Imaginator:AlienConstructs()
--Print("AlienConstructs")
       for i = 1, 8 do
         local success = self:ActualAlienFormula()
         if success == true then break end
       end
        --  if  GetHasShiftHive() then --messy
        --    HandleShiftCallReceive()
        --  end
       self:DoBetterUpgs()

return true

end

local function getAlienConsBuildOrig(techid)

    if GetSiegeDoorOpen() and techid == kTechId.Crag or techid == kTechId.Shade then//and GetRandomHive() ~= nil (if all hives are down? then game over duh)
        return GetRandomHive()
    else
         local random = math.random(1,3)
          --or active gorge tunnel  exit
          if random == 1 then
            return GetRandomDisabledPower()
          elseif random == 2 then 
            return GetRandomConnectedCyst()//Chance of erroring if entity dies ?
          elseif random == 3 then
            return GetRandomConstructEntityNearMostRecentPlacedCyst()//Chance of erroring if entity dies ?
          end
    end
 
end

function Imaginator:hiveSpawn()  
      //lets add a check here for a 4th tech point after front door is opened. 
      //or if tech chount count is 4 and aliens have 3 hives and the 4th tech is empty
      //it's possible marines moved away from tech point also..
       //if enabled, front door open, and has 3 hives?
       //if there's more than 4 tech point count (marine only have 1)
       //then prioritize the hives within range of eachother?
       //lesss priority on other? 
        //(Not really as that would require further withinrange requiresments
            //asserting other tech within range. I don't think this is necessary. 
            //MAybe later if I see it in game.
            //Reason I'm adding this is because of a round of ns2_hivesiege-4_2015b
                //having 4 tech points is actually a good mix. (For aliens)
      
      
      if self.alienenabled then
        local hiveCap = 3
        local hivecount = #GetEntitiesForTeam( "Hive", 2 )
        if GetSetupConcluded() then
            local techCount = #GetEntitiesWithinRange("TechPoint", self:GetOrigin(), 9999999)
            local isMarineTechEmpty = true
            //Requires further logic. Do a for loop of all tech. Make sure tech point attached is not marines.
            
            for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
                if techpoint.occupiedTeam == 1 then
                    isMarineTechEmpty = false
                end
            end
                                  //Any case where > 4 ?
            if techCount > 4 or ( techCount == 4 and isMarineTechEmpty and hivecount == hiveCap) then
                hiveCap = 4//Hm, why limit to 4? 
            end
            
        end
      
        if hivecount < hiveCap and hivecount >= 1 and TresCheck(2,40) then
            for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
                if techpoint:GetAttached() == nil then 
                    local hive =  techpoint:SpawnCommandStructure(2) 
                    if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) //The only area which deducts tres, eh?
                        break
                    end
                end
            end
        end
   

 end
end

function Imaginator:ActualAlienFormula()
    self:hiveSpawn()


    local randomspawn = nil
    local tospawn = GetAlienSpawnList(self) 
    local success = false
    local entity = nil

    if tospawn then    
        //print("ActualAlienFormula tospawn")
        local power = GetRandomDisabledPower()
        if power == nil then //hm?
            //print("ActualAlienFormula power is nil")
            local roll = math.random(1,3)
            if roll == 3 then
                self:ActualAlienFormula() return
            else
                return
            end
        end     
        print("ActualAlienFormula randomspawn")
        randomspawn = power:GetRandomSpawnPoint()  //FindFreeSpace(potential, math.random(2.5, 4) , math.random(8, 16), not tospawn == kTechId.Cyst )
            if randomspawn then 
                if tospawn == kTechId.Tunnel and GetHasTunnelInRoom(randomspawn) then
                    return
                end
                entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                SetDirectorLockedOnEntity(entity)
                if not GetSetupConcluded() then
                    entity:SetConstructionComplete() 
                end
                 local csyt = CreateEntity(Cyst.kMapName, FindFreeSpace(entity:GetOrigin(), 1, kCystRedeployRange),2)
            end
            success = true
    end
    -- if success and entity then self:AdditionalSpawns(entity) end
    return success
 end
  
  
function Imaginator:GetIsMapEntity()
    return true
end

function Imaginator:GetIsMarineEnabled()
    return self.marineenabled
end

function Imaginator:GetIsAlienEnabled()
    return self.alienenabled
end


Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)