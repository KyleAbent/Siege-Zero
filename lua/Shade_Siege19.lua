function Shade:GetMinRangeAC()
    return ShadeAutoCCMR     
end

local origCons = Shade.OnConstructionComplete
function Shade:OnConstructionComplete()
    origCons(self)
    GetImaginator().activeShades = GetImaginator().activeShades + 1;  
end

function Shade:PreOnKill(attacker, doer, point, direction)
    if self:GetIsBuilt() then
    GetImaginator().activeShades  = GetImaginator().activeShades- 1;  
    end
end
