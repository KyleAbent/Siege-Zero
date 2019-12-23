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
  activeArmorys = "integer",
  activeRobos = "integer",
  activeSentrys = "integer",
  activeObs = "integer",
  activePGs = "integer",
  activeProtos = "integer",
  activeArms = "integer",
  activeWhips = "integer",
  activeCrags = "integer",
  activeShades = "integer",
  activeShifts = "integer",
}

function Imaginator:OnCreate()
   self.alienenabled = false
   self.marineenabled = false
   self.activeArmorys = 0
   self.activeRobos = 0
   self.activeSentrys = 0
   self.activeObs = 0
   self.activePGs = 0
   self.activeProtos = 0
   self.activeArms = 0
   self.activeWhips = 0
   self.activeCrags = 0
   self.activeShades = 0
   self.activeShifts = 0
   for i = 1, 8 do
     Print("Imaginator created")
   end
   self.lasthealwave = 0
   self:SetUpdates(true)
end

local function NotBeingResearched(techId, who)

    //This is nasty lol, because it's looking at every structure. Ugh.
    //Why not an array of only strings that are current researches? Once research complete, remove from table. Hm? Or..?

    if techId ==  kTechId.AdvancedArmoryUpgrade or techId == kTechId.UpgradeRoboticsFactory then
     return true
    end

    for _, structure in ientitylist(Shared.GetEntitiesWithClassname( string.format("%s", who:GetClassName()) )) do
        if structure:GetIsResearching() and structure:GetClassName() == who:GetClassName() and structure:GetResearchingId() == techId then
            return false
        end
    end

    return true

end

local function ResearchEachTechButton(who)

    local techIds = who:GetTechButtons() or {}

    if who:isa("EvolutionChamber") then
        techIds = {}
        table.insert(techIds, kTechId.Charge )
        table.insert(techIds, kTechId.BileBomb )
        table.insert(techIds, kTechId.MetabolizeEnergy )
        table.insert(techIds, kTechId.Leap )
        table.insert(techIds, kTechId.Spores )
        table.insert(techIds, kTechId.Umbra )
        table.insert(techIds, kTechId.MetabolizeHealth )
        table.insert(techIds, kTechId.BoneShield )
        table.insert(techIds, kTechId.Stab )
        table.insert(techIds, kTechId.Stomp )
        table.insert(techIds, kTechId.Xenocide )
    end

    if who:isa("Observatory") then
        techIds = {}
        table.insert(techIds, kTechId.PhaseTech ) --advancedbeacon
    end

    for _, techId in ipairs(techIds) do
        if techId ~= kTechId.None then
            if not GetHasTech(who, techId)  and who:GetCanResearch(techId) then
                local tree = GetTechTree(who:GetTeamNumber())
                local techNode = tree:GetTechNode(techId)
                assert(techNode ~= nil)
                if tree:GetTechAvailable(techId) then
                    //local cost = 0--LookupTechData(techId, kTechDataCostKey) *
                    if  NotBeingResearched(techId, who) then //and TresCheck(1,cost) then
                        who:SetResearching(techNode, who)
                        break -- Because having 2 armslabs research at same time voids without break. So lower timer 16 to 4
                        --  who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                    end
                 end
             end
        end
    end
end
local function GetDelay()
  if not GetSetupConcluded() then 
      return 12
   end
  if not GetSiegeDoorOpen() then 
      return 16
  end
    return 24
end

if Server then
    function Imaginator:OnUpdate(deltatime)

        if not  self.timeLastImaginations or self.timeLastImaginations + GetDelay() <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
            self:Imaginations()
        end

        if not self.timeLastResearch or self.timeLastResearch + 16 <= Shared.GetTime() then

            local gamestarted = GetGamerules():GetGameState() == kGameState.Started
            if gamestarted then
                local researchables = {}

                if self.alienenabled then
                    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("EvolutionChamber")) do
                        table.insert(researchables, ent)
                    end
                end

                if self.marineenabled then
                    for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                        //Not that great, but try process of elimination?
                        if researchable:isa("EvolutionChamber") and researchable:GetTeamNumber() == 1 then
                            print("Found EvolutionChamber for Marine Team??????")
                        end
                        if not researchable:GetIsResearching()  then // and is Active ....
                            table.insert(researchables, researchable)
                        end
                    end
                end

                //Maybe a seperate delay by 1s rather than all at the same time.
                //Rather than every entity with research mixin, why not grab from a list of entities, grab one that's not researching, then research
                if self.alienenabled or self.marineenabled then
                    for i = 1, #researchables do
                        local researchable = researchables[i]
                        ResearchEachTechButton(researchable)
                    end
                end

                self.timeLastResearch = Shared.GetTime()
            end
        end

    end

end //Server

local function OrganizedIPCheck(who, self)
    if not who:GetIsBuilt() then
        return
    end

    -- One entity at a time
    local count = 0
    local ips = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
    --ADd in getisactive
    --Add in arms lab because having these spread through the map is a bit odd.

    //local armscost = 0//LookupTechData(kTechId.ArmsLab, kTechDataCostKey)
    local  ArmsLabs = GetEntitiesForTeam( "ArmsLab", 1 )
    local labs = #ArmsLabs or 0
    if #ArmsLabs >= 1 then
        for i = 1, #ArmsLabs do
        local ent = ArmsLabs[i]
            if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
                labs = labs - 1
            end
        end
    end

    if labs < 2 then //and TresCheck(1, armscost) then
        local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
        local armslab = CreateEntity(ArmsLab.kMapName, origin,  1)
        if not GetSetupConcluded() then
         armslab:SetConstructionComplete()
        end
        return --one at a time
    end


    for index, ent in ipairs(ips) do
        if ent:GetIsPowered() or not ent:GetIsBuilt() then
            count = count + 1
        end
    end

    if count >= 2 then
     return
    end

    --for i = 1, math.abs( 2 - count ) do --one at a time
    //local cost = 20
    //if TresCheck(1, cost) then
        local where = who:GetOrigin()
        local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
            if origin ~= where then
            local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
                if not GetSetupConcluded() then ip:SetConstructionComplete() end
                    //ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
                end
    //end

end

local function HaveCCsCheckIps(self)
    local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
    if not CommandStations then
     return
    end
    OrganizedIPCheck(table.random(CommandStations), self)
end

function Imaginator:ManageMarineBeacons()
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

local function ManageRoboticFactories()
    local ARCRobo = {} --ugh

    --Because researcher will spawn macs.
    for index, robo in ipairs(GetEntitiesForTeam("RoboticsFactory", 1)) do

        if  robo:GetTechId() ~= kTechId.ARCRoboticsFactory and robo:GetIsBuilt() and not robo:GetIsResearching() then
            local techid = kTechId.UpgradeRoboticsFactory
            local techNode = robo:GetTeam():GetTechTree():GetTechNode( techid )
            robo:SetResearching(techNode, robo)
        end

        if robo:GetTechId() == kTechId.ARCRoboticsFactory and not robo.open then
            table.insert(ARCRobo, robo)
        end --ugh

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
    //This function requires each entity to hook: OnConstructionComplete to GetImaginator and +1 the count
    //Also requires to use and hook OnKill to GetImaginator and -1 the count
    local tospawn = {}
    local canafford = {}
    local gamestarted = false
    --Horrible for performance, right? Not precaching ++ local variables ++ table && for loops !!!

    local  CCs = 0
        for index, cc in ipairs(GetEntitiesForTeam("CommandStation", 1)) do
            CCs = CCs + 1
        end

    if CCs < 3  and CCs >= 1 then
        return kTechId.CommandStation
    end

    -----------------------------------------------------------------------------------------------
    if self.activePGs <= 3 then
        table.insert(tospawn, kTechId.PhaseGate)
    end --phaseavoca init
    -------------------------------------------------------------------------------------------
    if self.activeArmorys <= 7 then
        table.insert(tospawn, kTechId.Armory)
    end
    ---------------------------------------------------------------------------------------------
    if self.activeRobos <= 3 then
        table.insert(tospawn, kTechId.RoboticsFactory)
    end
    ------------------------------------------------------------------------------------------------
    if self.activeObs <= 08 then
        table.insert(tospawn, kTechId.Observatory)
    end
    -----------------------------------------------------------------------------------------------
    if GetHasAdvancedArmory()  then
        if self.activeProtos < 6 then
            table.insert(tospawn, kTechId.PrototypeLab)
        end
    end
    -------------------------------------------------------------------------------------------------
    local  Sentry = #GetEntitiesForTeam( "Sentry", 1 ) --#GetActiveConstructsForTeam( "Sentry", 1 )
    //This aint gonna spawn well unless we spawn a sentrybattery then do something similar to CC Checking IPs

    if Sentry <= 11 then --self.activeSentrys <= 11 then
    table.insert(tospawn, kTechId.Sentry)
    end
    ----------------------------------------------------------------------------------------------------
    --timecheck to prevent 3 CC in one room w/o checking for such definition
    local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
    local timecheck = true --( Shared.GetTime() - GetGamerules():GetGameStartTime() ) >= 60 --true
    if timecheck and CommandStation < 3 then
        table.insert(tospawn, kTechId.CommandStation)
    end

    ----------------------------------------------------------------------------------------------------
    --Lets make arms lab do the same and spawn anywhere with power independent from cc
    -- local  Labs = #GetActiveConstructsForTeam( "ArmsLab", 1 )
    --the 3 on the map could be inactive.
    -- if Labs < 3 then --more? compare to alien 3 of each
    --   Print("Imaginator activeArms count == %s", self.activeArms)
    if self.activeArms < 3 then
        table.insert(tospawn, kTechId.ArmsLab)
    end
    ----------------------------------------------------------------------------------------------------

    local finalchoice  = table.random(tospawn)

    ---------------------------------------------------------------------------------------------------------
    return finalchoice
    ----------------------------------------------------------------------------------------------------------
end

local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end

function Imaginator:ActualFormulaMarine()
    local con = GetConductor()
    con:ManageMacs()
    con:ManageArcs()
    con:ManageScans()
    local randomspawn = nil
    local tospawn = GetMarineSpawnList(self) --cost, blah.

    if  GetIsTimeUp(self.lastMarineBeacon, 30) then
        self:ManageMarineBeacons()
    end

    if GetGamerules():GetGameState() == kGameState.Started then
        gamestarted = true
        HaveCCsCheckIps(self)
        ManageRoboticFactories()
    end

    local powerpoint = GetRandomActivePower()
    local success = false
    local entity = nil
    if powerpoint and tospawn then
        local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 1)
        if potential == nil then local roll = math.random(1,3)
            if roll == 3 then
                self:ActualFormulaMarine() return
            else
                return
            end
        end
        randomspawn = FindFreeSpace(potential, 2.5)
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, 
                function(ent) return ent:GetTechId() == tospawn
                or ( ent:GetTechId() == kTechId.AdvancedArmory 
                and tospawn == kTechId.Armory)  
                or ( ent:GetTechId() == kTechId.ARCRoboticsFactory 
                and tospawn == kTechId.RoboticsFactory) 
                end)

                if nearestof then
                    local range = GetRange(nearestof, randomspawn)
                    --    Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                    local minrange = nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,24) --nearestof:GetMinRangeAC()

                    if tospawn == kTechId.PhaseGate and GetHasPGInRoom(randomspawn) then
                        return
                    end

                    if range >=  minrange  then
                        entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if not GetSetupConcluded() then entity:SetConstructionComplete() end
                            --  if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                            --BuildNotificationMessage(randomspawn, self, tospawn)
                            success = true
                        end --
                    else -- it tonly takes 1!
                        entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if not GetSetupConcluded() then entity:SetConstructionComplete() end
                            --  if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                            success = true
                        end
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
function Imaginator:ShowWarningForToggleMarines(bool)

end
function Imaginator:ShowWarningForToggleAliens(bool)

end
function Imaginator:Imaginations() 
    local Gamerules = GetGamerules()
    local team1Commander = Gamerules.team1:GetCommander()
    local team2Commander = Gamerules.team2:GetCommander()
    
    if not team1Commander and not self.marineenabled then
        self.marineenabled = true
        self:ShowWarningForToggleMarines(true)
    elseif team1Commander and self.marineenabled then
        self.marineenabled = false   
        self:ShowWarningForToggleMarines(false)
    end
    
    if not team2Commander and not self.alienenabled then
        self.alienenabled = true
        self:ShowWarningForToggleAliens(true)
    elseif team2Commander and self.alienenabled then
        self.alienenabled = false   
        self:ShowWarningForToggleAliens(false)
    end
    
    if self.marineenabled then
        self:MarineConstructs()
    end
    
    if self.alienenabled then
        self:AlienConstructs(false)
    end

    return true

end

local function GetAlienSpawnList(self)

    local tospawn = {}

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


function Imaginator:AlienConstructs(cystonly)
--Print("AlienConstructs cystonly %s", cystonly)
       for i = 1, 8 do
         local success = self:ActualAlienFormula(cystonly)
         if success == true then break end
       end
        --  if  GetHasShiftHive() then --messy
        --    HandleShiftCallReceive()
        --  end
       self:DoBetterUpgs()

return true

end

local function getAlienConsBuildOrig()

 local random = math.random(1,3)
  --or active gorge tunnel  exit
  if random == 1 then
    return GetRandomDisabledPower()
  elseif random == 2 then --random built const
    return GetRandomDisabledPower()
  elseif random == 3 then--random built exit
    return GetRandomDisabledPower()
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
            local isMarineTechEmpty = false
            
            if techCount > 4 or ( techCount == 4 and isMarineTechEmpty and hivecount == hiveCap)then
                hiveCap = 4
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

function Imaginator:ActualAlienFormula(cystonly)
    self:hiveSpawn()
    local con = GetConductor()
    con:ManageDrifters() 
    //ManageCysts - look for struct without infestation, doChain for one then break
    con:ManageCrags() 
    con:ManageShifts()
    con:ManageWhips()

    local randomspawn = nil
    local powerpoint  = getAlienConsBuildOrig() 
    local tospawn = GetAlienSpawnList(self) --, cost, gamestarted = GetAlienSpawnList(self, cystonly)
    local success = false
    local entity = nil

    if spawnNearEnt then
        Print("ActualAlienFormula cystonly %s, spawnNearEnt %s, tospawn %s", cystonly,  powerpoint:GetMapName() or nil, LookupTechData(tospawn, kTechDataMapName)  )
    end

    if powerpoint and tospawn then     
        local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 2)
        if potential == nil then
            local roll = math.random(1,3)
        if roll == 3 then
            self:ActualAlienFormula() return
        else
            return
        end
    end     
         
    randomspawn = FindFreeSpace(potential, math.random(2.5, 4) , math.random(8, 16), not tospawn == kTechId.Cyst )
    if randomspawn then
        local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
            if nearestof then
            local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
            -- Print("ActualAlienFormula range is %s", range)
            -- Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
            local minrange =  nearestof.GetMinRangeAC and nearestof:GetMinRangeAC() or math.random(4,8) --nearestof:GetMinRangeAC()
            -- if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
            if range >=  minrange then
                --Print("ActualAlienFormula range range >=  minrange")
                entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                if not GetSetupConcluded() then
                    entity:SetConstructionComplete() 
                end
                doChain(entity)
                -- cost = GetAlienCostScalar(self, cost)
                --  if gamestarted then
                --	entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
                -- end
            end
            success = true
            else -- it tonly takes 1!
                entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                if not GetSetupConcluded() then
                    entity:SetConstructionComplete() 
                end
                    -- if entity:isa("Cyst") then CystChain(entity:GetOrigin()) end
                    --      if not entity:isa("Cyst") then FakeCyst(entity:GetOrigin()) end
                    --   if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                    success = true
            end 
        end
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