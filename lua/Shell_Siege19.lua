Script.Load("lua/ResearchMixin.lua")


function Shell:GetTechButtons(techId)
local table = {}

 --table[1] = kTechId.AlienHealth1
 
 return table

end


/*
if Server then

function Shell:OnResearchComplete(researchId)
  
  if researchId == kTechId.AlienHealth1 then  --Onkill if 0 shells then revert to 0, on built if hp == old then buff back
    Skulk.kHealth = Skulk.kHealth * 1.10
    Gorge.kHealth = Gorge.kHealth * 1.10
   -- Lerk.kHealth = Lerk.kHealth * 1.10
    Fade.kHealth = Fade.kHealth* 1.10
    Onos.kHealth = Onos.kHealth * 1.10
   end

end



end
*/

