local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local MessagingServiceUtils = require("MessagingServiceUtils")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

local LOBBY_INFO_PUBLISH_INTERVAL = 30
local LOBBY_INFO_EXPIRE_TIME = 60

local LobbyService = {}
LobbyService.ServiceName = "LobbyService"

type LobbyInfoPublishRequest = {
	targetLobbyId: number,
	sender: number,
}

type PlayerInfo = {
	UserId: number,
	SessionTime: number,
}

type LobbyInfo = {
	JobId: string,
	Name: string,
	Age: number,
	Host: number,
	Players: { PlayerInfo },
}

function LobbyService:Init(_serviceBag)
	self._maid = Maid.new()

	self._lobbyId = HttpService:GenerateGUID(false)
	self._lobbies = MemoryStoreService:GetSortedMap("Lobbies")

	-- Assign server host
	self:AssignNewHost()

	self._maid:GiveTask(Players.PlayerAdded:Connect(function()
		if self._host == nil then
			self:AssignNewHost()
		end
	end))

	-- When the host leaves, assign a new host
	self._maid:GiveTask(Players.PlayerRemoving:Connect(function(player)
		if player == self._host then
			self:AssignNewHost()
		end
	end))

	-- Handle requests from MessagingService to refresh lobby info
	MessagingServiceUtils.promiseSubscribe("LobbyInfoPublishRequest", function(message: LobbyInfoPublishRequest)
		if message.targetLobbyId == self._lobbyId then
			self:PublishLobbyInfo()
		end
	end):Then(function(connection)
		self._maid:GiveTask(connection)
	end)

	-- Lobby info update clock
	self._maid:GiveTask(task.spawn(function()
		while true do
			task.wait(LOBBY_INFO_PUBLISH_INTERVAL)
			self:PublishLobbyInfo()
		end
	end))

	self._maid:GiveTask(function()
		self._lobbies:RemoveAsync(self._lobbyId)
	end)

	game:BindToClose(function()
		self._maid:Destroy()
	end)
end

function LobbyService:AssignNewHost(): Player
	local host: Player = Players:GetPlayers()[1]
	if host ~= nil then
		self._host = host
		self:PublishLobbyInfo()
		return host
	end
end

function LobbyService:_compileLobbyInfo(): LobbyInfo
	local lobbyInfo: LobbyInfo = {
		JobId = game.JobId,
		Name = self._lobbyName,
		HostUserId = if self._host then self._host.UserId else nil,
		Age = workspace.DistributedGameTime,
		Players = {},
	}

	for _, player: Player in Players:GetPlayers() do
		local playerInfo: PlayerInfo = {
			UserId = player.UserId,
			SessionTime = 1,
		}

		table.insert(lobbyInfo.Players, playerInfo)
	end

	return lobbyInfo
end

function LobbyService:PublishLobbyInfo()
	local lobbyInfo = self:_compileLobbyInfo()
	local numPlayers = #lobbyInfo.Players
	print("Lobby Info", lobbyInfo)
	self._lobbies:SetAsync(self._lobbyId, lobbyInfo, LOBBY_INFO_EXPIRE_TIME, numPlayers)
end

function LobbyService:Destroy()
	self._maid:Destroy()
end

return LobbyService
