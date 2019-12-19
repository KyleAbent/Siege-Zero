/*
local origbuttons = InfantryPortal.GetTechButtons
function InfantryPortal:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[3] = kTechId.RunSpeed1
 table[4] = kTechId.ClipSize1
  
 return table

end
*/

function InfantryPortal:GetMinRangeAC()
return IPAutoCCMR  
end