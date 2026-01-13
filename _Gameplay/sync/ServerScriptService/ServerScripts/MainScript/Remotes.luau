local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemoteStorage = ReplicatedStorage:WaitForChild('RemoteEvents')

local remotes = {}

local RemoteList = {
	--Actually Useful | Direct Descendants --
	'NewPropertie',
	'Hatchet',
	'Server_Sound',
	'StunRemote',
	-- Accessed somehwere else or didn't check --
	'HatchAction',
	'CloneObject',
	'ObjectAppUpdater',
	'SendSkillCheck',
	'SetKillerCharacter',
	'GraspAction',
	-- Client Initted Events --
	'Bug_Reader',
	'Flashlight_Client',
}

local ServerList = {
	'Event' -- binded to ServerEvent
}

--Build all the remotes for the game in this folder from now on--



local function buildremote(name)
	local R = Instance.new('RemoteEvent', RemoteStorage)
	R.Name = name
end

local function buildevent(name)
	local R = Instance.new('BindableEvent', RemoteStorage)
	R.Name = name
end

local function buildremote_unreliable(name)
	local R = Instance.new('UnreliableRemoteEvent', RemoteStorage)
	R.Name = name
end

function remotes:Spawn() : "Build the remotes"
	
	for _,remoteName in pairs(RemoteList)do
		buildremote(remoteName)
	end
	
	for _,remote_module in pairs(script:GetChildren()) do
		
		if remote_module:GetAttribute("Unreliable") then
			buildremote_unreliable(remote_module.Name)
		else
			buildremote(remote_module.Name)
		end
	end
	
	for _,remoteName in pairs(ServerList)do
		buildevent(remoteName)
	end
end

function remotes:Connect() : "Connect child modules to Remotes"
	
	for _,module in pairs(script:GetChildren())do
		
		if module:IsA('ModuleScript') then
			require(module) -- gets the module
		end
	end
end

return remotes
