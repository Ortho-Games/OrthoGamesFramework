local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LightMachine = {}
LightMachine.__index = LightMachine

local AliasToName = {
	Lighting = {
		EnvironmentDiffuseScale = "EnvDiffuse",
		EnvironmentSpecularScale = "EnvSpecular",
		ClockTime = "Time1",
		GeographicLatitude = "Time2",
	},
}

local PropertyNames = {
	Lighting = {
		"Ambient",
		"Brightness",
		"ColorShift_Top",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"ClockTime",
		"GeographicLatitude",
		"FogColor",
		"FogEnd",
		"ExposureCompensation",
		"OutdoorAmbient",
		"GlobalShadows",
	},

	Atmosphere = {
		"Color",
		"Decay",
		"Glare",
		"Haze",
	},

	Sky = {
		"CelestialBodiesShown",
		"MoonAngularSize",
		"MoonTextureId",
		"SkyboxBk",
		"SkyboxDn",
		"SkyboxFt",
		"SkyboxLf",
		"SkyboxRt",
		"SkyboxUp",
		"StarCount",
		"SunAngularSize",
		"SunTextureId",
	},

	Bloom = {
		"Enabled",
		"Intensity",
		"Size",
		"Threshold",
	},

	ColorCorrection = {
		"Brightness",
		"Contrast",
		"Enabled",
		"Saturation",
		"TintColor",
	},

	SunRays = {
		"Enabled",
		"Intensity",
		"Spread",
	},
}

local tweenableValues = {
	number = true,
	Color3 = true,
}

local function CompileLightingPresetMemo(self, lightingPreset: Instance?, isDefault: boolean?)
	if not lightingPreset then return self._defaultCompiledPreset end
	local compiledParent = lightingPreset:FindFirstChild("Parent") :: ObjectValue?
	compiledParent = if not isDefault
		then CompileLightingPresetMemo(self, compiledParent and compiledParent.Value)
		else {}

	local compiledPreset = Global.Util.filter_map(compiledParent, function(itemName, itemProperties)
		return setmetatable({}, { __index = itemProperties })
	end)

	for itemName, item in self.Items do
		local propertyNames = PropertyNames[itemName]

		local presetItem = if itemName == "Lighting"
			then lightingPreset
			else lightingPreset:FindFirstChild(itemName)
		compiledPreset[itemName] = if presetItem then {} else false
		if not presetItem then continue end

		for _, propertyName in propertyNames do
			local propertyAlias = AliasToName[itemName] and AliasToName[itemName][propertyName]
				or propertyName

			local value
			local checkStatus = presetItem:GetAttribute(propertyAlias)
			if itemName == "Lighting" then
				value = lightingPreset:GetAttribute(propertyAlias)
			elseif checkStatus == nil or checkStatus == true then
				pcall(function()
					value = presetItem[propertyAlias]
				end)
			end

			compiledPreset[itemName][propertyName] = value
		end
	end

	return compiledPreset
end

local _lightMachine
function LightMachine.new(defaultPreset: Instance)
	if _lightMachine then
		_lightMachine:SetDefaultPreset(defaultPreset)
		return _lightMachine
	end

	local janitor = Janitor.new()

	local items = {
		Lighting = Lighting,
		Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			or janitor:Add(Instance.new("Atmosphere", Lighting), "Destroy"),
		Sky = Lighting:FindFirstChildOfClass("Sky")
			or janitor:Add(Instance.new("Sky", Lighting), "Destroy"),
		Bloom = Lighting:FindFirstChildOfClass("BloomEffect")
			or janitor:Add(Instance.new("BloomEffect", Lighting), "Destroy"),
		ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
			or janitor:Add(Instance.new("ColorCorrectionEffect", Lighting), "Destroy"),
		SunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
			or janitor:Add(Instance.new("SunRaysEffect", Lighting), "Destroy"),
	}

	local self = setmetatable({
		Items = items,
		Janitor = janitor,
		_locks = Global.Util.filter_map_dict(items, function()
			return {}
		end),
		_lightingPreset = nil,
		_lightingData = nil,
	}, LightMachine)

	_lightMachine = self
	_lightMachine:SetDefaultPreset(defaultPreset)

	return self
end

function LightMachine:Destroy()
	_lightMachine = nil
	self.Janitor:Destroy()
	table.clear(self)
end

function LightMachine:SetDefaultPreset(defaultPreset: Instance)
	self._defaultCompiledPreset = CompileLightingPresetMemo(self, defaultPreset, true)
	self:SetLighting(self._lightingPreset)
end

function LightMachine:SetLighting(lightingPreset: Instance?, tweenInfo: TweenInfo?)
	self._lightingPreset = lightingPreset
	self._lightingData = CompileLightingPresetMemo(self, lightingPreset)

	for itemName, item in self.Items do
		if next(self._locks[itemName]) then continue end

		if itemName ~= "Lighting" then
			if not self._lightingData[itemName] then
				item.Parent = game
				warn(item)
				continue
			else
				item.Parent = Lighting
				print(item)
			end
		end

		local tweenable = Global.Util.filter_map_dict(
			self._lightingData[itemName],
			function(_, value): string
				return tweenableValues[typeof(value)] and value
			end
		)

		local untweenable = Global.Util.filter_map_dict(
			self._lightingData[itemName],
			function(k, value): string
				return tweenable[k] == nil and value
			end
		)

		local tween: Tween =
			TweenService:Create(self.Items[itemName], tweenInfo or TweenInfo.new(0), tweenable)
		self.Janitor:Add(tween, "Cancel", tween):Play()
		self.Janitor:Add(
			tween.Completed:Once(function()
				self.Janitor:Remove(tween)
			end),
			"Disconnect"
		)

		for propName, propValue in untweenable do
			pcall(function()
				(item :: any)[propName] = propValue
			end)
		end
	end
end

return LightMachine
