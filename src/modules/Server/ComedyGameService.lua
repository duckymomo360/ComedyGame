--[=[
	@class ComedyGameService
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Remoting = require("Remoting")

local ComedyGameService = {}
ComedyGameService.ServiceName = "ComedyGameService"

function ComedyGameService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External Dependencies
	self._serviceBag:GetService(require("CmdrService"))
	self._serviceBag:GetService(require("IKService"))

	-- Internal Dependencies
	self._lobbyService = self._serviceBag:GetService(require("LobbyService"))
	self._binders = self._serviceBag:GetService(require("ServerBinderProvider"))

	-- TODO
	Remoting.new(game.ReplicatedStorage, "Actions"):Connect("EnterStage", function(player)
		local pbdr = self._binders:Get("Player"):Get(player)

		if pbdr._state == "InSeat" then
			pbdr:EnterStage()
		elseif pbdr._state == "OnStage" then
			pbdr:EnterSeat()
		end
	end)
end

return ComedyGameService
