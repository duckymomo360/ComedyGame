local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	local success, rig = pcall(Players.CreateHumanoidModelFromUserId, Players, player.UserId)

	if not success then
		rig = Players:CreateHumanoidModelFromUserId(1)
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

	return rig
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
	self.Character.HumanoidRootPart:SetNetworkOwner(nil)
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