//Script.Load("lua/PointGiverMixin.lua")  //if in siege then no bile?

local origcreate = Contamination.OnCreate
function Contamination:OnCreate()
    origcreate(self)
    InitMixin(self, PointGiverMixin)
end

/*
local orig = Contamination.OnInitialized
function Contamination:OnInitialized()

orig(self)

if not GetSetupConcluded() then DestroyEntity(self) end

end
*/
local function TimeUp(self)
    self:Kill()
    return false
end
function Contamination:OnInitialized()  --if siege then spawn bilebomb?

    ScriptActor.OnInitialized(self)

    InitMixin(self, InfestationMixin)
    
    self:SetModel(Contamination.kModelName, kAnimationGraph)

    local coords = Angles(0, math.random() * 2 * math.pi, 0):GetCoords()
    coords.origin = self:GetOrigin()
    
    if Server then
            -- if not Shared.GetCheatsEnabled() then
               if not GetSetupConcluded() then 
               DestroyEntity(self)
               end
          -- end
        InitMixin( self, StaticTargetMixin )
        self:SetCoords( coords )
        
        self:AddTimedCallback( TimeUp, kContaminationLifeSpan )
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
       
        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end


function Contamination:GetPointValue()
    return 3
end