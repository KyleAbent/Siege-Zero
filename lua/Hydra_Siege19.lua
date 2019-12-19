/*

local originit = Hydra.OnInitialized
function Hydra:OnInitialized()

originit(self)
     --Brilliant formula here. I'd like to copyright it. Well, as for modders. :P i'll capitalize on it. winning formula here!
     --Then again, who knows the perf onspawn adjusting networkvar. 
       -- if global then why call all the time and not when necessary? ill figure it out for later
   -- if Marine.kWalkMaxSpeed == 5 then

    Hydra.kDamage = ConditionalValue( GetHasTech(self, kTechId.HydraBuff1), Hydra.kDamage * 1.05, Hydra.kDamage)  
  --  end
    --Better if no respawn required such as alien
  --Print("%s %s %s", Marine.kWalkMaxSpeed, Marine.kRunMaxSpeed, Marine.kRunInfestationMaxSpeed)

end


function Hydra:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end

*/


