local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(script.Parent.loader).load(script)

local React = require(ReplicatedStorage.Packages.React)

local ServerBrowser = React.Component:extend("ServerBrowser")

type LobbyState = {
	Players: { number },
	ServerAge: number,
}

type LobbyInfo = {
	Name: string,
	Host: number,
	AccessCode: string?,
	LobbyState: LobbyState?,
}

local remoting = require("Remoting").new(ReplicatedStorage, "LobbyService")

function ServerBrowser:init()
	self:setState({ serverList = {} })
end

function ServerBrowser:render()
	local children = {
		React.createElement("UIListLayout"),
		React.createElement("TextButton", {
			Text = "Refresh",
			TextScaled = true,
			BackgroundColor3 = Color3.new(0, 1, 1),
			Size = UDim2.fromScale(1, 0.1),
			[React.Event.Activated] = function()
				self:fetchServers()
			end,
		}),
	}

	print("Server count:", #self.state.serverList)

	for _, lobbyInfo: LobbyInfo in self.state.serverList do
		local players = if lobbyInfo.LobbyState then #lobbyInfo.LobbyState.Players else "IDK"
		local age = if lobbyInfo.LobbyState then lobbyInfo.LobbyState.ServerAge else "IDK"

		table.insert(
			children,
			React.createElement("TextButton", {
				Text = `Name: {lobbyInfo.Name} - Host: {lobbyInfo.Host} - Player Count: {players} - Server Age: {age}`,
				TextScaled = true,
				Size = UDim2.fromScale(1, 0.1),
				[React.Event.Activated] = function()
					remoting:FireServer("JoinLobby", lobbyInfo.serverId)
				end,
			})
		)
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, children)
end

function ServerBrowser:fetchServers()
	self:setState(function()
		return { serverList = remoting:InvokeServer("GetLobbies") }
	end)
end

function ServerBrowser:componentDidMount()
	self:fetchServers()
end

return ServerBrowser
