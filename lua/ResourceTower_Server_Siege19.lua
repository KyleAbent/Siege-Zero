/*

local orig = ResourceTower.CollectResources
function ResourceTower:CollectResources()


    orig(self)
    
    if self:GetTeamNumber() == 1 and  GetHasTech(self, kTechId.MTresBuff1)  then
           local team = self:GetTeam()
            if team then
           -- Print("1 Bonus %s",kTeamResourcePerTick * 0.05)
            team:AddTeamResources(kTeamResourcePerTick * 0.05, true)
             end
    else if self:GetTeamNumber() == 2 and  GetHasTech(self, kTechId.ATresBuff1) then
           local team = self:GetTeam()
           if team then
            --Print("2 Bonus %s",kTeamResourcePerTick * 0.05)
            team:AddTeamResources(kTeamResourcePerTick * 0.05, true)
          end
      end
  end

end

*/