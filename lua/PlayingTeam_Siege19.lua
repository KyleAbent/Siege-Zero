//Override

function PlayingTeam:GetHasTeamLost()

    PROFILE("PlayingTeam:GetHasTeamLost")

    if GetGamerules():GetGameStarted() and not Shared.GetCheatsEnabled() then
    
        -- Team can't respawn or last Command Station or Hive destroyed
        local activePlayers = true //self:GetHasActivePlayers()
        local abilityToRespawn = self:GetHasAbilityToRespawn()
        local numAliveCommandStructures = self:GetNumAliveCommandStructures()
        
        if  (not activePlayers and not abilityToRespawn) or
            (numAliveCommandStructures == 0) or
            (self:GetNumPlayers() == 0) or 
            self:GetHasConceded() then
            
            return true
            
        end
        
    end
    
    return false
    
end