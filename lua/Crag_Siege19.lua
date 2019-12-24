local networkVars = { 

lastWave = "time",
}

local originit = Crag.OnInitialized
function Crag:OnInitialized()
    originit(self)
    self.lastWave = 0
end

function Crag:GetMinRangeAC()
return CragAutoCCMR       
end
 
function Crag:GetIsWaveAllowed()
    return GetIsTimeUp(self.lastWave, kHealWaveCooldown)
end
function Crag:JustWavedNowSetTimer()
    self.lastWave = Shared.GetTime()
end

local function ManageHealWave(self)
      for _, entity in ipairs(GetEntitiesWithinRange("Live", self:GetOrigin(), Crag.kHealRadius)) do
                 if not self:GetIsOnFire() and GetIsUnitActive(self) and entity:GetIsInCombat() and entity:GetHealthScalar() <= .9  then
                         self:TriggerHealWave()
                         if self.moving then 
                            self:ClearOrders()
                        end
                        break//Only trigger once , not for every ... lol
                end
      end
end

function Crag:InstructSpecificRules()
    if GetIsWaveAllowed() then
        ManageHealWave(self)
        self:JustWavedNowSetTimer()
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

    function Crag:OnOrderComplete(currentOrder)
        if currentOrder == kTechId.Move then 
            doChain(self)
        end
    end
    
    function Crag:OnEnterCombat() 
        if self.moving then  
            self:ClearOrders()
            self:GiveOrder(kTechId.Stop, nil, self:GetOrigin(), nil, true, true)  
            doChain(self)
        end
    end

end

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)