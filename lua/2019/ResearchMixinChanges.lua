//Kyle 'Avoca' Abent
if Server then
    local function DoResearches(self)
        //print("DoResearches [A]")
        //if self:GetIsResearching() then return or (self.GetIsBuilt and not self:GetIsBuilt()) or (self.GetIsPowered and not self:GetIsPowered()) then return true end
         
        //if self:isa("Sentry") then //or any other with 0 bleh
            //return false
       // end
        if self:GetIsResearching() then 
            //print("DoResearches isresearching")
            return true 
         end
         
    if (self.GetIsBuilt and not self:GetIsBuilt()) then
            //print("DoResearches Not built")
            return true 
         end
         
        if (self.GetIsPowered and not self:GetIsPowered()) then 
            //print("DoResearches Not powered")
            return true 
        end

 //print("DoResearches [B]")
            //tunnelentranceerrors
            if self:isa("TunnelEntrance") then
                return false
            end
            
            
            local techIds = {}
            if self:isa("EvolutionChamber") then
                table.insert(techIds, kTechId.Charge )
                table.insert(techIds, kTechId.BileBomb )
                table.insert(techIds, kTechId.MetabolizeEnergy )
                table.insert(techIds, kTechId.Leap )
                table.insert(techIds, kTechId.Spores )
                table.insert(techIds, kTechId.Umbra )
                table.insert(techIds, kTechId.MetabolizeHealth )
                table.insert(techIds, kTechId.BoneShield )
                table.insert(techIds, kTechId.Stab )
                table.insert(techIds, kTechId.Stomp )
                table.insert(techIds, kTechId.Xenocide )
            elseif self:isa("Hive") then
                table.insert(techIds, self:GetTechButtons()[2] )
            elseif self:isa("Egg") then
                table.insert(techIds, self:GetTechButtons()[5] )
                table.insert(techIds, self:GetTechButtons()[6] )
                table.insert(techIds, self:GetTechButtons()[7] )
                table.insert(techIds, self:GetTechButtons()[8] )
                table.shuffle(techIds)
            elseif self:isa("Observatory") then
                 table.insert(techIds, kTechId.PhaseTech )
            else
                 techIds = self:GetTechButtons()
            end
            //print("DoResearches [C]")
            
            //remove those counting digest so it doesnt go down below
            //remove it by trimming it before it gets added
            if techIds == nil or #techIds == 0 then 
                //print("Removing entity from being able to research")
                //print(self:GetMapName())
                return false 
            end // false?
            
            //print("DoResearches [D]")
            local techId = table.random(techIds)
            if techId and techId ~= kTechId.None and techId ~= kTechId.Recycle and techId ~= kTechId.Consume then
                //print("DoResearches [E]")
                if not GetHasTech(self, techId)  and self:GetCanResearch(techId) then
                    //print("DoResearches [F]")
                    local tree = GetTechTree(self:GetTeamNumber())
                    local techNode = tree:GetTechNode(techId)
                    if tree:GetTechAvailable(techId) and not techNode:GetResearching() then
                         //print("DoResearches [G]")
                        self:SetResearching(techNode, self)
                   end
               end
            end
        
        //Hold off on the "Not Being Researched" // duplication issue ... 
        
        return true // ? hm lol
        
    end





local origInit = ResearchMixin.__initmixin

function ResearchMixin:__initmixin()
    origInit(self)
        self:AddTimedCallback(DoResearches, 16) 
end

    //Random player teammate
    //local orig = ResearchMixin.GetIssuedCommander
//function ResearchMixin:GetIssuedCommander()
    //if ( self:GetTeamNumber() == 1 and not GetIsImaginatorMarineEnabled()  ) or 
      //(  self:GetTeamNumber() == 2 and not GetIsImaginatorAlienEnabled()  )   then
     //   return orig(self)
   // end
function ResearchMixin:GetAutoIssued()
    local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
    return table.random(players)
    
end



end




