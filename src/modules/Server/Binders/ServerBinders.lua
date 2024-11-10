local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local PlayerBinder = require("PlayerBinder")

return BinderProvider.new("ServerBinders", function(self, serviceBag)
	self:Add(PlayerBinder.new("Player", require("Player"), serviceBag))
end)
