

function TunnelEntrance:GetInfestationRadius()
  local frontdoor = GetEntitiesWithinRange("FrontDoor", self:GetOrigin(), 7)
   if #frontdoor >=1 then return 0
   else
    return 7
   end
end

function TunnelEntrance:GetInfestationMaxRadius()
  local frontdoor = GetEntitiesWithinRange("FrontDoor", self:GetOrigin(), 7)
   if #frontdoor >=1 then return 0
   else
    return 7
   end
end

if Server then


    local orig_TunnelEntrance_OnConstructionComplete = TunnelEntrance.OnConstructionComplete
     function TunnelEntrance:OnConstructionComplete()
         orig_TunnelEntrance_OnConstructionComplete(self)
         
         if not GetIsOriginInHiveRoom(self:GetOrigin()) then
            GetImaginator().activeTunnels = GetImaginator().activeTunnels + 1
         end
         
         //Print("Self tech id is %s", ToString(self:GetTechId()) )
         
            if GetIsImaginatorAlienEnabled() then 
                   //local name = LookupTechData(self:GetTechId(), kTechDataDisplayName)
                  // local isEntrance = string.find(name, "ENTRANCE")
                   //local isExit = string.find(name, "EXIT" )
                   //print("isExit?? %s", ToString(isExit) )
                   //print("isEntrance?? %s", ToString(isEntrance) )
                   
             
                local match = nil
                local start = false
                    
                for _, tunnel in ientitylist(Shared.GetEntitiesWithClassname("TunnelEntrance")) do
                   //local name = LookupTechData(self:GetTechId(), kTechDataDisplayName)
                   //local currentIsEntrance = string.find(name, "ENTRANCE")
                   //local currentIsExit = string.find(name, "EXIT")
                    //print("currentIsExit?? %s", ToString(currentIsExit) )
                   //print("currentIsEntrance?? %s", ToString(currentIsEntrance) )
                   
                  // if (isEntrance and currentIsExit) or (isExit and currentIsEntrance) and not tunnel:GetIsConnected() then 
                  //if tunnel ~= self and tunnel:GetIsBuilt() and (isEntrance and currentIsEntrance) and not tunnel:GetIsConnected() 
                   //and not ( GetLocationForPoint(self:GetOrigin()) == GetLocationForPoint(tunnel:GetOrigin()) )  then 
                   if tunnel ~= self and tunnel:GetIsBuilt() and not tunnel:GetIsConnected() and not ( GetLocationForPoint(self:GetOrigin()) == GetLocationForPoint(tunnel:GetOrigin()) )  then 
                       match = tunnel
                       start = true
                       //print("Found match")
                       break
                    end
                end
            
              if start then
                    //print("Connecting!")
                    local tunnel = match:GetTunnelEntity()
                        self:SetOtherEntrance(match)
                        match:SetOtherEntrance(self)
                        if not tunnel then
                         -- Create a new tunnel since neither of the two entrances had one.
                         tunnel = CreateEntity(Tunnel.kMapName, nil, self:GetTeamNumber())
                         match:SetTunnel(tunnel)
                         end
                        self:SetTunnel(tunnel)
              end
          end
    end

     function TunnelEntrance:PreOnKill(attacker, doer, point, direction)
          
          if not GetIsOriginInHiveRoom(self:GetOrigin()) then
            GetImaginator().activeTunnels  = GetImaginator().activeTunnels - 1;  
          end
    end

end