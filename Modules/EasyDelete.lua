local cf = CreateFrame("Frame")
cf:RegisterEvent("PLAYER_LOGIN")
cf:SetScript("OnEvent", function(self, event)

	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(s) s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING) end)

end)