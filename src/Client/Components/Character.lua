local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local Character = {}

function Character:add(_, humanoid: Humanoid, root: BasePart, rootAttachment: Attachment)
	local component = {
		janitor = Janitor.new(),
		humanoid = humanoid,
		root = root,
		rootAttachment = rootAttachment,
	}

	export type Character = typeof(component)
	return component
end

return Globals.World.factory(Character)
