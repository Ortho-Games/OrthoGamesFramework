local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local InputList = {}

local dict = Global.Util.arrayToDict(InputList)

setmetatable(dict, {
	__index = {
		list = InputList,
		lut = Global.Util.arrToOrderLUT(InputList),
	},
})

return dict :: { [string]: string, list: { string }, lut: { [string]: number } }
