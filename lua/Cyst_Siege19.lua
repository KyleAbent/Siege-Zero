/*

local networkVars = 

{
    forceConnected = "boolean"
}


local origonCreate = Cyst.OnCreate
function Cyst:OnCreate()
  origonCreate(self)
  self.forceConnected = false  
  if Server then
    self.forceConnected = GetImaginator():GetIsAlienEnabled()
  end
end

local origGetConnected = Cyst.GetIsConnected
function Cyst:GetIsConnected() 
    if self.forceConnected then
        return true
    else
        origGetConnected(self)
    end
end

if Server then
    local origConnected = Cyst.GetIsActuallyConnected
    function Cyst:GetIsActuallyConnected()
        if self.forceConnected then
            return true
        else
            origConnected(self)
        end
    end
end


Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)

*/

if Server then

///:ReconnectOthers()

        local orig_Cyst_GetIsActuallyConnected = Cyst.GetIsActuallyConnected

        function Cyst:GetIsActuallyConnected()
            if GetIsImaginatorAlienEnabled() then
                return true
            end
              return orig_Cyst_GetIsActuallyConnected(self)
        end
        
        
    local orig_Cyst_TryToFindABetterParent = Cyst.TryToFindABetterParent
    function Cyst:TryToFindABetterParent()
             --print("TryToFindABetterParent ????")
            if GetIsImaginatorAlienEnabled() and GetHasOneBuiltHive() then
                local randomhive = GetRandomHive()
                --print("randomhive is ", randomhive)//if randomhive ~= nil....
                return self:ChangeParent(randomhive)
            end
            return orig_Cyst_TryToFindABetterParent(self)
    end    
        
 function Cyst:GetCanAutoBuild()
    return GetIsImaginatorAlienEnabled()
end
       
 end //server