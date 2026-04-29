local addonName, ns = ...

local tonumber = tonumber
local string_match = string.match
local type = type
local UnitExists = UnitExists
local UnitClass = UnitClass
local C_ClassColor = C_ClassColor

local MAX_ARENA_ENEMIES = 3
local INDICATOR_SIZE = 40
local SPACING = 4

local Tracker = CreateFrame("Frame", "ArenaTargetTrackerFrame", UIParent)
Tracker:SetSize((INDICATOR_SIZE * MAX_ARENA_ENEMIES) + (SPACING * (MAX_ARENA_ENEMIES - 1)), INDICATOR_SIZE)
Tracker:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
Tracker:SetMovable(true)
Tracker:EnableMouse(true)
Tracker:RegisterForDrag("LeftButton")
Tracker:SetScript("OnDragStart", Tracker.StartMoving)
Tracker:SetScript("OnDragStop", Tracker.StopMovingOrSizing)

Tracker.bg = Tracker:CreateTexture(nil, "BACKGROUND")
Tracker.bg:SetAllPoints()
Tracker.bg:SetColorTexture(0, 0, 0, 0.6)

Tracker.indicators = {}

for i = 1, MAX_ARENA_ENEMIES do
    local f = CreateFrame("Frame", nil, Tracker)
    f:SetSize(INDICATOR_SIZE, INDICATOR_SIZE)

    if i == 1 then
        f:SetPoint("LEFT", Tracker, "LEFT", 0, 0)
    else
        f:SetPoint("LEFT", Tracker.indicators[i - 1], "RIGHT", SPACING, 0)
    end

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetColorTexture(0.15, 0.15, 0.15, 1)
    f.tex = tex

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("CENTER")
    text:SetText(i)

    Tracker.indicators[i] = f
end

local function UpdateTargetColor(arenaIndex, unitTarget)
    local indicator = Tracker.indicators[arenaIndex]
    if not indicator then return end

    if UnitExists(unitTarget) then
        local _, classFilename = UnitClass(unitTarget)

        if type(classFilename) == "string" then
            local c = C_ClassColor.GetClassColor(classFilename)
            if c then
                indicator.tex:SetColorTexture(c.r, c.g, c.b, 1)
                return
            end
        end
    end

    indicator.tex:SetColorTexture(0.15, 0.15, 0.15, 1)
end

Tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
Tracker:RegisterEvent("ARENA_OPPONENT_UPDATE")
Tracker:RegisterUnitEvent("UNIT_TARGET", "arena1", "arena2", "arena3")

Tracker:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        for i = 1, MAX_ARENA_ENEMIES do
            UpdateTargetColor(i, "arena" .. i .. "target")
        end
        return
    end

    local arenaIndex = tonumber(string_match(unit or "", "arena(%d+)"))
    if arenaIndex and arenaIndex <= MAX_ARENA_ENEMIES then
        UpdateTargetColor(arenaIndex, unit .. "target")
    end
end)

SLASH_ARENATARGETTRACKER1 = "/att"
SlashCmdList["ARENATARGETTRACKER"] = function()
    if Tracker:IsShown() then
        Tracker:Hide()
    else
        Tracker:Show()
    end
end
