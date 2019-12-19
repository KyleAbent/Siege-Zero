-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AchievementReceiverMixin.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- This mixin assigns stats based achievements to the players

AchievementReceiverMixin = CreateMixin(AchievementReceiverMixin)
AchievementReceiverMixin.type = "AchievementReceiver"

function AchievementReceiverMixin:__initmixin()
    
end

if Server then
	
	local function RewardAchievement(player, name)

	end
	
	function AchievementReceiverMixin:CheckWeldedPowerNodes()

	end

	function AchievementReceiverMixin:CheckWeldedPlayers()

	end

	function AchievementReceiverMixin:CheckBuildResTowers()

	end

	function AchievementReceiverMixin:CheckKilledResTowers()

	end

	function AchievementReceiverMixin:CheckDefendedResTowers()

	end

	function AchievementReceiverMixin:CheckFollowedOrders()

	end

	function AchievementReceiverMixin:CheckParasitedPlayers()

	end

	function AchievementReceiverMixin:CheckStructureDamageDealt()

	end

	function AchievementReceiverMixin:CheckPlayerDamageDealt()

	end

	function AchievementReceiverMixin:CheckDestroyedRessources()

	end

	function AchievementReceiverMixin:OnPhaseGateEntry()
	
	end

	function AchievementReceiverMixin:OnUseGorgeTunnel()
	
	end

	function AchievementReceiverMixin:AddWeldedPowerNodes()

	end

	function AchievementReceiverMixin:AddWeldedPlayers()

	end

	function AchievementReceiverMixin:AddBuildResTowers()

	end

	function AchievementReceiverMixin:AddKilledResTowers()

	end

	function AchievementReceiverMixin:AddDefendedResTowers()

	end

	function AchievementReceiverMixin:AddParsitedPlayers()

	end

	function AchievementReceiverMixin:AddStructureDamageDealt(amount)

	end

	function AchievementReceiverMixin:AddPlayerDamageDealt(amount)

	end

	function AchievementReceiverMixin:AddDestroyedRessources(amount)

	end

	function AchievementReceiverMixin:CompletedCurrentOrder()

	end

	function AchievementReceiverMixin:ResetScores()

	end

	function AchievementReceiverMixin:CopyPlayerDataFrom(player)

	end

end

if Client then



	function AchievementReceiverMixin:GetMaxPlayer()

	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)


	end

end