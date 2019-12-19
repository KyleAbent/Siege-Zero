if Server then 

    function Shift:GetMinRangeAC()
        return ShiftAutoCCMR    
    end

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