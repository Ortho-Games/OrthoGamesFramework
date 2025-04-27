local Players = game:GetService("Players")
return function(remoteEvent: RemoteEvent, ignore: Player, ...)
	for _, player in Players:GetPlayers() do
		if player == ignore then continue end
		remoteEvent:FireClient(player, ...)
	end
end
