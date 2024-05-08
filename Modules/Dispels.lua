local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local bit_band = bit.band
local playerGUID
local defaultIcon = select(3, GetSpellInfo(5024)) -- Chicken Icon

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)

	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if sourceGUID == playerGUID or sourceGUID == UnitGUID("pet") then
            if eventType == "SPELL_DAMAGE" or eventType == "SPELL_MISSED" then
                if extraArg4 == "RESIST" and (sourceGUID == playerGUID or sourceGUID == UnitGUID("pet")) then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    UIErrorsFrame:AddMessage(format(extraArg4..": ".."|T"..icon..":0|t".."%s", GetSpellLink(extraArg1)))
                elseif (extraArg4 == "REFLECT" or extraArg4 == "IMMUNE") then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    UIErrorsFrame:AddMessage(format(extraArg4..": ".."|T"..icon..":0|t".."%s", GetSpellLink(extraArg1)))
                elseif bit_band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 and destName == "Grounding Totem" and bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                    local icon = select(3, GetSpellInfo(extraArg1)) or defaultIcon
                    UIErrorsFrame:AddMessage(format("Ground: ".."|T"..icon..":0|t".."%s", GetSpellLink(extraArg1)))
                end

                return
            end

            local action = eventType == "SPELL_DISPEL" and "Dispelled" or eventType == "SPELL_INTERRUPT" and "Interrupted" or eventType == "SPELL_STOLEN" and "Stole"
            if action then
                local icon = select(3, GetSpellInfo(extraArg4)) or defaultIcon
                UIErrorsFrame:AddMessage(format("%s: ".."|T"..icon..":0|t".."%s", action, GetSpellInfo(extraArg4)))
            end
        end
	else
		if event == "PLAYER_LOGIN" then
			playerGUID = UnitGUID("player")
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end)