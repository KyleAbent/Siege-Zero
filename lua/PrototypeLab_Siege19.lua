function PrototypeLab:GetMinRangeAC()
return ProtoAutoCCMR      
end

function PrototypeLab:OnPowerOn()
	 GetImaginator().activeArmorys = GetImaginator().activeProtos + 1;  
end

function PrototypeLab:OnPowerOff()
	 GetImaginator().activeArmorys = GetImaginator().activeProtos - 1;  
end

 function PrototypeLab:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetImaginator().activeArmorys  = GetImaginator().activeProtos- 1;  
	  end
end