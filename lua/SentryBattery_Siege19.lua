local origInit = SentryBattery.OnInitialized 

function SentryBattery:OnInitialized()
    origInit(self)
    if Server then
        GetRoomPower(self):ToggleCountMapName(self:GetMapName(),1)
    end
end


 function SentryBattery:PreOnKill(attacker, doer, point, direction)
	    GetRoomPower(self):ToggleCountMapName(self:GetMapName(),-1)
end

//6.18.20 -- recent update had infinite entity spawn due to broken count haha. so much for lag!!!
//These functions may be better as a mixin to seperate the need for splitting upon each class
///use by GetMapName maybe, ah well. ..