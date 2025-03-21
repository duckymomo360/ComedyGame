local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local PlayerBinder = require("PlayerBinder")

return BinderProvider.new("ServerBinderProvider", function(self, _serviceBag)
	self:Add(PlayerBinder.new("Player", require("Player")))
end)
