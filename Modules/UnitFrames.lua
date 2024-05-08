local addonName = ...
local cf = CreateFrame("Frame")
cf:RegisterEvent("PLAYER_LOGIN")
cf:SetScript("OnEvent", function(self, event)
    --[[VEHICLE
function StyleVehicle(self, vehicleType)
    PlayerFrame.state = "vehicle"

    UnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar)
    UnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar)
    PetFrame_Update(PetFrame)
    PlayerFrame_Update()
    BuffFrame_Update()
    ComboFrame_Update(ComboFrame)

    PlayerFrameTexture:Hide()
    if ( vehicleType == "Natural" ) then
        PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic")
        PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash")
        PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
        PlayerFrameHealthBar:SetSize(103,12)
        PlayerFrameHealthBar:SetPoint("TOPLEFT",116,-41)
        PlayerFrameManaBar:SetSize(103,12)
        PlayerFrameManaBar:SetPoint("TOPLEFT",116,-52)
    else
        PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame")
        PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
        PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
        PlayerFrameHealthBar:SetSize(100,12)
        PlayerFrameHealthBar:SetPoint("TOPLEFT",119,-41)
        PlayerFrameManaBar:SetSize(100,12)
        PlayerFrameManaBar:SetPoint("TOPLEFT",119,-52)
    end
    PlayerFrame_ShowVehicleTexture()

    PlayerName:SetPoint("CENTER",50,23)
    PlayerLeaderIcon:SetPoint("TOPLEFT",40,-12)
    PlayerMasterIcon:SetPoint("TOPLEFT",86,0)
    PlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -13)

    PlayerFrameBackground:SetWidth(114)
    PlayerLevelText:Hide()
end
hooksecurefunc("PlayerFrame_ToVehicleArt", StyleVehicle)


hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self,_,value,_,maxValue)
  if self.RightText and value and maxValue>0 and not self.showPercentage and GetCVar("statusTextDisplay")=="BOTH" then
    local k,m=1e3
    m=k*k
    self.RightText:SetText( (value>1e3 and  value<1e5 and  format("%1.3f",value/k))  or (value>=1e5 and  value<1e6 and  format("%1.0f K",value/k)) or (value>=1e6 and  value<1e9 and  format("%1.1f M",value/m))  or (value>=1e9 and  format("%1.1f M",value/m))  or value )
    end
end)
]]

    --PLAYER
    function StylePlayerFrame(self)
        PlayerFrameTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame")
        PlayerName:Hide()
        PlayerFrameGroupIndicatorText:ClearAllPoints()
        PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", 0, -20)
        PlayerFrameGroupIndicatorLeft:Hide()
        PlayerFrameGroupIndicatorMiddle:Hide()
        PlayerFrameGroupIndicatorRight:Hide()
        PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -24)
        PlayerFrameHealthBar:SetHeight(26)
        PlayerFrameHealthBar.LeftText:ClearAllPoints()
        PlayerFrameHealthBar.LeftText:SetPoint("LEFT", PlayerFrameHealthBar, "LEFT", 10, 0)
        PlayerFrameHealthBar.RightText:ClearAllPoints()
        PlayerFrameHealthBar.RightText:SetPoint("RIGHT", PlayerFrameHealthBar, "RIGHT", -5, 0)
        PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0)
        -- PlayerFrameManaBar:SetPoint("TOPLEFT",106,-52)
        -- PlayerFrameManaBar:SetHeight(13)
        PlayerFrameManaBar.FeedbackFrame:ClearAllPoints()
        PlayerFrameManaBar.FeedbackFrame:SetPoint("CENTER", PlayerFrameManaBar, "CENTER", 0, 0)
        PlayerFrameManaBar.FeedbackFrame:SetHeight(13)
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:ClearAllPoints()
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame, "RIGHT", -6, -3)
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30, 29)
        PlayerFrameManaBar.FullPowerFrame.PulseFrame:ClearAllPoints()
        PlayerFrameManaBar.FullPowerFrame.PulseFrame:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame, "CENTER", -6, -2)
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:ClearAllPoints()
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame, "RIGHT", 5, -4)
        PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetSize(30, 50)

        PlayerStatusTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-Player-Status")
    end

    hooksecurefunc("PlayerFrame_ToPlayerArt", StylePlayerFrame)

    --TARGET
    function StyleTargetFrame(self, forceNormalTexture)
        local classification = UnitClassification(self.unit)
        self.deadText:ClearAllPoints()
        self.deadText:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        self.levelText:SetPoint("RIGHT", self.healthbar, "BOTTOMRIGHT", 63, 10)
        self.nameBackground:Hide()
        self.Background:SetSize(119, 42)
        self.manabar.pauseUpdates = false
        self.manabar:Show()
        TextStatusBar_UpdateTextString(self.manabar)
        self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
        self.name:SetPoint("LEFT", self, 15, 36)
        self.healthbar:SetSize(119, 26)
        self.healthbar:ClearAllPoints()
        self.healthbar:SetPoint("TOPLEFT", 5, -24)
        self.healthbar.LeftText:ClearAllPoints()
        self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0)
        self.healthbar.RightText:ClearAllPoints()
        self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0)
        self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)

        --TargetOfTarget
        FocusFrameToT.deadText:SetWidth(0.01)

        if (forceNormalTexture) then
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame")
        elseif (classification == "minus") then
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame-Minus")
            forceNormalTexture = true
        elseif (classification == "worldboss" or classification == "elite") then
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
        elseif (classification == "rareelite") then
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
        elseif (classification == "rare") then
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
        else
            self.borderTexture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\Interface\\TargetingFrame\\UI-TargetingFrame")
            forceNormalTexture = true
        end

        if (forceNormalTexture) then
            self.haveElite = nil
            if (classification == "minus") then
                self.Background:SetSize(119, 42)
                self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
                self.nameBackground:Hide()
                self.name:SetPoint("LEFT", self, 15, 36)
                self.healthbar:ClearAllPoints()
                self.healthbar:SetPoint("LEFT", 5, 13)
            else
                self.Background:SetSize(119, 42)
                self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
            end
            if (self.threatIndicator) then
                if (classification == "minus") then
                    self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash")
                    self.threatIndicator:SetTexCoord(0, 1, 0, 1)
                    self.threatIndicator:SetWidth(256)
                    self.threatIndicator:SetHeight(128)
                    self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0)
                else
                    self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625)
                    self.threatIndicator:SetWidth(242)
                    self.threatIndicator:SetHeight(93)
                    self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0)
                    self.threatNumericIndicator:SetPoint("BOTTOM", PlayerFrame, "TOP", 75, -22)
                end
            end
        else
            self.haveElite = true
            TargetFrameBackground:SetSize(119, 42)
            self.Background:SetSize(119, 42)
            self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
            if (self.threatIndicator) then
                self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625)
                self.threatIndicator:SetWidth(242)
                self.threatIndicator:SetHeight(112)
                self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9)
            end
        end

        if (self.questIcon) then
            if (UnitIsQuestBoss(self.unit)) then
                self.questIcon:Show()
            else
                self.questIcon:Hide()
            end
        end
    end

    hooksecurefunc("TargetFrame_CheckClassification", StyleTargetFrame)

    --PET
    PetFrameHealthBar:ClearAllPoints()
    PetFrameHealthBar:SetPoint("TOPLEFT", 45, -22)
    PetFrameHealthBar:SetHeight(10)
    PetFrameManaBar:ClearAllPoints()
    PetFrameManaBar:SetPoint("TOPLEFT", 45, -32)
    -- PetFrameManaBar:SetHeight(5)

    -- Hide
    -- hooksecurefunc("PlayerFrame_UpdateStatus",function()
    -- PlayerStatusTexture:Hide()
    -- PlayerRestGlow:Hide()
    -- PlayerStatusGlow:Hide()
    -- PlayerPrestigeBadge:SetAlpha(0)
    -- PlayerPrestigePortrait:SetAlpha(0)
    -- TargetFrameTextureFramePrestigeBadge:SetAlpha(0)
    -- TargetFrameTextureFramePrestigePortrait:SetAlpha(0)
    -- FocusFrameTextureFramePrestigeBadge:SetAlpha(0)
    -- FocusFrameTextureFramePrestigePortrait:SetAlpha(0)
    -- end)

    --Removing ToT / Pet / Focus ToT Debuffs
    for i = 1, 4 do
        local pet = _G["PetFrameDebuff" .. i]
        local tot = _G["TargetFrameToTDebuff" .. i]
        local ftot = _G["FocusFrameToTDebuff" .. i]
        for _, t in pairs({
            pet, tot, ftot
        }) do
            if t then
                t:UnregisterAllEvents()
                t:Hide()
                t.Show = function() end
            end
        end
    end

    --Class icons in portraits sans pets / NPCs / player portrait
    hooksecurefunc("UnitFramePortrait_Update", function(self)
        if self.portrait then
            if UnitIsPlayer(self.unit) and UnitGUID(self.unit) ~= UnitGUID("player") then
                local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
                if t then
                    self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                    self.portrait:SetTexCoord(unpack(t))
                end
            else
                self.portrait:SetTexCoord(0, 1, 0, 1)
            end
        end
    end)

    -- Arena 123 on nameplates
    -- hooksecurefunc("CompactUnitFrame_UpdateName",function(F)
    -- if IsActiveBattlefieldArena() and F.unit:find("nameplate") then
    -- for i=1,5 do
    -- if UnitIsUnit(F.unit,"arena"..i) then
    -- F.name:SetText(i)F.name:SetTextColor(1,1,0) break
    -- end
    -- end
    -- end
    -- end)

    --Darken Frames
    for _, t in pairs({
        PlayerFrameTexture, PlayerFrameAlternateManaBarBorder, PlayerFrameAlternateManaBarRightBorder, PlayerFrameAlternateManaBarLeftBorder,
        TargetFrameTextureFrameTexture, TargetFrameToTTextureFrameTexture,
        PetFrameTexture, FocusFrameTextureFrameTexture, FocusFrameToTTextureFrameTexture,
        PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
        PartyMemberFrame1PetFrameTexture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame4PetFrameTexture
    }) do
        t:SetVertexColor(0.5, 0.5, 0.5)
    end
end)
