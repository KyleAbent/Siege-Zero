local oninit = Whip.OnInitialized
function Whip:OnInitialized()
    oninit(self)
     GetImaginator().activeWhips = GetImaginator().activeWhips + 1  
end

 function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
if Server then

    function Whip:OnOrderComplete(currentOrder)     
        --doChain(self)
            if not self:GetGameEffectMask(kGameEffect.OnInfestation) then
                local cyst = CreateEntity(Cyst.kMapName, FindFreeSpace(self:GetOrigin(), 1, kCystRedeployRange),2)
            end
    end
    
    
    function Whip:OnEnterCombat() 
        if self.moving then  
            self:ClearOrders()
            self:GiveOrder(kTechId.Stop, nil, self:GetOrigin(), nil, true, true)  
            --doChain(self)
            if not self:GetGameEffectMask(kGameEffect.OnInfestation) then
                local cyst = CreateEntity(Cyst.kMapName, FindFreeSpace(self:GetOrigin(), 1, kCystRedeployRange),2)
            end
        end
    end
    
end


 function Whip:PreOnKill(attacker, doer, point, direction)
      
	    GetImaginator().activeWhips  = GetImaginator().activeWhips - 1
end