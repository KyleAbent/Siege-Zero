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