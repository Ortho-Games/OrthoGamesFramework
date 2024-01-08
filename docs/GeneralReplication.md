# Introduction

General replication is an important problem to solve in any multi-player game system. Networking is the bane of many a programmer and its important we have good protocols for getting our data to the right places. In our system we have opted for a case by case basis because every component is different and needs to be treated generally different.

# Overview

The general file structure for the system involves components which are meant to store data and systems which modify/read data. In our case we need a way to replicate entire entities and entire components. Replication is its own problem so it should be treated as such, in that vein we have decided that Replication fits more into the category of Systems but not in the more general use case of it. Therefore we will have a system on both client and server inside of a Replication subfolder of Systems on both client and server respectively, from there the networking functionality will be handled.

Summary:
Replication is a System inside of a Replication folder per component/entity inside
Local>Systems>Replication

One thing that should be noted is that using World.entity() on client or server results in a number that counts up per world. That means if we want client and world entities to not overwrite each other when replicating its important that we multiply the entity number by -1 to get the correct client (from server) entity as distinct from a client made entity. In rare cases the same operation should be performed when going client -> server.

# First Example, Replication of Model Component

Example Replication of Models, These are ordered in the path of data from server to client:

Server>Components>ModelComponent.lua

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local LemonSignal = require(Globals.Packages.LemonSignal)
local World = require(Globals.Shared.Modules.World)

local ModelComponent = {}

-- Added/Removed Signals
ModelComponent.addedSignal = LemonSignal.new()
ModelComponent.removeSignal = LemonSignal.new()

function ModelComponent:add(entity, model)
	-- insert constructor for component here
	if typeof(entity) == "Instance" and workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved then
		error(
			"You created a Model Component with a instance entity and a model behavior set to improved, there will be problems with replication!"
		)
	end

  -- Initial Replication
	self.addedSignal:Fire(entity, model)

	return model
end

function ModelComponent:remove(entity, model)
	model:Destroy()
end

return World.factory(ModelComponent)
```

Server>Systems>Replication>ModelReplication.lua

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)

return Schedules.init.job(function()
	local added = Net:RemoteEvent("ModelReplicationAdded")

  -- Receiving Signal Server <-> Server
	ModelComponent.addedSignal:Connect(function(entity: number, model)
		-- insert ser here
    -- send over a NEGATIVE entity so the receiving client signal knows it as a server entity.
		added:FireAllClients(-entity, model)
	end)

	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways.
end)
```

Client>Systems>Replication>ModelReplication.lua

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)

return Schedules.init.job(function()
	Net:Connect("ModelReplicationAdded", function(entity, model)
    -- insert deserialization here.
		ModelComponent:add(entity, model)
	end)

	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways via events.
end)
```

Client>Components>Replication>ModelReplication.lua

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local World = require(Globals.Shared.Modules.World)

local ModelComponent = {}
ModelComponent.re = Net:RemoteEvent("ModelComponentReplication")

function ModelComponent:add(entity, model)
	-- insert constructor for component here
	if typeof(entity) == "Instance" and workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved then
		warn(
			"You created a Model Component with a instance entity and a model behavior set to improved, there will be problems with replication!"
		)
	end

	model.Destroying:Once(function()
		self:remove(entity)
	end)

	return model
end

function ModelComponent:remove(entity, model)
	if model then
		model:Destroy()
	end
end

Net:Connect("ModelComponentReplication", function() end)

return World.factory(ModelComponent)
```

# Second Example, Money Replication
