local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
local loader = require(script:WaitForChild('UserAppearence'))

loader.load(player.Character, player.UserId)