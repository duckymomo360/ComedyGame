local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = ReplicatedStorage:WaitForChild("ComedyGame"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent)

local serviceBag = require("ServiceBag").new()

serviceBag:GetService(require("ClientBinderProvider"))
serviceBag:GetService(require("CameraService"))
serviceBag:GetService(require("SignController"))
serviceBag:GetService(require("ComedyGameServiceClient"))

serviceBag:Init()
serviceBag:Start()
