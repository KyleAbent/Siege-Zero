function ArmsLab:OnPowerOn()
	 GetImaginator().activeArms = GetImaginator().activeArms + 1;  
end

function ArmsLab:OnPowerOff()
	 GetImaginator().activeArms = GetImaginator().activeArms - 1;  
end

 function ArmsLab:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetImaginator().activeArms  = GetImaginator().activeArms- 1;  
	  end
end