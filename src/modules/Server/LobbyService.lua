local require = require(script.Parent.loader).load(script)

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Maid = require("Maid")

local LobbiesMap = MemoryStoreService:GetSortedMap("Lobbies")
local PlayerCurrentLobbyMap = MemoryStoreService:GetHashMap("PlayerCurrentLobby")

local LOBBY_PLACEID = 91745465506672

local STUDIO_LOBBY_INFO: LobbyInfo = {
	Name = "Studio Lobby",
	Host = 0,
}

type LobbyState = {
	Players: { number },
	ServerAge: number,
}

type LobbyInfo = {
	Name: string,
	Host: number,
	AccessCode: string?,
	LobbyState: LobbyState?,
}

local LobbyService = {}
LobbyService.ServiceName = "LobbyService"

function LobbyService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	if self:IsInLobby() then
		self:_startupLocalLobby()
	end
end

function LobbyService:IsInLobby()
	return game.PlaceId == LOBBY_PLACEID
end

function LobbyService:ShutdownServer(reason: string)
	reason = reason or "Server shutting down"

	Players.PlayerAdded:Connect(function(player)
		player:Kick(reason)
	end)

	for _, player in Players:GetPlayers() do
		player:Kick(reason)
	end
end

function LobbyService:_publishLocalLobbyInfo()
	assert(self:IsInLobby(), "This server is not a lobby")

	self._lobbyInfo.LobbyState = {}
	self._lobbyInfo.LobbyState.ServerAge = workspace.DistributedGameTime
	self._lobbyInfo.LobbyState.Players = {}

	for _, player in Players:GetPlayers() do
		table.insert(self._lobbyInfo.LobbyState.Players, player.UserId)
	end

	LobbiesMap:SetAsync(self._serverId, self._lobbyInfo, 60, #self._lobbyInfo.LobbyState.Players)

	print("Lobby info published")
end

function LobbyService:_startupLocalLobby()
	assert(self:IsInLobby(), "This server is not a lobby")
	assert(not self._gameService, "Lobby already registered")

	self._serverId = if RunService:IsStudio() then "STUDIO" else game.PrivateServerId
	self._gameService = self._serviceBag:GetService(require("ComedyGameService"))

	local publishThread = task.spawn(function()
		-- When running in Studio, use the default Studio lobby config
		if RunService:IsStudio() then
			self._lobbyInfo = STUDIO_LOBBY_INFO
			return
		end

		-- Get the lobbyInfo that the main menu set up before teleporting here
		self._lobbyInfo = LobbiesMap:GetAsync(self._serverId)

		-- lobbyInfo is nil either when in Studio or when the main menu didn't set it up corrently
		if self._lobbyInfo == nil then
			self:ShutdownServer("Failed to start server")
			return
		end

		while true do
			self:_publishLocalLobbyInfo()
			task.wait(30)
		end
	end)

	game:BindToClose(function()
		task.cancel(publishThread)
		LobbiesMap:RemoveAsync(self._serverId)
	end)

	self._maid:GiveTask(Players.PlayerAdded:Connect(function(player)
		PlayerCurrentLobbyMap:SetAsync(tostring(player.UserId), self._serverId, 60 * 60 * 24)
	end))

	self._maid:GiveTask(Players.PlayerRemoving:Connect(function(player)
		PlayerCurrentLobbyMap:RemoveAsync(tostring(player.UserId))
	end))
end

function LobbyService:CreateNewLobby(lobbyInfo: LobbyInfo)
	local accessCode, privateServerId = TeleportService:ReserveServer(LOBBY_PLACEID)
	lobbyInfo.AccessCode = accessCode

	LobbiesMap:SetAsync(privateServerId, lobbyInfo, 120, 1)

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = accessCode

	TeleportService:TeleportAsync(LOBBY_PLACEID, { Players:GetPlayerByUserId(lobbyInfo.Host) }, teleportOptions)
end

function LobbyService:TeleportPlayerToLobby(player: Player, serverId: string)
	local lobbyInfo = LobbiesMap:GetAsync(serverId) :: LobbyInfo

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = lobbyInfo.AccessCode

	TeleportService:TeleportAsync(LOBBY_PLACEID, { player }, teleportOptions)
end

function LobbyService:FindLobbyContainingUserId(userId: number)
	return PlayerCurrentLobbyMap:GetAsync(tostring(userId))
end

function LobbyService:Destroy()
	self._maid:Destroy()
end

return LobbyService
