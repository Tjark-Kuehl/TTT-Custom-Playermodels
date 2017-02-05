if SERVER then
	-- playerModels for traitor and innocent, detectiveModels for detective
	modelSave = { }
	playerModels = { }
	detectiveModels = { }

	-- Skin set hooks at preperation, begin and end
	hook.Add("Initialize", "CustomPlayermodelsSetup", function()
		ConsoleMsg("Initialized addon!")
		CreateDefaultConfigIfNotExist()
		LoadConfig()
	end)

	hook.Add("TTTPrepareRound", "SetPrepareModels", function()
		--Updating config data
		LoadConfig()
		--Timer to set the playermodel at the preparation time
		modelSave = { }
		timer.Simple(0.2, function()
			for _, player in pairs(player.GetAll()) do
				SetNewPlayermodel(player)
			end
		end)
		--Create check timer that check the player model every 5 seconds
		timer.Create("Timer_CheckPlayermodel", 2, 0, function()
			for _, player in pairs(player.GetAll()) do
				if not IsValidPlayermodel(player, player:GetModel()) then
					SetNewPlayermodel(player)
				end
			end
		end)
	end)

	hook.Add("TTTBeginRound", "SetBeginModels", function() --Set models again and set detective model.
		timer.Simple(0.2, function()
			for _, player in pairs(player.GetAll()) do
				if not IsStringValid(modelSave[player:SteamID()]) or player:IsActiveDetective() then
					SetNewPlayermodel(player)
				end
			end
		end)
	end)

	hook.Add("TTTEndRound", "SetEndModels", function() --Set models again because they reset...
		timer.Destroy("Timer_CheckPlayermodel")
		timer.Simple(0.2, function()
			for _, player in pairs(player.GetAll()) do
				if IsStringValid(modelSave[player:SteamID()]) then
					player:SetModel(modelSave[player:SteamID()])
				end
			end
		end)
	end)

	-- END

	function IsValidPlayermodel(player, model)
		if player:IsActiveDetective() then
			for k in pairs(detectiveModels) do
				if string.match(detectiveModels[k], model, 0) then
					return true
				end
			end
		else
			for k in pairs(playerModels) do
				if string.match(playerModels[k], model, 0) then
					return true
				end
			end
		end
		return false
	end

	function SetNewPlayermodel(player)
		if player:Alive() then
			if player:IsActiveDetective() then
				local model = table.Random(detectiveModels)
				modelSave[player:SteamID()] = model
				player:SetModel(model)
			else
				local model = table.Random(playerModels)
				modelSave[player:SteamID()] = model
				player:SetModel(model)
			end
		end
	end

	function CreateDefaultConfigIfNotExist()
		-- Definition of the default table wit css models
		local defaultTable = {
			player1 = "models/player/phoenix.mdl", player2 = "models/player/arctic.mdl",
			player3 = "models/player/guerilla.mdl", player4 = "models/player/leet.mdl",
			detective1 = "models/player/ct_gign.mdl", detective2 = "models/player/ct_gsg9.mdl",
			detective3 = "models/player/ct_sas.mdl", detective4 = "models/player/ct_urban.mdl",
		}
		-- Check if config file exist
		if not file.Exists("ttt_custom_playermodels.txt", "DATA") then
				file.Write("ttt_custom_playermodels.txt", util.TableToJSON(defaultTable))
				ConsoleMsg("Created default config.")
		end
	end

	function LoadConfig()
		playerModels = { }
		detectiveModels = { }
		if file.Exists("ttt_custom_playermodels.txt", "DATA") then
			ConsoleMsg("Loading config!")
			local fileRead = file.Read("ttt_custom_playermodels.txt", "DATA")
			local modelTable = util.JSONToTable(fileRead)
			for key, value in pairs(modelTable) do
				if string.find(string.lower(key), "player") then
					LoadPlayermodel("player", value)
				elseif string.find(string.lower(key), "detective") then
					LoadPlayermodel("detective", value)
				end
			end
		else
			ConsoleMsg("Config file doesnt exist.. creating")
			CreateDefaultConfigIfNotExist()
		end
	end

	function LoadPlayermodel(tableName, model)
		if tableName == "player" then table.insert(playerModels, model)
		elseif tableName == "detective" then table.insert(detectiveModels, model) end
		util.PrecacheModel(model) -- Precache the Model
		resource.AddFile(model) -- Adding model to download list
	end

	function IsStringValid(str)
	  if str ~= nil and str ~= '' and str ~= ' ' then
	    return true
	  end
	end

	function ConsoleMsg(text)
		print("[TTT-Playermodels] " .. text)
	end
end
