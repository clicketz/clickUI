local Frame, FrameEvents = CreateFrame('Frame'), {}

local block = {
	['TradeSkillMaster_Destroying'] = 'TSMDestroyingFrame',
	['Easy_Obliterate']							= 'ObliterumForgeFrame'
}

Frame.ready = false
Frame.group = false
Frame.count = 0
Frame.items = {}

local method, rarity, locked, treshold
function FrameEvents:LOOT_READY(...)
	if Frame.ready then
		return
	end
	
	for k, v in pairs(block) do
		if IsAddOnLoaded(k) and _G[v]:IsVisible() then
			return
		end
	end
	
	if (GetCVar('autoLootDefault') == '1' and not IsModifiedClick('AUTOLOOTTOGGLE')) or (GetCVar('autoLootDefault') ~= '1' and IsModifiedClick('AUTOLOOTTOGGLE')) then
		Frame.ready = true
		Frame.count = 5
		
		if IsInGroup() then
			method = GetLootMethod()
			Frame.group = method == 'master' and true or false
		end
		
		if #Frame.items ~= 0 then
			for i = #Frame.items, 1, -1 do
				table.remove(Frame.items, i)
			end
		end
		for i = GetNumLootItems(), 1, -1 do
			_, _, _, rarity, locked = GetLootSlotInfo(i)
			threshold = GetLootThreshold()
			
			if locked ~= nil and not locked then
				if (Frame.group and rarity < threshold) or not Frame.group then
					table.insert(Frame.items, i)
				end
			end
		end
	end
end

for k in pairs(FrameEvents) do
	Frame:RegisterEvent(k)
end
Frame:SetScript('OnEvent', function(self, event, ...)
	FrameEvents[event](self, ...)
end)

Frame:SetScript('OnUpdate', function(self)
	if not Frame.ready or Frame.count <= 0 then
		return
	end
	
	Frame.count = Frame.count - 1
	for k, v in pairs(Frame.items) do
		LootSlot(v)
	end
	
	if Frame.count <= 0 or GetNumLootItems() == 0 then
		Frame.ready = false
		for i = #Frame.items, 1, -1 do
			table.remove(Frame.items, i)
		end
		CloseLoot()
	end
end)