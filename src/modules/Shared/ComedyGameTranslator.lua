--[[
	@class ComedyGameTranslator
]]

local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("ComedyGameTranslator", "en", {
	gameName = "ComedyGame",
})
