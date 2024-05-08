local function log(msg) DEFAULT_CHAT_FRAME:AddMessage("|cff00E5EEclickUI|r: " .. msg) end
local cf = CreateFrame("Frame")
cf:RegisterEvent("PLAYER_LOGIN")
cf:SetScript("OnEvent", function(self, event)

    SLASH_CUI1 = "/cs"
    SlashCmdList["CUI"] = function(...)
        cRaidFrames()
    end

    function cRaidFrames(self)
        LoadAddOn("Blizzard_CompactRaidFrames")

        CRFSort_Group=function(t1, t2)
            if UnitIsUnit(t1,"player") then return true
            elseif UnitIsUnit(t2,"player") then return false
            else return t1 < t2
            end
        end

        CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameManager.container, CRFSort_Group)
        -- CompactRaidFrameContainer.flowSortFunc=CRFSort_Group
        log("Player frame now on top. Causes taint.")
    end

    local q = CreateFrame("FRAME")
    local has_run = false
    q:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    q:SetScript("OnEvent",function()
        if not has_run then
            for i=1, GetMaxBattlefieldID() do
                status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(i)
                if queueType == "ARENA" or queueType == "ARENASKIRMISH" then
                    cRaidFrames()
                    has_run = true
                    break
                end
            end
        end
    end)
end)
