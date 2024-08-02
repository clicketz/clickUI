local cf = CreateFrame("Frame")
cf:RegisterEvent("PLAYER_LOGIN")
cf:SetScript("OnEvent", function(self, event)
    LossOfControlFrame:SetScale(.7)
    --Center Icon
    select(4, LossOfControlFrame:GetRegions()):ClearAllPoints()
    select(4, LossOfControlFrame:GetRegions()):SetPoint("CENTER", 0, 0)
    select(4, LossOfControlFrame:GetRegions()).SetPoint = function() end
    --Background Shadow
    select(1, LossOfControlFrame:GetRegions()):SetAlpha(0)
    --Red Frame
    select(2, LossOfControlFrame:GetRegions()):SetAlpha(0)
    select(3, LossOfControlFrame:GetRegions()):SetAlpha(0)
    LossOfControlFrame.RedLineBottom:SetAlpha(0)
    LossOfControlFrame.RedLineTop:SetAlpha(0)
    --Effect Text
    select(5, LossOfControlFrame:GetRegions()):ClearAllPoints()
    select(5, LossOfControlFrame:GetRegions()):SetPoint("TOP", select(4, LossOfControlFrame:GetRegions()), "BOTTOM")
    --Countdown Text
    select(2, LossOfControlFrame:GetChildren()):SetAlpha(0)

    -- LossOfControlFrame:ClearAllPoints()
    -- LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- select(1, LossOfControlFrame:GetRegions()):SetAlpha(0)
    -- select(2, LossOfControlFrame:GetRegions()):SetAlpha(0)
    -- select(3, LossOfControlFrame:GetRegions()):SetAlpha(0)
end)
