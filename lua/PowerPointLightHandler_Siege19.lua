local function SetLight(renderLight, intensity, color)
    
    PROFILE("PowerPointLightHandler:SetLight")
    
    if intensity then
        renderLight:SetIntensity(intensity)
    end

    if color then

        renderLight:SetColor(color)

        if renderLight:GetType() == RenderLight.Type_AmbientVolume then

            renderLight:SetDirectionalColor(RenderLight.Direction_Right,    color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Left,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Up,       color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Down,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Backward, color)

        end

    end

end

//Only change lights if toggled on with powerpoint else do normal functionality

local origWorker = NormalLightWorker.Run
function NormalLightWorker:Run()

    PROFILE("NormalLightWorker:Run")

    if  self.handler.powerPoint:GetIsDisco() then
        local time = Shared.GetTime()

        if not self.lastTime then
            self.lastTime = Shared.GetTime()
        end
         local timePassed = time - self.lastTime
        
         if timePassed > math.random(4,16) then
         
         //Orig worker clears active lights. 
         self.activeLights:Clear()
         
            for _, light in ipairs(self.handler.lightTable) do
                self.activeLights:Insert(light) //We need this here because origworker deletes them all
            end
            
            for renderLight in self.activeLights:IterateBackwards() do
            // for _, renderLight in ipairs(GetLightsForLocation(self.handler.powerPoint:GetLocationName())) if I dont want to deal with active lights
                SetLight(renderLight, intensity, Color( math.random(0.1, 1) , math.random(0.1, 1) , math.random(0.1, 1)) )
            end
            self.lastTime = Shared.GetTime()
         end
     else
        origWorker(self)
     end
end