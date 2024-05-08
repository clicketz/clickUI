local function OnEvent(self, event)
	-- Auto Sell Grey Items
	totalPrice = 0
	for myBags = 0, 4 do
		for bagSlots = 1, GetContainerNumSlots(myBags) do
			CurrentItemLink = GetContainerItemLink(myBags, bagSlots)
			if CurrentItemLink then
				_, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(CurrentItemLink)
				_, itemCount = GetContainerItemInfo(myBags, bagSlots)
				if itemRarity == 0 and itemSellPrice ~= 0 then
					totalPrice = totalPrice + (itemSellPrice * itemCount)
					UseContainerItem(myBags, bagSlots)
					PickupMerchantItem()
				end
			end
		end
	end
	if totalPrice ~= 0 then
		DEFAULT_CHAT_FRAME:AddMessage("Items were sold for " .. GetCoinTextureString(totalPrice), 255, 255, 255)
	end
	--[[
	-- Auto Repair
	if (CanMerchantRepair()) then
		repairAllCost, canRepair = GetRepairAllCost()
		-- If merchant can repair and there is something to repair
		if (canRepair and repairAllCost > 0) then
			-- Use Guild Bank
			guildRepairedItems = false
			if (IsInGuild() and CanGuildBankRepair()) then
				-- Checks if guild has enough money
				local amount = GetGuildBankWithdrawMoney()
				local guildBankMoney = GetGuildBankMoney()
				amount = amount == -1 and guildBankMoney or min(amount, guildBankMoney)

				if (repairAllCost <= amount) then
					guildRepairedItems = true
					RepairAllItems(1)
					DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired by your Guild for "..GetCoinTextureString(repairAllCost), 255, 255, 255)
					-- return
				end
			end

			-- Use own funds if guild fails
			if (repairAllCost <= GetMoney() and (not guildRepairedItems)) then
				RepairAllItems(0)
				DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired for "..GetCoinTextureString(repairAllCost), 255, 255, 255)
			end
		end
	end
]]
	if (CanMerchantRepair()) then
		repairAllCost, canRepair = GetRepairAllCost()
		-- If merchant can repair and there is something to repair
		if (canRepair and repairAllCost > 0) then
			--Guild funds first
			RepairAllItems(true)
			RepairAllItems(false)
			DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired for " .. GetCoinTextureString(repairAllCost), 255, 255, 255)
		end
	end
end


local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("MERCHANT_SHOW")
