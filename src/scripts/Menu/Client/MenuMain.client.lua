local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = ReplicatedStorage:WaitForChild("ComedyGame"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local serviceBag = require("ServiceBag").new()

local binders = serviceBag:GetService(require("ClientBinderProvider"))
serviceBag:GetService(require("SignController"))
serviceBag:GetService(require("Weather"))

local cameraStack = serviceBag:GetService(require("CameraStackService"))
cameraStack:SetDoNotUseDefaultCamera(true)

serviceBag:Init()
serviceBag:Start()

local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
local root = ReactRoblox.createRoot(gui)
root:render(React.createElement(require("ServerBrowser"), {}, {}))

binders:Get("SpringSign"):Promise(workspace:WaitForChild("Signs"):WaitForChild("Host")):Then(function(sign)
	sign.Activated:Connect(function()
		game.ReplicatedStorage.RemoteEvent:FireServer()
	end)
end)

local camera = require("TrackCamera").new(workspace.Positions.Camera)
camera.FieldOfView = 50

local cameraDown = require("TrackCamera").new(workspace.Positions.CameraDown)
cameraDown.FieldOfView = 50
cameraStack:Add(cameraDown)

local introTween = require("CameraStateTweener").new(serviceBag, camera, 7)

task.wait(1)

introTween:Show()
