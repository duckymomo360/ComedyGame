local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new("ClientBinders", function(self, serviceBag)
    self:Add(Binder.new("SoundboardButton", require("SoundboardButton"), serviceBag))
end)
