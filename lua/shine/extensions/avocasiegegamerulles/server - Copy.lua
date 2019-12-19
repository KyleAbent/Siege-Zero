--Kyle 'Avoca' Abent
Script.Load("lua/doors/timer.lua") -- to load timer hook opensiege onopensiege otherwise wont hook
//Script.Load("lua/Additions/Imaginator.lua")
local Shine = Shine
local Plugin = Plugin


local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

local function NewUpdateBatteryState( self )
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 1) then
        
           local location = GetLocationForPoint(self:GetOrigin())
           local powerpoint = location ~= nil and GetPowerPointForLocation(location:GetName())   
            self.attachedToBattery = false
           if powerpoint then 
            self.attachedToBattery = (powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled()) or GetHasSentryBatteryInRadius(self)
            end
            self.lastBatteryCheckTime = time
        end
end

OldUpdateBatteryState = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateBatteryState", NewUpdateBatteryState )


local function NewGetDestinationGate(self)

    // Find next phase gate to teleport to
    local phaseGates = {}    
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) and phaseGate.channel == self.channel then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    if table.count(phaseGates) < 2 then
        return nil
    end
    
    // Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
    
        local nextIndex = ConditionalValue(index == table.count(phaseGates), 1, index + 1)
        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.count(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil
    
end

OldGetDestinationGate = Shine.Hook.ReplaceLocalFunction( PhaseGate.Update, "GetDestinationGate", NewGetDestinationGate )


Shine.Hook.SetupClassHook( "Alien", "TriggerRedeemCountDown", "OnRedemedHook", "PassivePre" )
Shine.Hook.SetupClassHook( "Alien", "TriggerRebirthCountDown", "TriggerRebirthCountDown", "PassivePre" )

  function Plugin:OnRedemedHook(player) 
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Redemption Cooldown: %s",Duration = derp:GetRedemptionCoolDown() or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
 end

 function Plugin:TriggerRebirthCountDown(player)
            local herp = player:GetClient()
            local derp = herp:GetControllingPlayer()
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Rebirth Cooldown: %s",Duration = ( derp:GetRedemptionCoolDown() * 1.3 ) or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
end


local OldUpdGestation

local function NewHpdateGestation(self)
    // Cannot spawn unless alive.
    if self:GetIsAlive() and self.gestationClass ~= nil then
    
        if not self.gestateEffectsTriggered then
        
            self:TriggerEffects("player_start_gestate")
            self.gestateEffectsTriggered = true
            
        end
        
        // Take into account catalyst effects
        local kUpdateGestationTime = 0.1
        local amount = GetAlienCatalystTimeAmount(kUpdateGestationTime, self)
        self.evolveTime = self.evolveTime + kUpdateGestationTime + amount
        
        self.evolvePercentage = Clamp((self.evolveTime / self.gestationTime) * 100, 0, 100)
        
        if self.evolveTime >= self.gestationTime then
        
            // Replace player with new player
            local newPlayer = self:Replace(self.gestationClass)
            newPlayer:SetCameraDistance(0)

            local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
            local newAlienExtents = LookupTechData(newPlayer:GetTechId(), kTechDataMaxExtents)

            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            --validate the spawn point before using it
            if self.validSpawnPoint and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self.validSpawnPoint + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, newPlayer)) then
                newPlayer:SetOrigin(self.validSpawnPoint)
            else
                for index = 1, 100 do

                    local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

                    if spawnPoint then

                        newPlayer:SetOrigin(spawnPoint)
                        break

                    end

                end

            end

            newPlayer:DropToFloor()
            
            self:TriggerEffects("player_end_gestate")
            
            // Now give new player all the upgrades they purchased
            local upgradesGiven = 0
            
            for index, upgradeId in ipairs(self.evolvingUpgrades) do

                if newPlayer:GiveUpgrade(upgradeId) then
                    upgradesGiven = upgradesGiven + 1
                end
                
            end
            
            local healthScalar = self.storedHealthScalar or 1
            local armorScalar = self.storedArmorScalar or 1

            newPlayer:SetHealth(healthScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth))
            newPlayer:SetArmor(armorScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxArmor))
           if  newPlayer.OnGestationComplete then newPlayer:OnGestationComplete() end
            newPlayer:SetHatched()
            newPlayer:TriggerEffects("egg_death")
           
            
           if  GetHasRebirthUpgrade(newPlayer) then
               if self.triggeredrebirth then
                  newPlayer:SetHealth(newPlayer:GetHealth() * 0.7)
                  newPlayer:SetArmor(newPlayer:GetArmor() * 0.7)
               end
          newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
           end
          


        if GetHasRedemptionUpgrade(newPlayer) then
          newPlayer:TriggerRedeemCountDown(newPlayer:GetClient():GetControllingPlayer())
          newPlayer.lastredeemorrebirthtime = Shared.GetTime()
         end
            
            if self.resOnGestationComplete then
                newPlayer:AddResources(self.resOnGestationComplete)
            end
            
            local newUpgrades = newPlayer:GetUpgrades()
            if #newUpgrades > 0 then            
                newPlayer.lastUpgradeList = newPlayer:GetUpgrades()
            end

            // Notify team

            local team = self:GetTeam()

            if team and team.OnEvolved then

                team:OnEvolved(newPlayer:GetTechId())

                for _, upgradeId in ipairs(self.evolvingUpgrades) do

                    if team.OnEvolved then
                        team:OnEvolved(upgradeId)
                    end
                    
                end

            end
            
            -- Return false so that we don't get called again if the server time step
            -- was larger than the callback interval
            return false
            
        end
        
    end
    
    return true

end

OldUpdGestation = Shine.Hook.ReplaceLocalFunction( Embryo.OnInitialized, "UpdateGestation", NewHpdateGestation )


Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end


function Plugin:MapPostLoad()
      Server.CreateEntity(Timer.kMapName)

end



  function Plugin:OnSiege() 
    Shared.ConsoleCommand("sh_csay Siege Door(s) now open!!!!") 
    self:NotifyTimer( nil, "Siege Door(s) now open!!!!", true)
  end
  
   function Plugin:OnFront() 
    Shared.ConsoleCommand("sh_csay Front Door(s) now open!!!!") 
    self:NotifyTimer( nil, "Front Door(s) now open!!!!", true)
  end
  
Shine.Hook.SetupClassHook( "NS2Gamerules", "DisplayFront", "OnFront", "PassivePost" ) --NS2GameRules b.c im assuming timer isnt created
  
Shine.Hook.SetupClassHook( "NS2Gamerules", "DisplaySiege", "OnSiege", "PassivePost" )  --Timmer calling gamerules for this hook -.-

local function AddFrontTimer(who,NowToFront)
      if not NowToFront then 
     NowToFront = GetTimer():GetFrontLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
	 end
    Shine.ScreenText.Add( 1, {X = 0.02, Y = 0.40,Text = "Front: %s",Duration = NowToFront,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, who )
end

local function AddSiegeTimer(who, NowToSiege)
    if not NowToSiege then 
     NowToSiege = GetTimer():GetSiegeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
	 end
    Shine.ScreenText.Add( 2, {X = 0.02, Y = 0.45,Text = "Siege: %s",Duration = NowToSiege,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, who )
end


local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
			  local NowToFront = GetTimer():GetFrontLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
			  local NowToSiege = GetTimer():GetSiegeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
                  AddFrontTimer(nil, NowToFront)
                  AddSiegeTimer(nil, NowToSiege) 
end


//Add timer on join if game started
function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
      
   if GetGamerules():GetGameStarted() then

      if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < GetTimer():GetFrontLength() then
       AddFrontTimer(Client)
      end
   
      if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < GetTimer():GetSiegeLength() then
         AddSiegeTimer(Client)
      end

   end

end
local function OpenAllBreakableDoors()
 for _, door in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do 
           door.open = true
       door.timeOfDestruction = Shared.GetTime() 
       door:SetHealth(door:GetHealth() - 10)
 end
end
function Plugin:SetGameState( Gamerules, State, OldState )

 if State == kGameState.Started then 
    GiveTimersToAll()
   --  if string.find(Shared.GetMapName(), "pl_") then GivePayloadInfoToAll(self) end
     OpenAllBreakableDoors()
  else
      Shine.ScreenText.End(1) 
      Shine.ScreenText.End(2)
      Shine.ScreenText.End(3)
	end
     if State ==  kGameState.Team1Won  or State ==  kGameState.Team2Won   then
           elseif State == kGameState.Countdown then
              GetTimer():OnRoundStart()
           elseif State == kGameState.NotStarted then
              GetTimer():OnPreGame()
          end
          
    
end


function Plugin:NotifyTimer( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Timer]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGiveRes( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[GiveRes]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyAutoComm( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[AutoComm]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyMods( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Moderator Chat]",  255, 0, 0, String, Format, ... )
end
function Plugin:GiveCyst(Player)
            local ent = CreateEntity(CystSiege.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  
             ent:SetConstructionComplete()
end



function Plugin:CreateCommands()




local function Pres( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            Player:SetResources(Number)
           	 Shine:CommandNotify( Client, "set %s's resources to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local PresCommand = self:BindCommand( "sh_pres", "pres", Pres)
PresCommand:AddParam{ Type = "clients" }
PresCommand:AddParam{ Type = "number" }
PresCommand:Help( "sh_pres <player> <number> sets player's pres to the number desired." )


local function  AddScore( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if HasMixin(Player, "Scoring") then
            Player:AddScore(Number, 0, false)
           	 Shine:CommandNotify( Client, "%s's score increased by %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local AddScoreCommand = self:BindCommand( "sh_addscore", "addscore", AddScore)
AddScoreCommand:AddParam{ Type = "clients" }
AddScoreCommand:AddParam{ Type = "number" }
AddScoreCommand:Help( "sh_addscore <player> <number> adds number to players score" )





local function RandomRR( Client )
        local rrPlayers = GetGamerules():GetTeam(kTeamReadyRoom):GetPlayers()
        for p = #rrPlayers, 1, -1 do
            JoinRandomTeam(rrPlayers[p])
        end
           Shine:CommandNotify( Client, "randomized the readyroom", true)  
end
local RandomRRCommand = self:BindCommand( "sh_randomrr", "randomrr", RandomRR )
RandomRRCommand:Help( "randomize's the ready room.") 


local function Stalemate( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
Gamerules:DrawGame()
end 


local StalemateCommand = self:BindCommand( "sh_stalemate", "stalemate", Stalemate )
StalemateCommand:Help( "declares the round a draw." )




local function Slap( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()


  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           self:NotifyGeneric( nil, "slapping %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 13, 1, Number, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(13) then self:DestroyTimer( 13 ) return end
            Player:SetVelocity(  Player:GetVelocity() + Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900)  ) )
            end )
end
end
end
local SlapCommand = self:BindCommand( "sh_slap", "slap", Slap)
SlapCommand:Help ("sh_slap <player> <time> Slaps the player once per second random strength")
SlapCommand:AddParam{ Type = "clients" }
SlapCommand:AddParam{ Type = "number" }


local function Respawn( Client, Targets )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Shine:CommandNotify( Client, "respawned %s.", true,
				Player:GetName() or "<unknown>" )  
         Player:GetTeam():ReplaceRespawnPlayer(Player)
                 Player:SetCameraDistance(0)
     end--
end--
local RespawnCommand = self:BindCommand( "sh_respawn", "respawn", Respawn )
RespawnCommand:AddParam{ Type = "clients" }
RespawnCommand:Help( "<player> respawns said player" )

local function Destroy( Client, String  ) 
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  self:NotifyGeneric( nil, "destroyed %s in %s", true, entity:GetMapName(), entity:GetLocationName())
                  DestroyEntity(entity)
				  break
             end
         end
end

local DestroyCommand = self:BindCommand( "sh_destroy", "destroy", Destroy )
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:Help( "Destroy <string> Destroys entity with this name within 8 radius" )

local function Disco( Client )
     if Shine:GetUserImmunity(Client) >= 50 then 
     local Player = Client:GetControllingPlayer()
     GetTimer():PerformDisco()
     self:NotifyGeneric( Client, "Disco has no off switch bay bay", true)  
     end 
end

local DiscoCommand = self:BindCommand( "sh_disco", "disco", Disco, true)
--DiscoCommand:Help( "" )

local function Gbd( Client )
local Player = Client:GetControllingPlayer()
 Player:GiveLayStructure(kTechId.Door, BreakableDoor.kMapName)
end
local GbdCommand = self:BindCommand( "sh_gbd", "gbd", Gbd )
GbdCommand:Help( "gives self laystructure breakabledoor placeable anywhere without limit - aboos" )

local function Give( Client, Targets, String, Number )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Player and Player:GetIsAlive() and String ~= "alien" and not (Player:isa("Alien") and String == "armory") and not (Player:isa"ReadyRoomTeam" and String == "CommandStation" or String == "Hive") and not Player:isa("Commander") then


           
 local teamnum = Number and Number or Player:GetTeamNumber()
 local ent = CreateEntity(String, Player:GetOrigin(), teamnum)  
if HasMixin(ent, "Construct") then  ent:SetConstructionComplete() end
             Shine:CommandNotify( Client, "gave %s an %s", true,
			 Player:GetName() or "<unknown>", String )  
end
end
end
local GiveCommand = self:BindCommand( "sh_give", "give", Give )
GiveCommand:AddParam{ Type = "clients" }
GiveCommand:AddParam{ Type = "string" }
GiveCommand:AddParam{ Type = "number", Optional = true }
GiveCommand:Help( "<player> Give item to player(s)" )




local function OpenFrontDoors()
           for index, timer in ientitylist(Shared.GetEntitiesWithClassname("Timer")) do
                timer:OpenFrontDoors() 
                end

end

local function OpenBreakableDoors()
           for index, breakabledoor in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do
               if breakabledoor.health ~= 0 then breakabledoor.health = 0 end 
                end

end

local function Open( Client, String )
local Gamerules = GetGamerules()
     if String == "Front" or String == "front" then
       OpenFrontDoors()
        Shine.ScreenText.End(1) 
     elseif String == "Siege" or String == "siege" then
       GetTimer():OpenSiegeDoors()
         Shine.ScreenText.End(2) 
        -- self:OnOpenSiegeDoors()
     elseif String == "Breakable" or String == "breakable" then
        OpenBreakableDoors()
    end  --
  self:NotifyGeneric( nil, "Opened the %s doors", true, String)  
  
end --

local OpenCommand = self:BindCommand( "sh_open", "open", Open )
OpenCommand:AddParam{ Type = "string" }
OpenCommand:Help( "Opens <type> doors (Front/Siege) (not case sensitive) - timer will still display." )

local function TestFilm( Client )
           for i = 1, 10 do
          Shared.ConsoleCommand("addbot")
         end
         Shared.ConsoleCommand("sh_randomrr")
            Shared.ConsoleCommand("sh_forceroundstart")
            Shared.ConsoleCommand("sh_imaginator 1 true")
          Shared.ConsoleCommand("sh_imaginator 2 true")

  
   self:NotifyGeneric( nil, "%s Test Film ", true)
  
end

local TestFilmCommand = self:BindCommand( "sh_testfilm", "testfilm", TestFilm )
TestFilmCommand:Help( "sh_testfilm adds bots forces round and enables imaginator  " )



local function BringAll( Client )
    self:NotifyGeneric( nil, "Brought everyone to one locaiton/area", true)
    
        local Players = Shine.GetAllPlayers() //change to player for bots lol
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and not Player:isa("Commander") and not Player:isa("Spectator") then
                       local where = FindFreeSpace(Client:GetControllingPlayer():GetOrigin())
                       Player:SetOrigin(where)
                  end
              end
end

local BringAllCommand = self:BindCommand( "sh_bringall", "bringall", BringAll )
BringAllCommand:Help( "sh_bringall - teleports everyone to the same spot" )





end