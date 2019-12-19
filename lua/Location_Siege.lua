if Server then
  local orig = Location.OnTriggerEntered
   function Location:OnTriggerEntered(entity, triggerEnt)
     orig(self, entity, triggerEnt)
         if GetGamerules():GetGameStarted() then
              if (  ( string.find(self.name, "siege") or string.find(self.name, "Siege") )  and not GetTimer():GetSiegeOpenBoolean() ) then
                  entity:Kill() 
               end
         end
         
        if not entity:isa("Commander") and ( GetImaginator():GetIsMarineEnabled() or GetImaginator():GetIsAlienEnabled() ) then
            local powerPoint = GetPowerPointForLocation(self.name)
                if powerPoint ~= nil then
                    if entity:isa("Marine") then --and marine/alien enabled
                        if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then
                            powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)
                        end
                        if not GetFrontDoorOpen() then
                            powerPoint:SetConstructionComplete()
                        end
                    elseif entity:isa("Alien") and not entity:isa("Commander") then
                        if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then
                            powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)
                            powerPoint:SetConstructionComplete()
                            powerPoint:Kill()
                        end
                    end
                end
        end  
   
    end
end//Server