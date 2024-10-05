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
	local newAnimate = ReplicatedStorage.AnimateScripts[rig.Humanoid.RigType.Name]:Clone()

	for _, v in oldAnimate:GetChildren() do
		v.Parent = newAnimate
	end

	oldAnimate:Destroy()

	newAnimate.Name = "Animate"
	newAnimate.Enabled = true
	newAnimate.Parent = rig

	return rig, userId
end

return AvatarUtils