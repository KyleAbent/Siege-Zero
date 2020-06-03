/*
for i = 1, 64 do
    print("Infestedunpowered damage")
end
local origInfes = InfestationTrackerMixin.UpdateInfestedState
    function InfestationTrackerMixin:UpdateInfestedState(onInfestation)
      origInfes(self, onInfestation)
      if not self.alienspawnLoc or self.alienspawnLoc + 5 <= Shared.GetTime() then
        if self:GetTeamNumber() == 1 then
            if self.GetIsPowered and not self:GetIsPowered() then
                print("Self is unpowered and infested. Damaging!!!")
                //percent of health? Bleh
                self:DoDamage( 50, self, self:GetOrigin() )
            end
        end
      end
    end    
 */
  
    //Override and modify to add in lowering hp if power is off
    
    function CorrodeMixin:CorrodeOnInfestation()

   // if self:GetMaxArmor() == 0 then
    //    self.corrodeOnInfestationTimerActive = false
    //    return false
   // end

    if self.updateInitialInfestationCorrodeState and GetIsPointOnInfestation(self:GetOrigin()) then
    
        self:SetGameEffectMask(kGameEffect.OnInfestation, true)
        self.updateInitialInfestationCorrodeState = false
        
    end

    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetCanTakeDamage() and (not HasMixin(self, "GhostStructure") or not self:GetIsGhostStructure()) then
        
        self:SetCorroded()

        -- No point in dealing armor only damage to a unit without armor left
        -- Stops spamming marine commanders with "Your base is under attack" alerts
        if self:GetArmor() > 0 then
            if self:isa("PowerPoint") then
                self:DoDamageLighting()
            end

            self:DeductHealth(kInfestationCorrodeDamagePerSecond, nil, nil, false, self.GetIsPowered and self:GetIsPowered(), true) //If power off then damage health
        end
        
    end

    return true

end