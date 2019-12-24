-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/


class 'Conductor' (Entity)
Conductor.kMapName = "conductor"

local networkVars =

{
    arcSiegeOrig = "vector",//Added a way in to reset this if there's two hives down and 1 hive outside of radius 
    //mostRecentCyst = "entityid"
    mostRecentCystOrig = "vector",
    lastInk = "time" //Global in one location rather than local for every shade in many locations
}


function Conductor:OnCreate()
    self.arcSiegeOrig = self:GetOrigin()
    self.mostRecentCystOrig = self:GetOrigin()
    self.lastInk = 0
    for i = 1, 8 do
        Print("Conductor created")
    end
    self:SetUpdates(true)
end

function Conductor:GetIsInkAllowed()
    return GetHasShadeHive() and GetIsTimeUp(self.lastInk, kShadeInkCooldown)
end
function Conductor:JustInkedNowSetTimer()
    self.lastInk = Shared.GetTime()
end
/*
function Conductor:SetMostRecentCyst(cystid)
    self.mostRecentCyst = cystid//Do I have to hook CystPreOnKill, call cond, get most recent cyst id.. if match then set back to invalid? Hm. Not Sure. Ah.
end
*/    
function Conductor:SetMostRecentCystOrigin(vector)
    self.mostRecentCystOrig = vector//So I don't have to worry about entity id with cyst and all that hehe
end
   function Conductor:GetMostRecentCystOrigin()
    return self.mostRecentCystOrig
end 
function Conductor:GetArcSpotForSiege()
local inradius = GetIsPointWithinHiveRadius(self.arcSiegeOrig)//#GetEntitiesWithinRange("Hive", self.arcSiegeOrig, ARC.kFireRange - 3) >= 1
    if not inradius then
        //Print("Conductor arc spot to place not in hive radius")
        local siegelocation = GetASiegeLocation()
        local siegepower = GetPowerPointForLocation(siegelocation.name)
        local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
        if hiveclosest then
            //Print("Found hiveclosest")
            local origin  = FindArcHiveSpawn(self.arcSiegeOrig)//Adding for 0 incase old spot is saved, find new one near old spot.
            if origin == nil then
                print("[0]ERROR! AH! Unable to find Arc placement near siege.")
                origin  = FindArcHiveSpawn(siegepower:GetOrigin())
            end
            if origin == nil then
                print("[1]ERROR! AH! Unable to find Arc placement near siege.")
                origin  = FindArcHiveSpawn(hiveclosest:GetOrigin())
            end
            if origin == nil then
                print("[2]ERROR! AH! Unable to find Arc placement near siege.")
                local avg = siegepower:GetOrigin().x + hiveclosest:GetOrigin().x
                avg = avg / 2
                local toLook = siegepower:GetOrigin()
                      toLook.x = avg
                origin  = FindArcHiveSpawn(toLook)
            end
            if origin == nil then
                print("[3]ERROR! AH! Unable to find Arc placement near siege.")
                return
            end

            if origin ~= nil then
                local inRangeofOrigin = GetIsPointWithinHiveRadius(origin) //#GetEntitiesWithinRange("Hive", origin, ARC.kFireRange) >= 1
                if inRangeofOrigin then
                self.arcSiegeOrig = origin
                Print("Found arc spot within hive radius")
                end
            end
            if origin == nil then
                print("[4]ERROR! AH! Unable to find Arc placement for Siege!")
                return
            end
        end
    end
end

if Server then
    function Conductor:OnUpdate(deltatime)

        if not self.timeLastArcSiege or self.timeLastArcSiege + 20 <= Shared.GetTime() then//and self.arcSiegeOrig == self:GetOrigin() then
            if GetSiegeDoorOpen() and GetIsImaginatorMarineEnabled() then 
            self:GetArcSpotForSiege()
            self.timeLastArcSiege = Shared.GetTime()
            //So if 2 hives are dead and 1 is remaining then find new spot. If possible. Though 2 more will likely drop in the meantime haha.
            end
        end

        if not self.timeLastAutomations or self.timeLastAutomations + 8 <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() then
                self:DoMist()
                self.timeLastAutomations = Shared.GetTime()//Just incase? o_O
            end
            if (GetIsImaginatorMarineEnabled() or GetIsImaginatorAlienEnabled()) then 
                self:Automations(GetIsImaginatorMarineEnabled(),GetIsImaginatorAlienEnabled())
                self.timeLastAutomations = Shared.GetTime()
            end
        end

        if not self.phaseCannonTime or self.phaseCannonTime + math.random(23,69) <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() then
                self:ContaminationSpawnTimer()
                self.phaseCannonTime = Shared.GetTime()
            end
        end

    end
end//Server


local function ChanceContaminationSpawn(self)
//Probably a more fair version of this rather than DDOS? LOL
    local onechance = math.random(1,2)

    if onechance == 1 then
        local chance = math.random(1,100)
        if chance >= 70 then
            local power = GetRandomActivePower()
            if power then  self:SpawnContamination(power)
                return
            end --if not power then
            else
                local cc = GetRandomCC()
                if cc then  self:SpawnContamination(cc)
                    return
                 end
        end
    else

        local power = GetRandomActivePower()
        if power then
          self:SpawnContamination(power)
           return
         end
    end

    local built = {}
    for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if not GetIsPointInMarineBase(powerpoint:GetOrigin()) and powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
            table.insert(built, powerpoint)
        end
    end
    
    if #built == 0 then return end
    local random = table.random(built)
    self:SpawnContamination(random)
end


function Conductor:ContaminationSpawnTimer()
         ChanceContaminationSpawn(self)
end

function Conductor:Automations(isMarineEnabled,isAlienEnabled)
             
            if isMarineEnabled then
              self:HandoutMarineBuffs()
            end

             if isMarineEnabled or isAlienEnabled and GetGameStarted() then
               self:AutoBuildResTowers()
             end

             return true
end

local function PowerPointStuff(who, self)
    local location = GetLocationForPoint(who:GetOrigin())
    local powerpoint =  location and GetPowerPointForLocation(location.name)
    local imaginator = GetImaginator()
    if powerpoint ~= nil then
        if imaginator:GetIsMarineEnabled() and ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) then
            print("PowerPointStuff return 1")
            return 1
        elseif imaginator:GetIsAlienEnabled() and ( powerpoint:GetIsDisabled() )  then
            print("PowerPointStuff return 2")
            return 2
        end
    end
end


local function WhoIsQualified(who, self)
   return PowerPointStuff(who, self)
end


local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
   if not GetSetupConcluded() then tower:SetConstructionComplete() end
         if tower then
            who:SetAttached(tower)
            if number == 2 then
             doChain(tower)
            end
            return tower
         end
end


local function Envision(self,who, which)
    local imaginator = GetImaginator()
   if which == 1 and imaginator:GetIsMarineEnabled() then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 and imaginator:GetIsAlienEnabled() then
    Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end

local function AutoDrop(self,who)
  local which = WhoIsQualified(who, self)
  if which ~= 0 then Envision(self,who, which) end
end

function Conductor:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if not respoint:GetAttached() then
            AutoDrop(self, respoint)
            if GetSetupConcluded() then
                break//One at a time? lol meh probably not. Huge delay? We'll see. Heh.
            end
        end
    end
end

function Conductor:DoMist()
   local hive = GetRandomHive()
   local embryo = nil
      if hive then
         embryo = GetNearest(hive:GetOrigin(), "Embryo", 2,  function(ent) return ent:GetIsAlive()  end ) --not misted
         if embryo then
            CreateEntity(NutrientMist.kMapName,embryo:GetModelOrigin(), 2 )
         end
      end
end


local function BuildAllNodes(self)

          for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
             powerpoint:SetConstructionComplete()
             local where = powerpoint:GetOrigin()
             if not GetIsPointInMarineBase(where) and math.random(1,2) == 1  then
                powerpoint:Kill()
             end
          end

end

function Conductor:OnRoundStart()
           if Server then
              BuildAllNodes(self)
              self:SpawnInitialStructures()
            end
end

function Conductor:ManageScans()
    if not GetSiegeDoorOpen() then
     return // Scan the avg origin of arc or something meh
    end
    local hive = GetRandomHive()
    if hive then
    CreateEntity(Scan.kMapName, hive:GetOrigin(), 1)
    end
end

function Conductor:ManageArcs()

    local where = nil

    if GetSiegeDoorOpen() and self.arcSiegeOrig ~= self:GetOrigin() then
        //print("ManageArcs SiegeDoorOpen and arcSiegeOrig origin is at conductor origin")
        where = self.arcSiegeOrig
    end
    
    if where == self:GetOrigin() then
        where = FindFreeSpace(GetRandomActivePower():GetOrigin(), math.random(2,4), math.random(8,24), false ) 
    end
    
    if where == self:GetOrigin()  then
        //print("Could not find spot for ARC!")
        return
    end
    
    for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
        arc:Instruct(where) //Function for ARCS !
    end

end

local function ManagePlayerWeld(who, where)
    local player =  GetNearest(who:GetOrigin(), "Marine", 1, function(ent) return ent:GetIsAlive() end)
    if player then
        who:GiveOrder(   kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
    end
end

function Conductor:ManageMacs()

    local cc = GetRandomCC()
    local  macs = GetEntitiesForTeam( "MAC", 1 )

    if cc then
        local where = cc:GetOrigin()
        if not #macs or #macs <6 then
            CreateEntity(MAC.kMapName, FindFreeSpace(where), 1)
        end
    end

    for i = 1, #macs do
        local mac = macs[i]
        if not mac:GetHasOrder() then
            ManagePlayerWeld(mac, mac:GetOrigin())
            break//One at a time for perf? lol
        end
    end

end

function Conductor:ManageShades()
    local random = math.random(1,4)
    if not GetSiegeDoorOpen() then return end//for now just during siege
    local shades = GetEntitiesForTeam( "Shade", 2 )

    for i = 1, random do --maybe time delay ah
        local hive = GetRandomHive()
        local shade = table.random(shades)
        if not shade then break end
        //Maybe better to have the origin of scan search for shades within radius
        if GetIsScanWithinRadius(shade:GetOrigin()) and self:GetIsInkAllowed() then
            CreateEntity(ShadeInk.kMapName, shade:GetOrigin() + Vector(0, 0.2, 0), 2)
            shade:TriggerEffects("shade_ink")
            self:JustInkedNowSetTimer()
        end
        if shade.moving then
            return 
        end
        if not GetIsPointWithinHiveRadius(shade:GetOrigin()) then
            local hive = GetRandomHive()
            if hive then
                shade:GiveOrder(kTechId.Move, hive:GetId(), FindFreeSpace(hive:GetOrigin(), 4), nil, false, false) 
            end
        end
    end 
end


function Conductor:ManageCrags()

    local random = math.random(1,4)
    if not GetFrontDoorOpen() then return end
    local crags = GetEntitiesForTeam( "Crag", 2 )

    for i = 1, random do --maybe time delay ah
        local hive = GetRandomHive()
        local crag = table.random(crags)
        if crag then
            --if moving then like arc instruct specificrules
            crag:InstructSpecificRules()
            if crag.moving then
                return 
            end
            if GetSiegeDoorOpen() and not GetIsPointWithinHiveRadiusForHealWave(crag:GetOrigin()) then
                local hive = GetRandomHive()
                if hive then
                    crag:GiveOrder(kTechId.Move, hive:GetId(), FindFreeSpace(hive:GetOrigin(), 4), nil, false, false) 
                end
            else
                local random = math.random(1,2)
                if random == 1 then
                    local power = GetNearest(crag:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and ent:GetIsDisabled() and GetLocationForPoint(crag:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin()) end ) 
                    if power then
                        crag:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
                    end
                    //Maybe some teammate in combat? and once not moving then doChain ?
                else
                    if self.mostRecentCystOrig ~= self:GetOrigin() then
                        crag:GiveOrder(kTechId.Move, nil, FindFreeSpace(self.mostRecentCystOrig, 4), nil, false, false) 
                    end
                end
            end
        end 
    end  
end

function Conductor:ManageShifts()
    if not GetFrontDoorOpen() then return end
    local random = math.random(1,4)
    for i = 1, random do --maybe time delay ah
        local hive = GetRandomHive()
        local nearestof = GetNearest(hive:GetOrigin(), "Shift", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat()  and not ent.moving )  end) //and not ent:GetIsACreditStructure()
        if nearestof then
            --if not moving
            local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and ent:GetIsDisabled() and GetLocationForPoint(nearestof:GetOrigin()) ~= GetLocationForPoint(ent:GetOrigin())  end ) 
            if power then
                nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
            end
        end 
    end  
end

function Conductor:ManageWhips()

    if not GetFrontDoorOpen() then return end
       --mindfuck would be getnearest built node that is beyond the arc radius of the closest arc to that node. HAH.
       --local powerpoint = GetRandomActivePower() 
       
       --gonna affect contam whip etc
       local random = math.random(1,4)
      
       --leave min around hive not all leave. hm.

       for i = 1, random do --maybe time delay ah
           local hive = GetRandomHive()--if hive then or return chair if no hive lol
           local nearestof = GetNearest(hive:GetOrigin(), "Whip", 2, function(ent) return ent:GetIsBuilt() and ( ent.GetIsInCombat and not ent:GetIsInCombat() and not ent.moving )  end)
            if nearestof then
               -- if not moving
               local power = GetNearest(nearestof:GetOrigin(), "PowerPoint", 1,  function(ent) return ent:GetIsBuilt() and not ent:GetIsDisabled()  end ) 
               if power then
                 nearestof:GiveOrder(kTechId.Move, power:GetId(), FindFreeSpace(power:GetOrigin(), 4), nil, false, false) 
                 -- CreatePheromone(kTechId.ThreatMarker,power:GetOrigin(), 2)  if get is time up then
               end
            end 
       end   

end
local function GiveDrifterOrder(who, where)

    local structure =  GetNearestMixin(who:GetOrigin(), "Construct", 2, function(ent) return not ent:GetIsBuilt() and (not ent.GetCanAutoBuild or ent:GetCanAutoBuild())   end)
    local player =  GetNearest(who:GetOrigin(), "Alien", 2, function(ent) return ent:GetIsInCombat() and ent:GetIsAlive() end) 

    local target = nil

    if structure then
        target = structure
    end

    if player then
        local chance = math.random(1,100)
        local boolean = chance >= 70
        if boolean then
            who:GiveOrder(GetDrifterBuff(), player:GetId(), player:GetOrigin(), nil, false, false)
            return
        end
    end

    if  structure then      
        who:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
        return  
    end
        
end
function Conductor:ManageDrifters()
    local hive = GetRandomHive()

    if hive then
        local where = hive:GetOrigin()
        local Drifters = GetEntitiesForTeamWithinRange("Drifter", 2, where, 9999)
        if not #Drifters or #Drifters <=3 then
            CreateEntity(Drifter.kMapName, FindFreeSpace(where), 2)
        end

        if #Drifters >= 1 then
            for i = 1, #Drifters do
                local drifter = Drifters[i]
                if not drifter:GetHasOrder() then
                    GiveDrifterOrder(drifter, drifter:GetOrigin())
                    break
                end
            end
        end

    end
   
end

function Conductor:GetIsMapEntity()
return true
end

Shared.LinkClassToMap("Conductor", Conductor.kMapName, networkVars)
