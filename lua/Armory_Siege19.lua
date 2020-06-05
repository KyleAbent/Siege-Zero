function Armory:GetMinRangeAC()
return ArmoryAutoCCMR 
end


function Armory:OnPowerOn()
	 GetRoomPower(self).activeArmorys = GetImaginator().activeArmorys + 1;  
end

function Armory:OnPowerOff()
	 GetRoomPower(self).activeArmorys = GetImaginator().activeArmorys - 1;  
end

 function Armory:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetRoomPower(self).activeArmorys  = GetImaginator().activeArmorys- 1;  
	  end
end
