/*

local origbuttons = Harvester.GetTechButtons
function Harvester:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.ATresBuff1
 table[3] = kTechId.APresBuff1
 
 return table

end

*/