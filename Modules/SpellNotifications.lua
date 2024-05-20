local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local bit_band = bit.band
local playerGUID, defaultIcon, groundingTotemNameLocalized

local MISS_TYPE_DEST = {
    ["ABSORB"] = false,
    ["BLOCK"] = false,
    ["DEFLECT"] = true,
    ["DODGE"] = true,
    ["EVADE"] = true,
    ["IMMUNE"] = true,
    ["MISS"] = true,
    ["PARRY"] = true,
    ["REFLECT"] = true,
    ["RESIST"] = true,
}

local MISS_TYPE_SOURCE = {
    ["ABSORB"] = false,
    ["BLOCK"] = false,
    ["DEFLECT"] = true,
    ["DODGE"] = false,
    ["EVADE"] = true,
    ["IMMUNE"] = false,
    ["MISS"] = true,
    ["PARRY"] = false,
    ["REFLECT"] = true,
    ["RESIST"] = true,
}

local ACTION_TYPE = {
    ["SPELL_DISPEL"] = "Dispelled",
    ["SPELL_INTERRUPT"] = "Interrupted",
    ["SPELL_STOLEN"] = "Stole",
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if eventType == "SPELL_MISSED" then
            -- Fade / Immunities / Reflects / Etc
            if destGUID == playerGUID then
                if MISS_TYPE_DEST[extraArg4] then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    UIErrorsFrame:AddMessage(format("Self->" .. extraArg4 .. ": " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
                end
            elseif sourceGUID == playerGUID then
                if MISS_TYPE_SOURCE[extraArg4] then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    UIErrorsFrame:AddMessage(format(extraArg4 .. ": " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
                end
            end

            -- Grounding Totem
            if destName == groundingTotemNameLocalized
            and bit_band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
            and bit_band(destFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
            and bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                UIErrorsFrame:AddMessage(format("Ground: " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
            end
        end

        -- Shadow Word: Death
        if eventType == "SPELL_AURA_BROKEN_SPELL" then
            if extraArg4 == 32379 -- if sw: death
            and destGUID == playerGUID
            and sourceGUID == playerGUID
            then
                local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                UIErrorsFrame:AddMessage(format("Deathed: " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
            end
        end

        -- Dispels / Kicks / Purges
        if sourceGUID == playerGUID or sourceGUID == UnitGUID("pet") then
            local action = ACTION_TYPE[eventType]

            if action then
                local icon = select(3, GetSpellInfo(extraArg4)) or defaultIcon
                UIErrorsFrame:AddMessage(format("%s: " .. "|T" .. icon .. ":0|t" .. "%s", action, GetSpellInfo(extraArg4)))
            end
        end
    elseif event == "PLAYER_LOGIN" then
        playerGUID = UnitGUID("player")
        defaultIcon = select(3, GetSpellInfo(5024)) -- Chicken Icon
        groundingTotemNameLocalized = GetSpellInfo(204336)

        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end)
