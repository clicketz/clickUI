local _, addon = ...

local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_AURA")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    addon[event](addon, ...)
end)

local buttons = {}
local activeAuras = {}

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", function()
    -- print("Hello World!")
    -- addon:HandleAuras("player", nil)
end)

-- Create 4 buttons side-by-side in the center of the screen
do
    for i = 1, 4 do
        local button = CreateFrame("Button", nil, UIParent, "CompactAuraTemplate")
        button:SetSize(36, 36)
        button:SetPoint("CENTER", (i - 1) * 36, 0)
        button:SetMouseClickEnabled(false)
        button:RegisterForClicks()
        buttons[i] = button
    end
end

local function HandleAura(aura)
    print(aura.name)
    activeAuras[aura.auraInstanceID] = aura
end

function addon:UNIT_AURA(unit, info)
    if unit == "player" then
        self:HandleAuras(unit, info)
    end
end

function addon:FullAuraUpdate()
    AuraUtil.ForEachAura("player", "HELPFUL", nil, HandleAura, true)
    AuraUtil.ForEachAura("player", "HARMFUL", nil, HandleAura, true)
    print("FullAuraUpdate")
end

function addon:HandleAuras(unit, unitAuraUpdateInfo)
    local aurasChanged = false

    -- print("HANDLING...")

    -- DevTools_Dump(info)
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
        self:FullAuraUpdate()
        aurasChanged = true
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                -- DevTools_Dump(aura)
                activeAuras[aura.auraInstanceID] = aura
                aurasChanged = true;
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if activeAuras[auraInstanceID] ~= nil then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID);
                    activeAuras[auraInstanceID] = newAura;
                    aurasChanged = true;
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if activeAuras[auraInstanceID] ~= nil then
                    activeAuras[auraInstanceID] = nil;
                    aurasChanged = true;
                end
            end
        end
    end

    if aurasChanged then
        local frameNum = 1;
        local maxAuras = 4;

        for _, aura in pairs(activeAuras) do
            if frameNum > maxAuras then
                return true;
            end

            local auraFrame = buttons[frameNum];
            auraFrame.icon:SetTexture(aura.icon)
            local startTime = aura.expirationTime - aura.duration
            CooldownFrame_Set(auraFrame.cooldown, startTime, aura.duration, true)
            auraFrame:Show()
            -- CompactUnitFrame_UtilSetBuff(debuffFrame, aura);
            frameNum = frameNum + 1;
        end

        for i = frameNum, #buttons do
            buttons[i]:Hide()
        end
    end
end
