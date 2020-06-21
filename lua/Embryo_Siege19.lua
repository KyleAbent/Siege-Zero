local origInit = Embryo.OnInitialized
function Embryo:OnInitialzed()
    origInit(self)
    if Server then
        if GetIsImaginatorAlienEnabled() then
            CreateEntity(NutrientMist.kMapName, self:GetModelOrigin(), 2 )
         end
    end

end