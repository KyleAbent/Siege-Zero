function Armory:OnPowerOn()
	GetRoomPower(self):ToggleCountMapName(self:GetMapName(),-1)
end

function Armory:OnPowerOff()
	 GetRoomPower(self):ToggleCountMapName(self:GetMapName(),-1)
end

 function Armory:PreOnKill(attacker, doer, point, direction)
	  if self:GetIsPowered() then
	    GetRoomPower(self):ToggleCountMapName(self:GetMapName(),-1) 
	  end
end

//6.18.20 -- recent update had infinite entity spawn due to broken count haha. so much for lag!!!
//These functions may be better as a mixin to seperate the need for splitting upon each class
///use by GetMapName maybe, ah well. ..
