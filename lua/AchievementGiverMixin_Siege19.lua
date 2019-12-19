-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AchievementGiverMixin.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- This mixin assigns event based achievements to the players
AchievementGiverMixin = CreateMixin(AchievementGiverMixin)
AchievementGiverMixin.type = "AchievementGiver"

function AchievementGiverMixin:__initmixin()

end

if Server then

	function AchievementGiverMixin:PreUpdateMove(input, runningPrediction)

	end

	function AchievementGiverMixin:OnTaunt()

	end

	function AchievementGiverMixin:OnAddHealth()

	end

	function AchievementGiverMixin:OnCommanderStructureLogout(hive)
	
	end

	function AchievementGiverMixin:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)

	end

	function AchievementGiverMixin:SetParasited(fromPlayer)

	end

	function AchievementGiverMixin:OnWeldTarget(target)

	end

	function AchievementGiverMixin:OnConstruct(builder, newFraction, oldFraction)

	end

	function AchievementGiverMixin:OnConstructionComplete(builder)

	end

	function AchievementGiverMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)

	end

	function AchievementGiverMixin:PreOnKill(attacker, doer, point, direction)
       
	end
end