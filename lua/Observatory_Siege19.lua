function Observatory:OnPowerOn()
	 GetRoomPower(self).activeObs = GetImaginator().activeObs + 1;  
end

function Observatory:OnPowerOff()
	 GetRoomPower(self).activeObs = GetImaginator().activeObs - 1;  
end

 function Observatory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetRoomPower(self).activeObs  = GetImaginator().activeObs- 1;  
	  end
end
