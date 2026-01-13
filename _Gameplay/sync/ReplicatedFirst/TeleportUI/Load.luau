local v2 = Vector2
local v2n = v2.new
local v2u = v2n(1, 1)
local v2x = v2n(1, 0)
local v2y = v2n(0, 1)

local ud = UDim2
local udn = ud.new

local rgb = Color3.fromRGB

local module = {}

local function clean_rbx_signal(signal)
	if not signal then return end
	signal:Disconnect()
end

function module.load()
	game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
	game:GetService("Players").LocalPlayer.PlayerGui:SetTopbarTransparency(1)

	local array = {}

	local screen = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 50
	array.object = screen

	local frame = Instance.new("Frame", screen)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = v2u*(1/2)

	local back = frame:Clone()
	back.ZIndex = frame.ZIndex-2
	back.BackgroundColor3 = rgb()
	back.Size = udn(2, 0, 2, 0)
	back.Position = udn(1/2, 0, 1/2, 0)
	back.Parent = screen
	
	frame.BackgroundTransparency = 1

	array.text = module.text(frame)

	local render = game:GetService("RunService").Heartbeat

	render = render:Connect(function()
		array:display()
	end)		

	function array:delete()
		clean_rbx_signal(render)
		screen:Destroy()
	end

	local function image()
		local frame = Instance.new("Frame", frame)
		frame.BackgroundTransparency = 1
		
		local self = Instance.new("ImageLabel", frame)
		self.BackgroundTransparency = 1
		
		return self, frame
	end
	
	local prefix = "rbxassetid://"
	
	local id = {
		2871399158,
		2871399248,
		2871399297,
		2871399362,
		2871399415,
	}
	
	local x0 = {
		142,
		208,
		273,
		332,
	}
	
	local y0 = {
		145,
		120,
		125,
		160,
	}
	
	local h0 = {
		250,
		280,
		250,
		225,
		465,
	}

local instances = {}

	for n = 1, 5 do
		local id = prefix.. id[n]
		
		local self, frame = image()
			self.Image = id
		
			local sha = self:Clone()
				sha.ZIndex = sha.ZIndex-1
				sha.ImageColor3 = rgb()
			
				sha.Size = udn(1, 0, 1, 0)
				
			sha.Parent = frame
		
		instances[n] = {
			self = self 
			,frame = frame
			,sha = sha
		}
	end

	instances[5].frame.AnchorPoint = v2u*(1/2)
	
	local my_tick = tick()
		local my_time = 5
			local timef = 1/5
			local timec = 1/4
			local fin = 1/10
			local fou = 1/5
			
		local y1 = 250
		local y2 = 6
		
	local function get(self, y1, y2)
		return self*y1/y2
	end 
	
	local function get2(self)
		return self*y2/y1
	end 
	
	local function get3(self)
		return self*y2/y1
	end 
		
	local w = 1/y2

	function array:display()
		if array.text.frame.Visible then
			array.text:display()
		end
	
		local abs = screen.AbsoluteSize
			local h = 1/5
			local w1 = abs.Y/abs.X*h
	
		frame.Position = udn(1/2, 0, 1/2, 0)
		frame.Size = udn(w1, 0, h, 0)
		
		local timef2 = timef
		
		local res = my_time-(
			my_time*(fin+fou+timec)
		)
			
			local timef = res*timef
		
			local function r_time(a)
				return a-my_time*fin
			end
		
		local lapsed_r = tick()-my_tick
			
			if lapsed_r >= my_time then
				my_tick = tick()
			end
		
		local start_fo = my_time*(fin+timec)+res
		local time_fo = my_time*fou
			
		for n = 1, 4 do
			local self = instances[n]
				local image = self.self
				local frame = self.frame
				local sha = self.sha
			
				local start = (n-1)*timef
			local lapsed = lapsed_r
				
			local lapsed_f = lapsed
			local lapsed_fo
			
			if lapsed_r < my_time*fin then
				lapsed = 0
			elseif lapsed_r >= start_fo then
				lapsed_fo = lapsed_r-start_fo
			else
				if lapsed < start then
					lapsed = 0
				else
					lapsed = r_time(lapsed-start)
				end
			end
			
			local my_time = timef
			
					local a = 50
					local b = 255
				local delta = b-a
				
				if lapsed_fo then
					local alpha = math.clamp(lapsed_fo/time_fo, 0, 1)
					local c = b-(alpha*delta)
					
						local new = rgb(c , c, c)
						
					image.ImageColor3 = new
					sha.ImageTransparency = 1
				else
					image.ImageColor3 = rgb(b, b, b)
					sha.ImageColor3 = rgb(a, a, a)
					sha.ImageTransparency = 0
				end
	
			local y1 = h0[n] --250, 280
			local y2 = get3(y1)
	
			local inv = lapsed^3*1/timef^3
			local alpha = math.clamp(inv, 0, 1)
				
			local function solve(self, alpha)
				local scale = alpha*y2
					local offset = get(scale, y1, y2) --get offset from scale
			
				local y = get2(y0[n]-y0[1]) 
			
					if n == 0 then
						y = 0
					end
				
				self.ImageRectSize = v2n(40, offset)
				self.Position = udn(0, 0, y, 0)
				self.Size = udn(1, 0, scale, 0)
				
				local x, y = x0[n], y0[n]
				
				self.ImageRectOffset = v2n(x, y)
			end
			
			solve(image, alpha)
			solve(sha, 1)
			
			local edge = 1-(3/4+w)
			
			frame.Position = udn(edge/2+1/4*(n-1), 0, 0, 0)
			frame.Size = udn(w, 0, w, 0)
		end
		
		local self = instances[5]
			local image = self.self
			local frame = self.frame
			local sha = self.sha
		
			local start = timef*4
		local lapsed = lapsed_r
			local lapsed_f = lapsed
			local lapsed_fo
			
			if lapsed_r < my_time*fin then
				lapsed = 0
			elseif lapsed_r >= start_fo then
				lapsed_fo = lapsed_r-start_fo
			else
				if lapsed < start then
					lapsed = 0
				else
					lapsed = r_time(lapsed-start)
				end
			end
		
		local my_time = timef
	
				local a = 50
				local b = 255
			local delta = b-a
			
			if lapsed_fo then
				local alpha = math.clamp(lapsed_fo/time_fo, 0, 1)
				local c = b-(alpha*delta)
				
					local new = rgb(c , c, c)
					
				image.ImageColor3 = new
				sha.ImageTransparency = 1
			else
				image.ImageColor3 = rgb(b, b, b)
				sha.ImageColor3 = rgb(a, a, a)
				sha.ImageTransparency = 0
			end
	
		local y1 = h0[5] --250, 280
		local y2 = 7
	
		local inv = lapsed^3*1/my_time^3
		local alpha = math.clamp(inv, 0, 1)
		
		local function solve(self, alpha)
			local scale = alpha*y2
				local offset = get(scale, y1, y2) --get offset from scale
			
			self.ImageRectSize = v2n(60, offset)
			self.ImageRectOffset = v2n(235, 25)
	
			self.Size = udn(1, 0, scale, 0)
		end
		
		solve(image, alpha)
		solve(sha, 1)
		
			local w = w*(1+1/2)
		frame.Size = udn(w, 0, w, 0)
		
		local deg = -75
		
		frame.Rotation = deg
		
		local x = w*math.cos(deg)*y2
		local y = 1/5
		
			local f = 1
		local mx = f*math.cos(deg)
		local my = f*math.sin(deg)
		
		local pad = 3/40
		
		local p = v2n(1/2+pad-x/2, 1/2-y)
		
		frame.Position = udn(p.X, 0, p.Y, 0)
		end
	return array
end

function module.text(frame)
	local self = {}

	local text = "Dead By Roblox is a multiplayer (4v1) horror game where one player takes on the role of the savage Killer, and the other four players play as Survivors, trying to escape the Killer and avoid being caught, and sent back to the lobby."

	local prefix = "rbxassetid://"
	local zindex = frame.ZIndex+1

	local w = 1/2
	
	local text_frame = Instance.new("Frame", frame)
	text_frame.BackgroundTransparency = 1
	text_frame.Size = UDim2.new(1, 0, 1, 0)
	text_frame.Visible = false
	
	self.frame = text_frame
	
	local label = Instance.new("TextLabel", text_frame)
	label.ZIndex = zindex
	label.AnchorPoint = v2n(1/2, 1)

	label.TextWrapped = true
	label.TextXAlignment = "Left"
	label.TextYAlignment = "Top"

	label.Font = Enum.Font.Arial
	label.BackgroundTransparency = 1
	label.TextColor3 = rgb(255, 255, 255)

	local offset = 1/10
	local image_s = w/2+offset
	local image_h = w/2+offset

	label.Size = udn(4-image_s, 0, w, 0)
	label.Position = udn(1/2+image_h, 0, 25/10, 0)

	label.Text = text

	local image = Instance.new("ImageLabel", text_frame)
	image.ZIndex = zindex
	image.AnchorPoint = label.AnchorPoint
	image.BackgroundTransparency = 1
	image.Image = prefix.. tostring(2128216541)

	image.Size = udn(w, 0, w, 0)
	image.Position = udn(1/2-(2-w/4), 0, 25/10, 0)

	function self:display()
		local abs = frame.AbsoluteSize
		local alpha = abs.Y/100

		local new = alpha*12

		label.TextSize = new
		end
	return self
end

return module