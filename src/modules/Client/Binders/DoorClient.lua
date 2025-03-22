local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Spring = require("Spring")
local Remoting = require("Remoting")

local DoorClient = {}
DoorClient.__index = DoorClient

function DoorClient.new(door, _serviceBag)
	local self = setmetatable({}, DoorClient)

	self._maid = Maid.new()

	self._spring = Spring.new(0)
	self._spring.Damper = 0.4
	self._spring.Speed = 2

	local remoting = self._maid:Add(Remoting.new(door, "Door"))

	remoting:Connect("Impulse", function(velocity: number)
		self._spring:Impulse(velocity)
	end)

	local originalPivot = door:GetPivot()

	self._maid:Add(RunService.RenderStepped:Connect(function()
		door:PivotTo(originalPivot * CFrame.Angles(0, math.abs(self._spring.Position), 0))
	end))

	return self
end

function DoorClient:Destroy()
	self._maid:Destroy()
end

return DoorClient
