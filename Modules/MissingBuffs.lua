---- Settings ----
local size = 0.4
------------------

local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitCanAssist = UnitCanAssist
local UnitClass = UnitClass
local GetUnitAuraBySpellID = C_UnitAuras.GetUnitAuraBySpellID
local math_max = math.max
local math_floor = math.floor
local strmatch = string.match

local RAID_BUFFS = {
    MAGE = { 1459, 432778 },
    WARRIOR = { 6673 },
    DRUID = { 1126, 432661 },
    PRIEST = { 21562 },
    SHAMAN = { 462854 },
    EVOKER = { 381748 }
}

local EVOKER_AURA_MAP = {
    DEATHKNIGHT = 381732,
    DEMONHUNTER = 381741,
    DRUID = 381746,
    EVOKER = 381748,
    HUNTER = 381749,
    MAGE = 381750,
    MONK = 381751,
    PALADIN = 381752,
    PRIEST = 381753,
    ROGUE = 381754,
    SHAMAN = 381756,
    WARLOCK = 381757,
    WARRIOR = 381758
}

local _, playerClass = UnitClass("player")
local myBuffSpells = RAID_BUFFS[playerClass]

if not myBuffSpells then return end

local UnitHasMyRaidBuff
if playerClass == "EVOKER" then
    UnitHasMyRaidBuff = function(unit)
        local _, targetClass = UnitClass(unit)
        local spellID = EVOKER_AURA_MAP[targetClass]
        return spellID and GetUnitAuraBySpellID(unit, spellID) ~= nil
    end
else
    UnitHasMyRaidBuff = function(unit)
        for i = 1, #myBuffSpells do
            if GetUnitAuraBySpellID(unit, myBuffSpells[i]) then
                return true
            end
        end
        return false
    end
end

local displayTexture = playerClass == "EVOKER" and C_Spell.GetSpellTexture(381748) or C_Spell.GetSpellTexture(myBuffSpells[1])

hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
    local unit = frame.unit

    if not unit or strmatch(unit, "^nameplate") or strmatch(unit, "pet") then return end
    if not UnitExists(unit) then return end

    if UnitIsDeadOrGhost(unit) or not UnitCanAssist("player", unit) then
        if frame.MissingBuffIndicator then frame.MissingBuffIndicator:Hide() end
        return
    end

    if not frame.MissingBuffIndicator then
        local indicator = CreateFrame("Frame", nil, frame)
        indicator:SetPoint("LEFT", frame, "LEFT", 2, 0)
        indicator:SetFrameLevel(frame:GetFrameLevel() + 5)

        local border = indicator:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetColorTexture(0, 0, 0, 1)

        local tex = indicator:CreateTexture(nil, "ARTWORK")
        tex:SetPoint("TOPLEFT", indicator, "TOPLEFT", 1, -1)
        tex:SetPoint("BOTTOMRIGHT", indicator, "BOTTOMRIGHT", -1, 1)
        tex:SetTexture(displayTexture)
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        frame.MissingBuffIndicator = indicator
    end

    local frameHeight = frame:GetHeight() or 40
    local iconSize = math_max(12, math_floor(frameHeight * size))

    if frame.MissingBuffIndicator._currentSize ~= iconSize then
        frame.MissingBuffIndicator:SetSize(iconSize, iconSize)
        frame.MissingBuffIndicator._currentSize = iconSize
    end

    if not UnitHasMyRaidBuff(unit) then
        frame.MissingBuffIndicator:Show()
    else
        frame.MissingBuffIndicator:Hide()
    end
end)
