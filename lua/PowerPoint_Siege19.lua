//Kyle 'Avoca' Abent

//These should reference Functions19.lua rather than powerpoint but w/e

local networkVars = { 

discoEnabled = "boolean",
}

    function PowerPoint:ToggleDisco()
        print("Toggling Disco")
        self.discoEnabled = not self.discoEnabled
        
    end
  
    function PowerPoint:EnableDisco()
        print("Enabling Disco")
        self.discoEnabled = true
        
    end
  
    function PowerPoint:GetIsDisco()
       
        if self.discoEnabled then
            // print("PP GetIsDisco is true")
             return true
         end
         
         //print("PP GetIsDisco is false")
        return false 
 
    end
    local origInit = PowerPoint.OnInitialized
    function PowerPoint:OnInitialized()
    origInit(self)
       self.discoEnabled = false
    if Server then 
        self.SpawnTableOne = {}
        self:GenerateTables()
        self.hasBeenToggledDuringSetup = false //OnReset???
        
        
        //Moving these from imaginator to be per room basis
       self.activeArmorys = 0
       self.activeRobos = 0
       self.activeBatteries = 0
       self.activeObs = 0
       self.activePGs = 0
       self.activeProtos = 0
    end
   end
    
    if Server then 
    
    
    function PowerPoint:ToggleCountMapName(mapname, count)//although onpoweron may never register...?
        if not GetGameStarted() then return end
        Print("ToggleCountMapName mapname %s, count %s", mapname, count)
        if string.find(mapname, "armor") then
            self.activeArmorys = self.activeArmorys + (count)
        elseif string.find(mapname, "observ") then
             self.activeObs = self.activeObs + (count)
        elseif string.find(mapname, "robo") then
             self.activeRobos = self.activeRobos + (count)
        elseif string.find(mapname, "batter") then
             self.activeBatteries = self.activeBatteries + (count)
        elseif string.find(mapname, "phase") then
             self.activePGs = self.activePGs + (count)
        elseif string.find(mapname, "prot") then
             self.activeProtos = self.activeProtos + (count)
        end
    end

    //So every point will have three tables pre-configured/saved which will lessen dynamic calculations in game heh.


    function PowerPoint:GenerateTables()
            local maxAttempts = 300 
            local maxSizePer = 75
            for i = 0, maxAttempts do 
                   table.insert(self.SpawnTableOne, FindFreeSpace( self:GetOrigin() ,4,70) ) // The room could be big. is 20 large enough? then attempts/size may be toggled
                   currentIndexLocation = nil//temp
               
                if #self.SpawnTableOne == maxSizePer then
                    break
                end
                
            end 
    end

    function PowerPoint:GetRandomSpawnPoint()
            return table.random(self.SpawnTableOne)
    end
    
    function PowerPoint:GetHasBeenToggledDuringSetup()
        return self.hasBeenToggledDuringSetup
    end
    
    local origKill = PowerPoint.OnKill
    
    
     function PowerPoint:OnKill(attacker, doer, point, direction) //Initial hive 
        origKill(self, attacker, doer, point, direction)
        local isSetup = not GetSetupConcluded()
        if isSetup or GetIsOriginInHiveRoom(self:GetOrigin()) then // Well if darksiege2016b tall room (marine sided room in setup with a tech point in it..) .. lol ... ahh
            self.hasBeenToggledDuringSetup = true
        end
     end
     
    local function GetMarineSpawnList(self) // Count should be based on size of location(s).
        local tospawn = {}
             -----------------------------------------------------------------------------------------------
        if self.activePGs < 1 and TresCheck(1, kPhaseGateCost) then
            table.insert(tospawn, kTechId.PhaseGate)
        end
        -------------------------------------------------------------------------------------------
        if self.activeArmorys < 4 and TresCheck(1, kArmoryCost) then 
            table.insert(tospawn, kTechId.Armory)
        end
        ---------------------------------------------------------------------------------------------
        if self.activeRobos < 1 and TresCheck(1, kRoboticsFactoryCost) then
            table.insert(tospawn, kTechId.RoboticsFactory)
        end
        ------------------------------------------------------------------------------------------------
        if self.activeObs < 3 and TresCheck(1, kPhaseGateCost) then
            table.insert(tospawn, kTechId.Observatory)
        end
        -----------------------------------------------------------------------------------------------
        if GetHasAdvancedArmory()  then
            if self.activeProtos < 2 and TresCheck(1, kPrototypeLabCost) then
                table.insert(tospawn, kTechId.PrototypeLab)
            end
        end
        -------------------------------------------------------------------------------------------------

        if self.activeBatteries < 1 and TresCheck(1, kSentryBatteryCost) then //or count of locations with built power up lol
          table.insert(tospawn, kTechId.SentryBattery)
        end
        ----------------------------------------------------------------------------------------------------
        return table.random(tospawn) //if empty..
    end


    function PowerPoint:GetRandomSpawnEntity()
        /// self name has X number of X entity
        local location = GetLocationForPoint(self:GetOrigin())
        //Print("%s has %s Observatory", ToString(location.name),  ToString(self.activeObs))
        //Print("%s has %s Armory", ToString(location.name),  ToString(self.activeArmorys))
        //Print("%s has %s Robo", ToString(location.name),  ToString(self.activeRobos))
        //Print("%s has %s PG", ToString(location.name),  ToString(self.activePGs))
       // Print("%s has %s Proto", ToString(location.name),  ToString(self.activeProtos))
        //Print("%s has %s Battery", ToString(location.name),  ToString(self.activeBatteries))
        return GetMarineSpawnList(self)
    end

end

Shared.LinkClassToMap("PowerPoint", PowerPoint.kMapName, networkVars)