--[=[
	@class CameraService
]=]

local require = require(script.Parent.loader).load(script)

local LagPointCamera = require("LagPointCamera")
local TrackCamera = require("TrackCamera")

local CameraService = {}
CameraService.ServiceName = "CameraService"

function CameraService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	
	self._cameraStackService = self._serviceBag:GetService(require("CameraStackService"))
	self._cameraStackService:SetDoNotUseDefaultCamera(true)
end

function CameraService:Start()
	self._camera = TrackCamera.new(workspace.Positions.Camera)
	self._camera.FieldOfView = 50
	
	self._stageCamera = TrackCamera.new(workspace.Positions.Stage)
	
	self._cameraStackService:Add((self._camera + require("NoisyCamera").new()):SetMode("Relative"))
end

return CameraService