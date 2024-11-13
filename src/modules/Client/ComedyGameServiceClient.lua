--[=[
	@class ComedyGameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Remoting = require("Remoting")

local ComedyGameServiceClient = {}
ComedyGameServiceClient.ServiceName = "ComedyGameServiceClient"

function ComedyGameServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	
	self._serviceBag:GetService(require("CmdrServiceClient"))
	self._serviceBag:GetService(require("IKServiceClient"))
	
	self._maid = Maid.new()

	self._binders = self._serviceBag:GetService(require("ClientBinders"))
	self._cameraService = self._serviceBag:GetService(require("CameraService"))
	
	game:GetService("StarterGui").MainGui:Clone().Parent = game.Players.LocalPlayer.PlayerGui

	self._remoting = Remoting.new(game.ReplicatedStorage, "Actions")

	self._maid:GiveTask(game.Players.LocalPlayer.PlayerGui.MainGui.Frame.Button.MouseButton1Down:Connect(function()
		self._remoting:FireServer("EnterStage")
	end))
end

function ComedyGameServiceClient:Destroy()
	self._maid:DoCleaning()
end

return ComedyGameServiceClient
