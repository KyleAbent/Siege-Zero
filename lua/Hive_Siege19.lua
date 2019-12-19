/*
breaks cysts
if Server then

local orig = Hive.OnInitialized
function Hive:OnInitialized()
orig(self)
    local origin = self:GetOrigin()
    local nearest = GetNearest(self:GetOrigin(), "TechPoint" ) //nearest should be alien tech not marine :P
    //  Print("Eh? 1")
    if nearest then
  //  Print("Eh? 2")
        origin = origin + Vector(0,nearest.height,0)
        self:SetOrigin(origin)
    end
    
end
end

*/

if Server then

-- overwrite get rid of scale with player count

function Hive:UpdateSpawnEgg()

    local success = false
    local egg

    local eggCount = self:GetNumEggs()
    if eggCount < kAlienEggsPerHive then

        egg = self:SpawnEgg()
        success = egg ~= nil

    end

    return success, egg

end

function Hive:HatchEggs() --overwrite get rid of scaleplayer
    local amountEggsForHatch = kEggsPerHatch
    local eggCount = 0
    for i = 1, amountEggsForHatch do
        local egg = self:SpawnEgg(true)
        if egg then eggCount = eggCount + 1 end
    end

    if eggCount > 0 then
        self:TriggerEffects("hatch")
        return true
    end

    return false
end

function Hive:GetNumEggs() --Well all 3 hives in same location, and if each hive is suppose to have X eggs then assign them the hive id via egg

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())

    for index, egg in ipairs(eggs) do

        if self == egg:GetHive() and egg:GetIsAlive() and egg:GetIsFree() and not egg.manuallySpawned then
            numEggs = numEggs + 1
        end

    end

    return numEggs

end


end --server


//What happens if constructed with commander in hive then commander leaves and doesnt upgrade biomass?
//Then biomass here is skipped. Ugh. AHH. Maybe on research complete.

local orig_Hive_OnConstructionComplete = Hive.OnConstructionComplete
function Hive:OnConstructionComplete()
    orig_Hive_OnConstructionComplete(self)
    local imaginator = GetImaginator()
    if imaginator:GetIsAlienEnabled() then
        self.bioMassLevel = 3
        UpdateTypeOfHive(self)
    end
end


local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete()
    orig_Hive_OnResearchComplete(self)
    if self.bioMassLevel == 3 then return end
    local imaginator = GetImaginator()
    if imaginator:GetIsAlienEnabled() then
        self.bioMassLevel = 3
        UpdateTypeOfHive(self)
    end
end
