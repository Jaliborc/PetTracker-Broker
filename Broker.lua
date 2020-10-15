--[[
Copyright 2013 João Cardoso
PetTracker Broker is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this addon do not give permission to
redistribute and/or modify it.

This addon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the addon. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.

This file is part of PetTracker Broker.
--]]

local Broker = PetTracker:NewModule('Broker', LibStub('LibDataBroker-1.1'):NewDataObject('PetTracker', {
	tocname = 'PetTracker',
	type = 'data source',
	icon = 'Interface/Icons/Tracking_WildPet',
	label = PETS,
}))


--[[ Startup ]]--

function Broker:OnEnable()
	self:RegisterSignal('COLLECTION_CHANGED', 'Update')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update')

	self.tip = CreateFrame('GameTooltip', 'PetTrackerBrokerTip', UIParent, 'GameTooltipTemplate')
	self.tracker = PetTracker.Tracker(self.tip)
	self.tracker.MaxEntries = 20
	self.tracker:SetPoint('TOPLEFT', 15, -30)
	self.tracker.Anchor:SetPoint('TOPLEFT')
	self.tracker.AddSpecies = function(tracker)
		self.tracker:GetClass().AddSpecies(tracker)
		self:Resize()
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
	Broker.tip:SetOwner(self, self:GetBottom() < UIParent:GetHeight() / 2  and 'ANCHOR_TOP' or 'ANCHOR_BOTTOM')
	Broker.tip:SetText(PETS)
	Broker.tip:Show()
	Broker:Resize()
end

function Broker:OnLeave()
	Broker.tip:Hide()
end

function Broker:OnClick(button)
	if button == 'RightButton' then
		Broker:OnLeave()
		Broker.tracker.ToggleDropdown(self)
	else
		Broker.tracker:Toggle()
	end
end
