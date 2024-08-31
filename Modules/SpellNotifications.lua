local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local bit_band = bit.band
local playerGUID, petGUID, defaultIcon, groundingTotemNameLocalized, msgFrame
local GetSpellLink = C_Spell.GetSpellLink

-- Local ignore list for spells you wish to ignore.
-- TODO: Add to a database
local ignore = {
    [370898] = true, -- Permeating Chill
}

local GetSpellInfo = function(spellID)
    if not spellID then
        return nil
    end

    -- Classic flavors still use old GetSpellInfo
    if GetSpellInfo then
        return GetSpellInfo(spellID)
    end

    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
    end
end

-- This will show if the player gets attacked into this type
-- e.g. player immunes a cast with ice block
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

-- This will show if the player hitting into this type
-- e.g. player attacks into an iced blocked mage
local MISS_TYPE_SOURCE = {
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

local ACTION_TYPE = {
    ["SPELL_DISPEL"] = "Dispelled",
    ["SPELL_INTERRUPT"] = "Interrupted",
    ["SPELL_STOLEN"] = "Stole",
}

local function SetupMessageFrame()
    if not msgFrame then
        msgFrame = CreateFrame("ScrollingMessageFrame", "clickUI_MessageFrame", UIParent)
        msgFrame:SetFontObject("NumberFont_Outline_Large")
        msgFrame:SetSize(500, 500)
        msgFrame:SetPoint("CENTER")
        msgFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        msgFrame:SetTimeVisible(4)
        msgFrame:SetMaxLines(5)
        msgFrame:SetIndentedWordWrap(true)
        msgFrame:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

        if ignore[extraArg1]
        or ignore[extraArg4] then
            return
        end

        -- Fade / Immunities / Reflects / Etc
        if subevent == "SPELL_MISSED" then
            if destGUID == playerGUID then
                if MISS_TYPE_DEST[extraArg4] then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    msgFrame:AddMessage(format("Self->" .. extraArg4 .. ": " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
                end
            elseif sourceGUID == playerGUID then
                if MISS_TYPE_SOURCE[extraArg4] then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    msgFrame:AddMessage(format(extraArg4 .. ": " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
                end
            end
        end

        -- Shadow Word: Death
        if subevent == "SPELL_AURA_BROKEN_SPELL" then
            if extraArg4 == 32379 -- if sw: death
            and destGUID == playerGUID
            and sourceGUID == playerGUID
            then
                local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                msgFrame:AddMessage(format("Deathed: " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
            end
        end

        -- Grounding Totem
        if subevent == "SPELL_CAST_SUCCESS" then
            if destName == groundingTotemNameLocalized
            and bit_band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
            and bit_band(destFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
            and bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                msgFrame:AddMessage(format("Ground: " .. "|T" .. icon .. ":0|t" .. "%s", GetSpellLink(extraArg1)))
            end
        end

        -- Dispels / Kicks / Purges
        if subevent == "SPELL_DISPEL"
        or subevent == "SPELL_INTERRUPT"
        or subevent == "SPELL_STOLEN" then
            if sourceGUID == playerGUID or sourceGUID == petGUID then
                local icon = select(3, GetSpellInfo(extraArg4)) or defaultIcon
                msgFrame:AddMessage(format("%s: " .. "|T" .. icon .. ":0|t" .. "%s", ACTION_TYPE[subevent], GetSpellLink(extraArg4)))
            end
        end
    elseif event == "PLAYER_LOGIN" then
        playerGUID = UnitGUID("player")
        petGUID = UnitGUID("pet")
        defaultIcon = select(3, GetSpellInfo(5024)) -- Chicken Icon
        groundingTotemNameLocalized = GetSpellInfo(204336)
        SetupMessageFrame()

        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end)
