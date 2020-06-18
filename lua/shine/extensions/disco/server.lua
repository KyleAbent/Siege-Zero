--Kyle 'Avoca' Abent
Plugin.Version = "1.0"
------------------------------------------------------------
Plugin.HasConfig = true
Plugin.ConfigName = "Disco.json"

Plugin.DefaultConfig = {
discoEnabled = true
}

Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()

return true
end


function Plugin:PerformDisco()
local powerpoints = {}
      for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        powerpoint:ToggleDisco()
    end
end
    
function Plugin:EnableDisco()
local powerpoints = {}
      for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        powerpoint:EnableDisco()
    end
end
    
function Plugin:CreateCommands()

local function Disco( Client )
     local Player = Client:GetControllingPlayer()
     self:PerformDisco()
end
local DiscoCommand = self:BindCommand( "sh_disco", "disco", Disco, true)
--DiscoCommand:Help( "" )


---------------------------------------------------------------
end//CreateCommands


function Plugin:SetGameState( Gamerules, State, OldState )
     if State == kGameState.Started and self.Config.discoEnabled then 
        self:EnableDisco()
     end 
end

