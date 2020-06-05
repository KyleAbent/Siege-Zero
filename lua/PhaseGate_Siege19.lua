function PhaseGate:GetMinRangeAC()
return PGAutoCCMR  
end

function PhaseGate:OnPowerOn()
	 GetRoomPower(self).activePGs = GetImaginator().activePGs + 1;  
end

function PhaseGate:OnPowerOff()
	 GetRoomPower(self).activePGs = GetImaginator().activePGs - 1;  
end

 function PhaseGate:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetRoomPower(self).activePGs  = GetImaginator().activePGs- 1;  
	  end
end