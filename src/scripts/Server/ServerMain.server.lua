--[=[
	@class ServerMain
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.ComedyGame:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.ComedyGame)

local GAME_ID = 91745465506672

local serviceBag = require("ServiceBag").new()

if game.PlaceId == GAME_ID then
	serviceBag:GetService(require("ComedyGameService"))
else
	local LobbyService = serviceBag:GetService(require("LobbyService"))

	Players.PlayerAdded:Connect(function(player)
		if player.FollowUserId ~= 0 then
			local serverId = LobbyService:FindLobbyContainingUserId(player.FollowUserId)

			LobbyService:TeleportPlayerToLobby(player, serverId)
		end
	end)

	ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(player)
		LobbyService:CreateNewLobby({ Name = `{player.Name}'s Lobby`, Host = player.UserId })
	end)
end

serviceBag:Init()
serviceBag:Start()
