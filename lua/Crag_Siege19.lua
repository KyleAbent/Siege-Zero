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


Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)