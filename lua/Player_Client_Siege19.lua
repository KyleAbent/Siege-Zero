//Display AutoComm
local origName = PlayerUI_GetCommanderName
function PlayerUI_GetCommanderName()

    local player = origName(self)
    if not player then
        return "AutoComm"
    else
        return commanderName
    end


end

