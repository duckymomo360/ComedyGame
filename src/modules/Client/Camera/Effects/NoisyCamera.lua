--[=[
	@class NoisyCamera
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")

local CameraState = require("CameraState")
local SummedCamera = require("SummedCamera")
local Maid = require("Maid")

local NoisyCamera = {}
NoisyCamera.ClassName = "NoisyCamera"

function NoisyCamera.new()
	local self = setmetatable({}, NoisyCamera)

	self._maid = Maid.new()

	return self
end

function NoisyCamera:__add(other)
	return SummedCamera.new(self, other)
end

--[=[
	The current state.
	@readonly
	@prop CameraState CameraState
	@within NoisyCamera
]=]
function NoisyCamera:__index(index)
	if index == "CameraState" then
		local state = CameraState.new()

		state.CFrame = CFrame.Angles(
			math.noise(os.clock() / 20) / 50,
			math.noise(os.clock() / 20 + 100) / 50,
			math.noise(os.clock() / 20 + 1000) / 50
		)

		return state
	else
		return NoisyCamera[index]
	end
end

function NoisyCamera:Destroy()
	self._maid:DoCleaning()
end

return NoisyCamera