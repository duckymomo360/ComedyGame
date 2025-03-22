local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local Door = {}
Door.__index = Door

function Door.new(door, _serviceBag)
	local self = setmetatable({}, Door)

	self._maid = Maid.new()

	self._remoting = self._maid:Add(require("Remoting").new(door, "Door"))
	self._remoting:DeclareEvent("Impulse")

	return self
end

function Door:Impulse(velocity: number)
	self._remoting:FireAllClients("Impulse", velocity)
end

function Door:Destroy()
	self._maid:Destroy()
end

return Door
