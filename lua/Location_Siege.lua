if Server then
  local orig = Location.OnTriggerEntered
   function Location:OnTriggerEntered(entity, triggerEnt)
    //print("OnTriggerEntered")
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
                        if not powerPoint:GetIsBuilt() then //powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then
                            powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)
                        end
                        if not GetFrontDoorOpen() then
                            powerPoint:SetConstructionComplete()
                            powerPoint.hasBeenToggledDuringSetup = true
                        end
                    elseif entity:isa("Alien") and not entity:isa("Commander") then
                        //print("Alien Entity walked in room...")
                        if not powerPoint:GetIsBuilt() then
                        print("Setup power then kill")
                            powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)
                            powerPoint:SetConstructionComplete()
                            powerPoint:Kill()
                            if not GetFrontDoorOpen() then
                                powerPoint.hasBeenToggledDuringSetup = true
                            end
                        end
                    end
                end
        end  
   
    end
end//Server