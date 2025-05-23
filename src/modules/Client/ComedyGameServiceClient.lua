--[=[
	@class ComedyGameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Remoting = require("Remoting")
local CoreGuiUtils = require("CoreGuiUtils")

local ComedyGameServiceClient = {}
ComedyGameServiceClient.ServiceName = "ComedyGameServiceClient"

function ComedyGameServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Disable reset button
	CoreGuiUtils.promiseRetrySetCore(120, 0.25, "ResetButtonCallback", false)

	self._serviceBag:GetService(require("CmdrServiceClient"))
	self._serviceBag:GetService(require("IKServiceClient"))

	self._maid = Maid.new()

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
