local Content_Provider = game:GetService('ContentProvider')
local Animation_File = game.ReplicatedStorage:WaitForChild('Game_Assets')

Content_Provider:PreloadAsync(Animation_File:GetChildren()) -- this preloads the assets and causes game to have all animation lengths correct on first attempt