local addonName, addon = ...

local _
local playerClass = select(2, UnitClass("player"))
local GetSpellInfo = GetSpellInfo
local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

-- Upvalues
local PetFrame = _G.PetFrame
local PlayerFrame = _G.PlayerFrame
local TargetFrame = _G.TargetFrame
local FocusFrame = _G.FocusFrame

-- DEVTOOLS_MAX_ENTRY_CUTOFF = 9999

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
-- eventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")

-- Hide Arena Frames
local hiddenFrame = CreateFrame("Frame")
hiddenFrame:SetScript("OnShow", hiddenFrame.Hide)

local function hide(frame)
    frame:SetParent(hiddenFrame)
    hiddenFrame:Hide()
end

eventFrame:SetScript("OnEvent", function(self)
    local arenaFrame = _G["CompactArenaFrame"]

    if arenaFrame and not arenaFrame.hooked then
        hide(arenaFrame)

        arenaFrame.hooked = arenaFrame:HookScript("OnShow", function(af)
            local combat = InCombatLockdown()

            if not combat then
                hide(af)
            else
                af:RegisterEvent("PLAYER_REGEN_ENABLED", function()
                    hide(af)
                    af:UnregisterEvent("PLAYER_REGEN_ENABLED")
                end)
            end
        end)

        if arenaFrame.hooked then
            self:UnregisterAllEvents()
        end
    end
end)

--General UI Edits
_G.ChatBubbleFont:SetFont(_G.STANDARD_TEXT_FONT, 14, "OUTLINE")
_G.SpellActivationOverlayFrame:SetScale(.7)
_G.UIErrorsFrame:SetScale(1.3)
-- GameFontNormalSmall:SetShadowOffset(.7,-.7)

--Group Eyeball
-- QueueStatusButton:SetMovable(true)
-- QueueStatusButton:RegisterForDrag("LeftButton")
-- QueueStatusButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
-- QueueStatusButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)

-- QueueStatusButton:HookScript("OnShow", function(self)
-- self:ClearAllPoints()
-- self:SetClampedToScreen(true)
-- self:SetPoint("TOP", Minimap, "TOP", -80, -290)
-- self:SetScale(0.6)
-- end)

hooksecurefunc(_G.QueueStatusButton, "SetPoint", function(self, point, relativeFrame, relativePoint, x, y)
    if y ~= -290 then
        self:ClearAllPoints()
        self:SetClampedToScreen(true)
        self:SetPoint("TOP", _G.Minimap, "TOP", -80, -290)
        self:SetScale(0.6)
    end
end)

-- Action Bars
if isClassic then
    _G.MainMenuBarArtFrame.LeftEndCap:Hide()
    _G.MainMenuBarArtFrame.RightEndCap:Hide()
    _G.MainMenuBarArtFrame.PageNumber:Hide()
    _G.MainMenuBarArtFrameBackground:Hide()
    _G.ActionBarUpButton:Hide()
    _G.ActionBarDownButton:Hide()
    _G.MicroButtonAndBagsBar.MicroBagBar:Hide()
    _G.MicroButtonAndBagsBar:Hide()
    _G.StatusTrackingBarManager:Hide()
end

-- Alert Frame
if isClassic and _G.AlertFrame then
    _G.AlertFrame:ClearAllPoints()
    _G.AlertFrame:SetPoint("BOTTOMRIGHT", -500, 0)
end

-- Move stance/pet frame over to the right to avoid trinket weakaura
if isClassic then
    local bars_to_move = {
        _G.StanceBarFrame,
        _G.PetActionButton1,
    }

    for _, v in ipairs(bars_to_move) do
        local width = _G.ActionButton1:GetSize()
        v:SetPoint("LEFT", width * 2.3, 0)
    end
end

-- Raid Frame Name
hooksecurefunc("CompactUnitFrame_UpdateName", function(self)
    if self.name and (not self:IsForbidden()) and self.name:IsVisible() then
        self.name:Hide()
    end
end)

-- Raid Frame "Party" Title
if not isClassic then
    _G.CompactPartyFrameTitle:SetAlpha(0)
end

-- Role Icon (Hide DPS icons)
hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(self)
    if not self.roleIcon then return end

    -- local role = UnitGroupRolesAssigned(self.unit)
    self.roleIcon:SetAlpha(UnitGroupRolesAssigned(self.unit) == "DAMAGER" and 0 or 1)
end)

-- hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
-- local name = frame.name:GetText()

-- if name then
-- local range = IsSpellInRange("Cyclone", frame.displayedUnit)
-- if range ~= nil then
-- print(name, range)
-- end
-- end
-- end)

-- local not_registered = true
-- function MUI_UpdateMacroIcon(self)
-- if not_registered then
-- self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
-- self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
-- not_registered = false
-- end

-- if not InCombatLockdown() then
-- SetMacroSpell("PRIEST_HONORTALS",
-- GetSpellInfo "Thoughtsteal"
-- or GetSpellInfo "Divine Ascension"
-- or GetSpellInfo "Ray of Hope"
-- or GetSpellInfo "Holy Ward"
-- or GetSpellInfo "Spirit of Redemption(PvP Talent)"
-- or GetSpellInfo "Greater Heal"
-- or GetSpellInfo "Dark Archangel"
-- or GetSpellInfo "Archangel"
-- or GetSpellInfo "Resurrection")
-- end
-- end

-- Honor Talent Macro Udate
-- if playerClass == "PRIEST" then
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("INITIAL_CLUBS_LOADED")
-- f:HookScript("OnEvent", MUI_UpdateMacroIcon)
-- end


_G.PetFrame.name:Hide()
-- PetFrame:HookScript("OnShow", function(self)
-- if self:IsMouseEnabled() then
-- self:SetFrameLevel(PlayerFrame:GetFrameLevel() - 1)
-- self:EnableMouse(false)
-- end
-- end)

--Remove Pet Border on Raid Frames
for i = 1, 5 do
    local frame = _G["CompactPartyFramePet" .. i]

    if frame then
        frame.horizBottomBorder:SetAlpha(0)
        frame.horizTopBorder:SetAlpha(0)
        frame.vertLeftBorder:SetAlpha(0)
        frame.vertRightBorder:SetAlpha(0)
    end
end

-- for i = 1, 40 do
-- local frame = _G["CompactRaidFrame" .. i]

-- if frame then
-- frame.horizBottomBorder:SetAlpha(0)
-- frame.horizTopBorder:SetAlpha(0)
-- frame.vertLeftBorder:SetAlpha(0)
-- frame.vertRightBorder:SetAlpha(0)
-- end
-- end


-- DAMAGE_TEXT_FONT = "Interface\\AddOns\\" .. addonName .. "\\Fonts\\Prototype.ttf"
-- UNIT_NAME_FONT   = "Interface\\AddOns\\" .. addonName .. "\\Fonts\\Prototype.ttf"
-- NAMEPLATE_FONT   = "Interface\\AddOns\\" .. addonName .. "\\Fonts\\Prototype.ttf"
-- STANDARD_TEXT_FONT = "Interface\\AddOns\\" .. addonName .. "\\Fonts\\Prototype.ttf"

--[[ Three Bars
local z, x = MultiBarBottomRightButton1, MultiBarBottomRightButton7
z:ClearAllPoints()
x:ClearAllPoints()
z:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0, 6)
x:SetPoint("LEFT", MultiBarBottomRightButton6, "RIGHT", 6, 0)

hooksecurefunc("MultiActionBar_Update", function()
	MultiBarBottomRight:Show()
end)
]]

-- COMBO POINTS
--[[

if GetCVar("comboPointLocation") ~= 2 and playerClass == "ROGUE" then -- [2] is new location, [1] is old location
    SetCVar("comboPointLocation", 2)
	ReloadUI()
elseif GetCVar("comboPointLocation") ~= 1 and playerClass == "DRUID" then
	SetCVar("comboPointLocation", 1)
	ComboPointPlayerFrame:SetAlpha(0)
	ReloadUI()
end
-- ComboPointPlayerFrame:ClearAllPoints()
-- ComboPointPlayerFrame:SetPoint("BOTTOM", PlayerFrame, "TOP", 30, 2)
-- ComboPointPlayerFrame.Background:SetAlpha(0)
-- ComboPointPlayerFrame:EnableMouse(false)

-- make sure frame stays behind playerframe (druid combo frame gets reset on shift)
if playerClass == "DRUID" then
	ComboPointPlayerFrame:HookScript("OnShow", function(self)
		self:SetFrameLevel(PlayerFrame:GetFrameLevel() - 1)
	end)
end

]]

--Druid Alternate Mana Bar Fix (TAINTS)
-- local t = ALT_MANA_BAR_PAIR_DISPLAY_INFO["DRUID"]
-- t[Enum.PowerType.Energy] = true
-- t[Enum.PowerType.Rage] = true

--Castbar
if isClassic then
    local castBar = _G.CastingBarFrame
    castBar.ignoreFramePositionManager = true
    castBar:SetAttribute("ignoreFramePositionManager", true)
    castBar:ClearAllPoints()
    castBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 155)
else
    _G.TargetFrameSpellBar.TextBorder:Hide()
    _G.FocusFrameSpellBar.TextBorder:Hide()
    _G.PlayerCastingBarFrame.TextBorder:HookScript("OnShow", function(self)
        self:Hide()
    end)
    for i = 1, 5 do
        local bar = _G["Boss" .. i .. "TargetFrameSpellBar"]
        bar.TextBorder:Hide()
    end
end

-- Focus Castbar
-- FocusFrameSpellBar:ClearAllPoints()
-- FocusFrameSpellBar:SetPoint("LEFT", FocusFrame, "RIGHT", 5, 0)
-- FocusFrameSpellBar:SetScale(1.6)

-- hooksecurefunc(FocusFrameSpellBar, "SetPoint", function(self, _, _, _, _, _, stop)
-- if  not stop then
-- FocusFrameSpellBar:ClearAllPoints()
-- FocusFrameSpellBar:SetPoint("LEFT", FocusFrame, "RIGHT", 5, 0, true)
-- end
-- end)

-- Move Tooltip Frame
if isClassic then
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -340, 120)
    end)
end

-- Pet Frame
PetFrame:ClearAllPoints()
-- PetFrame:SetMovable(true)
PetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75)
PetFrame:SetPoint("BOTTOM", PlayerFrame, "TOP", 50, 50)

-- needed for easy frames in retail
if select(4, C_AddOns.GetAddOnInfo("EasyFrames")) then
    local p = CreateFrame("Frame")
    p:SetScript("OnEvent", function()
        PetFrame:EnableMouse(nil)
        p:UnregisterAllEvents()
    end)
    p:RegisterEvent("PLAYER_ENTERING_WORLD")
else
    PetFrame:EnableMouse(nil)
    PetFrame:UnregisterEvent("UNIT_COMBAT")
end

-- PetFrame:SetUserPlaced(true)
-- PetFrame:SetMovable(false)

-- PetFrame:ClearAllPoints()
-- PetFrame:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 60, 0)
-- PetFrame.SetPoint = function() end

-- hooksecurefunc("PetFrame_UpdateAnchoring", function(self, _, _, _, _, _, stop)
-- if not stop then
-- self:ClearAllPoints()
-- self:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 60, 0, true)
-- end
-- end)

if isClassic then
    SLASH_CFRAMES1 = "/cframes"
    SlashCmdList["CFRAMES"] = function(msg)
        if not InCombatLockdown() then
            PlayerFrame:ClearAllPoints()
            TargetFrame:ClearAllPoints()
            if msg == "rogue" then
                PlayerFrame:SetPoint("CENTER", nil, "CENTER", -294, 73)
                TargetFrame:SetPoint("TOP", PlayerFrame, "BOTTOM", 95, 54)
                print("|cFF00A6FFm|rFrames Reset to Rogue layout.")
            elseif msg == "rogue2" then
                PlayerFrame:SetPoint("CENTER", nil, "CENTER", -294, 73)
                TargetFrame:SetPoint("TOP", _G.ComboPointPlayerFrame, "BOTTOM", 50, 17)
                print("|cFF00A6FFm|rFrames Reset to Rogue2 layout.")
            elseif msg == "warlock" or msg == "lock" then
                PlayerFrame:SetPoint("CENTER", nil, "CENTER", -294, 73)
                TargetFrame:SetPoint("TOP", _G.WarlockPowerFrame, "BOTTOM", 50, 17)
                print("|cFF00A6FFm|rFrames Reset to Warlock layout.")
            elseif msg == "healer" then
                PlayerFrame:SetPoint("CENTER", nil, "CENTER", -345, 119)
                TargetFrame:SetPoint("TOP", PlayerFrame, "BOTTOM", 95, 54)
                print("|cFF00A6FFm|rFrames Reset to Healer layout.")
            elseif msg == "2" then
                PlayerFrame:SetPoint("LEFT", nil, "LEFT", 261, 229)
                TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 10, 0)
                print("|cFF00A6FFm|rFrames Reset to 2 layout.")
            else
                PlayerFrame:SetPoint("LEFT", nil, "LEFT", 357, 147)
                TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 0, 0)
                print("|cFF00A6FFm|rFrames Reset to normal layout.")
            end
            PlayerFrame:SetUserPlaced(true)
            TargetFrame:SetUserPlaced(true)
            FocusFrame:ClearAllPoints()
            FocusFrame:SetPoint("CENTER", PlayerFrame, "CENTER", 20, -200)
            -- FocusFrame:SetPoint("CENTER", nil, "CENTER", -200, -35)
            FocusFrame:SetUserPlaced(true)
        end
    end

    SLASH_CBAR1 = "/cbar"
    SlashCmdList["CBAR"] = function()
        if not InCombatLockdown() then
            local a = _G["InterfaceOptionsActionBarsPanelBottomRight"]
            a:Click()
        end
    end
end

--Hide status text unless mouseover
if isClassic then
    for _, v in pairs({ "Pet", "Focus" }) do
        _G[v .. "FrameHealthBar"].cvar = nil
        _G[v .. "FrameManaBar"].cvar = nil
    end

    for _, v in pairs({ "Player" }) do
        _G[v .. "FrameHealthBar"].cvar = nil
        -- _G[v.."FrameManaBar"].cvar = nil
        _G[v .. "FrameManaBarTextLeft"]:SetAlpha(0)
        _G[v .. "FrameManaBarTextRight"]:SetScale(.8)
        _G[v .. "FrameManaBarTextRight"]:ClearAllPoints()
        _G[v .. "FrameManaBarTextRight"]:SetPoint("CENTER", _G.PlayerFrameManaBar)
    end

    for i = 1, 4 do
        _G["PartyMemberFrame" .. i .. "HealthBar"].cvar = nil
        _G["PartyMemberFrame" .. i .. "ManaBar"].cvar = nil
    end
else
    for _, v in pairs({ "PetFrame", "FocusFrame", "TargetFrame" }) do
        _G[v].healthbar.cvar = nil
        _G[v].manabar.cvar = nil
    end

    for _, frame in pairs({ PlayerFrame }) do
        frame.healthbar.cvar = nil
        frame.manabar.LeftText:SetAlpha(0)
        frame.manabar.RightText:SetScale(0.8)
        frame.manabar.RightText:ClearAllPoints()
        frame.manabar.RightText:SetPoint("CENTER", frame.manabar)
    end
end

--Removing ToT / Pet / Focus ToT Debuffs
-- for i=1, 4 do
-- local pet = _G["PetFrameDebuff"..i]
-- local tot = _G["TargetFrameToTDebuff"..i]
-- local ftot = _G["FocusFrameToTDebuff"..i]
-- for _, t in pairs({pet, tot, ftot}) do
-- if t then
-- t:UnregisterAllEvents()
-- t:Hide()
-- t.Show = function() end
-- end
-- end
-- end

--Class icons in portraits sans pets / NPCs / player portrait
-- hooksecurefunc("UnitFramePortrait_Update",function(self)
-- if self.portrait then
-- if UnitIsPlayer(self.unit) and UnitGUID(self.unit)~=UnitGUID("player") then
-- local t = CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
-- if t then
-- self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
-- self.portrait:SetTexCoord(unpack(t))
-- end
-- else
-- self.portrait:SetTexCoord(0,1,0,1)
-- end
-- end
-- end)

--Fade Raid Frames More
-- local group = {
-- 	part = true, -- party, only check char 1 to 4
-- 	raid = true,
-- }

-- hooksecurefunc("CompactUnitFrame_UpdateInRange", function(frame)
-- 	if not group[strsub(frame.displayedUnit, 1, 4)] then return end -- ignore player, nameplates
-- 	local inRange, checkedRange = UnitInRange(frame.displayedUnit)

-- 	if checkedRange and not inRange then
-- 		frame:SetAlpha(0.4)
-- 		frame.background:SetAlpha(0.4)
-- 	else
-- 		frame:SetAlpha(1)
-- 		frame.background:SetAlpha(1)
-- 	end
-- end)

-- Nameplates
--[[
local x = CreateFrame("Frame")
x:HookScript("OnEvent", function()
    if not (IsAddOnLoaded("nPlates")) then
        C_NamePlate.SetNamePlateEnemySize(80, 100)
    end
    C_NamePlate.SetNamePlateFriendlySize(60,30)
    x:UnregisterAllEvents()
end)
x:RegisterEvent("INITIAL_CLUBS_LOADED")
]]

-- local np = CreateFrame("Frame")
-- np:HookScript("OnEvent", function(self, event, unit)
-- if UnitIsFriend("player", unit) then
-- C_NamePlate.GetNamePlateForUnit(unit).UnitFrame.name:SetAlpha(0)
-- end
-- end)
-- np:RegisterEvent("NAME_PLATE_UNIT_ADDED")

--Combat Indicator
if playerClass == "ROGUE" then
    local CTT = CreateFrame("Frame")
    CTT.unit = "target"
    CTT:SetParent(TargetFrame)
    CTT:SetPoint("RIGHT", TargetFrame, -15)
    CTT:SetSize(26, 26)
    CTT.t = CTT:CreateTexture(nil, "BORDER")
    CTT.t:SetAllPoints()
    CTT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    CTT:Hide()

    local CFT = CreateFrame("Frame")
    CFT.unit = "focus"
    CFT:SetParent(FocusFrame)
    CFT:SetPoint("RIGHT", FocusFrame, -15)
    CFT:SetSize(26, 26)
    CFT.t = CFT:CreateTexture(nil, "BORDER")
    CFT.t:SetAllPoints()
    CFT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    CFT:Hide()

    local function FrameOnUpdate(self) if UnitAffectingCombat(self.unit) then self:Show() else self:Hide() end end

    CFT:SetScript("OnUpdate", function(self) FrameOnUpdate(CFT) end)
    CTT:SetScript("OnUpdate", function(self) FrameOnUpdate(CTT) end)
end

--Hide talking head
if isClassic then
    local function HookTalkingHead()
        hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
            _G.TalkingHeadFrame:Hide()
        end)
    end

    if _G.TalkingHeadFrame then
        HookTalkingHead()
    else
        hooksecurefunc('TalkingHead_LoadUI', HookTalkingHead)
    end
end

local frameColor = 0.3
local barColor = 0.5
local frames

local function CreateFrameList()
    if isClassic then
        frames = {
            _G.PlayerFrameTexture,
            _G.PlayerFrameAlternateManaBarBorder,
            _G.PlayerFrameAlternateManaBarRightBorder,
            _G.PlayerFrameAlternateManaBarLeftBorder,
            _G.TargetFrameTextureFrameTexture,
            _G.TargetFrameToTTextureFrameTexture,
            _G.PetFrameTexture,
            _G.FocusFrameTextureFrameTexture,
            _G.FocusFrameToTTextureFrameTexture,
            _G.PartyMemberFrame1Texture,
            _G.PartyMemberFrame2Texture,
            _G.PartyMemberFrame3Texture,
            _G.PartyMemberFrame4Texture,
            _G.PartyMemberFrame1PetFrameTexture,
            _G.PartyMemberFrame2PetFrameTexture,
            _G.PartyMemberFrame3PetFrameTexture,
            _G.PartyMemberFrame4PetFrameTexture,
            _G.Boss1TargetFrameTextureFrameTexture,
            _G.Boss2TargetFrameTextureFrameTexture,
            _G.Boss3TargetFrameTextureFrameTexture,
            _G.Boss4TargetFrameTextureFrameTexture,
            _G.Boss5TargetFrameTextureFrameTexture,
            _G.ComboPointPlayerFrame.Background,
            _G.PVEFrame,
            _G.FriendsFrame,
            _G.CharacterFrame,
            _G.MinimapBorder,
            _G.QueueStatusMinimapButtonBorder,
            _G.MiniMapTrackingButtonBorder,
            _G.MinimapBorderTop,
            _G.GameTooltip,
            _G.CastingBarFrame.Border,
            _G.TargetFrameSpellBar.Border,
            _G.FocusFrameSpellBar.Border,
            _G.MiniMapMailBorder,
            _G.GameTimeTexture,
            _G.LibDBIconTooltip,
            _G.DropDownList1MenuBackdrop,
            _G.QueueStatusFrame,
            _G.SpellBookFrame,
        }
    else
        frames = {
            PlayerFrame.PlayerFrameContainer.FrameTexture,
            PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
            TargetFrame.TargetFrameContainer.FrameTexture,
            FocusFrame.TargetFrameContainer.FrameTexture,
            PlayerFrame.PlayerFrameContainer.VehicleFrameTexture,
            _G.PetFrameTexture,
            _G.PlayerFrameAlternateManaBarBorder,
            _G.PlayerFrameAlternateManaBarRightBorder,
            _G.PlayerFrameAlternateManaBarLeftBorder,
            _G.TargetFrameToT.FrameTexture,
            _G.FocusFrameToT.FrameTexture,
            _G.PlayerCastingBarFrame.Border,
            _G.TargetFrameSpellBar.Border,
            _G.FocusFrameSpellBar.Border,
            _G.GameTooltip,
            _G.MinimapCompassTexture,
            _G.PVEFrame,
            _G.CharacterFrame,
            _G.FriendsFrame,
            _G.LibDBIconTooltip,
            _G.QueueStatusFrame,
            _G.StatusTrackingBarManager.BottomBarFrameTexture,
            _G.StatusTrackingBarManager.TopBarFrameTexture,
            _G.Boss1TargetFrame.TargetFrameContainer.FrameTexture,
            _G.Boss2TargetFrame.TargetFrameContainer.FrameTexture,
            _G.Boss3TargetFrame.TargetFrameContainer.FrameTexture,
            _G.Boss4TargetFrame.TargetFrameContainer.FrameTexture,
            _G.Boss5TargetFrame.TargetFrameContainer.FrameTexture,
            _G.Boss1TargetFrameSpellBar.Border,
            _G.Boss2TargetFrameSpellBar.Border,
            _G.Boss3TargetFrameSpellBar.Border,
            _G.Boss4TargetFrameSpellBar.Border,
            _G.Boss5TargetFrameSpellBar.Border,
            _G.SpellBookFrame,
            _G.CollectionsJournal,
        }
    end
end

local function DarkenFrame(frame)
    if frame then
        if frame.SetDesaturated then
            frame:SetDesaturated(true)
        end

        if frame.NineSlice then
            frame.NineSlice:SetBorderColor(frameColor, frameColor, frameColor, 1)
        else
            frame:SetVertexColor(frameColor, frameColor, frameColor, 1)
        end
    end
end

local darkenFrameEvents = CreateFrame("Frame")

darkenFrameEvents:SetScript("OnEvent", function(self, event, ...)
    if event == "GUILD_NEWS_UPDATE" then
        DarkenFrame(_G.CommunitiesFrame)
        self:UnregisterEvent(event)
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name == "Blizzard_Collections" then
            DarkenFrame(_G.CollectionsJournal)
            DarkenFrame(_G.MountJournalSummonRandomFavoriteButtonBorder)
            self:UnregisterEvent(event)
        end
    end
end)

darkenFrameEvents:RegisterEvent("GUILD_NEWS_UPDATE")
darkenFrameEvents:RegisterEvent("ADDON_LOADED")

--Darken Frames
local function DarkenFrames()
    CreateFrameList()

    for _, t in pairs(frames) do
        DarkenFrame(t)
    end

    -- Darken ActionBars
    for _, bar in pairs({
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarLeftButton",
        "MultiBarRightButton",
        "StanceButton",
        "PetActionButton",
        "BonusActionButton",
        "PossessButton1",
        "PossessButton2",
        "PossessButton3",
        "PossessButton4",
        "MultiBar5Button",
        "MultiBar6Button",
        "MultiBar7Button",
        "MultiBar8Button",
    }) do
        for i = 1, 12 do
            local btex = _G[bar .. i .. "NormalTexture"]
            local fbg = _G[bar .. i .. "FloatingBG"]
            local btex2 = _G[bar .. i .. "NormalTexture2"]

            if btex then
                btex:SetDesaturated(true)
                btex:SetVertexColor(barColor, barColor, barColor, 1)
                hooksecurefunc(btex, "SetVertexColor", function(self, r, g, b)
                    if r ~= barColor or g ~= barColor or b ~= barColor then
                        self:SetVertexColor(barColor, barColor, barColor, 1)
                    end
                end)
            end

            if btex2 then
                btex2:SetDesaturated(true)
                btex2:SetVertexColor(barColor, barColor, barColor, 1)
            end

            if fbg then
                fbg:Hide()
            end
        end
    end
end

-- Darken LibDB borders
local function DarkenChildren(frame)
    if frame:IsForbidden() then return end

    for i = 1, select("#", frame:GetChildren()) do
        local child = select(i, frame:GetChildren())

        if child:IsForbidden() then return end

        local childName = child:GetName()

        if childName and string.match(childName, "LibDB") then
            -- if child:GetNumChildren() > 0 then
            -- DarkenChildren(child)
            -- end

            for j = 1, select("#", child:GetRegions()) do
                local region = select(j, child:GetRegions())
                if region:IsForbidden() then return end
                if region:IsObjectType("Texture") and not region.UpdateCoord then
                    region:SetDesaturated(true)
                    if region.NineSlice then
                        region.NineSlice:SetBorderColor(frameColor, frameColor, frameColor, 1)
                    else
                        region:SetVertexColor(frameColor, frameColor, frameColor, 1)
                    end
                end
            end
        end
    end
end

C_Timer.After(0, function()
    C_Timer.After(0, function()
        DarkenFrames()
        DarkenChildren(_G.Minimap)
    end)
end)

-- Keybinds
SLASH_KB1 = "/kb"
SlashCmdList["KB"] = function(msg)
    _G.QuickKeybindFrame:Show()
end

-- local LockShowCountdownNumbers;
-- do
--     local function ReshowCountdownNumbers(cooldown)
--         -- Call the real function still in the frame's metatable
--         getmetatable(cooldown).__index.SetHideCountdownNumbers(cooldown, false)
--     end

--     function LockShowCountdownNumbers(cooldown, lock)
--         if lock then
--             -- We use hooksecurefunc() to prevent taint
--             -- A quirk of this is it copies the original function from the metatable and stores our hooked version in the frame's actual table
--             -- This still performs what we want and setting the entry to nil will restore the original operation
--             hooksecurefunc(cooldown, "SetHideCountdownNumbers", ReshowCountdownNumbers)
--         else
--             cooldown.SetHideCountdownNumbers = nil; --   Clear table entry, allowing fallback to frame metatable
--         end
--     end
-- end

-- local f = CreateFrame("Button", nil, UIParent, "CompactAuraTemplate")
-- f:SetSize(40, 40)
-- f:SetPoint("CENTER", 0, 0)
-- f:SetFrameStrata("HIGH")

-- f.icon:SetTexture("Interface\\Icons\\spell_holy_divineillumination")

-- LockShowCountdownNumbers(f.cooldown, true)
-- f.cooldown:SetHideCountdownNumbers(true)

-- f:SetScript("OnClick", function(self)
--     CooldownFrame_Set(self.cooldown, GetTime(), 10, 1)
-- end)

-- local timeElapsed = 0
-- f.cooldown:SetScript("OnUpdate", function(self, elapsed)
--     timeElapsed = timeElapsed + elapsed
--     if timeElapsed > 0.2 then
--         local start, dur = self:GetCooldownTimes()
--         local timeLeft = start / 1000 + dur / 1000 - GetTime()

--         if timeLeft >= 1 then
--             self.text:SetText(format("%d", timeLeft))
--         else
--             self.text:SetText("")
--         end

--         timeElapsed = 0
--     end
-- end)

--[[
hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
    local name = frame:GetName().."Buff"
    for i = 4, 6 do
        local buff = _G[name..i] or CreateFrame("Button", name..i, frame, "CompactBuffTemplate")
        buff:ClearAllPoints()
        if i == 4 then
            buff:SetPoint("BOTTOMRIGHT", _G[name..i-3], "TOPRIGHT")
        else
            buff:SetPoint("BOTTOMRIGHT", _G[name..i-1], "BOTTOMLEFT")
        end
        -- local options = DefaultCompactUnitFrameSetupOptions
        -- local componentScale = min(options.height / 36, options.width / 72)
        -- local size = 11 * componentScale
        local orig = _G[name .. 1]
        local size = orig:GetSize()
        buff:SetSize(size, size)
    end
    CompactUnitFrame_SetMaxBuffs(frame, 6)
end)
]]

EventRegistry:RegisterFrameEventAndCallback('PLAYER_LOGIN', function()
    local activities = C_PerksActivities.GetTrackedPerksActivities()
    if activities and activities.trackedIDs then
        for _, id in next, activities.trackedIDs do
            C_PerksActivities.RemoveTrackedPerksActivity(id)
        end
    end
end)

-- Temporary fix for 10.2.6 chat channel bug
-- EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function()
--     for i = 1, NUM_CHAT_WINDOWS do
--         local frame = _G["ChatFrame" .. i]

--         if frame and frame.isDocked then
--             if i == 1 then
--                 ChatFrame_RemoveChannel(frame, "Services")
--             elseif frame.name == "services" then
--                 ChatFrame_RemoveChannel(frame, "General")
--                 ChatFrame_RemoveChannel(frame, "Trade")
--                 ChatFrame_RemoveChannel(frame, "LocalDefense")
--             else
--                 ChatFrame_RemoveChannel(frame, "General")
--                 ChatFrame_RemoveChannel(frame, "Trade")
--                 ChatFrame_RemoveChannel(frame, "LocalDefense")
--                 ChatFrame_RemoveChannel(frame, "Services")
--             end
--         end
--     end
-- end)
