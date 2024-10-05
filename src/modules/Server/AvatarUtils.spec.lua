return function()
	local AvatarUtils = require(script.Parent.AvatarUtils)

	describe("getHumanoidModelForPlayer", function()
		it("should give a rig even if the load failed", function()
			local rig, userId = AvatarUtils.getHumanoidModelForPlayer(-22) -- Invalid UserId.

			expect(userId).to.equal(1)
			expect(rig).to.be.ok()
		end)

		it("should give a rig that has an Animate script with Client RunContext", function()
			local rig = AvatarUtils.getHumanoidModelForPlayer(1)
			local animate = rig:FindFirstChild("Animate")

			expect(animate).to.be.ok()
			expect(animate.ClassName).to.equal("Script")
			expect(animate.RunContext).to.equal(Enum.RunContext.Client)
		end)
	end)
end
