local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local RandomUtils = require("RandomUtils")
local Spring = require("Spring")

local Weather = {}
Weather.ServiceName = "Weather"

function Weather:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()

	self._random = Random.new()

	self._brightness = Spring.new(0)
	self._brightness.Damper = 0.5
	self._brightness.Speed = 10

	self._maid:Add(RunService.RenderStepped:Connect(function()
		for _, v in CollectionService:GetTagged("ThunderLight") do
			v.Brightness = self._brightness.Position
		end
	end))

	self._maid:Add(task.spawn(function()
		while true do
			task.wait(self._random:NextNumber(15, 40))
			self:Thunder()
		end
	end))
end

function Weather:Thunder()
	self._brightness.Position = 1

	local sound = RandomUtils.choice(SoundService.Weather.Thunder:GetChildren(), self._random)

	task.delay(0.2, function()
		sound:Play()
	end)
end

function Weather:Destroy() end

return Weather
