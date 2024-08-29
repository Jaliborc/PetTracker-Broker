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
	icon = 'Interface/Addons/PetTracker/art/logo',
	type = 'data source',
	label = PETS,
}))

local LOCALE = GetLocale()
local NONE_HERE = 'No known species in this zone.'

if LOCALE == 'deDE' then
    NONE_HERE = 'Keine bekannte Spezies in dieser Zone.'
elseif LOCALE == 'frFR' then
    NONE_HERE = 'Aucune espèce connue dans cette zone.'
elseif LOCALE == 'esES' or LOCALE == 'esMX' then
    NONE_HERE = 'No hay especies conocidas en esta zona.'
elseif LOCALE == 'itIT' then
    NONE_HERE = 'Nessuna specie conosciuta in questa zona.'
elseif LOCALE == 'ptBR' or LOCALE == 'ptPT' then
    NONE_HERE = 'Nenhuma espécie conhecida nesta zona.'
elseif LOCALE == 'ruRU' then
    NONE_HERE = 'В этой зоне нет известных видов.'
elseif LOCALE == 'koKR' then
    NONE_HERE = '이 지역에는 알려진 종이 없습니다.'
elseif LOCALE == 'zhCN' then
    NONE_HERE = '该区域没有已知物种。'
elseif LOCALE == 'zhTW' then
    NONE_HERE = '此區域中無已知物種。'
end


--[[ Startup ]]--

function Broker:OnEnable()
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
	if self.tracker:IsShown() then
		self.tip:SetSize(265, self.tracker:GetHeight())
	else
		self.tip:SetText(NONE_HERE)
	end
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
