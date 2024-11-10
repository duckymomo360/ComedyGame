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

	self._binders = self._serviceBag:GetService(require("ServerBinders"))
	self._remoting = Remoting.new(game.ReplicatedStorage, "Actions")

	self._remoting:Connect("EnterStage", function(player)
		local pbdr = self._playerBinder:Get(player)

		if pbdr._state == "InSeat" then
			pbdr:EnterStage()
		elseif pbdr._state == "OnStage" then
			pbdr:EnterSeat()
		end
	end)
end

function ComedyGameService:Destroy()
	self._maid:DoCleaning()
end

return ComedyGameService
