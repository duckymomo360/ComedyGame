local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new("ServerBinders", function(self, serviceBag)
	self:Add(Binder.new("Player", require("Player"), serviceBag))
end)
