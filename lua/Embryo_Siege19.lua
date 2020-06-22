local origInit = Embryo.SetGestationData
function Embryo:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)
    origInit(self,techIds, previousTechId, healthScalar, armorScalar)
    if Server then
        if GetIsImaginatorAlienEnabled() then
            CreateEntity(NutrientMist.kMapName, self:GetModelOrigin(), 2 )
         end
    end

end