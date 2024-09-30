local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")

local Promise = require("Promise")
local PathfindingUtils = require("PathfindingUtils")

local PATH_CONFIG = {
	AgentCanJump = false,
	WaypointSpacing = 1,
	Costs = {
		DoorPath = 1,
		Floor = 10,
		Avoid = math.huge,
	},
}

local function GetAnimatorForRig(rig: Model)
	local robloxScripts = game:GetService("ReplicatedStorage"):WaitForChild("RobloxScripts")
	local animator: Script

	if rig.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		animator = robloxScripts.AnimateR15
	else
		animator = robloxScripts.AnimateR6
	end

	animator = animator:Clone()
	animator.Name = "Animator"
	animator.Disabled = false

	return animator
end

local function GetUnoccupiedSeats()
	local seats = {}

	for _, v in workspace.Tables:GetDescendants() do
		if v:IsA("Seat") and v:GetAttribute("Reserved") ~= true then
			table.insert(seats, v)
		end
	end
	
	return seats
end

local function GetHumanoidModelForPlayer(player: Player)
	local success, result = pcall(Players.CreateHumanoidModelFromUserId, Players, player.UserId)

	if success then
		return result
	else
		return Players:CreateHumanoidModelFromUserId(1)
	end
end

local Player = {}
Player.__index = Player

function Player.new(player: Player)
	local self = setmetatable({}, Player)
	
	self.Player = player
	self.Random = Random.new()

	-- Create character
	self.Character = GetHumanoidModelForPlayer(player)
	self.Character.Name = player.Name
	self.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	-- Animate
	self.Animator = GetAnimatorForRig(self.Character)
	self.Animator.Parent = self.Character
	
	-- ForceField
	local forceField = Instance.new("ForceField")
	forceField.Visible = false
	forceField.Parent = self.Character
	
	-- Path
	self.Path = PathfindingService:CreatePath(PATH_CONFIG)
	
	-- Voice
	self.VoiceInput = Instance.new("AudioDeviceInput")
	self.VoiceInput.Player = player
	self.VoiceInput.Parent = player

	self.AudioWire = Instance.new("Wire")
	self.AudioWire.SourceInstance = self.VoiceInput
	self.AudioWire.Parent = player
	
	-- Find & reserve a seat
	local seats = GetUnoccupiedSeats()
	self.Seat = seats[self.Random:NextInteger(1, #seats)]
	self.Seat:SetAttribute("Reserved", true)
	
	-- Spawn character
	self.Character.Parent = workspace.Characters
	self.Character:PivotTo(workspace.Positions.Spawn.CFrame)
	
	-- Walk to seat
	self:PromisePathfindTo(self.Seat.Position):Finally(function()
		self:EnterSeat()
	end)

	return self
end

function Player:PromisePathfindTo(finish: Vector3)
	return PathfindingUtils.promiseComputeAsync(
		self.Path,
		self.Character.HumanoidRootPart.Position,
		finish
	):Then(function(path)
		if path.Status ~= Enum.PathStatus.Success then
			return Promise.rejected(path.Status)
		end
		
		self.Character.Humanoid.Sit = false

		for _, waypoint: PathWaypoint in path:GetWaypoints() do
			self.Character.Humanoid:MoveTo(waypoint.Position)
			self.Character.Humanoid.MoveToFinished:Wait()
		end

		return Promise.resolved(path.Status)
	end)
end

function Player:EnterSeat()
	self.AudioWire.TargetInstance = nil
	self.Seat:Sit(self.Character.Humanoid)
end

function Player:EnterStage()
	self.Character.Humanoid.Sit = false
	self.Character:PivotTo(workspace.Positions.Stage.CFrame)
	self.AudioWire.TargetInstance = SoundService.StageAudio
end

function Player:Destroy()
	self:PromisePathfindTo(workspace.Positions.Spawn.Position):Finally(function()
		self.Character:Destroy()
	end)

	self.Seat:SetAttribute("Reserved", nil)
end

return require("PlayerBinder").new("Player", Player)