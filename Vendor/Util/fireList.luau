return function(remoteEvent: RemoteEvent, players: { Player }, ...)
	for _, player in players do
		remoteEvent:FireClient(player, ...)
	end
end
