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



function Shade:ManageShades()


    /////////////During Setup/////////////////////////////////////////

    if not GetSiegeDoorOpen() then 

        if self:GetCanTeleport() then                                                
            local nonCloaked = GetNearestMixin(self:GetOrigin(), "Cloakable", 2, function(ent) return not ent:GetIsCloaked() end)
            if nonCloaked then
                self:TriggerTeleport(5, self:GetId(), FindFreeSpace(nonCloaked:GetOrigin(), 4), 0)
                return
            end
        end

    end
    
    ////////////During Front Open//////////////////////////////////////
    if GetFrontDoorOpen() then //Manage ShadeInk
           //Maybe better to have the origin of scan search for shades within radius
        if GetIsScanWithinRadius(self:GetOrigin()) and GetConductor():GetIsInkAllowed() then
            CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), 2)
            self:TriggerEffects("shade_ink")
            GetConductor():JustInkedNowSetTimer()
        end
    end


   /////////////////////During Siege////////////////////////////////////////
    if not GetSiegeDoorOpen() then return end//for now just during siege

        local hive = GetRandomHive()
        if self.moving then
            return 
        end
        if not GetIsPointWithinHiveRadius(self:GetOrigin()) then
            local hive = GetRandomHive()
            if hive then
                self:GiveOrder(kTechId.Move, hive:GetId(), FindFreeSpace(hive:GetOrigin(), 4), nil, false, false) 
                SetDirectorLockedOnEntity(self)
            end
        end
    
    
end

local origUpdate = Shade.OnUpdate 

function Shade:OnUpdate(deltaTime)
    origUpdate(self,deltaTime)
     if Server then
        if not self.manageShadeTime or self.manageShadeTime + kManageShadeInterval <= Shared.GetTime() then
            if GetIsImaginatorAlienEnabled() and GetConductor():GetIsShadeMovementAllowed() then
                self:ManageShades()
                 GetConductor():JustMovedShadeSetTimer()
            end
              self.manageShadeTime = Shared.GetTime()
        end
     end
        
end