function PhaseGate:GetMinRangeAC()
return PGAutoCCMR  
end

function PhaseGate:OnPowerOn()
	 GetImaginator().activePGs = GetImaginator().activePGs + 1;  
end

function PhaseGate:OnPowerOff()
	 GetImaginator().activePGs = GetImaginator().activePGs - 1;  
end

 function PhaseGate:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetImaginator().activePGs  = GetImaginator().activePGs- 1;  
	  end
end