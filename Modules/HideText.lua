local hkey = CreateFrame("Frame")
local str_match, pairs = string.match, pairs

--------------
-- Bars
--------------
local bars = {
    "Action",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarRight",
    "MultiBarLeft",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
}

--------------
-- Hooks
--------------
do
    for _, bar in pairs(bars) do
        for btnnum = 1, 12 do
            if _G[bar .. "Button" .. btnnum] then
                local hotkey = _G[bar .. "Button" .. btnnum .. "HotKey"]
                if hotkey then
                    local name = _G[bar .. "Button" .. btnnum .. "Name"]
                    hotkey:HookScript("OnShow", function(self)
                        if not str_match(hotkey:GetText(), "^[%w-%p]+$") then
                            self:Hide()
                        else
                            self:SetShown(CUI_TEXT_SHOW)
                        end
                        name:SetAlpha(CUI_TEXT_SHOW and 1 or 0)
                    end)
                end
            end
        end
    end
end

--------------
-- Core Func
--------------
local function UpdateText()
    for _, bar in pairs(bars) do
        for btnnum = 1, 12 do
            if _G[bar .. "Button" .. btnnum] then
                local hotkey = _G[bar .. "Button" .. btnnum .. "HotKey"]
                if hotkey then
                    if not str_match(hotkey:GetText(), "^[%w-%p]+$") then
                        hotkey:Hide()
                    else
                        hotkey:SetShown(CUI_TEXT_SHOW)
                    end
                    _G[bar .. "Button" .. btnnum .. "Name"]:SetAlpha(CUI_TEXT_SHOW and 1 or 0)
                end
            end
        end
    end
end

--------------
-- Events
--------------
local function EventHandler()
    CUI_TEXT_SHOW = CUI_TEXT_SHOW or false
    UpdateText()
end

hkey:SetScript("OnEvent", EventHandler)
hkey:RegisterEvent("PLAYER_ENTERING_WORLD")

--------------
-- Slash Cmd
--------------
local function Slash()
    CUI_TEXT_SHOW = not CUI_TEXT_SHOW
    UpdateText()
end

SLASH_CUITEXT1 = "/ctext"
SlashCmdList["CUITEXT"] = Slash
