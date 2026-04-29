local alertAmount = 14000

local HonorAlertFrame = CreateFrame("Frame", "HighHonorAlertFrame", UIParent)
HonorAlertFrame:SetSize(300, 50)
HonorAlertFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
HonorAlertFrame:Hide()

local alertIcon = HonorAlertFrame:CreateTexture(nil, "ARTWORK")
alertIcon:SetSize(32, 32)
alertIcon:SetPoint("LEFT", HonorAlertFrame, "LEFT", 0, 0)
alertIcon:SetTexture(1044077)

local alertText = HonorAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
alertText:SetPoint("LEFT", alertIcon, "RIGHT", 10, 0)
alertText:SetText("YOUR HONOR IS OVER " .. alertAmount)

local function TryDisplayHonorAlert()
    local inInstance = IsInInstance()
    if inInstance then
        HonorAlertFrame:Hide()
        return
    end

    local currentHonor = 0

    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(1792)
        if info and info.quantity then
            currentHonor = info.quantity
            if info.iconFileID then
                alertIcon:SetTexture(info.iconFileID)
            end
        elseif GetHonorCurrency then
            currentHonor = GetHonorCurrency()
        end
    elseif GetHonorCurrency then
        currentHonor = GetHonorCurrency()
    end

    if currentHonor > alertAmount then
        HonorAlertFrame:Show()
    else
        HonorAlertFrame:Hide()
    end
end

EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", TryDisplayHonorAlert)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", TryDisplayHonorAlert)
