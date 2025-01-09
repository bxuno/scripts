--[[
    Brought to you by tar/bv/1rs
    beta - 29jul24 - [unreleased/private] very barebones, newfound dupe method
    1.00 - 16sep24 - [unreleased/private] semi-automated required manual server id inputs
    1.01 - 05dec24 - released, no longer required manual server id inputting
    1.02 - 08dec24 - uploaded to github, changed from 35s to 40s
    1.03 - 08dec24 - removed extra 40s measure on first rejoin
    1.04 - 08dec24 - brought it back, removed UI trade updating to avoid lag
    1.05 - 08dec24 - added variable MAX_PETS_TO_DUPE to avoid network lag to not fail duping
    1.06 - 08dec24 - changed server size minimum 1 -> 2
    1.07 - 10dec24 - added ui interface - used "GUI to Lua 3.2" & some code snippet to make the frame draggable
    1.08 - 11dec24 - minor fixes
    1.09 - 11dec24 - added a block thingy for the toggle
    1.10 - 12dec24 - fixed max pets to give problem, added autotoggle if trades are disabled, replaced required() because some exploits don't support it
    1.11 - 22dec24 - changed to 45s and removed the other waiting, added yet another QoL warning
    1.12 - 26dec24 - added a duping possibility meter
    1.13 - 28dec24 - added inventory ui deletion to avoid performance lag while duping many pets
    1.14 - 29dec24 - fixed post-teleport execution if injected too early
    1.15 - 01jan25 - changed the duping chance meter parameters and fixed a bug with the dupe button
]]

-- //

local Ver = '1.15'

-- \\

local selected_IDs = {}
local mode = 0
local SERVER = nil
local MAX_PETS_TO_DUPE = 125
local ACC_TO_GIVE_PETS = ''
local Debris = game:GetService'Debris'
local TeleportService = game:GetService'TeleportService'
local H = Instance.new("Hint")
H.Text = 'Finding another server'

function notify(M)
	game.StarterGui:SetCore("SendNotification", {
		Title = "tar's dupe v"..Ver,
		Text = M,
		Duration = 5
	})
end

local Dir = {
	[77002] = 'Festive Dragon',
	[9004] = 'Wavy Cheeta',
	[7004] = 'Dragon',
	[8004] = 'Demon',
	[5004] = 'Bat',
	[6004] = 'Ladybug',
	[66010] = 'Skeleton Ghost',
	[4004] = 'Seal',
	[14001] = 'Revurse',
	[2004] = 'Mouse',
	[16012] = 'Cyborg Dominus',
	[16010] = 'C0RE',
	[77003] = 'Snow Spike',
	[15005] = 'Green Gummy Bear',
	[13007] = 'Space Dragon',
	[10004] = 'Electric Slime',
	[66002] = 'Zombie Dog',
	[76002] = 'Festive Dog',
	[15008] = 'Rainbow',
	[16002] = 'Cyborg Dog',
	[12003] = 'Angel',
	[13001] = 'Alien',
	[15010] = 'Ame Damnee',
	[17003] = 'Dominus Noob',
	[66003] = 'Spider',
	[12007] = 'Mortuus',
	[12005] = 'Ice Queen',
	[11004] = 'Lava Watermelon',
	[76004] = 'Festive Racoon',
	[66004] = 'Pumpkin',
	[16006] = 'Red Space Ranger',
	[16001] = 'Cyborg Cat',
	[11002] = 'Sherbert',
	[76001] = 'Festive Cat',
	[66001] = 'Zombie Cat',
	[79003] = 'Giant Penguin',
	[15007] = 'Cookie',
	[1001] = 'Cat',
	[3001] = 'Dalmatian',
	[2001] = 'Brown Cat',
	[5001] = 'Owl',
	[90010] = 'Huge Cat',
	[7001] = 'Watermelon',
	[6001] = 'Cheeta',
	[9001] = 'Fantasy Dragon',
	[8001] = 'Bomb',
	[66006] = 'Ghostdeeri',
	[12004] = 'Fire King',
	[90003] = 'Red Snake',
	[78002] = 'Gingerbread',
	[90004] = 'Purple Snake',
	[10003] = 'Lava Turtle',
	[15001] = 'Candy Cane',
	[18002] = 'Spike',
	[90011] = 'Giant Mortuus',
	[17009] = 'Dominus Huge',
	[78003] = 'Reindeer',
	[2005] = 'White Bunny',
	[1005] = 'Orange Cat',
	[10002] = 'Lava Dalmatian',
	[8005] = 'Cyclops',
	[9005] = 'Wavy Tiger',
	[4005] = 'Racoon',
	[90002] = 'Green Snake',
	[78004] = 'Festive Dominus',
	[5005] = 'Bee',
	[18006] = 'Agony',
	[90006] = 'Dominus Partner',
	[66007] = 'Sorrow',
	[14003] = 'Space Owl',
	[17007] = 'Dominus Rainbow',
	[90001] = 'BIG Maskot',
	[11005] = 'Wavy Bee',
	[10006] = 'Dominus Messor',
	[14004] = 'Space Cyclops',
	[17001] = 'Dominus Pumpkin',
	[12002] = 'Reaper',
	[2002] = 'White Cat',
	[3002] = 'Bear',
	[4002] = 'Crocodile',
	[5002] = 'Monkey',
	[6002] = 'Tiger',
	[7002] = 'Yeti',
	[8002] = 'Ghost',
	[9002] = 'Cherry Bomb',
	[11006] = 'Unicorn',
	[18005] = 'Hydra',
	[77001] = 'Festive Seal',
	[16011] = 'C0RE SH0CK',
	[18004] = 'Chimera',
	[1002] = 'Dog',
	[12006] = 'Immortuos',
	[18001] = 'Aesthetic Cat',
	[14009] = '1NE',
	[18003] = 'Magic Fox',
	[17006] = 'Dominus Damnee',
	[17008] = 'Dominus Electric',
	[16004] = 'Cyborg',
	[17002] = 'Dominus Cherry',
	[10008] = 'Dominus Empyreus',
	[14007] = 'Dark Saturn',
	[17005] = 'Dominus HeadStack',
	[13003] = 'Wooga',
	[16003] = 'Computer',
	[16007] = 'Friendly Cyborg',
	[16009] = 'Cyborg Demon',
	[12001] = 'Tank',
	[16008] = 'RoVer',
	[16005] = 'Space Ranger',
	[15004] = 'Green Lollipop',
	[66008] = 'Willow Wisp',
	[13005] = 'Space Dog',
	[66009] = 'Willow Wisp Green',
	[90007] = 'Love Dog',
	[11003] = 'Robot',
	[1004] = 'Lamb',
	[10001] = 'Lava Zebra',
	[14005] = 'Space Bear',
	[90008] = 'Noob',
	[15009] = 'Dark Candy Corn',
	[77004] = 'Ice Spike',
	[13004] = 'Space Cat',
	[15002] = 'Candy Corn',
	[15011] = 'Domortuus',
	[13006] = 'Space Bunny',
	[15006] = 'Yellow Gummy Bear',
	[78001] = 'Festive Ame Damnee',
	[8003] = 'Cherry Monkey',
	[14008] = 'ZER0',
	[14006] = 'Saturn',
	[17004] = 'Dominus Wavy',
	[14002] = 'HeadStack',
	[13002] = 'Puffer',
	[76003] = 'Festive Bunny',
	[3004] = 'Pig',
	[15003] = 'Red Lollipop',
	[78005] = 'Randolph',
	[10007] = 'Dominus Frigidus',
	[66005] = 'Skeleton',
	[6003] = 'Zebra',
	[5003] = 'Turtle',
	[4003] = 'Platypus',
	[3003] = 'Polar Bear',
	[2003] = 'White Dog',
	[1003] = 'Bunny',
	[11001] = 'Zombie',
	[10005] = 'Electric Ghost',
	[7003] = 'Slime',
	[3005] = 'Panda',
	[79002] = 'Festive C0RE',
	[4001] = 'Koala',
	[90009] = 'Love Cat',
	[9003] = 'Wavy Zebra',
	[79001] = 'Festive Immortuos',
	[90005] = 'Wavy Snake'
}

do  -- // GUI

	-- Gui to Lua
	-- Version: 3.2
	
	-- Instances:
	
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIGridLayout = Instance.new("UIGridLayout")
	local dupe = Instance.new("TextButton")
	local all = Instance.new("TextButton")
	local TextLabel_2 = Instance.new("TextLabel")
	local pets = Instance.new("TextBox")
	local specific = Instance.new("TextButton")
	local TextLabel_3 = Instance.new("TextLabel")
	local acc = Instance.new("TextBox")
	local TextLabel_4 = Instance.new("TextLabel")

	--Properties:

	Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 5)

	ScreenGui.Parent = game.CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	do -- // draggable snippet not made by me \\
		local UserInputService = game:GetService("UserInputService")

		local gui = Frame

		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end -- \\ draggable snippet not made by me //

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.38648814, 0, 0.13872759, 0)
	Frame.Size = UDim2.new(0, 373, 0, 459)
	Frame.ZIndex = 2

	TextLabel.Parent = Frame
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(1, 0, 0, 50)
	TextLabel.Font = Enum.Font.Cartoon
	TextLabel.Text = "tar's dupe v"..Ver
	TextLabel.TextColor3 = Color3.fromRGB(218, 218, 218)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14.000
	TextLabel.TextWrapped = true

	ScrollingFrame.Parent = Frame
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 0.500
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Position = UDim2.new(0.0428954437, 0, 0.287581712, 0)
	ScrollingFrame.Size = UDim2.new(0, 340, 0, 278)
	ScrollingFrame.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	
	UIGridLayout.Parent = ScrollingFrame
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	UIGridLayout.CellSize = UDim2.new(1, -12, 0, 20)

	dupe.Name = "dupe"
	dupe.Parent = Frame
	dupe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dupe.BackgroundTransparency = 0.500
	dupe.BorderColor3 = Color3.fromRGB(0, 0, 0)
	dupe.BorderSizePixel = 0
	dupe.Position = UDim2.new(0.793565691, 0, 0.126361653, 0)
	dupe.Size = UDim2.new(0, 60, 0, 58)
	dupe.Font = Enum.Font.Cartoon
	dupe.Text = "doope"
	dupe.TextColor3 = Color3.fromRGB(0, 0, 0)
	dupe.TextSize = 14.000

	all.Name = "all"
	all.Parent = Frame
	all.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	all.BackgroundTransparency = 0.500
	all.BorderColor3 = Color3.fromRGB(0, 0, 0)
	all.BorderSizePixel = 0
	all.Position = UDim2.new(0.0428954437, 0, 0.126361653, 0)
	all.Size = UDim2.new(0, 20, 0, 20)
	all.Font = Enum.Font.Cartoon
	all.Text = "X"
	all.TextColor3 = Color3.fromRGB(0, 0, 0)
	all.TextSize = 14.000

	TextLabel_2.Parent = Frame
	TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_2.BackgroundTransparency = 1.000
	TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel_2.BorderSizePixel = 0
	TextLabel_2.Position = UDim2.new(0.1152815, 0, 0.126361653, 0)
	TextLabel_2.Size = UDim2.new(0.436997324, 0, -0.0653594807, 50)
	TextLabel_2.Font = Enum.Font.Cartoon
	TextLabel_2.Text = "Dupe X amount of pets:"
	TextLabel_2.TextColor3 = Color3.fromRGB(218, 218, 218)
	TextLabel_2.TextSize = 17.000
	TextLabel_2.TextWrapped = true

	pets.Name = "pets"
	pets.Parent = Frame
	pets.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pets.BackgroundTransparency = 0.500
	pets.BorderColor3 = Color3.fromRGB(0, 0, 0)
	pets.BorderSizePixel = 0
	pets.Position = UDim2.new(0.579088449, 0, 0.126361653, 0)
	pets.Size = UDim2.new(0, 60, 0, 20)
	pets.ClearTextOnFocus = false
	pets.Font = Enum.Font.SourceSans
	pets.Text = MAX_PETS_TO_DUPE
	pets.TextColor3 = Color3.fromRGB(0, 0, 0)
	pets.TextSize = 14.000

	specific.Name = "specific"
	specific.Parent = Frame
	specific.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	specific.BackgroundTransparency = 0.500
	specific.BorderColor3 = Color3.fromRGB(0, 0, 0)
	specific.BorderSizePixel = 0
	specific.Position = UDim2.new(0.0428954437, 0, 0.193899781, 0)
	specific.Size = UDim2.new(0, 20, 0, 20)
	specific.Font = Enum.Font.Cartoon
	specific.Text = ""
	specific.TextColor3 = Color3.fromRGB(0, 0, 0)
	specific.TextSize = 14.000

	TextLabel_3.Parent = Frame
	TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_3.BackgroundTransparency = 1.000
	TextLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel_3.BorderSizePixel = 0
	TextLabel_3.Position = UDim2.new(0.1152815, 0, 0.193899781, 0)
	TextLabel_3.Size = UDim2.new(0.436997324, 0, -0.0653594807, 50)
	TextLabel_3.Font = Enum.Font.Cartoon
	TextLabel_3.Text = "Dupe specific pets"
	TextLabel_3.TextColor3 = Color3.fromRGB(218, 218, 218)
	TextLabel_3.TextSize = 17.000
	TextLabel_3.TextWrapped = true

	acc.Name = "acc"
	acc.Parent = Frame
	acc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	acc.BackgroundTransparency = 0.500
	acc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	acc.BorderSizePixel = 0
	acc.Position = UDim2.new(0.619302928, 0, 0.921568632, 0)
	acc.Size = UDim2.new(0, 114, 0, 20)
	acc.Font = Enum.Font.SourceSans
	acc.PlaceholderColor3 = Color3.fromRGB(50, 50, 50)
	acc.PlaceholderText = "Username"
	acc.Text = ""
	acc.TextColor3 = Color3.fromRGB(0, 0, 0)
	acc.TextSize = 14.000

	TextLabel_4.Parent = Frame
	TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_4.BackgroundTransparency = 1.000
	TextLabel_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel_4.BorderSizePixel = 0
	TextLabel_4.Position = UDim2.new(0.0428954437, 0, 0.921568632, 0)
	TextLabel_4.Size = UDim2.new(0.536193073, 0, -0.0653594807, 50)
	TextLabel_4.Font = Enum.Font.Cartoon
	TextLabel_4.Text = "Account to give pets to:"
	TextLabel_4.TextColor3 = Color3.fromRGB(218, 218, 218)
	TextLabel_4.TextSize = 17.000
	TextLabel_4.TextWrapped = true
	
	local block = Instance.new('Frame', Frame)
	block.Visible = true
	block.BackgroundTransparency = .2
	block.BorderSizePixel = 0
	block.Position = ScrollingFrame.Position
	block.Size = ScrollingFrame.Size
	block.ZIndex = ScrollingFrame.ZIndex + 1
	block.BackgroundColor3 = Color3.new(0.5115, 0.5115, 0.5115)

	local colorz = {
		['true'] = Color3.fromRGB(0, 130, 180),
		['nil'] = Color3.new(.8, .8, .8)
	}
	
	local function LoadPets()
		for _, v in pairs(ScrollingFrame:GetChildren()) do
			if v:IsA'TextButton' then
				v:Destroy()
			end
		end
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

		task.wait(.5)
		
		local Pets = workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets
	
		table.sort(Pets, function(a, b) return tonumber(a.xp) > tonumber(b.xp) end)
		
		local fn = function(number)
			if not number then return 'nil' end
			local formatted = tostring(number)
			local k
			while true do
				formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
				if k == 0 then
					break
				end
			end
			return formatted
		end
	
		for _, v in pairs(Pets) do
			local b = Instance.new('TextButton', ScrollingFrame)
			local prefix = v.dm and v.r and'Glitched'or v.dm and'Dark Matter'or v.r and'Rainbow'or v.g and'Gold'or'Regular'
			b.Text = ' ' .. fn(v.l) .. ' | ' .. prefix .. ' ' .. Dir[tonumber(v.n)]
			b.Font = Enum.Font.Cartoon
			b.TextSize = 15
			b.BackgroundColor3 = colorz[tostring(selected_IDs[v.id])]
			b.TextXAlignment = 'Left'
			b.BackgroundTransparency = .5
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollingFrame.CanvasSize.Y.Offset + 20)
			b.MouseButton1Click:Connect(function()
				if selected_IDs[v.id] then
					selected_IDs[v.id] = nil
				else
					selected_IDs[v.id] = true
				end
				b.BackgroundColor3 = colorz[tostring(selected_IDs[v.id])]
			end)
		end
	end
	
	local Refresh = dupe:Clone()
	Refresh.Size = pets.Size
	Refresh.Position = UDim2.new(pets.Position.X.Scale, 0, TextLabel_3.Position.Y.Scale, 0)
	Refresh.Text = 'Refresh'
	Refresh.Parent = Frame
	Refresh.MouseButton1Click:Connect(LoadPets)
	
	LoadPets()

	all.MouseButton1Click:Connect(function()
		all.Text = 'X'
		specific.Text = ''
		mode = 0
		block.Visible = true
	end)

	specific.MouseButton1Click:Connect(function()
		all.Text = ''
		specific.Text = 'X'
		mode = 1
		block.Visible = false
	end)
	
	pets:GetPropertyChangedSignal'Text':connect(function()
		local N = tonumber(pets.Text)
		N = N or 0
		local Value = math.ceil(N)
		if Value == nil or Value <= 0 then
			Value = 1
		elseif Value > 665 then
			Value = 665
		end
		pets.Text = Value
		MAX_PETS_TO_DUPE = Value
	end)
	
	acc:GetPropertyChangedSignal'Text':connect(function()
		ACC_TO_GIVE_PETS = acc.Text 
	end)
	
	local ready = false
	local deb = false
	dupe.MouseButton1Click:Connect(function()
		if deb then return end
		deb = true

		if not game.Players:FindFirstChild(ACC_TO_GIVE_PETS) then
			notify"Player isn't in game"
			deb = false
			return
		else
			if game.Players.LocalPlayer.Name == ACC_TO_GIVE_PETS then
				notify"Can't do it on yourself"
				deb = false
				return
			end
		end
		if not queue_on_teleport then 
			notify"Your exploit doesn't support queue_on_teleport()"
			deb = false
			return
		end
		if not http_request then
			notify"Your exploit doesn't support httprequest()"
			deb = false
			return
		end
		if #workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets < 2 then
			notify"You need to have more than 1 pet"
			deb = false
			return
		end
		
		H.Parent = workspace
		-- servers
		local servers = {}

		local body = game:service'HttpService':JSONDecode(game:HttpGet'https://games.roblox.com/v1/games/1599679393/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true')

		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing >= 2 and v.id ~= game.JobId then
					servers[#servers+1] = v
				end
			end
		end

		table.sort(servers, function(a, b) return a.playing < b.playing end)

		if #servers > 0 then
			SERVER = servers[1].id
		else
			H.Parent = nil
			notify"Couldn't find a new server"
			return
		end
		
		ready = true
	end)
	
	repeat wait() until ready
end

H.Text = "tar's dupe v" .. Ver .. " | [1/4] Teleporting to a different server"

local IDs = ""

if mode == 0 then
	local totalToSend = 0
	local Pets = workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets
	table.sort(Pets, function(a, b) return tonumber(a.xp) > tonumber(b.xp) end)
	for _, v in pairs(Pets) do
		totalToSend = totalToSend + 1

		IDs = IDs .. v.id .. ','

		if totalToSend == MAX_PETS_TO_DUPE then
			break
		end
	end
elseif mode == 1 then
	for id, _ in pairs(selected_IDs) do
		IDs = IDs .. id .. ','
	end
end


queue_on_teleport([==[
    repeat task.wait() until game:IsLoaded()
	
    local h = Instance.new('Hint',workspace)
    --for i = 35, 0, -1 do
    --    h.Text = '[2/4] ' .. i
    --    task.wait(1)
    --end
    h.Text = '[2/4] Teleporting back..'

    local tptimestamp = os.clock()

    queue_on_teleport([=[
	repeat task.wait() until game:IsLoaded()

	pcall(function()
                hookfunction(getsenv(game.Players.LocalPlayer:WaitForChild'PlayerGui':WaitForChild'Scripts':WaitForChild'GUIs':WaitForChild'Trading').UpdateTrade, function() end)
        end)
	pcall(function()
		game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Pets:Destroy()
	end)
	local IDs = {]==] .. IDs .. [==[}
        local hint = Instance.new('Hint', workspace)
	hint.Text = '[3/4] Trading pets to account'

	local tptimestamp = ]=] .. tptimestamp .. [=[
	function perc()
		local sec = 15
		local delta = os.clock() - tptimestamp - (40-sec)
		if delta < 0 then
			delta = 0
		end
		return (string.format("%.1f",(100 - ((math.min(delta, sec)/sec)*100))) .. '%')
	end
	task.spawn(function()
		while task.wait() do
			hint.Text = '[3/4] Trading pets to account | Dupe chance: ' .. perc() .. ' | ' .. string.format("%.1f",(os.clock() - tptimestamp)) .. ' elapsed'
		end
	end)
        local T, lastTradeId = workspace:WaitForChild'__REMOTES':WaitForChild'Game':WaitForChild'Trading', nil
	
	local PLR = game.Players[']==] .. ACC_TO_GIVE_PETS .. [==[']
        
        game:FindFirstChild('Trade Update', true).OnClientEvent:Connect(function(id, data, operation)
            lastTradeId = id
        end)
        
	if not workspace.__REMOTES.Core['Get Stats']:InvokeServer().Save.TradingEnabled then
		workspace.__REMOTES.Game.Trading:InvokeServer("ToggleTrading")
	end

        repeat task.wait(.25) until T:InvokeServer("InvSend", PLR) == true
        
        repeat task.wait() until lastTradeId
        
        local PLR_PET_COUNT = #workspace.__REMOTES.Core["Get Other Stats"]:InvokeServer()[PLR.Name].Save.Pets
        
        local TotalIn = 0
        for _, id in pairs(IDs) do
            task.spawn(function()
                T:InvokeServer("Add", lastTradeId, id)
		TotalIn = TotalIn + 1
            end)
        end
        
        repeat task.wait(.1) until #IDs == TotalIn
        
        workspace.__REMOTES.Game.Trading:InvokeServer("Ready", lastTradeId)
        
        repeat task.wait(0.1) until PLR_PET_COUNT < #workspace.__REMOTES.Core["Get Other Stats"]:InvokeServer()[PLR.Name].Save.Pets
        
        queue_on_teleport([[
	    repeat task.wait() until game:IsLoaded()
            local h = Instance.new('Hint',workspace)
            for i = 45, 0, -1 do
                h.Text = '[4/4] ' .. i
                task.wait(1)
            end
            h.Text = "[4/4] Teleporting.. (If it failed to teleport it's okay because your data already saved)"

            queue_on_teleport("repeat task.wait() until game:IsLoaded()local h = Instance.new('Hint',workspace) h.Text = 'Done' wait(10) h:Destroy()")

            game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==] .. game.JobId .. [==[", game.Players.LocalPlayer)
        ]])
        game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==] .. SERVER .. [==[", game.Players.LocalPlayer)
    ]=])
game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==].. game.JobId .. [==[", game.Players.LocalPlayer)
]==])
TeleportService:TeleportToPlaceInstance(game.PlaceId, SERVER, game.Players.LocalPlayer)