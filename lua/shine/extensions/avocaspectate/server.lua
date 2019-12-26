--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin

Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end

function Plugin:CreateCommands()

local function Direct( Client, Targets )
          AutoSpectate(self)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
          Player:Replace(AvocaSpectator.kMapName, 3)
     end
end

local DirectCommand = self:BindCommand( "sh_direct", "direct", Direct)
DirectCommand:AddParam{ Type = "clients" }

end