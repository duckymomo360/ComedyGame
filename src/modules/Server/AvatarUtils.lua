--[=[
	@class ComedyGameService
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local AvatarUtils = {}

function AvatarUtils.getHumanoidModelForUserId(userId: number): (Model?, number)
	local success, rig

	for attemptNumber = 1, 5 do
		if attemptNumber > 2 then
			task.wait(1)
		end

		success, rig = pcall(Players.CreateHumanoidModelFromUserId, Players, userId)

		if success then
			break
		else
			userId = 1
			continue
		end
	end

	if not success then
		return nil, userId
	end

	-- Swap Animate script for Client RunContext one
	local oldAnimate = rig:FindFirstChild("Animate")
	local newAnimate = ReplicatedStorage.AnimateScripts:FindFirstChild(rig.Humanoid.RigType.Name)

	if newAnimate ~= nil then
		newAnimate = newAnimate:Clone()

		-- Copy any custom animations they may have equipped
		for _, v in oldAnimate:GetChildren() do
			v.Parent = newAnimate
		end

		newAnimate.Name = "Animate"
		newAnimate.Enabled = true
		newAnimate.Parent = rig
	end

	oldAnimate:Destroy()

	return rig, userId
end

return AvatarUtils
