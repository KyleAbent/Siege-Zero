function PrototypeLab:GetMinRangeAC()
return ProtoAutoCCMR      
end

function PrototypeLab:OnPowerOn()
	 GetRoomPower(self).activeProtos = GetImaginator().activeProtos + 1;  
end

function PrototypeLab:OnPowerOff()
	 GetRoomPower(self).activeProtos = GetImaginator().activeProtos - 1;  
end

 function PrototypeLab:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetRoomPower(self).activeProtos  = GetImaginator().activeProtos- 1;  
	  end
end