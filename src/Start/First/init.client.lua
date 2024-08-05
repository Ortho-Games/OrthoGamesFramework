local ReplicatedFirst = game:GetService("ReplicatedFirst")
ReplicatedFirst:RemoveDefaultLoadingScreen()

local LoadScreen = require(ReplicatedFirst.First.LoadScreen)
LoadScreen.startLoadScreen()
