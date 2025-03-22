local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new("ClientBinderProvider", function(self, _serviceBag)
	self:Add(Binder.new("SoundboardButton", require("SoundboardButton")))
	self:Add(Binder.new("SpringSign", require("SpringSign")))
	self:Add(Binder.new("Door", require("DoorClient")))
end)
