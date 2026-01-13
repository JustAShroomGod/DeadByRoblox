local Game_Data = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data') -- collect game_data folder (it is dependent)

local function deepCopy(original)
	local copy = {}

	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end

		copy[k] = v
	end

	return copy
end

local DefaultKeyboardKeys = {
	["Interact"] = 'Space',
	["Interact2"] = "MouseButton1",
	["Interact3"] = "MouseButton2",
	["Interact4"] = "E",
	["Interact5"] = "R",
	["Interact6"] = "One",
	["Interact7"] = "Two",
	["Interact10"] = "Q",
	["Interact11"] = "Tab",
	['Secondary_Power'] = "LeftControl",
}

local DefaultGamepad = {
	["Interact"] = 'ButtonA'; -- vault/loop interactions | must figure out a way to merge w/ interact 2
	["Interact2"] = 'ButtonR2'; -- primary interaction (gen)
	["Interact3"] = 'ButtonR1'; -- use items
	["Interact4"] = 'ButtonX'; -- Perk 1 Ability
	["Interact5"] = 'ButtonB'; -- drop button
	["Interact6"] = 'DPadUp'; -- emote point
	["Interact7"] = 'DPadDown'; -- emote follow
	["Interact10"] = 'ButtonY';
	["Interact11"] = 'ButtonSelect';
	['Secondary_Power'] = "ButtonL1",
}

local DefaultColors = {
	["Default"] = {
		Outline = {190, 0, 0}, 
		Fill = {220, 0, 0}
	};
	["Ally"] = {
		Outline = {255, 235, 0}, 
		Fill = {225, 205, 0}
	};
	["Hostile"] = {
		Outline = {190, 0, 0}, 
		Fill = {220, 0, 0}
	};
	["Objects"] = {
		Outline = {255, 255, 255}, 
		Fill = {225, 225, 225}
	};
	["Totems"] = {
		Outline = {0, 255, 255},
		Fill = {0, 225, 225}
	};
	["Special"] = {
		Outline = {255, 235, 0}, 
		Fill = {225, 205, 0}
	};
}

local KillerBinds = {
	Interact = { -- the buttons are circle so making x/y size different is pointless
		Button = "Primary";
		Size = {.65, .65};
		Position = {.8, .825};
	}; -- vault/loop interactions
	Interact2 = {
		Button = "Primary2";
		Size = {.425, .475};
		Position = {.585, -0.125};
	}; -- primary interaction
	Interact3 = {
		Button = "Item";
		Size = {.5, .5};
		Position = {.535, .34};
	}; -- use item?
	Interact4 = {
		Button = "Ability";
		Size = {.5, .5};
		Position = {.5, .825};
	}; -- Perk 1 Ability
	Interact5 = {
		Button = "Drop";
		Size = {.375, .375};
		Position = {.825, -0.55};
	}; -- drop button
	Secondary_Power = {
		Button = "Second Ability";
		Size = {.5, .5};
		Position = {.85, .825};
	},
	Deadzones = {};
}

local SurvivorBinds = { -- Mobile Buttons are Buttons so we will Use Size/Position instead of controls
	Interact = { -- the buttons are circle so making x/y size different is pointless
		Button = "Primary";
		Size = {.65, .65};
		Position = {.8, .825};
	}; -- vault/loop interactions
	Interact2 = {
		Button = "Primary2";
		Size = {.425, .475};
		Position = {.585, -0.125};
	}; -- primary interaction
	Interact3 = {
		Button = "Item";
		Size = {.5, .5};
		Position = {.535, .34};
	}; -- use item?
	Interact4 = {
		Button = "Ability";
		Size = {.5, .5};
		Position = {.5, .825};
	}; -- Perk 1 Ability
	Interact5 = {
		Button = "Drop";
		Size = {.375, .375};
		Position = {.825, -0.55};
	}; -- drop button
	Interact8 = {
		Button = "Sprint";
		Size = {.5, .5};
		Position = {.8, 0.28};
	}; -- Sprinting Toggle | MOBILE ONLY
	Interact9 = {
		Button = "Crouch";
		Size = {.375, .375};
		Position = {.825, -0.2};
	};-- Crouching Toggle | MOBILE ONLY
	Interact10 = {
		Button = "Ability2";
		Size = {.5, .5};
		Position = {.7, .700};
	};
	Interact6 = {
		Button = "Emote_1";
		Size = {.2, .2};
		Position = {.535, .6};
	};
	Interact7 = {
		Button = "Emote_2";
		Size = {.4, .4};
		Position = {.535, .4};
	};
	Deadzones = {};
}

local template = { -- Default Stuff DON'T CHANGE vvvv ----
	

	--Killer Basekit --
	killerDataTemplate = {
		Inventory = {
			Addons = {};
			Cosmetics = {};
			Offerings = {};
			Perks = {};
			Sounds = {};
		};
		Loadout = {
			Cosmetic = {
				Head = "";
				Torso = "";
				Weapon = "";
			};
			Addons = {
				Slot1 = "";
				Slot2 = "";
			};
			Offering = "";
			Sound_Pack = "Default";
			Perks = {
				Slot1 = "";
				Slot2 = "";
				Slot3 = "";
				Slot4 = "";
			};
		};
		Other = {
			Prestige = 0;
			Rank = 20;
			Rank_Settings = {
				Progress = 0;
				Time = 0;
				Timeout = 0 -- if 0 no timeout, if > 0 then there was a timeout because of a dc
			};
			Level = 1;
			Character = "trapper";
			Unlocked = false;
		};
		Misc = {
			Kills = 0; -- killer will be seperate
			Quests = {};
			Web = {};
		};
	};

	-- Main/Survivor Basekit --
	survivorDataTemplate = {
		Inventory = {
			Addons = {};
			Cosmetics = {};
			Items = {};
			Offerings = {};
			Perks = {};
			Emotes = {};
			Sounds = {};
		};
		Loadout = {
			Cosmetic = {
				Head = "";
				Torso = "";
				Legs = "";
			};
			Emotes = {
				['One'] = "Point";
				['Two'] = "Follow";
			},
			Item = {
				Addons = {
					Slot1 = "";
					Slot2 = "";
				};
				Class = "";
				Name = "";
			};
			Sound_Pack = "Default";
			Offering = "";
			Perks = {
				Slot1 = "";
				Slot2 = "";
				Slot3 = "";
				Slot4 = "";
			};
		};
		Other = {
			Blockpoints = 0;
			Ban = {
				Banned = false;
				Time = {
					Started = 0; -- time ban was started
					Length = -1; -- -1 will be inf
				},
				Reason = "";
			};
			Settings = {
				REGION = "Any"; -- used for better matchmaking
				MATCHMAKING = "QUICK"; -- QUICK OR RANK
				
				-->> above being depricated in settings << --
				PERFORMANCE_MODE = false;
				VISUALIZE_ATTACKS = false;
				
				SOUND = {
					Volume = {
						Master = 10;
						SFX = 5;
						Music = 5;
					},
				},
				AUDIO = true;
				PLATFORM = "Auto"; -- auto-detect | keyboard | console | touch
				CAMERA = {
					Mode = 2; -- camera-mode for mobile
					Sensitivity = { -- Custom Sens
						X = 10;
						Y = 10;
					},
				},
				KEYBINDS = {
					Killer = {
						Keyboard = deepCopy(DefaultKeyboardKeys); -- keys
						Console = deepCopy(DefaultGamepad); -- buttons
						Mobile = KillerBinds; -- size/position/transparency
					};
					Survivor = {
						Keyboard = deepCopy(DefaultKeyboardKeys); -- keys
						Console = deepCopy(DefaultGamepad); -- buttons
						Mobile = SurvivorBinds; -- size/position/transparency
					};
				},
				COLORS = {
					Killer = deepCopy(DefaultColors);
					Survivor = deepCopy(DefaultColors);
					SkillCheck = {52, 116, 42}, {255, 255, 255};
				}, 
			};
			Killer = "trapper";
			Prestige = 0;
			Rank = 20;
			Rank_Settings = {
				Progress = 0;
				Time = 0; 
				Timeout = 0 -- if 0 no timeout, if > 0 then there was a timeout because of a dc
			};
			Level = 1;
		};
		Misc = {
			Quest_Selection = {
				Weekly = {
					Time = 0;
					Slot1 = {
						Character = ""; --Trapper,Wraith.. or Survivor
						Name = "";
						Completed = false
					};
					Slot2 = {};
					Slot3 = {}
				};
				Daily = {
					Time = 0;
					Slot1 = {
						Character = ""; --Trapper,Wraith.. or Survivor
						Name = "";
						Completed = false
					};
					Slot2 = {};
					Slot3 = {}
				};
			};
			Transferred = false; -- if they data-transferred or not
			Escapes = 0; -- 0 escapes to start with
			Quests = {};
			Web = {};
			Codes = {}; -- for codes
			Creation = workspace:GetServerTimeNow(); -- started playing dead by roblox on this moment!
			Tutorial = {
				Survivor = false; -- has not completed tutorial teleport them there!
				Killer = false; -- has not completed tutorial teleport them there!
			},
			
			MMK = {
				Code = 0; -- Future MMK
				Custom = {
					Enabled = false;
					Friend = false;
					Password = false;
					Mode = false;
					Map = false;
				};
				Pro = {
					DC_Count = 0; -- add +1 to this when dcing game unsafely | at some point you just can't use pro anymore
					Last_DC = 0; -- set this to workspace now upon joining game (so you can't just crash your way out) / hour wait between each dc
					Enabled = false; -- if pro-mmk is enabled or not
				},
				Region = "Any";
				Team = "Survivor";
			}
		};
	};
}


function template:GetDefault()
	local Data = {}

	Data["Main"] = deepCopy(template.survivorDataTemplate)

	local baseTemplate = Data['Main']
	
	for _, cosmetic_module in pairs(Game_Data:WaitForChild('Cosmetics'):WaitForChild('Survivor'):GetChildren()) do
		if not require(cosmetic_module).Active then continue end -- not active skip over
		baseTemplate.Inventory.Cosmetics[cosmetic_module.Name] = {}
		
		for _, set_part in pairs(require(cosmetic_module).Content) do
			baseTemplate.Inventory.Cosmetics[cosmetic_module.Name][set_part] = require(cosmetic_module).Unlocked -- if unlocked by default will be true if not then not
		end
	end

	for _, emote_module in pairs(Game_Data:WaitForChild('Emotes'):GetChildren()) do
		if not require(emote_module).Active then continue end -- not active skip over
		emote_module = require(emote_module)
		
		baseTemplate.Inventory.Emotes[emote_module.Data_Name] = emote_module.Unlocked; -- does not have emote unlocked
	end

	for _, offering_module in pairs(Game_Data:WaitForChild('Offerings'):WaitForChild('Survivor'):GetChildren()) do
		if not require(offering_module).Active then continue end -- not active skip over
		
		baseTemplate.Inventory.Offerings[offering_module.Name] = 0 -- insert module offering into datastore if active
	end
	
	
	
	for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):FindFirstChild('Survivor'):GetChildren()) do
		if not require(perk_module).Active then continue end -- not activaed skip over this perk for now
		
		baseTemplate.Inventory.Perks[perk_module.Name] = 0 -- backfill perk if it's a module and set to active
	end
	
	for _, item_module in pairs(Game_Data:WaitForChild('Items'):GetChildren()) do -- imports items and addon class types?
		if not require(item_module).Active then continue end
		item_module = require(item_module)
		
		if not baseTemplate.Inventory.Items[item_module.Class] then
			baseTemplate.Inventory.Items[item_module.Class] = {}
		end

		if not baseTemplate.Inventory.Addons[item_module.Class] then
			baseTemplate.Inventory.Addons[item_module.Class] = {}
		end
		
		baseTemplate.Inventory.Items[item_module.Class][item_module.Variant] = 0
	end
	
	-- TODO: Create a addon importer/counter
	for _, addon_module in pairs(Game_Data:WaitForChild('Addons'):WaitForChild('Survivor'):GetChildren()) do
		if not require(addon_module).Active then continue end -- not active skip over
		addon_module = require(addon_module)
		if baseTemplate.Inventory.Addons[addon_module.Class] then
			baseTemplate.Inventory.Addons[addon_module.Class][addon_module.Data_Name] = 0
		end
	end


	local function CraftKillerTemplate(killer_module : "module")
		local baseTemplate = deepCopy(template.killerDataTemplate)
		
		baseTemplate.Other.Character = string.lower(killer_module.Name)
		baseTemplate.Other.Unlocked =require(killer_module).Unlocked

		for _, perk_module in pairs(Game_Data:WaitForChild('Perks'):WaitForChild('Killer'):GetChildren()) do
			if not require(perk_module).Active then continue end

			baseTemplate.Inventory.Perks[perk_module.Name] = 0 -- creat perk slot
		end

		for _, addon_module in pairs(require(killer_module).Addons) do
			if not addon_module.Active then continue end -- skip over non active addons

			baseTemplate.Inventory.Addons[addon_module.Data_Name] = 0
		end

		for _, offering_module in pairs(require(killer_module).Offerings) do
			if not offering_module.Active then continue end -- not active skip over
			
			baseTemplate.Inventory.Offerings[offering_module.Data_Name] = 0 -- insert into datastore if active
		end
		
		for _, cosmetic_module in pairs(Game_Data:WaitForChild('Cosmetics'):WaitForChild('Killer'):GetChildren()) do
			if not require(cosmetic_module).Active then continue end -- not active skip over
			if not table.find(require(cosmetic_module).Killers, killer_module) then continue end -- killer is not a part of this cosmetic
			baseTemplate.Inventory.Cosmetics[cosmetic_module.Name] = {}

			for _, set_part in pairs(require(cosmetic_module).Content) do
				baseTemplate.Inventory.Cosmetics[cosmetic_module.Name][set_part] = require(cosmetic_module).Unlocked -- if unlocked by default will be true if not then not
			end
		end
		
		return baseTemplate
	end

	for _, killer_module in pairs(Game_Data:WaitForChild('Killers'):GetChildren()) do
		if not require(killer_module).Active then continue end -- not a active killer skip over
		
		Data[string.lower(killer_module.Name)] = CraftKillerTemplate(killer_module)
	end
	
	return Data
end

return template
