
 function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
if Server then

    function Whip:OnOrderComplete(currentOrder)     
        doChain(self)
    end
    
    
    function Whip:OnEnterCombat() 
        if self.moving then  
            self:ClearOrders()
            self:GiveOrder(kTechId.Stop, nil, self:GetOrigin(), nil, true, true)  
            doChain(self)
        end
    end
    
end