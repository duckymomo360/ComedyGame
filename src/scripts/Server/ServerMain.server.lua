--[=[
	@class ServerMain
]=]

local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.ComedyGame:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.ComedyGame)

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("ComedyGameService"))
serviceBag:Init()
serviceBag:Start()