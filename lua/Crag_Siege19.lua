function Crag:GetMinRangeAC()
return CragAutoCCMR       
end
 
local function ManageHealWave(self)
      for _, entity in ipairs(GetEntitiesWithinRange("Live", self:GetOrigin(), Crag.kHealRadius)) do
                 if not self:GetIsOnFire() and GetIsUnitActive(self) and entity:GetIsInCombat() and entity:GetHealthScalar() <= .9  then
                         self:TriggerHealWave()
                         if self.moving then 
                            self:ClearOrders()
                        end
                end
      end
end

function Crag:InstructSpecificRules()
ManageHealWave(self)
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

end