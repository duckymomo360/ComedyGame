--[[
	@class ClientMain
]]
local loader = game:GetService("ReplicatedStorage"):WaitForChild("ComedyGame"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent)

local LOBBY_PLACEID = 91745465506672

local serviceBag = require("ServiceBag").new()

serviceBag:GetService(require("ClientBinders"))
serviceBag:GetService(require("CameraService"))
serviceBag:GetService(require("SignController"))

if game.PlaceId == LOBBY_PLACEID then
	serviceBag:GetService(require("ComedyGameServiceClient"))
end

serviceBag:Init()
serviceBag:Start()
