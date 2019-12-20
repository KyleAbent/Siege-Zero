//Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19") 
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")


local networkVars = 

{

}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)

local origcreate = ARC.OnCreate
function ARC:OnCreate()
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    origcreate(self)
end


if Server then


function ARC:Instruct(where)
   self:SpecificRules(where)
   return true
end

local function MoveToHives(self, where) --Closest hive from origin
--Print("Siegearc MoveToHives")  
/*
local where = nil
   if not GetIsInSiege(self) then
     local siegelocation = GetSiegeLocation()
     if not siegelocation then return true end
     local siegepower = GetPowerPointForLocation(siegelocation.name)
           where = FindFreeSpace(siegepower:GetOrigin())
   else Print("MoveToHives inSiege")   --in siege 
    -- local hiveclosest = GetNearest(self:GetOrigin(), "Hive", 2)
     --   if hiveclosest then
           local origin  = FindArcHiveSpawn(self:GetOrigin()) 
           if origin then
            where = origin
           end
       -- end
   end
*/
               if where then
                    self:GiveOrder(kTechId.Move, nil, FindFreeSpace(where), nil, true, true)
                    return
                end   
end
local function MoveToRandomChair(who) --Closest hive from origin
 local commandstation = GetEntitiesForTeam( "CommandStation", 1 )
  commandstation = table.random(commandstation)
 
               if commandstation then
        local origin = commandstation:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end
local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
function ARC:GetIsDeployed()
return  self.deployMode == ARC.kDeployMode.Deployed
end
function ARC:SetDeployed()
GiveDeploy(self) 
end

function ARC:SpecificRules(where)
local moving = self.mode == ARC.kMode.Moving    
local isSiegeOpen =  GetSiegeDoorOpen() 
Print("SpecificRules isSiegeOpen is %s", isSiegeOpen)
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed

local inradius =  not isSiegeOpen and ( GetIsPointWithinChairRadius(self:GetOrigin()) or CheckForAndActAccordingly(self) ) or 
                      isSiegeOpen and (  GetIsInSiege(self) and GetIsPointWithinHiveRadius(self:GetOrigin()) )
local shouldstop = false
local shouldmove = not shouldstop and not moving and not inradius
local shouldstop = moving and shouldstop
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving
  
  if moving then
    
    if shouldstop or shouldattack then 
           FindNewParent(self)
       --Print("StopOrder")
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
      
         GiveUnDeploy(self)
       else 
            if not isSiegeOpen then
             MoveToRandomChair(self)
            elseif where ~= nil then
             MoveToHives(self,where)
            end
       end
       
   elseif shouldattack then
   
     GiveDeploy(self)
    return true
    
 end
 
    end
end//function


local origrules = ARC.AcquireTarget
function ARC:AcquireTarget() 

local canfire = GetSetupConcluded()
--Print("Arc can fire is %s", canfire)
if not canfire then return end
return origrules(self)
end



end//server



Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)