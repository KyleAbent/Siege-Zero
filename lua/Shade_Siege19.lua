function Shade:GetMinRangeAC()
    return ShadeAutoCCMR     
end

function Shade:OnConstructionComplete()
    GetImaginator().activeShades = GetImaginator().activeShades + 1;  
end

function Shade:PreOnKill(attacker, doer, point, direction)
    if self:GetIsBuilt() then
    GetImaginator().activeShades  = GetImaginator().activeShades- 1;  
    end
end

if Server then

    function Shade:OnOrderComplete(currentOrder)
        if currentOrder == kTechId.Move then 
            doChain(self)
        end
    end
    
    function Shade:OnEnterCombat() 
        if self.moving then  
            self:ClearOrders()
            self:GiveOrder(kTechId.Stop, nil, self:GetOrigin(), nil, true, true)  
            doChain(self)
        end
    end

end