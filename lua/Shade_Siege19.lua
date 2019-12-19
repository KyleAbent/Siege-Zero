local networkVars = { 

shouldInk = "boolean",
lastInk = "time",
}



local originit = Shade.OnInitialized
function Shade:OnInitialized()
    originit(self)
    self.lastInk = 0
    self.shouldInk = false
end

function Shade:GetMinRangeAC()
    return ShadeAutoCCMR     
end


if Server then

    function Shade:OnUpdate(deltaTime)
        if self.shouldInk and  GetIsTimeUp(self.lastInk, kShadeInkCooldown)  then
            CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), 2) 
            self.lastInk = Shared.GetTime()
            self.shouldInk = false
        end
    end
end

    function Shade:OnConstructionComplete()
        GetImaginator().activeShades = GetImaginator().activeShades + 1;  
    end


    function Shade:PreOnKill(attacker, doer, point, direction)
        if self:GetIsBuilt() then
        GetImaginator().activeShades  = GetImaginator().activeShades- 1;  
        end
    end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)