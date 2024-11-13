--[=[
	@class Button
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Button = {}
Button.__index = Button

function Button.new(gui, _serviceBag)
	local self = setmetatable({}, Button)
	self._maid = require("Maid").new()

	self._mouseEntered = Fusion.Value(false)
	self._size = Fusion.Spring(Fusion.Value(UDim2.fromScale(1, 1)), 10, 0.9)

	Fusion.Hydrate(gui)({
		[Fusion.OnEvent("MouseEnter")] = function()
			game.SoundService.Roblox_UI_Small_Click:Play()
			self._mouseEntered:set(true)
		end,
		[Fusion.OnEvent("MouseLeave")] = function()
			game.SoundService.Roblox_UI_Small_Click2:Play()
			self._mouseEntered:set(false)
		end,
		[Fusion.OnEvent("MouseButton1Down")] = function()
			game.SoundService.Roblox_UI_Bright_Click:Play()

			self._size:setVelocity(UDim2.fromOffset(-50, -50))
		end,

		BackgroundColor3 = Fusion.Spring(
			Fusion.Computed(function()
				if self._mouseEntered:get() then
					return Color3.new(1, 1, 1)
				else
					return Color3.new(0.5, 0.5, 0.5)
				end
			end),
			20,
			1
		),
	})

	Fusion.Hydrate(gui.TextLabel)({
		Position = Fusion.Spring(
			Fusion.Computed(function()
				if self._mouseEntered:get() then
					return UDim2.new(0.5, 0, 0.5, -10)
				else
					return UDim2.new(0.5, 0, 0.5, 0)
				end
			end),
			20,
			0.4
		),

		Size = self._size,
	})

	return self
end

function Button:Destroy() end

return Button
