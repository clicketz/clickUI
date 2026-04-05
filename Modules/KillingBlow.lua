local playerGUID = UnitGUID("player")

local containerFrame
local linePool = {}
local activeLines = {}

local LINE_HEIGHT = 22
local MAX_LINES = 6
local ANIM_DURATION = 1.5
local ANIM_DELAY = 0.5
local TRANSLATE_OFFSET_Y = 30

local function ReanchorLines()
    for i, line in ipairs(activeLines) do
        line:ClearAllPoints()
        line:SetPoint("BOTTOM", containerFrame, "BOTTOM", 0, (i - 1) * LINE_HEIGHT)
    end
end

local function ReleaseLine(line)
    line:Hide()

    for i, activeLine in ipairs(activeLines) do
        if activeLine == line then
            table.remove(activeLines, i)
            break
        end
    end

    table.insert(linePool, line)
    ReanchorLines()
end

local function CreateLine()
    local frame = CreateFrame("Frame", nil, containerFrame)
    frame:SetSize(200, LINE_HEIGHT)

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetAllPoints(frame)
    text:SetText("Killing Blow!")
    text:SetTextColor(1, 1, 1, 1)

    local animGroup = frame:CreateAnimationGroup()

    local alphaAnim = animGroup:CreateAnimation("Alpha")
    alphaAnim:SetFromAlpha(1)
    alphaAnim:SetToAlpha(0)
    alphaAnim:SetStartDelay(ANIM_DELAY)
    alphaAnim:SetDuration(ANIM_DURATION)
    alphaAnim:SetSmoothing("OUT")

    local transAnim = animGroup:CreateAnimation("Translation")
    transAnim:SetOffset(0, TRANSLATE_OFFSET_Y)
    transAnim:SetStartDelay(ANIM_DELAY)
    transAnim:SetDuration(ANIM_DURATION)
    transAnim:SetSmoothing("OUT")

    animGroup:SetScript("OnFinished", function()
        ReleaseLine(frame)
    end)

    frame.anim = animGroup
    return frame
end

local function KillingBlow()
    while #activeLines >= MAX_LINES do
        local oldestLine = table.remove(activeLines)
        oldestLine.anim:Stop()
        oldestLine:Hide()
        table.insert(linePool, oldestLine)
    end

    local line = table.remove(linePool) or CreateLine()
    table.insert(activeLines, 1, line)

    ReanchorLines()

    line:Show()
    line.anim:Play()
end

local function PartyKill(_, ...)
    local attackerGUID = ...

    if issecretvalue(attackerGUID) then
        return
    end

    if attackerGUID == playerGUID then
        KillingBlow()
    end
end

local function Init()
    containerFrame = CreateFrame("Frame", "KillingBlowContainerFrame", UIParent)
    containerFrame:SetPoint("BOTTOM", PlayerFrame, "TOP", 15, -15)
    containerFrame:SetSize(300, LINE_HEIGHT * MAX_LINES)
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", Init)
EventRegistry:RegisterFrameEventAndCallback("PARTY_KILL", PartyKill)
