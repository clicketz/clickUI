local Internal

local classMap = {
    ["DEATHKNIGHT"] = "DeathKnight",
    ["DEMONHUNTER"] = "DemonHunter",
    ["DRUID"]       = "Druid",
    ["EVOKER"]      = "Evoker",
    ["HUNTER"]      = "Hunter",
    ["PALADIN"]     = "Paladin",
    ["PRIEST"]      = "Priest",
    ["ROGUE"]       = "Rogue",
    ["MAGE"]        = "Mage",
    ["SHAMAN"]      = "Shaman",
    ["WARRIOR"]     = "Warrior",
    ["MONK"]        = "Monk",
    ["WARLOCK"]     = "Warlock",
}

local localizedSpecs = {}
local specCache = {}
local plateToArenaID = {}

local function BuildLocalizedSpecTable()
    for classID = 1, GetNumClasses() do
        local _, class = GetClassInfo(classID)
        local classMale = LOCALIZED_CLASS_NAMES_MALE[class]
        local classFemale = LOCALIZED_CLASS_NAMES_FEMALE[class]

        for specIndex = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
            local specID, specName = GetSpecializationInfoForClassID(classID, specIndex)

            if classMale then
                localizedSpecs[string.format("%s %s", specName, classMale)] = specID
            end
            if classFemale and classFemale ~= classMale then
                localizedSpecs[string.format("%s %s", specName, classFemale)] = specID
            end
        end
    end
end

local function GetSpecIDFromTooltip(unit, guid, isSafeGUID)
    if not C_TooltipInfo or not C_TooltipInfo.GetUnit then
        return nil
    end

    local tooltipData = C_TooltipInfo.GetUnit(unit)
    if not tooltipData or not tooltipData.lines then
        return nil
    end

    for _, line in ipairs(tooltipData.lines) do
        if line and line.leftText and line.leftText ~= "" then
            local specID = localizedSpecs[line.leftText]
            if specID then
                if isSafeGUID then
                    specCache[guid] = specID
                end
                return specID
            end
        end
    end
    return nil
end

local function GetUnitSpecID(unit)
    if not Internal.Constants.IsRetail then return nil end

    local guid = UnitGUID(unit)
    local isSafeGUID = guid and not issecretvalue(guid)

    if isSafeGUID then
        if specCache[guid] then
            return specCache[guid]
        end
    end

    if UnitIsUnit(unit, "player") then
        local specIndex = C_SpecializationInfo.GetSpecialization()
        if specIndex then
            local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
            if isSafeGUID then specCache[guid] = specID end
            return specID
        end
    end

    if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) then
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            if isSafeGUID then specCache[guid] = specID end
            return specID
        end
    end

    local plate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if plate and plateToArenaID[plate] then
        local specID = GetArenaOpponentSpec(plateToArenaID[plate])
        if specID and specID > 0 then
            if isSafeGUID then specCache[guid] = specID end
            return specID
        end
    end

    return GetSpecIDFromTooltip(unit, guid, isSafeGUID)
end

local function SetupArenaTracker()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("PLAYER_FOCUS_CHANGED")
    f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    f:SetScript("OnEvent", function(self, event, unit)
        if event == "NAME_PLATE_UNIT_REMOVED" then
            local plate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
            if plate then
                plateToArenaID[plate] = nil
            end
            return
        end

        if not IsActiveBattlefieldArena() then return end

        for _, plate in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local npUnit = plate.namePlateUnitToken
            if npUnit then
                for i = 1, 3 do
                    local arenaUnit = "arena" .. i
                    if (UnitIsUnit(npUnit, "target") and UnitIsUnit("target", arenaUnit)) or
                    (UnitIsUnit(npUnit, "focus") and UnitIsUnit("focus", arenaUnit)) or
                    (UnitIsUnit(npUnit, "mouseover") and UnitIsUnit("mouseover", arenaUnit)) then
                        plateToArenaID[plate] = i
                    end
                end
            end
        end
    end)
end

local function OnLogin()
    if not Platynator or not Platynator.Internal then return end
    Internal = Platynator.Internal

    BuildLocalizedSpecTable()
    SetupArenaTracker()

    Internal.Display.ClassMarkerMixin.SetUnit = function(self, unit)
        self.unit = unit

        if unit then
            local plate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
            local arenaID = plate and plateToArenaID[plate]

            if arenaID then
                Platynator.API.SetUnitTextOverride(unit, tostring(arenaID))
            else
                Platynator.API.SetUnitTextOverride(unit, nil)
            end
        end

        if not self.specMask then
            self.specMask = self:CreateMaskTexture()
            self.specMask:SetTexture("Interface/Masks/CircleMaskScalable")
            self.specMask:SetAllPoints(self.marker)

            self.specBorder = self:CreateTexture(nil, "OVERLAY")
            self.specBorder:SetAtlas("AutoQuest-badgeborder")
            self.specBorder:SetDesaturated(true)
            self.specBorder:SetAllPoints(self.marker)
        end

        if self.unit and (UnitIsPlayer(self.unit) or (UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(self.unit))) then
            self.marker:Show()

            local specID = GetUnitSpecID(self.unit)
            local specIcon

            if specID then
                specIcon = select(4, GetSpecializationInfoByID(specID))
            end

            local _, class = UnitClass(self.unit)

            if specIcon then
                self.marker:SetTexture(specIcon)
                self.marker:AddMaskTexture(self.specMask)

                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    self.specBorder:SetVertexColor(classColor.r, classColor.g, classColor.b)
                end
                self.specBorder:Show()
            else
                self.marker:RemoveMaskTexture(self.specMask)
                self.specBorder:Hide()
                self.marker:SetTexture(self.path:format(classMap[class]))
            end
        else
            self.marker:Hide()
            if self.specBorder then
                self.specBorder:Hide()
            end
        end
    end
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", OnLogin)
