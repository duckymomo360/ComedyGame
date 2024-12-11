local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local loader = ServerScriptService.ComedyGame:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.ComedyGame)

local serviceBag = require("ServiceBag").new()

local LobbyService = serviceBag:GetService(require("LobbyService"))

serviceBag:Init()
serviceBag:Start()

Players.PlayerAdded:Connect(function(player)
	if player.FollowUserId ~= 0 then
		local serverId = LobbyService:FindLobbyContainingUserId(player.FollowUserId)

		LobbyService:TeleportPlayerToLobby(player, serverId)
	end
end)

ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(player)
	LobbyService:CreateNewLobby({ Name = `{player.Name}'s Lobby`, Host = player.UserId })
end)
