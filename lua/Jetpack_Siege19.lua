local origInit = Jetpack.OnInitialized 

function Jetpack:OnInitialized()
    origInit(self)
    if Server then
        self:AddTimedCallback(self.Cleanup, 60)
    end
end

if Server then
    function Jetpack:Cleanup()
        //print("jp cleanup")
        ScriptActor.OnDestroy(self)
    end
end


