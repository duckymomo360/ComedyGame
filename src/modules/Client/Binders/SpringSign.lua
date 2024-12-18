local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local Spring = require("Spring")
local Signal = require("Signal")

local BLACK = Color3.new(0, 0, 0)

local SpringSign = {}
SpringSign.__index = SpringSign

function SpringSign.new(sign, _serviceBag)
	assert(sign.PrimaryPart, "SpringSign needs a PrimaryPart")

	local self = setmetatable({}, SpringSign)

	self._maid = Maid.new()

	self.model = sign
	self.activated = self._maid:Add(Signal.new())

	-- Save neon part colors
	self._neonPartColor = {}
	for _, v in sign:GetDescendants() do
		if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
			self._neonPartColor[v] = v.Color
		end
	end

	self._maid:Add(sign.DescendantAdded:Connect(function(v)
		if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
			self._neonPartColor[v] = v.Color
		end
	end))

	self._rotSpring = Spring.new(Vector3.zero)
	self._rotSpring.Damper = 0.2
	self._rotSpring.Speed = 7

	self._originalRotation = sign:GetPivot().Rotation

	self.brightness = 1

	self._maid:Add(RunService.RenderStepped:Connect(function()
		local rotation = self._rotSpring.Position

		local s = math.sign(rotation.y)
		if s ~= self._currentS and math.abs(rotation.y) > 0.05 then
			self:_onGlassBumped()
			self._currentS = s
		end

		sign:PivotTo(
			CFrame.new(sign:GetPivot().Position)
				* self._originalRotation
				* CFrame.Angles(rotation.x, math.abs(rotation.y), rotation.z)
		)

		for i, v in self._neonPartColor do
			i.Color = BLACK:Lerp(v, self.brightness)
		end
	end))

	return self
end

function SpringSign:_onGlassBumped() end

function SpringSign:Activate(clickPosition: Vector3?)
	if clickPosition then
		local clickRelative = self.model.PrimaryPart.CFrame:PointToObjectSpace(clickPosition)
		self:Impulse(Vector3.new(-clickRelative.Y / 2, 2, 0))
	end

	self.activated:Fire()
end

function SpringSign:Impulse(velocity: Vector3)
	self._rotSpring:Impulse(velocity)
end

function SpringSign:Destroy()
	self._maid:Destroy()
end

return Binder.new("SpringSign", SpringSign)
