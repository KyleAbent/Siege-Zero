/*
--'Avoca' , KKyle etc
JetpackMarine.kJetpackFuelReplenishDelay = 1.2 
--JetpackMarine.kJetpackGravity = -11
--JetpackMarine.kJetpackTakeOffTime = .12
local kFlyAcceleration = 37
local kFlySpeed = 11
--@@OVerride

function JetpackMarine:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsJetpacking() then
        
        local verticalAccel = 33
        
        if self:GetIsWebbed() then
            verticalAccel = 5
        elseif input.move:GetLength() == 0 then
            verticalAccel = 33
        end
    
        self.onGround = false
        local thrust = math.max(0, -velocity.y) / 6
        velocity.y = math.min(5, velocity.y + verticalAccel * deltaTime * (1 + thrust * 2.5))
 
    end
    
    if not self.onGround then
    
        -- do XZ acceleration
        local prevXZSpeed = velocity:GetLengthXZ()
        local maxSpeedTable = { maxSpeed = math.max(kFlySpeed, prevXZSpeed) }
        self:ModifyMaxSpeed(maxSpeedTable)
        local maxSpeed = maxSpeedTable.maxSpeed        
        
        if not self:GetIsJetpacking() then
            maxSpeed = prevXZSpeed
        end
        
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        local acceleration = 0
        wishDir.y = 0
        wishDir:Normalize()
        
        acceleration = kFlyAcceleration
        
        velocity:Add(wishDir * acceleration * self:GetInventorySpeedScalar() * deltaTime)

        if velocity:GetLengthXZ() > maxSpeed then
        
            local yVel = velocity.y
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(maxSpeed)
            velocity.y = yVel
            
        end 
        
        if self:GetIsJetpacking() then
            velocity:Add(wishDir * kJetpackingAccel * deltaTime)
        end
    
    end

end
*/