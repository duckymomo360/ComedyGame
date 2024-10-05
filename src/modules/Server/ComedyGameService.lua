--[=[
	@class ComedyGameService
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local ComedyGameService = {}
ComedyGameService.ServiceName = "ComedyGameService"

function ComedyGameService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	self._serviceBag:GetService(require("ServerBinders"))
end

function ComedyGameService:Destroy()
	self._maid:DoCleaning()
end

return ComedyGameService
