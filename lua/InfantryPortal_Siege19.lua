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

function InfantryPortal:OnPowerOn()
	 GetImaginator().activeIPS = GetImaginator().activeIPS + 1;  
end

function InfantryPortal:OnPowerOff()
	 GetImaginator().activeIPS = GetImaginator().activeIPS - 1;  
end

 function InfantryPortal:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetImaginator().activeIPS  = GetImaginator().activeIPS- 1;  
	  end
end