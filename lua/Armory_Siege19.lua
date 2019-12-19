function Armory:GetMinRangeAC()
return ArmoryAutoCCMR 
end


function Armory:OnPowerOn()
	 GetImaginator().activeArmorys = GetImaginator().activeArmorys + 1;  
end

function Armory:OnPowerOff()
	 GetImaginator().activeArmorys = GetImaginator().activeArmorys - 1;  
end

 function Armory:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetImaginator().activeArmorys  = GetImaginator().activeArmorys- 1;  
	  end
end
