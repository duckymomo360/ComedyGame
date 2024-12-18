local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local BinderUtils = require("BinderUtils")
local SpringSign = require("SpringSign")

local SignController = {}
SignController.ServiceName = "SignController"

function SignController:Init(_serviceBag)
	self._maid = Maid.new()

	local mouseLocationLastFrame = Vector2.zero
	local mouseDelta = Vector2.zero

	self._maid:Add(RunService.RenderStepped:Connect(function()
		local mouseLocation = UserInputService:GetMouseLocation()
		mouseDelta = mouseLocation - mouseLocationLastFrame
		mouseLocationLastFrame = mouseLocation
	end))

	self._maid:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local sign = self:RaycastForSign(input.Position.X, input.Position.Y)

			if sign then
				sign:Impulse(Vector3.new(-mouseDelta.X / 500, mouseDelta.Y / 500, mouseDelta.X / 1000))
			end
		end
	end))

	self._maid:Add(UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local sign, position = self:RaycastForSign(input.Position.X, input.Position.Y)

			if sign then
				sign:Activate(position)
			end
		end
	end))
end

function SignController:RaycastForSign(screenX, screenY)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("SpringSign")

	local ray = workspace.CurrentCamera:ScreenPointToRay(screenX, screenY)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 100, raycastParams)

	if result then
		return BinderUtils.findFirstAncestor(SpringSign, result.Instance), result.Position
	end
end

function SignController:Destroy()
	self._maid:Destroy()
end

return SignController
