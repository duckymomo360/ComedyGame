local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")

return BinderProvider.new("ServerBinderProvider", function(self, _serviceBag)
	self:Add(require("Player"))
end)
