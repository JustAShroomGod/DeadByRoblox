local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local Voided_Animation = 80 -- distance at which you will not play animations (too far)
local Handler = {}

function Bind_Hiding(Hiding_Spot : Model) : "Binds Hiding Spot Sounds + Animations"
	if not Handler[Hiding_Spot] then Handler[Hiding_Spot] = {} end
	if not Handler[Hiding_Spot].Connections then Handler[Hiding_Spot].Connections = {} end
	
	Hiding_Spot:GetAttributeChangedSignal("Animation"):Connect(function()
		local Distance = (game.Players.LocalPlayer.Character:GetPivot().Position - Hiding_Spot:GetPivot().Position).Magnitude
		
		if Distance <= Voided_Animation then
			local Animation = Hiding_Spot:WaitForChild('Animations'):FindFirstChild(Hiding_Spot:GetAttribute("Animation"))
			
			if Animation then
				
				if not Handler[Hiding_Spot][Animation.Name] then
					Handler[Hiding_Spot][Animation.Name] = Hiding_Spot:WaitForChild('AnimationController'):WaitForChild('Animator'):LoadAnimation(Animation)
					
					Handler[Hiding_Spot].Connections[Animation.Name] = Handler[Hiding_Spot][Animation.Name].KeyframeReached:Connect(function(frame)
						
						if Hiding_Spot:WaitForChild('Sounds'):FindFirstChild(frame) then -- looks for sound matching keyframe name
							Hiding_Spot:WaitForChild('Sounds')[frame]:Play()
						end
					end)
				end
				
				local A_Length = if Handler[Hiding_Spot][Animation.Name].Length < 0.1 then 1 else Handler[Hiding_Spot][Animation.Name].Length
				local True_Length : number = 0 - (workspace:GetServerTimeNow() - Hiding_Spot:GetAttribute("Animation_Time"))
				
				Handler[Hiding_Spot][Animation.Name]:Play()
				Handler[Hiding_Spot][Animation.Name]:AdjustSpeed(A_Length/True_Length) -- Times the Animation to Match Remainer of Time to Stop at Same Time --
			end
		end
	end)
end

function Handler.new() --TODO: this is a prototype version, but the overall idea is we need to move animations to client
	--[[ WHY AM I DOING THIS??
	 * less server strain
	 * we can further optimize clients by putting limits on what to not animate if too far (no point, server can't do that)
	 * client do animations better overall so more performance
	 * we can pre-load animations and the game on the clients better/more accurately (when I do add loading screens at the start)
	 
	 -- DOWNSIDES TO THIS --
	 * Obviously it's harder to do
	 * Potential animation desync by a few frames (so may look iffy on some things)
	]]
	
	for _, model : Model in pairs(workspace:GetChildren()) do
		
		if model:GetAttribute("IsInteractable") and string.match(model.Name, "Hiding_Spot") then
			Bind_Hiding(model)
		end
	end
	
	return Handler
end

return Handler.new()
