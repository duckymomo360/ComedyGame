local require = require(script.Parent.loader).load(script)

local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")

local Promise = require("Promise")
local PathfindingUtils = require("PathfindingUtils")
local AvatarUtils = require("AvatarUtils")
local GetUnoccupiedSeats = require("GetUnoccupiedSeats")

local PATH_CONFIG = {
	AgentCanJump = false,
	WaypointSpacing = 1,
	Costs = {
		DoorPath = 1,
		Floor = 10,
		Avoid = math.huge,
	},
}

local Player = {}
Player.__index = Player

function Player.new(player: Player)
	local self = setmetatable({}, Player)

	self._player = player
	self._random = Random.new()

	-- Create character
	self._character = AvatarUtils.getHumanoidModelForUserId(player.UserId)
	self._character.Name = player.Name
	self._character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- ForceField
	local forceField = Instance.new("ForceField")
	forceField.Visible = false
	forceField.Parent = self._character

	-- Path
	self._path = PathfindingService:CreatePath(PATH_CONFIG)

	-- Voice
	self._voiceInput = Instance.new("AudioDeviceInput")
	self._voiceInput.Player = player
	self._voiceInput.Parent = player

	self._audioWire = Instance.new("Wire")
	self._audioWire.SourceInstance = self._voiceInput
	self._audioWire.Parent = player

	-- Find & reserve a seat
	local seats = GetUnoccupiedSeats()
	self._seat = seats[self._random:NextInteger(1, #seats)]
	self._seat:SetAttribute("Reserved", true)

	-- Spawn character
	self._character.Parent = workspace.Characters
	self._character.HumanoidRootPart:SetNetworkOwner(nil)
	self._character:PivotTo(workspace.Positions.Spawn.CFrame)

	self._state = "WalkingIn"

	-- Walk to seat
	self:PromisePathfindTo(self._seat.Position):Finally(function()
		self:EnterSeat()
	end)

	return self
end

function Player:PromisePathfindTo(finish: Vector3)
	return PathfindingUtils.promiseComputeAsync(self._path, self._character.HumanoidRootPart.Position, finish)
		:Then(function(path)
			if path.Status ~= Enum.PathStatus.Success then
				return Promise.rejected(path.Status)
			end

			self._character.Humanoid.Sit = false

			for _, waypoint: PathWaypoint in path:GetWaypoints() do
				self._character.Humanoid:MoveTo(waypoint.Position)
				self._character.Humanoid.MoveToFinished:Wait()
			end

			return Promise.resolved(path.Status)
		end)
end

function Player:EnterSeat()
	self._audioWire.TargetInstance = nil
	self._seat:Sit(self._character.Humanoid)
	self._state = "InSeat"
end

function Player:EnterStage()
	if self._state ~= "InSeat" then
		return
	end

	self._state = "OnStage"
	
	local seatWeld = self._seat:FindFirstChild("SeatWeld", true)
	
	if seatWeld ~= nil then
		seatWeld:Destroy()
	end

	self._character.Humanoid.Sit = false
	
	self._character:PivotTo(workspace.Positions.Stage.CFrame)
	self._audioWire.TargetInstance = SoundService.StageAudio
end

function Player:Destroy()
	self:PromisePathfindTo(workspace.Positions.Spawn.Position):Finally(function()
		self._character:Destroy()
	end)

	self._seat:SetAttribute("Reserved", nil)
end

return require("PlayerBinder").new("Player", Player)
