local _, addon = ...
local DRAGONRIDING_TRAIT_SYSTEM_ID = 1

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_LOGIN")
eventHandler:SetScript("OnEvent", function(self, event, ...)
    addon[event](addon, ...)
end)

function addon:PLAYER_LOGIN()
    eventHandler:RegisterEvent('SPELLS_CHANGED')
    self.disabledByRefund = false
    hooksecurefunc(C_Traits, 'RefundRank', function(configID)
        if configID == self.configID then
            self.disabledByRefund = true
        end
    end)

    self.enabled = true
    if self.talentsLoaded then
        self:PurchaseTalents()
    end
    eventHandler:RegisterEvent('TRAIT_TREE_CURRENCY_INFO_UPDATED')
end

function addon:OnEnable()
    self.enabled = true
    if self.talentsLoaded then
        self:PurchaseTalents()
    end
    eventHandler:RegisterEvent('TRAIT_TREE_CURRENCY_INFO_UPDATED')
end

function addon:OnDisable()
    self.enabled = false
    eventHandler:UnregisterEvent('TRAIT_TREE_CURRENCY_INFO_UPDATED')
end

function addon:SPELLS_CHANGED()
    self.talentsLoaded = true

    self.configID = C_Traits.GetConfigIDBySystemID(DRAGONRIDING_TRAIT_SYSTEM_ID)
    if not self.configID then return end
    local configInfo = C_Traits.GetConfigInfo(self.configID)
    self.treeID = configInfo and configInfo.treeIDs and configInfo.treeIDs[1]

    if self.enabled then
        self:PurchaseTalents()
    end
    eventHandler:UnregisterEvent('SPELLS_CHANGED')
end

function addon:TRAIT_TREE_CURRENCY_INFO_UPDATED(_, treeID)
    if not self.purchasing and treeID == self.treeID then
        RunNextFrame(function() self:PurchaseTalents() end)
    end
end

function addon:GetCurrencyInfo()
    local excludeStagedChanges = true
    local currencyInfo = C_Traits.GetTreeCurrencyInfo(self.configID, self.treeID, excludeStagedChanges)
    return currencyInfo
end

function addon:PurchaseTalents()
    if not self.configID then return end
    if self.purchasing or self.disabledByRefund then
        -- Already purchasing or disabled by refund
        return
    end

    local currencyInfo = self:GetCurrencyInfo()
    if
    not currencyInfo or
    not currencyInfo[1] or
    not currencyInfo[1].quantity or
    currencyInfo[1].quantity < 1
    then
        -- Not enough currency
        return
    end
    local availableCurrency = currencyInfo[1].quantity

    self.purchasing = true
    local nodes = C_Traits.GetTreeNodes(self.treeID)
    local purchasedEntries = {}
    while availableCurrency > 0 do
        local purchasedSomething = false
        for _, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(self.configID, nodeID)
            local nodeCost = self:GetOrCacheNodeCost(nodeID)
            if
            nodeInfo
            and nodeInfo.ID == nodeID
            and nodeInfo.canPurchaseRank
            and nodeCost ~= 0
            and nodeCost <= availableCurrency
            then
                if #nodeInfo.entryIDs == 1 then
                    -- Single entry, just purchase it
                    if C_Traits.PurchaseRank(self.configID, nodeID) then
                        availableCurrency = availableCurrency - nodeCost
                        purchasedSomething = true
                        table.insert(purchasedEntries, nodeInfo.entryIDs[1])
                    end
                else
                    -- Multiple entries, purchase the second one
                    local entryID = nodeInfo.entryIDs[2]
                    if C_Traits.SetSelection(self.configID, nodeID, entryID) then
                        availableCurrency = availableCurrency - nodeCost
                        purchasedSomething = true
                        table.insert(purchasedEntries, entryID)
                    end
                end
            end
        end
        if not purchasedSomething then
            -- Nothing left to purchase
            break
        end
    end
    if #purchasedEntries > 0 and C_Traits.CommitConfig(self.configID) then
        self:ReportPurchases(purchasedEntries)
    end

    self.purchasing = false
end

function addon:GetOrCacheNodeCost(nodeID)
    if not self.nodeCostCache then
        self.nodeCostCache = {}
    end
    if not self.nodeCostCache[nodeID] then
        local nodeCost = C_Traits.GetNodeCost(self.configID, nodeID)
        self.nodeCostCache[nodeID] = nodeCost and nodeCost[1] and nodeCost[1].amount or 0
    end
    return self.nodeCostCache[nodeID]
end

function addon:ReportPurchases(entryIDs)
    local spellLinks = {}
    for _, entryID in ipairs(entryIDs) do
        local entryInfo = C_Traits.GetEntryInfo(self.configID, entryID)
        if entryInfo and entryInfo.definitionID then
            local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
            if definitionInfo and (definitionInfo.spellID or definitionInfo.overriddenSpellID) then
                local spellID = definitionInfo.spellID or definitionInfo.overriddenSpellID
                local spellLink = C_Spell.GetSpellLink(spellID)
                if spellLink then
                    table.insert(spellLinks, spellLink)
                end
            end
        end
    end
    print(
        string.format(
            "|cff33ff99clickUI DragonRiding Auto Purchaser:|r Purchased %d new talents.\n%s",
            #entryIDs,
            table.concat(spellLinks, ', ')
        )
    )
end
