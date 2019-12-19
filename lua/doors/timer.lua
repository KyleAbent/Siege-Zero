-- Kyle 'Avoca' Abent
--http://twitch.tv/kyleabent
--https://github.com/KyleAbent/
class 'Timer' (ScriptActor)
Timer.kMapName = "timer"

if Server then
    Timer.kSiegeDoorSound = PrecacheAsset("sound/siegeroom.fev/door/siege")
    Timer.kFrontDoorSound = PrecacheAsset("sound/siegeroom.fev/door/frontdoor")
end

local networkVars = 
{
   SiegeTimer = "integer",
   FrontTimer = "integer",
   frontOpened = "boolean",
   siegeOpened = "boolean",
   siegeBeaconed = "boolean",
}

function Timer:TimerValues()
   self.SiegeTimer = kSiegeTime 
   self.FrontTimer = kFrontTime
   self.siegeOpened = false
   self.frontOpened = false
   self.siegeBeaconed = false
end

function Timer:OnReset() 
   self:TimerValues()
end

function Timer:GetIsMapEntity()
    return true
end

function Timer:GetHasSiegeBeaconed()
    return self.siegeBeaconed
end

function Timer:SetSiegeBeaconed(boolean)
 self.siegeBeaconed = boolean
end

function Timer:ClearAttached()
    return 
end

function Timer:OnCreate()
  self:TimerValues()
  self:SetUpdates(true)
end

local function DoubleCheckLocks(who)
   for index, door in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
     door:CloseLock()
  end 
end

function Timer:OnRoundStart() 
  self:TimerValues()
  DoubleCheckLocks(self)
  GetGamerules():SetDamageMultiplier(0)
end

function Timer:GetSiegeOpenBoolean()
 if not GetGameStarted() then
    return true
 else
    return self.siegeOpened
 end 
end
function Timer:GetFrontOpenBoolean()
 if not GetGameStarted() then
    return true
 else
    return self.frontOpened
 end
end
function Timer:GetFrontLength()
 return self.FrontTimer 
end

local function OpenEightTimes(who)
    if not who then return end
    for i = 1, math.max(9 / 2, 16) do
        who:Open()
        who.isvisible = false
    end
end

function Timer:OpenSiegeDoors()
     self.SiegeTimer = 0
     self.siegeOpened = true
       for index, siegedoor in ientitylist(Shared.GetEntitiesWithClassname("SiegeDoor")) do
            if not siegedoor:isa("FrontDoor") then 
            OpenEightTimes(siegedoor) 
            end
       end
      if GetGameStarted() then
         GetGamerules():DisplaySiege()
            for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            StartSoundEffectForPlayer(Timer.kSiegeDoorSound, player)
           end
      end   
end

local function CloseAllBreakableDoors()
  for _, door in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do 
           door.open = false
           door:SetHealth(door:GetHealth() + 10)
  end
end

function Timer:OpenFrontDoors()
         self.frontOpened = true
          GetGamerules():SetDamageMultiplier(1) 
           CloseAllBreakableDoors()
           self.FrontTimer = 0
               for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                      OpenEightTimes(frontdoor)
              end 
               if GetGameStarted() then 
                GetGamerules():DisplayFront()
              
                      for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                      StartSoundEffectForPlayer(Timer.kFrontDoorSound, player)
                      end
               end          
end

function Timer:GetIsSiegeOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= kSiegeTime
end

function Timer:GetIsFrontOpen()
           local gamestarttime = GetGameInfoEntity():GetStartTime()
           local gameLength = Shared.GetTime() - gamestarttime
           return  gameLength >= kFrontTime
end

if Server then
     function Timer:OnUpdate(deltatime)
          local gamestarted = GetGamerules():GetGameStarted()
          if gamestarted then 
               if not self.timelasttimerup or self.timelasttimerup + 1 <= Shared.GetTime() then
                    if not self.frontOpened then self:FrontDoorTimer() end
                    if not self.siegeOpened then self:SiegeDoorTimer() end   
                    self.timelasttimerup = Shared.GetTime()  
                end
          end
     end
end

function Timer:SiegeDoorTimer()
       if  self:GetIsSiegeOpen() then
           self:OpenSiegeDoors()
       end
end

function Timer:FrontDoorTimer()
    if self:GetIsFrontOpen() then
       self:OpenFrontDoors()
     end
end

function Timer:OnPreGame()
   for i = 1, 4 do
     Print("Timer OnPreGame")
   end
   
   for i = 1, 8 do
   self:OpenSiegeDoors()
   self:OpenFrontDoors()
   end
   
end

Shared.LinkClassToMap("Timer", Timer.kMapName, networkVars)