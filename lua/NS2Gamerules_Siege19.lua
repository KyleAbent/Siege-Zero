function NS2Gamerules:DisplayFront()

end

function NS2Gamerules:DisplaySiege()

end

/*
--this is why the mod is ns2_  and ns1_ because we rely on the gamerules provided
local origupdate = NS2Gamerules.OnUpdate
function NS2Gamerules:OnUpdate(deltatime)
       origupdate(self,deltatime)
      local timer = GetTimer()
	  if timer ~= nil then
	     timer:gamerulesUpdate(deltatime)
	  end  
end
*/