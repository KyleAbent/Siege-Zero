Script.Load("lua/2019/Con_Vars.lua")

local origUpdate = Drifter.OnUpdate 

function Drifter:OnUpdate(deltaTime)
    origUpdate(self,deltaTime)
    if Server then
        if not self.manageDriferTime or self.manageDriferTime + kManageDrifterInterval <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() and GetConductor():GetIsDriftMovementAllowed() then
                self:ManageDrifters()
                GetConductor():JustMovedDriftSetTimer()
            end
             self.manageDriferTime = Shared.GetTime()
        end
    end
        
end


local function GiveDrifterOrder(who, where)

    local structure =  GetNearestMixin(who:GetOrigin(), "Construct", 2, function(ent) return not ent:GetIsBuilt() and (not ent.GetCanAutoBuild or ent:GetCanAutoBuild()) and not ent:isa("Cyst")  end)
    local player =  GetNearest(who:GetOrigin(), "Alien", 2, function(ent) return ent:GetIsInCombat() and ent:GetIsAlive() end) 

    local target = nil

    if structure then
        target = structure
    end

    if player then
        local chance = math.random(1,100)
        local boolean = chance >= 70
        if boolean then
            who:GiveOrder(GetDrifterBuff(), player:GetId(), player:GetOrigin(), nil, false, false)
            SetDirectorLockedOnEntity(who)
            return
        end
    end

    if  structure then      
        who:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
        SetDirectorLockedOnEntity(who)
        return  
    end
        
end


function Drifter:ManageDrifters()
    if not self:GetHasOrder() then
        GiveDrifterOrder(self, self:GetOrigin())
    end
end