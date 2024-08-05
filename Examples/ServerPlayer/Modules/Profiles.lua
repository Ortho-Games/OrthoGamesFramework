local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local ProfileService =
	require(ServerScriptService.ServerPackages.ProfileService)

local Profiles = {}
local ProfileTemplates = {}
local ProfileStores =
	{} :: { [string]: ProfileService.ProfileStore<any, any, any> }

Profiles.defaultPlayerStore = "PlayerData"

function Profiles.addDefaultData(
	profileStoreName: string,
	id: string,
	defaultData: { [string]: any }
): ()
	if not ProfileTemplates[profileStoreName] then
		ProfileTemplates[profileStoreName] = {}
	end
	ProfileTemplates[profileStoreName][id] = defaultData
end

function Profiles.getProfileStore(
	profileStoreName: string
): ProfileService.ProfileStore<any, any, any>
	if not ProfileStores[profileStoreName] then
		local template = ProfileTemplates[profileStoreName]
		if not template then
			error(`No profile template exists with name "{profileStoreName}"`)
		end

		ProfileStores[profileStoreName] =
			ProfileService.GetProfileStore(profileStoreName, template)
		warn("Profiles", profileStoreName, template)
	end

	return ProfileStores[profileStoreName]
end

return Profiles
