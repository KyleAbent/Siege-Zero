function SentryBattery:GetMinRangeAC()
return IPAutoCCMR  
end

function SentryBattery:GetMinRangeAC()
    return ArmsLabAutoCCMR 
end

function SentryBattery:OnPowerOn()
	 GetImaginator().activeBatteries = GetImaginator().activeBatteries + 1;  
end

function SentryBattery:OnPowerOff()
	 GetImaginator().activeBatteries = GetImaginator().activeBatteries - 1;  
end

 function SentryBattery:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetImaginator().activeBatteries  = GetImaginator().activeBatteries- 1;  
	  end
end