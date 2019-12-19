/*

local origbuttons = Extractor.GetTechButtons
function Extractor:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.MTresBuff1
 table[3] = kTechId.MPresBuff1
 
 return table

end

*/

/*
Script.Load("lua/ResearchMixin.lua")




local origbuttons = Extractor.GetTechButtons
function Extractor:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.ExtractorArmor1

 
 return table

end

if Server then

function Extractor:OnResearchComplete(researchId)
  
  if researchId == kTechId.ExtractorArmor1 then
     self:AdjustMaxArmor(self:GetMaxArmor() * 1.10)
  end

end

function Extractor:UpdateResearch()

    local researchId = self:GetResearchingId()

    if researchId == kTechId.AdvancedArmoryUpgrade then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.ExtractorArmor1)    
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
        
    end

end


end

*/