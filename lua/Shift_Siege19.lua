Script.Load("lua/2019/Con_Vars.lua")

if Server then 

    function Shift:OnConstructionComplete()
        GetImaginator().activeShifts = GetImaginator().activeShifts + 1;  
    end


    function Shift:PreOnKill(attacker, doer, point, direction)

        if self:GetIsBuilt() then
            GetImaginator().activeShifts  = GetImaginator().activeShifts- 1;  
        end
    end

    function Shift:OnOrderComplete(currentOrder)
        if currentOrder == kTechId.Move then 
            doChain(self)
        end
    end

end

function Shift:ManageShifts()

    if self:GetCanTeleport() then
        local destination = findDestinationForAlienConst(self)
        if destination then
            self:TriggerTeleport(5, self:GetId(), FindFreeSpace(destination:GetOrigin(), 4), 0)
            return
        end
    end
    
end

local origUpdate = Shift.OnUpdate 

function Shift:OnUpdate(deltaTime)
    origUpdate(self,deltaTime)
     if Server then
        if not self.manageShiftsTime or self.manageShiftsTime + kManageShiftsInterval <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() then
                self:ManageShifts()
            end
            self.manageShiftsTime = Shared.GetTime()
        end
     end
        
end