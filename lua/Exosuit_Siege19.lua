local origInit = Exosuit.OnInitialized 

function Exosuit:OnInitialized()
    origInit(self)
    if self.layout ~= "MinigunMinigun" and self.layout ~= "RailgunRailgun" then
        self.layout = "MinigunMinigun"
    end
end


