-- made with love by myzsyn

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

local t = tick()

repeat task.wait() until workspace.Enemies:FindFirstChild("Enemy") or tick() - t >= 10

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ditchmethis/UI-/main/uilib2.lua"))()
local venyx = library.new("TRAVERSAL by myzsyn", 5013109572)

-- // vars
local LocalPlayer = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:service('HttpService')
local PlaceId = game.PlaceId
local animationInfo = {}

local AnimNames = {
    'AttackOne',
    'AttackTwo',
    'AttackThree',
    'AttackFour',
    'Untitled', 
}

local WeaponNames = {
    'Machete',
    'Axe',
    'Bat'
}

local allWeapons = {
    'Machete',
    'Axe',
    'Bat',
    'Knife'
}

local apArgsOn = {
    [1] = {
        [1] = {
            [1] = "\13",
            [2] = "True"
        }
    }
}

local apArgsOff = {
    [1] = {
        [1] = {
            [1] = "\13",
            [2] = "False"
        }
    }
}

local Settings = {
    -- // auto-parry
    apdist = 1,
    apenabled = false,

    -- // weapon manipulation
    swingspeedEnabled = false,
    swingspeed = 0.1,
    noweapondrain = false,
    infdmg = false,

    -- // npcs
    espEnabled = false,
}

--// config

makefolder("Traversal")

function SaveSettings()
	local JSON
	JSON = HttpService:JSONEncode(Settings)
	if not isfile('Traversal\\TraversalConfig.cfg') then
		writefile('Traversal\\TraversalConfig.cfg', JSON)
    else
        delfile('Traversal\\TraversalConfig.cfg')
        writefile('Traversal\\TraversalConfig.cfg', JSON) -- rewrite config
	end
end

function LoadSettings()
	if isfile('Traversal\\TraversalConfig.cfg') then
		Settings = HttpService:JSONDecode(readfile('Traversal\\TraversalConfig.cfg'))
	end
end

function ResetSettings()
	if isfile('Traversal\\TraversalConfig.cfg') then
		delfile('Traversal\\TraversalConfig.cfg')
	end
end

LoadSettings() -- init config

-- // functions

-- // auto-parry

function getInfo(id)
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(id)
    end)
    if success then
        return info
    end
    return {Name=''}
end

function parry(v)
    if v:FindFirstChild("Knife") and not table.find(WeaponNames, v:FindFirstChild(WeaponNames)) then
        task.wait(.02)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(apArgsOn))
        task.wait(.3)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(apArgsOff))
        -- knif
    else
        -- not knif
        task.wait(.2)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(apArgsOn))
        task.wait(.5)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(apArgsOff))
    end
end

function npcAdded(v)
        local humanoid = v:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.AnimationPlayed:Connect(function(track)
            local info = animationInfo[track.Animation.AnimationId]
            if not info then
                info = getInfo(tonumber(track.Animation.AnimationId:match("%d+")))
                animationInfo[track.Animation.AnimationId] = info
            end
            if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("HumanoidRootPart")) then
                local magn = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if magn < Settings.apdist then
                    for _, animName in pairs(AnimNames) do
                        if string.match(info.Name, animName) then
                            if Settings.apenabled == true then
                                pcall(parry, v)
                            end
                        end
                    end
                end
            end
        end)
    end
end

function ESP(v)
    if not v:FindFirstChild("Highlight") and v ~= nil then
        local H = Instance.new("Highlight", v)
        H.FillTransparency = 1
        H.OutlineColor = Color3.fromRGB(255,0,0)
    end
end

for i, v in pairs(workspace.Enemies:GetChildren()) do
    npcAdded(v)
    if Settings.espEnabled and v ~= nil then
        ESP(v)
    end
end

workspace.Enemies.ChildAdded:Connect(function(npc)
    if npc.Name == "Enemy" then
       for i, v in pairs(workspace.Enemies:GetChildren()) do
            npcAdded(v)
            if Settings.espEnabled and v ~= nil then
                ESP(v)
            end
        end
    end
end)

local loop

loop = RunService.Stepped:Connect(function()
    if Settings.swingspeedEnabled then
        for i, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Model") then
                v:SetAttribute("AnimationSpeed", Settings.swingspeed)
            end
        end
    if Settings.infdmg then
        for i, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Model") then
                v:SetAttribute("Damage", math.huge)
                v:SetAttribute("Heavy", true)
            end
        end
    if Settings.noweapondrain then
        for i, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Model") then
                v:SetAttribute("StaminaCost", 0)
            end 
        end
    end
end
end
end)

-- // init

local page1 = venyx:addPage("Main", 5012544693)
local apSection = page1:addSection("Parry Section")
local weaponSection = page1:addSection("Weapon Section")
local NPCSection = page1:addSection("Visuals")

apSection:addToggle("Auto-Parry", Settings.apenabled, function(bool)
    Settings.apenabled = bool
end)

apSection:addSlider("Auto-Parry Range", Settings.apdist, 1, 20, function(value)
    Settings.apdist = value
end)

weaponSection:addButton("No Stamina Drain", function()
    Settings.noweapondrain = true
    for i, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Model") and v ~= nil then
            v:SetAttribute("StaminaCost", 0)
        end 
    end
end)

weaponSection:addButton("Infinite Damage // Always Execute", function()
    Settings.infdmg = true
    for i, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Model") and v ~= nil then
            v:SetAttribute("Damage", math.huge)
            v:SetAttribute("Heavy", true)
        end
    end
end)

weaponSection:addSlider("Swing Speed", Settings.swingspeed, 1, 10, function(value)
    Settings.swingspeedEnabled = true
    Settings.swingspeed = value
    for i, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Model") and v ~= nil then
            v:SetAttribute("AnimationSpeed", value)
        end
    end
end)

NPCSection:addToggle("ESP // Highlight NPCs", Settings.espEnabled, function(bool)
    Settings.espEnabled = bool
    if Settings.espEnabled then
        for i, v in pairs(workspace.Enemies:GetChildren()) do
            ESP(v)
        end
    else
        for i, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Hightlight") then
                v:Destroy()
            end
        end
    end
end)

local page2 = venyx:addPage("Misc", 5012544693)
local miscSection = page2:addSection("Miscellaneous")

miscSection:addButton("Rejoin Server", function()
    LocalPlayer:Kick("Rejoining...")
    TeleportService:Teleport(PlaceId, LocalPlayer)
end)

miscSection:addButton("Teleport Katana", function()
    if workspace:FindFirstChild("Katana") ~= nil then
    workspace:FindFirstChild("Katana").Main.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
    end
end)

miscSection:addButton("Teleport Crowbar", function()
    for i, v in pairs(workspace.Corpses:GetDescendants()) do
        if v.Name == "Crowbar" and v ~= nil then
            v:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
        end
    end
end)

miscSection:addKeybind("Toggle GUI", Enum.KeyCode.RightControl, function()
    venyx:toggle()
end, function()
end)

local page3 = venyx:addPage("Configs", 5012544693)
local configSection = page3:addSection("Configurations")

configSection:addButton("Save Settings", function()
    if not isfile('Traversal\\TraversalConfig.cfg') then
        SaveSettings()
        Notification:Notify(
            {Title = "Configuration Saved.", Description = "Configurations are successfully saved."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
            {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
        )
    else
        Notification:Notify(
            {Title = "Configuration saved already!", Description = "Configuration has been already saved, this will do nothing.."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
            {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
        )
        task.wait(3)
        Notification:Notify(
            {Title = "Do you wish to rejoin?", Description = "If you're looking for this, then you have the answer."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 15, Type = "option"},
            {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State) 

                if State == true then
                    TeleportService:Teleport(PlaceId, LocalPlayer)
                elseif State == false then
                    Notification:Notify(
                        {Title = "Staying in the server.", Description = "This might not be a good idea to think if the feature is even on or not."},
                        {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 8, Type = "default"},
                        {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(0, 255, 60)}
                    )

                end

            end}
        )
    end
end)

configSection:addButton("Overwrite Current Saved Settings", function()
    if isfile('Traversal\\TraversalConfig.cfg') then
        SaveSettings()
        Notification:Notify(
            {Title = "Overwritten current config.", Description = "Configurations are successfully overwritten."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
            {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
        )
    else
        Notification:Notify(
            {Title = "No saved config file!", Description = "There are no saved config file, save some config first."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
            {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
        )
    end
end)

configSection:addButton("Reset Settings", function()
    if isfile('Traversal\\TraversalConfig.cfg') then
        ResetSettings()
        Notification:Notify(
            {Title = "Successfully cleared configs.", Description = "Do you want to rejoin the server? This will take full effect after the rejoin, it is recommended to rejoin."},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 15, Type = "option"},
            {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State) 

                if State == true then
                    TeleportService:Teleport(PlaceId, LocalPlayer)
                elseif State == false then
                    Notification:Notify(
                        {Title = "Staying in the server.", Description = "This might not be a good idea to think if the feature is even on or not."},
                        {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 3, Type = "default"},
                        {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(0, 255, 60)}
                    )

                end

            end}
        )
    else
        Notification:Notify(
            {Title = "No save file found!", Description = "There are no save file are found, save some config first"},
            {OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
            {Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
        )
    end
end)

venyx:SelectPage(venyx.pages[1], true) -- init ui page
Notification:Notify(
{Title = "UI Loaded", Description = "UI is completely loaded and ready to use."},
{OutlineColor = Color3.fromRGB(110, 255, 124),Time = 5, Type = "default"},
{Image = "http://www.roblox.com/asset/?id=", ImageColor = Color3.fromRGB(255, 84, 84)}
)
