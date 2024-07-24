local addonName, addon = ...
local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local UnitExists, UnitSelectionColor, UnitClass, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo = UnitExists, UnitSelectionColor, UnitClass, UnitIsPlayer, UnitCastingInfo, UnitChannelInfo
local select = select

local statusBarPath = "Interface\\AddOns\\" .. addonName .. "\\Textures\\UI-StatusBar"

local frame = CreateFrame("FRAME")

local hiddenFrame = CreateFrame("FRAME")
hiddenFrame:Hide()

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_FACTION")
frame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
frame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
frame:RegisterUnitEvent("UNIT_TARGET", "target", "focus")
frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "target", "focus")
frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "target", "focus")
frame:RegisterUnitEvent("UNIT_PET", "player")

local changeHealthBars = true
local changeManaBars = false

local function CreateFrameBackground(frame)
    if not frame then return end
    local bg = CreateFrame("Frame", nil, frame)
    local tex = bg:CreateTexture()

    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.5)

    -- bg:SetAllPoints()
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -0.5, 0)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -0.5)
    bg:SetFrameLevel(frame:GetParent():GetFrameLevel() - 1)

    frame.bg = bg
end

--Player Frame Edits ***(ENABLE IF EASYFRAMES IS DISABLED)***
do
    if not select(4, GetAddOnInfo("EasyFrames")) then
        if isClassic then
            PlayerFrameGroupIndicator:ClearAllPoints()
            PlayerFrameGroupIndicator:SetPoint("TOPLEFT", 34, 15)
            PlayerFrameGroupIndicatorLeft:SetAlpha(0)
            PlayerFrameGroupIndicatorRight:SetAlpha(0)
            PlayerFrameGroupIndicatorMiddle:SetAlpha(0)
            PlayerPVPIcon:SetAlpha(0)
            PlayerPVPTimerText:SetAlpha(0)
            PlayerFrame:UnregisterEvent("UNIT_COMBAT")
            ComboPointPlayerFrame:SetAlpha(0)
            RuneFrame:SetPoint("TOP", PlayerFrame, "TOP", 50, 1)
        elseif not isClassic then
            PlayerFrame:UnregisterEvent("UNIT_COMBAT")

            -- Fix Blizzard's broken frame levels
            for _, f in pairs({ PlayerFrame, TargetFrame, FocusFrame, TargetFrameToT, FocusFrameToT, PetFrame }) do
                local container = f["PlayerFrameContainer"] or f["TargetFrameContainer"]
                local fLevel = f:GetFrameLevel()

                if container then
                    container:SetFrameLevel(fLevel + 20)

                    local content = f["PlayerFrameContent"] or f["TargetFrameContent"]
                    if content then
                        local context = content["PlayerFrameContentContextual"] or content["TargetFrameContentContextual"]
                        if context then
                            context:SetFrameLevel(fLevel + 25)
                        end
                    end
                else
                    f.healthbar:SetFrameLevel(fLevel - 1)
                    f.manabar:SetFrameLevel(fLevel - 1)
                end

                CreateFrameBackground(f.healthbar)
                CreateFrameBackground(f.manabar)
            end

            CreateFrameBackground(AlternatePowerBar)

            TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
            FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
            PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:Hide()
        end
    elseif not isClassic then
        for _, f in pairs({ PlayerFrame, TargetFrame, FocusFrame, TargetFrameToT, FocusFrameToT, PetFrame }) do
            CreateFrameBackground(f.healthbar)
            CreateFrameBackground(f.manabar)
        end
    end
end

if isClassic then
    local function eventHandler(self, event, ...)
        if UnitIsPlayer("target") then
            local c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
            TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
        end
        if UnitIsPlayer("focus") then
            local c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
            FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
        end
    end

    frame:SetScript("OnEvent", eventHandler)


    --Change Texture
    for _, BarTextures in pairs({ TargetFrameNameBackground, FocusFrameNameBackground }) do
        BarTextures:SetTexture(statusBarPath)
    end
else
    local c
    local function eventHandler(self, event, ...)
        if UnitExists("target") then
            if changeHealthBars then
                if UnitIsPlayer("target") then
                    c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
                    TargetFrame.healthbar:SetStatusBarColor(c.r, c.g, c.b)
                else
                    TargetFrame.healthbar:SetStatusBarColor(UnitSelectionColor("target", true))
                end
            end

            if changeManaBars then
                local manabar = TargetFrame.manabar
                local manaColor = PowerBarColor[manabar.powerType]
                manabar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b)
            end
        end

        if UnitExists("focus") then
            if changeHealthBars then
                if UnitIsPlayer("focus") then
                    c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
                    FocusFrame.healthbar:SetStatusBarColor(c.r, c.g, c.b)
                else
                    FocusFrame.healthbar:SetStatusBarColor(UnitSelectionColor("focus", true))
                end
            end

            if changeManaBars then
                local manabar = FocusFrame.manabar
                local manaColor = PowerBarColor[manabar.powerType]
                manabar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b)
            end
        end

        if UnitExists("targettarget") then
            if changeHealthBars then
                if UnitIsPlayer("targettarget") then
                    c = RAID_CLASS_COLORS[select(2, UnitClass("targettarget"))]
                    TargetFrameToT.healthbar:SetStatusBarColor(c.r, c.g, c.b)
                else
                    TargetFrameToT.healthbar:SetStatusBarColor(UnitSelectionColor("targettarget", true))
                end
            end

            if changeManaBars then
                local manabar = TargetFrameToT.manabar
                local manaColor = PowerBarColor[manabar.powerType]
                manabar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b)
            end
        end

        if UnitExists("focustarget") then
            if changeHealthBars then
                if UnitIsPlayer("focustarget") then
                    c = RAID_CLASS_COLORS[select(2, UnitClass("focustarget"))]
                    FocusFrameToT.healthbar:SetStatusBarColor(c.r, c.g, c.b)
                else
                    FocusFrameToT.healthbar:SetStatusBarColor(UnitSelectionColor("focustarget", true))
                end
            end
        end

        if changeHealthBars then
            if UnitExists("vehicle") then
                PlayerFrame.healthbar:SetStatusBarColor(UnitSelectionColor("vehicle", true))
            else
                PlayerFrame.healthbar:SetStatusBarColor(RAID_CLASS_COLORS[select(2, UnitClass("player"))]:GetRGBA())
            end

            if PetFrame:IsVisible() then
                if UnitIsPlayer(PetFrame.unit) then
                    c = RAID_CLASS_COLORS[select(2, UnitClass(PetFrame.unit))]
                    PetFrame.healthbar:SetStatusBarColor(c.r, c.g, c.b)
                else
                    PetFrame.healthbar:SetStatusBarColor(UnitSelectionColor(PetFrame.unit, true))
                end
            end
        end
    end

    -- Spellbar Colors
    local defaultColor = {
        r = 233 / 256,
        g = 164 / 256,
        b = 0
    }

    local shieldColor = {
        r = 0.8,
        g = 0.8,
        b = 0.8
    }

    for _, f in pairs({ PlayerFrame, TargetFrame, FocusFrame, TargetFrameToT, FocusFrameToT, PetFrame }) do
        if changeManaBars then
            f.manabar:SetStatusBarDesaturated(true)
            f.manabar:SetStatusBarTexture(statusBarPath)

            hooksecurefunc(f.manabar, "SetStatusBarTexture", function(self, texture)
                if texture ~= statusBarPath then
                    self:SetStatusBarTexture(statusBarPath)
                end
            end)

            hooksecurefunc(f.manabar, "SetStatusBarColor", function(self, r, g, b)
                local manaColor = PowerBarColor[self.powerType]
                -- make mana "blue" a bit lighter
                local green = self.powerType == Enum.PowerType.Mana and 0.3 or manaColor.g

                if r ~= manaColor.r or g ~= green or b ~= manaColor.b then
                    self:SetStatusBarColor(manaColor.r, green, manaColor.b)
                end
            end)
        end

        if changeHealthBars then
            f.healthbar:SetStatusBarDesaturated(true)
            f.healthbar:SetStatusBarTexture(statusBarPath)

            local tex = f.healthbar.HealthBarTexture or f.healthbar.texture
            if tex then
                hooksecurefunc(tex, "SetAtlas", function()
                    f.healthbar:SetStatusBarTexture(statusBarPath)
                end)
            end
        end

        local spellbar = f.spellbar
        if spellbar then
            spellbar.Background:SetTexture(statusBarPath)
            spellbar.Background:SetVertexColor(0, 0, 0, 0.5)

            hooksecurefunc(spellbar, "SetStatusBarTexture", function(self, texture)
                if texture ~= statusBarPath then
                    self:SetStatusBarTexture(statusBarPath)
                end
            end)

            spellbar:HookScript("OnEvent", function(self)
                if self.casting or self.channeling then
                    local notInterruptible

                    if self.casting then
                        notInterruptible = select(8, UnitCastingInfo(self.unit))
                    else
                        notInterruptible = select(7, UnitChannelInfo(self.unit))
                    end

                    if notInterruptible then
                        self:SetStatusBarColor(shieldColor.r, shieldColor.g, shieldColor.b)
                    else
                        self:SetStatusBarColor(defaultColor.r, defaultColor.g, defaultColor.b)
                    end
                end
            end)
        end
    end

    if changeHealthBars then
        PlayerFrame.healthbar:SetStatusBarColor(RAID_CLASS_COLORS[select(2, UnitClass("player"))]:GetRGBA())
        PetFrame.healthbar:SetStatusBarDesaturated(true)
    end

    local pCastBar = PlayerCastingBarFrame
    pCastBar.Background:SetTexture(statusBarPath)
    pCastBar.Background:SetVertexColor(0, 0, 0, 0.5)

    pCastBar.Border:Hide()

    pCastBar.border = CreateFrame("Frame", nil, pCastBar, "BackdropTemplate")

    pCastBar.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 7,
    })

    pCastBar.border:SetBackdropBorderColor(0.4, 0.4, 0.4)
    pCastBar.border:SetPoint("TOPLEFT", pCastBar, "TOPLEFT", -1.1, 1.1)
    pCastBar.border:SetPoint("BOTTOMRIGHT", pCastBar, "BOTTOMRIGHT", 1.1, -1.1)

    hooksecurefunc(PlayerCastingBarFrame, "SetStatusBarTexture", function(self, texture)
        if texture ~= statusBarPath then
            self:SetStatusBarTexture(statusBarPath)
            self:SetStatusBarColor(4 / 256, 241 / 256, 3 / 256)
        end
    end)

    -- For god knows what reason PTR has a gap between Portrait and PlayerFrame. This fixes it.
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetScale(1.02)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetScale(1.09)
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 24, -18)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(60,61)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 20, -15)
    -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar.HealthBarMask:SetHeight(33)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar, "TOPLEFT", -2, 3)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetHeight(17)
    PlayerFrame.healthbar:SetHeight(21)
    PlayerFrame.manabar:SetSize(125,12)
    local p, r, rr, x, y = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(p, r, rr, -3, 0)
    --local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:GetPoint()
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:ClearAllPoints()
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint(a, b, c, d, 99)
    -- TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar.HealthBarMask:SetWidth(129)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
    local point, relativeTo, relativePoint, xOffset, yOffset = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
    local p, r, rr, x, y = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)
    -- FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar.HealthBarMask:SetWidth(129)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
    local point, relativeTo, relativePoint, xOffset, yOffset = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
    local p, r, rr, x, y = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = PlayerLevelText:GetPoint()
    PlayerLevelText:SetPoint(a,b,c,d,-28)
    --ToT
    local a, b, c, d, e = TargetFrame.totFrame.HealthBar:GetPoint()
    TargetFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
    TargetFrame.totFrame.HealthBar:SetSize(71, 13)
    --anchor x = 5
    TargetFrame.totFrame.ManaBar:SetSize(76, 8)
    local a, b, c, d, e = TargetFrame.totFrame.ManaBar:GetPoint()
    TargetFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
    TargetFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
    TargetFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)
    --anchor x = -5
    local a, b, c, d, e = TargetFrame.totFrame.Portrait:GetPoint()
    TargetFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)
    local a, b, c, d, e = FocusFrame.totFrame.HealthBar:GetPoint()
    FocusFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
    FocusFrame.totFrame.HealthBar:SetSize(71, 13)
    --anchor x = 5
    FocusFrame.totFrame.ManaBar:SetSize(77, 10)
    local a, b, c, d, e = FocusFrame.totFrame.ManaBar:GetPoint()
    FocusFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
    FocusFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
    FocusFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)
    --anchor x = -5
    local a, b, c, d, e = FocusFrame.totFrame.Portrait:GetPoint()
    FocusFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)
    for i = 1, 4 do
        local memberFrame = PartyFrame["MemberFrame" .. i]
        if memberFrame and memberFrame.Portrait then
            memberFrame.Portrait:SetHeight(38)
        end
    end

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight()

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)

    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)

    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait:SetAlpha(0)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:SetAlpha(0)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetAlpha(0)

    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetParent(hiddenFrame)

    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetAlpha(0)
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:SetAlpha(0)

    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetAlpha(0)
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:SetAlpha(0)

    -- BigDebuffs Player Portrait Fix
    C_Timer.After(0, function()
        C_Timer.After(0, function()
            if IsAddOnLoaded("BigDebuffs") then
                BigDebuffsplayerUnitFrame:SetScript("OnShow", function(self)
                    self:SetScale(PlayerFrame.PlayerFrameContainer.PlayerPortrait:GetScale())
                    self:SetAllPoints(PlayerFrame.PlayerFrameContainer.PlayerPortrait)
                    self.mask:SetScale(PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:GetScale())
                    self.mask:SetAllPoints(PlayerFrame.PlayerFrameContainer.PlayerPortraitMask)

                    self:SetScript("OnShow", nil)
                end)
            end
        end)
    end)

    -- Remove Group Border Frames
    PlayerFrameGroupIndicatorLeft:SetAlpha(0)
    PlayerFrameGroupIndicatorMiddle:SetAlpha(0)
    PlayerFrameGroupIndicatorRight:SetAlpha(0)

    frame:SetScript("OnEvent", eventHandler)
end
