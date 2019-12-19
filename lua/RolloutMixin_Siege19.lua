--[Server] Script Error #1: lua/RolloutMixin.lua:44: Attempt to access an object that no longer exists (was type RoboticsFactory)

-- When the first order completes, we complete the rollout

/*
so basically a robotics factory died a split second after creating an arc, just after being recognized as the parent , and somehow between that short timespan the robotics died and could not be found
and spammed the log endnlessly
thats what im guessing happened
It seems rare but i cann try writing something to not error
*/

/*

function RolloutMixin:__initmixin()
  self.hasDonealready = false
end

function RolloutMixin:OnOrderComplete(order) --ok but what if another robo is closer than the spawning? do if robo is open? lol

 if not self.hasDonealready then
 
        self.hasDonealready = true
        local robo  = GetNearest(self:GetOrigin(), "RoboticsFactory", nil, function(ent) return self:GetDistance(ent) <= 6   end)
        if robo then
        robo:CompleteRollout(self)
        self.rolloutSourceFactory = nil
        end
   end
end

*/