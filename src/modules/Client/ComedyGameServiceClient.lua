--[=[
	@class ComedyGameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local ComedyGameServiceClient = {}
ComedyGameServiceClient.ServiceName = "ComedyGameServiceClient"

function ComedyGameServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._serviceBag:GetService(require("CameraService"))
end

return ComedyGameServiceClient