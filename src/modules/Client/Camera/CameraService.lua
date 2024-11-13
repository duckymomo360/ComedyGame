--[=[
	@class CameraService
]=]

local require = require(script.Parent.loader).load(script)

local CameraStackService = require("CameraStackService")
local TrackCamera = require("TrackCamera")

local CameraService = {}
CameraService.ServiceName = "CameraService"

function CameraService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._cameraStackService = self._serviceBag:GetService(CameraStackService)
	self._cameraStackService:SetDoNotUseDefaultCamera(true)
end

function CameraService:Start()
	self._stageCamera = TrackCamera.new(workspace.Positions.Camera)
	self._stageCamera.FieldOfView = 50

	self._cameraStackService:Add(self._stageCamera)
end

return CameraService
