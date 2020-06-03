local kSmashEggRange = 1.5
local function SmashNearbyCysts(self)
    assert(Server)
    local nearbyEggs = GetEntitiesWithinRange("Cyst", self:GetOrigin(), kSmashEggRange)
    for e = 1, #nearbyEggs do
        nearbyEggs[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
    end
    return true
end

local origCreate = Exo.OnCreate 

function Exo:OnCreate()
    origCreate(self)
    if Server then
        self:AddTimedCallback(SmashNearbyCysts, 0.1)
    end
end


