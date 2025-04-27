local GroupService = game:GetService("GroupService")
return function(UserId: number): {
	{
		Name: string,
		Id: number,
		EmblemUrl: string,
		EmblemId: number,
		Rank: number,
		Role: string,
		IsPrimary: boolean,
		IsInClan: boolean,
	}
}
	local Success, GroupInfo = pcall(function()
		return GroupService:GetGroupsAsync(UserId)
	end)
	if Success then
		return GroupInfo
	else
		return {}
	end
end
