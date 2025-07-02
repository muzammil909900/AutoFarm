-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window
local Window = Rayfield:CreateWindow({
	Name = "$mile Hub",
	LoadingTitle = "$mile Hub",
	LoadingSubtitle = "Connecting To $mile Hub...",
	KeySystem = true,
	KeySettings = {
		Title = "$mile Hub",
		Subtitle = "Key System",
		Note = "🎁 Key Link: https://rebrand.ly/sm-ke",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = "SM-KEY-986-312-343-2"
	}
})

-- Variables
local selectedAmount = "1K SHECKLES"
local webhookUrl = ""

-- Main Tab
local MainTab = Window:CreateTab("Dashboard", 4483362458)

MainTab:CreateParagraph({
	Title = "✨$mile Hub Instructions",
	Content = [[
Step 1: Select your goal from the dropdown  
Step 2: Paste your Discord webhook URL  
Step 3: Click "Start Farming"  
Step 4: Wait until your goal is completed  
A webhook embed will be sent once farming is done!
]]
})

MainTab:CreateDropdown({
	Name = "Select Goal",
	Options = {
		"1K SHECKLES", "100K SHECKLES", "1M SHECKLES", "100M SHACKLES",
		"1B SHECKLES", "5B SHECLES", "100B SHACKLES"
	},
	CurrentOption = "1K SHECKLES",
	Flag = "ShecklesDropdown",
	Callback = function(Option)
		selectedAmount = Option
	end,
})

MainTab:CreateInput({
	Name = "Webhook URL",
	PlaceholderText = "Paste your Discord Webhook URL...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		webhookUrl = Text
	end,
})

MainTab:CreateButton({
	Name = "Start Farming",
	Callback = function()
		startCleanAnimation(selectedAmount, webhookUrl)
	end,
})

-- Function
function startCleanAnimation(goal, webhook)
	local goals = {
		["1K SHECKLES"] = 1_000,
		["100K SHECKLES"] = 100_000,
		["1M SHECKLES"] = 1_000_000,
		["100M SHACKLES"] = 100_000_000,
		["1B SHECKLES"] = 1_000_000_000,
		["5B SHECLES"] = 5_000_000_000,
		["100B SHACKLES"] = 100_000_000_000
	}

	local target = goals[goal] or 1_000
	local sheckles = 0
	local speedPerSecond = 1000 / 60 -- 1K per minute
	local multiplier = 1
	local startTime = tick()

	local gui = Instance.new("ScreenGui", game.CoreGui)
	gui.Name = "SmileHubScreen"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	local blackBG = Instance.new("Frame", gui)
	blackBG.BackgroundColor3 = Color3.new(0, 0, 0)
	blackBG.Size = UDim2.new(1, 0, 1, 0)

	local counterText = Instance.new("TextLabel", blackBG)
	counterText.AnchorPoint = Vector2.new(0.5, 0.5)
	counterText.Position = UDim2.new(0.5, 0, 0.5, 0)
	counterText.Size = UDim2.new(1, 0, 0.3, 0)
	counterText.BackgroundTransparency = 1
	counterText.TextColor3 = Color3.fromRGB(180, 255, 180)
	counterText.TextScaled = true
	counterText.Font = Enum.Font.GothamBold
	counterText.Text = "0 SHECKLES"

	local RunService = game:GetService("RunService")
	local lastUpdate = tick()

	local heartbeatConn = RunService.Heartbeat:Connect(function()
		local now = tick()
		local delta = now - lastUpdate
		lastUpdate = now

		if sheckles < target then
			sheckles += speedPerSecond * multiplier * delta
			if sheckles > target then sheckles = target end
			counterText.Text = string.format("%.0f SHECKLES", sheckles)
		end
	end)

	task.spawn(function()
		while sheckles < target do
			wait(60)
			multiplier *= 2
		end
	end)

	task.spawn(function()
		repeat wait(1) until sheckles >= target

		local endTime = tick()
		local totalTime = math.floor(endTime - startTime)
		local minutes = math.floor(totalTime / 60)
		local seconds = totalTime % 60

		for i = 1, 6 do
			counterText.Text = (i % 2 == 0) and "GOAL COMPLETED!" or ""
			counterText.TextColor3 = Color3.fromRGB(0, 255, 127)
			wait(0.5)
		end
		counterText.Text = "GOAL COMPLETED\nPlease Rejoin."

		if webhook and webhook:match("^https://") then
			local HttpService = game:GetService("HttpService")
			local Players = game:GetService("Players")
			local username = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"

			local payload = {
				content = "",
				embeds = {{
					title = "🎉 Farming Goal Completed",
					color = 65280,
					fields = {
						{ name = "✅ Roblox Username", value = username, inline = true },
						{ name = "⏱️ Time Taken", value = string.format("%d minutes %d seconds", minutes, seconds), inline = true },
						{ name = "💰 Total Amount Earned", value = goal, inline = false },
					},
					footer = { text = "$mile Hub | Powered by LootLabs" },
					timestamp = DateTime.now():ToIsoDate()
				}}
			}

			pcall(function()
				request({
					Url = webhook,
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = HttpService:JSONEncode(payload)
				})
			end)
		end
	end)
end
