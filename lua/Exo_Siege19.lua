Script.Load("lua/StunMixin.lua")
Script.Load("lua/2019/StunWall.lua")




local networkVars = {   


 }
 
AddMixinNetworkVars(StunMixin, networkVars)
 
local oninit = Exo.OnInitialized
function Exo:OnInitialized()
    oninit(self)
    InitMixin(self, StunMixin)
end

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

function Exo:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + 8 < Shared.GetTime() 
end

function Exo:OnStun()
         if Server then
                local stunwall = CreateEntity(StunWall.kMapName, self:GetOrigin(), 2)    
                StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
        end
end


Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars)