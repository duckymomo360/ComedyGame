local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")
local PlayerBinder = require("PlayerBinder")

return BinderProvider.new("ServerBinderProvider", function(self, _serviceBag)
	self:Add(PlayerBinder.new("Player", require("Player")))
	self:Add(Binder.new("Door", require("Door")))
end)
