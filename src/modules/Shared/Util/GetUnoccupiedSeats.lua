local function GetUnoccupiedSeats()
	local seats = {}

	for _, v in workspace.Tables:GetDescendants() do
		if v:IsA("Seat") and v:GetAttribute("Reserved") ~= true then
			table.insert(seats, v)
		end
	end

	return seats
end

return GetUnoccupiedSeats