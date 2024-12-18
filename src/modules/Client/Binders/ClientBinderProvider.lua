local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")

return BinderProvider.new("ClientBinderProvider", function(self, _serviceBag)
	self:Add(require("SoundboardButton"))
	self:Add(require("SpringSign"))
end)
