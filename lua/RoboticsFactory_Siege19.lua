function RoboticsFactory:GetMinRangeAC()
return RoboAutoCCMR    
end

function RoboticsFactory:OnPowerOn()
	 GetRoomPower(self).activeRobos = GetImaginator().activeRobos + 1;  
end

function RoboticsFactory:OnPowerOff()
	 GetRoomPower(self).activeRobos = GetImaginator().activeRobos - 1;  
end

 function RoboticsFactory:PreOnKill(attacker, doer, point, direction)
      
	  if self:GetIsPowered() then
	    GetRoomPower(self).activeRobos  = GetImaginator().activeRobos- 1;  
	  end
end