local moving
hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(self)
	if moving then
		return
	end
	moving = true
	self:SetMovable(true)
	self:SetUserPlaced(true)
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOM")
	-- self:SetScale(1.1) -- optional
	self:SetWidth(260) -- optional
	self:SetHeight(550) -- optional
	self:SetMovable(false)
	moving = nil
end)