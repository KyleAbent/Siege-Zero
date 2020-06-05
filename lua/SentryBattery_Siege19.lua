function SentryBattery:GetMinRangeAC()
return IPAutoCCMR  
end

function SentryBattery:GetMinRangeAC()
    return ArmsLabAutoCCMR 
end

function SentryBattery:OnPowerOn()
	 GetRoomPower(self).activeBatteries = GetImaginator().activeBatteries + 1;  
end

function SentryBattery:OnPowerOff()
	 GetRoomPower(self).activeBatteries = GetImaginator().activeBatteries - 1;  
end

 function SentryBattery:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetRoomPower(self).activeBatteries  = GetImaginator().activeBatteries- 1;  
	  end
end