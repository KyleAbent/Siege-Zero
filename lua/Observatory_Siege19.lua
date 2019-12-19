function Observatory:OnPowerOn()
	 GetImaginator().activeObs = GetImaginator().activeObs + 1;  
end

function Observatory:OnPowerOff()
	 GetImaginator().activeObs = GetImaginator().activeObs - 1;  
end

 function Observatory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activeObs  = GetImaginator().activeObs- 1;  
	  end
end
