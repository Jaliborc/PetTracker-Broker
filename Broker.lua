--[[
	Copyright 2013-2024 João Cardoso
	All Rights Reserved
--]]

local Broker = PetTracker:NewModule('Broker', LibStub('LibDataBroker-1.1'):NewDataObject('PetTracker', {
	tocname = 'PetTracker',
	icon = 'Interface/Addons/PetTracker/art/logo',
	type = 'data source',
	label = PETS,
}))


--[[ Startup ]]--

function Broker:OnLoad()
	self:RegisterSignal('COLLECTION_CHANGED', 'Update')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update')

	self.tip = CreateFrame('GameTooltip', 'PetTrackerBrokerTip', UIParent, 'GameTooltipTemplate')
	self.tracker = PetTracker.Tracker(self.tip)
	self.tracker:SetPoint('TOPLEFT', 15, -30)
	self.tracker.Update = function(tracker)
		if self.tip:IsVisible() then
			self.tracker:GetClass().Update(tracker)
			self:Resize()
		end
	end
end

function Broker:Update()
	local progress = PetTracker.Maps:GetCurrentProgress()
	local owned = 0

	for i = PetTracker.MaxQuality, 1, -1 do
		owned = owned + progress[i].total
	end

	self.text = owned .. '/' .. progress.total
	if self.tracker:IsVisible() then
		self.tracker:Update()
	end
end

function Broker:Resize()
	self.tip:SetSize(265, self.tracker:GetHeight())
end


--[[ Interaction ]]--

function Broker:OnEnter()
	Broker.tip:ClearAllPoints()
	Broker.tip:SetOwner(self, self:GetBottom() < UIParent:GetHeight() / 2 and 'ANCHOR_TOP' or 'ANCHOR_BOTTOM')
	Broker.tip:SetText(PETS)
	Broker.tip:Show()
	Broker:Resize()
end

function Broker:OnLeave()
	Broker.tip:Hide()
end

function Broker:OnClick(button)
	if button == 'RightButton' then
		PetTracker.ToggleOption('zoneTracker')
	else
		Broker:OnLeave()
		Broker.tracker.Menu(self)
	end
end
