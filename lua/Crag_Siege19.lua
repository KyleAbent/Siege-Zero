Script.Load("lua/2019/Con_Vars.lua")

local networkVars = { 

lastWave = "time",
}

local originit = Crag.OnInitialized
function Crag:OnInitialized()
    originit(self)
    self.lastWave = 0
end

 
function Crag:GetIsWaveAllowed()
    return GetIsTimeUp(self.lastWave, kHealWaveCooldown)
end
function Crag:JustWavedNowSetTimer()
    self.lastWave = Shared.GetTime()//Although should be global in conductor like shadeink is , rather than for every crag having its own unique delay
end

local function ManageHealWave(self)
    for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Combat", 2, self:GetOrigin(),Crag.kHealRadius) ) do
                 if entity ~= self and entity:GetIsInCombat() and entity:GetHealthScalar() <= .9  then
                         self:TriggerHealWave()
                         //if self.moving then 
                            //self:ClearOrders()
                        //end
                        self:JustWavedNowSetTimer()
                        break//Only trigger once , not for every ... lol
                end
      end
end

function Crag:InstructSpecificRules()
    if self:GetIsWaveAllowed() and not self:GetIsOnFire() and GetIsUnitActive(self) then
        ManageHealWave(self)
    end
end

 function Crag:OnConstructionComplete()
	 GetImaginator().activeCrags = GetImaginator().activeCrags + 1;  
end

 function Crag:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsBuilt() then
	    GetImaginator().activeCrags  = GetImaginator().activeCrags- 1;  
	  end
end


if Server then

    function Crag:ManageCrags()
    
           self:InstructSpecificRules()
           if self:GetCanTeleport() then    
                local destination = findDestinationForAlienConst(self)
                if destination then 
                    self:TriggerTeleport(5, self:GetId(), FindFreeSpace(destination:GetOrigin(), 4), 0)
                    return
                end
            end
        
    end


end//server
local origUpdate = Crag.OnUpdate 

function Crag:OnUpdate(deltaTime)
    origUpdate(self,deltaTime)
     if Server then
        if not self.manageCragsTime or self.manageCragsTime + kManageCragInterval <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() and GetConductor():GetIsCragMovementAllowed() then
                self:ManageCrags()
                GetConductor():JustMovedCragSetTimer()
            end
            self.manageCragsTime = Shared.GetTime()
        end
     end
        
end



Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)