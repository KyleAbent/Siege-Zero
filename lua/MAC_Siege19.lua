Script.Load("lua/2019/Con_Vars.lua")

local origUpdate = MAC.OnUpdate 

function MAC:OnUpdate(deltaTime)
    origUpdate(self,deltaTime)
    
    if Server then
        if not self.manageMacTime or self.manageMacTime + kManageMacInterval <= Shared.GetTime() then
            if GetIsImaginatorMarineEnabled() then
                self:ManageMacs()
            end
            self.manageMacTime = Shared.GetTime()
        end
    end
        
end


local function ManagePlayerWeld(who, where)
    local player =  GetNearest(who:GetOrigin(), "Marine", 1, function(ent) return ent:GetIsAlive() end)
    if player then
        who:GiveOrder(   kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
        SetDirectorLockedOnEntity(who)
    end
end

local function ManagePowerMac(who, where)
    print("ManagePowerMac")
    local power =  GetNearest(who:GetOrigin(), "Powerpoint", 1, function(ent) return not ent:GetIsBuilt() and not GetIsInSiege(ent) end) //Not in siege and siege not open .. for not just not siege.
    if power then
        print("ManagePowerMac found power")
        who:GiveOrder(kTechId.Move, nil, FindFreeSpace(power:GetOrigin(),4), nil, true, true)
        SetDirectorLockedOnEntity(who)
    end
end


function MAC:ManageMacs()

    if not self:GetHasOrder() then
        local random = math.random(1,2)
        if random == 1 or isSetup then
            ManagePlayerWeld(self, self:GetOrigin())
        else
            ManagePowerMac(self, self:GetOrigin())
        end
    end
    
end