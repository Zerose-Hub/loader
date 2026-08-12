--[[
    Zerose Hub Loader
    =================
    One script, many games. Add a new game by appending an entry to GAME_CONFIGS
    below (PlaceId + remotes + enemy structure + UI click flow). The script
    auto-detects the current game from game.PlaceId and loads the matching config;
    if no config matches it falls back to the "Generic" config.

    Adding a new game:
      1. Copy the "Anime Dungeons" entry and rename it.
      2. Set PlaceIds to the game's place ids (you can use game.PlaceId in the game).
      3. Fix the remote names / enemy structure / UI click buttons to match that game.
      4. If the game has no dungeon system, set HasDungeon = false (the Dungeon tab
         and all dungeon toggles will be hidden automatically).

    Supported games:
      - Anime Dungeons (70863683083739) - full support
      - Generic fallback for any other game
]]

-- ============================================================
-- GAME CONFIGS (the only part you usually need to edit)
-- ============================================================
local GAME_CONFIGS = {
    ["Anime Dungeons"] = {
        PlaceIds = { 70863683083739 },
        Title = "Zerose Hub",
        SubTitle = "Auto Farm",

        HasDungeon = true,   -- false = hide the whole Dungeon tab
        HasSkills = true,    -- false = hide the whole Skill tab

        -- Remotes (each is a path array inside ReplicatedStorage)
        RemotesFolder = { "Remotes" },
        AttackRemote = { "Attack" },
        DungeonRemote = { "Dungeon" },
        StartDungeonRemote = { "StartDungeon" },

        -- Attack call format: remote:FireServer(<args...>)
        -- %WEAPON% is replaced with the selected weapon, %DIR% with the direction vector.
        AttackArgs = { "M1", "%WEAPON%", "%DIR%", 1 },
        -- Skill call format (per enabled slot): remote:FireServer(<args...>)
        -- %SLOT% = Spell1/Spell2/Spell3, %SKILL% = the selected skill name
        SkillArgs = { "%SLOT%", "%SKILL%" },

        -- Enemy detection
        EnemiesFolderPath = { "Game", "Enemies" },  -- inside Workspace; nil = scan whole workspace
        EnemyHRPNames = { "HumanoidRootPart", "Bot", "PrimaryPart", "Torso", "Head" },
        HealthValueName = "Health",   -- NumberValue read when there is no Humanoid
        HasDiedName = "HasDied",      -- BoolValue; enemies with true are skipped
        LobbyEnemyKeyword = "Dummy",  -- enemy name that only exists in the lobby

        -- Dungeon creation (UI clicks). Each step is { ButtonText } to click a
        -- fixed button, or { mode = "OptionName" } to click the value currently
        -- selected in that dropdown, or { ButtonText, onlyIf = "ToggleName" }
        -- to only click when that toggle is on. The sequence must match the
        -- in-game UI flow.
        DungeonUIClickSequence = {
            { "Play" },
            { mode = "DungeonMode" },
            { mode = "DungeonDifficulty" },
            { "JoinStatus", onlyIf = "DungeonPrivate" },
            { "Hardcore", onlyIf = "DungeonHardcore" },
            { "Create" },
            { "Start" },
        },
        ClickRetries = 5,
        TeleportWait = 6,      -- wait after teleporting before touching the UI
        ClickWait = 3,         -- wait between UI clicks

        -- Dungeon room position (used as fallback teleport target when the
        -- PlayArea Walls are not found)
        PlayAreaPath = { "Game", "PlayArea" },   -- inside Workspace
        WallsName = "Walls",
        WallsChildIndex = 6,

        -- Save slots (teleport points). Each entry is a CFrame; keep them in
        -- the order you want them to appear in the dropdown.
        SaveSlots = {
            { "Slot 1", CFrame.new(530.9998168945312, 61.70981979370117, 5001.09423828125) },
            { "Slot 2", CFrame.new(529.83984375, 61.99496078491211, 4944.4306640625) },
            { "Slot 3", CFrame.new(531.8348999023438, 61.718807220458984, 4871.55810546875) },
            { "Slot 4", CFrame.new(349.04486083984375, 62.0443229675293, 5002.4208984375) },
            { "Slot 5", CFrame.new(350.6943359375, 62.06184387207031, 4945.0380859375) },
            { "Slot 6", CFrame.new(348.0281982421875, 62.06033706665039, 4882.85107421875) },
        },

        -- Weapon list (Items.Weapons)
        Weapons = {
            "Axe", "AxeOfPride", "Biwa", "BlackSword", "CaptainBlades", "CeroPrismStaff",
            "CrimsonScythe", "CrimsonStaff", "CrimsonSword", "CryoGreatsword", "DancerSword",
            "DemonStaff", "DivineDaggers", "DragonSlayerSword", "DreamLamp", "FatedDeclaration",
            "FlameKatana", "FrostFans", "FrostbiteOrb", "FrozenScythe", "GalaxyBreaker",
            "GiantShuriken", "GlacialBlade", "GlacialDaggers", "GlacialStaff", "GoldenFans",
            "GoldenKatana", "Gunbai", "HokageDaggers", "HollowStaff", "IceElfMageBook",
            "IllusionKatana", "Katana", "Kusanagi", "LanceOfLightning", "MonarchDaggers",
            "NocturnalScythe", "OrcBook", "OrcCommanderSword", "Rebellion", "Requiem",
            "SageScrolls", "SandGourd", "ScholarStaff", "ShadowCrimsonStaff", "ShadowCrimsonSword",
            "ShadowScythe", "ShadowSummons", "ShadyKatana", "SnowKatana", "SoulBlade", "SoulBook",
            "SoulWarriorBlade", "SoundBlades", "StaffOfAdaptation", "SteelDaggers", "SteelSword",
            "Sunscorch", "SwordKingKatana", "SwordOfHarmony", "SwordOfMist", "SwordOfRupture",
            "VoidLance", "VoidRods", "VoidStaff", "WaterKatana", "WoodenStaff"
        },
        DefaultWeapon = "Katana",

        -- Spell list (Items.Spells)
        Spells = {
            "ArmyIceArrow", "BasicSlash", "BattleSpirit", "BearClaw", "BearRoar", "BlackFlame",
            "Blessing", "BorakaFrostCuts", "CarpetBombing", "Cero", "Claw", "CrimsonSlash",
            "CrimsonTornado", "DeadCalm", "DivineConsequence", "DragonNest", "DragonSpine",
            "DreamClaw", "DreamRoot", "EdgeClaw", "ElementEruption", "FireBall", "FireBreath",
            "FireShot", "Firework", "FrostBiteSlash", "FrostCuts", "GravityGem", "GroundSlam",
            "Hado", "HollowBurst", "HollowSlash", "IceArrow", "LightningStrike", "MartialStep",
            "Meteor", "NinjaBombs", "Nuke", "OrcSlash", "Paralysis", "Retribution", "SandSlash",
            "ShadowSummon", "SlashRotation", "SoulHeal", "SpeedClaw", "SpikeRumble",
            "StarSplitter", "TheOne", "VoidCollapse", "VoidDivider", "WakingDream"
        },

        -- Dungeon modes (DungeonSelect screen buttons)
        DungeonModes = { "Dungeon1", "Dungeon2", "Dungeon3", "Dungeon4", "BossRush1", "Raid1", "EvolveChallenge" },
        DungeonDifficulties = { "Easy", "Medium", "Hard", "Hell" },
    },

    -- Fallback for any game without a dedicated config.
    -- All data here is best-effort; the dungeon tab is disabled because the
    -- dungeon UI flow is game-specific.
    ["Generic"] = {
        PlaceIds = {},
        Title = "Zerose Hub",
        SubTitle = "Auto Farm",

        HasDungeon = false,
        HasSkills = false,

        RemotesFolder = { "Remotes" },
        AttackRemote = { "Attack" },
        DungeonRemote = { "Dungeon" },
        StartDungeonRemote = { "StartDungeon" },

        AttackArgs = { "M1", "%WEAPON%", "%DIR%", 1 },
        SkillArgs = { "%SLOT%", "%SKILL%" },

        EnemiesFolderPath = { "Game", "Enemies" },
        EnemyHRPNames = { "HumanoidRootPart", "PrimaryPart", "Torso", "Head" },
        HealthValueName = "Health",
        HasDiedName = "HasDied",
        LobbyEnemyKeyword = "Dummy",

        DungeonUIClickSequence = {},
        ClickRetries = 5,
        TeleportWait = 6,
        ClickWait = 3,

        PlayAreaPath = { "Game", "PlayArea" },
        WallsName = "Walls",
        WallsChildIndex = 6,

        SaveSlots = {
            { "Slot 1", CFrame.new(0, 50, 0) },
            { "Slot 2", CFrame.new(0, 50, 0) },
            { "Slot 3", CFrame.new(0, 50, 0) },
            { "Slot 4", CFrame.new(0, 50, 0) },
            { "Slot 5", CFrame.new(0, 50, 0) },
            { "Slot 6", CFrame.new(0, 50, 0) },
        },

        Weapons = { "Katana", "Sword", "Dagger", "Axe", "Staff" },
        DefaultWeapon = "Katana",

        Spells = {},
        DungeonModes = {},
        DungeonDifficulties = {},
    },
}

-- ============================================================
-- GAME DETECTION
-- ============================================================
local function DetectGame()
    local pid = game.PlaceId
    for name, cfg in pairs(GAME_CONFIGS) do
        for _, id in ipairs(cfg.PlaceIds) do
            if id == pid then
                return name, cfg
            end
        end
    end
    return "Generic", GAME_CONFIGS["Generic"]
end

local GAME_NAME, CFG = DetectGame()

-- ============================================================
-- LIBRARY + WINDOW
-- ============================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = CFG.Title,
    SubTitle = CFG.SubTitle,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
}
if CFG.HasSkills then
    Tabs.Skill = Window:AddTab({ Title = "Skill", Icon = "zap" })
end
if CFG.HasDungeon then
    Tabs.Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "castle" })
end
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

local Options = Fluent.Options

-- Forward-declared so the button callbacks below can reference them.
local CreateRoom, SavePosition, TeleportToSaved
local SavedSlots
local GetSelectedSlotIndex
local GetPlayAreaPart
local GetEnemyList

-- ============================================================
-- UI
-- ============================================================
do
    Tabs.Main:AddToggle("AutoAttack", {
        Title = "Auto Attack",
        Description = "Attack the closest monster without teleporting",
        Default = false
    })

    Tabs.Main:AddDropdown("WeaponSelect", {
        Title = "Weapon",
        Description = "Weapon name sent to the Attack remote",
        Values = CFG.Weapons,
        Default = CFG.DefaultWeapon,
    })

    Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Description = "Teleport to the closest monster, stand at the chosen position, and attack it",
        Default = false
    })

    Tabs.Main:AddDropdown("TeleportPosition", {
        Title = "Teleport Position",
        Description = "Where to stand relative to the monster",
        Values = { "Front", "Back", "Left", "Right", "Above", "Below", "Center" },
        Default = "Front",
    })

    Tabs.Main:AddSlider("TeleportDistance", {
        Title = "Distance from Monster",
        Description = "How many studs away from the monster",
        Default = 5,
        Min = 1,
        Max = 15,
        Rounding = 1
    })

    Tabs.Main:AddToggle("AutoDodge", {
        Title = "Auto Dodge",
        Description = "Circle around the target so enemy skills miss",
        Default = false
    })

    Tabs.Main:AddSlider("DodgeSpeed", {
        Title = "Dodge Speed",
        Description = "How fast to circle around the target",
        Default = 8,
        Min = 1,
        Max = 20,
        Rounding = 1
    })

    Tabs.Main:AddSlider("AttackDelay", {
        Title = "Attack Delay (ms)",
        Description = "Delay between attacks (0 = spam as fast as possible)",
        Default = 0,
        Min = 0,
        Max = 1000,
        Rounding = 1
    })

    if CFG.HasDungeon then
        Tabs.Dungeon:AddToggle("AutoCreateRoom", {
            Title = "Auto Create Room",
            Description = "Teleport to the saved position, then create the room and start the dungeon automatically",
            Default = false
        })

        Tabs.Dungeon:AddToggle("AutoPlayAgain", {
            Title = "Auto Play Again",
            Description = "Restart the dungeon automatically when the round ends",
            Default = false
        })

        Tabs.Dungeon:AddToggle("AutoStartDungeon", {
            Title = "Auto Start Dungeon",
            Description = "Fire StartDungeon when not in a dungeon",
            Default = false
        })

        Tabs.Dungeon:AddDropdown("DungeonMode", {
            Title = "Mode",
            Description = "Dungeon mode to create / play",
            Values = CFG.DungeonModes,
            Default = CFG.DungeonModes[1],
        })

        Tabs.Dungeon:AddDropdown("DungeonDifficulty", {
            Title = "Difficulty",
            Description = "Dungeon difficulty",
            Values = CFG.DungeonDifficulties,
            Default = CFG.DungeonDifficulties[1],
        })

        Tabs.Dungeon:AddToggle("DungeonPrivate", {
            Title = "Private Room",
            Description = "Create a private room instead of public",
            Default = false
        })

        Tabs.Dungeon:AddToggle("DungeonHardcore", {
            Title = "Hardcore",
            Description = "Enable hardcore mode for the room",
            Default = false
        })

        Tabs.Dungeon:AddToggle("UIClickMode", {
            Title = "Click UI to select",
            Description = "Click the difficulty + Create buttons in the game UI when creating a room",
            Default = true
        })
    end

    if CFG.HasDungeon then
        Tabs.Dungeon:AddDropdown("TeleportSlot", {
            Title = "Teleport Slot",
            Description = "Which saved position slot to teleport to",
            Values = (function()
                local names = {}
                for _, slot in ipairs(CFG.SaveSlots) do
                    table.insert(names, slot[1])
                end
                return names
            end)(),
            Default = CFG.SaveSlots[1][1],
        })

        Tabs.Dungeon:AddButton({
            Title = "Save Position",
            Description = "Save your current position into the selected slot",
            Callback = function()
                SavePosition()
            end
        })

        Tabs.Dungeon:AddButton({
            Title = "Teleport to Saved",
            Description = "Teleport to the position saved in the selected slot",
            Callback = function()
                TeleportToSaved()
            end
        })
    else
        -- Without a dungeon tab, keep the save/teleport buttons on Main
        Tabs.Main:AddDropdown("TeleportSlot", {
            Title = "Teleport Slot",
            Description = "Which saved position slot to teleport to",
            Values = (function()
                local names = {}
                for _, slot in ipairs(CFG.SaveSlots) do
                    table.insert(names, slot[1])
                end
                return names
            end)(),
            Default = CFG.SaveSlots[1][1],
        })

        Tabs.Main:AddButton({
            Title = "Save Position",
            Description = "Save your current position into the selected slot",
            Callback = function()
                SavePosition()
            end
        })

        Tabs.Main:AddButton({
            Title = "Teleport to Saved",
            Description = "Teleport to the position saved in the selected slot",
            Callback = function()
                TeleportToSaved()
            end
        })
    end

    if CFG.HasSkills then
        Tabs.Skill:AddToggle("AutoSkill", {
            Title = "Auto Skill",
            Description = "Spam the selected skill",
            Default = false
        })

        Tabs.Skill:AddSlider("SkillDelay", {
            Title = "Skill Delay (ms)",
            Description = "Delay between each skill cast",
            Default = 500,
            Min = 100,
            Max = 3000,
            Rounding = 1
        })

        local spellValues = { "None" }
        for _, s in ipairs(CFG.Spells) do
            table.insert(spellValues, s)
        end

        Tabs.Skill:AddDropdown("Skill1Select", {
            Title = "Skill Slot 1 (Spell1)",
            Description = "Spell to cast in slot 1 (None = disabled)",
            Values = spellValues,
            Default = "FireBall",
        })

        Tabs.Skill:AddDropdown("Skill2Select", {
            Title = "Skill Slot 2 (Spell2)",
            Description = "Spell to cast in slot 2 (None = disabled)",
            Values = spellValues,
            Default = "None",
        })

        Tabs.Skill:AddDropdown("Skill3Select", {
            Title = "Skill Slot 3 (Spell3)",
            Description = "Spell to cast in slot 3 (None = disabled)",
            Values = spellValues,
            Default = "None",
        })
    end
end

-- ============================================================
-- Remote lookup (per game config)
-- ============================================================
local function FindRemote(names)
    local root = game:GetService("ReplicatedStorage")
    local current = root
    for _, part in ipairs(CFG.RemotesFolder) do
        current = current and current:FindFirstChild(part)
    end
    if not current then return nil end
    for _, part in ipairs(names) do
        current = current and current:FindFirstChild(part)
    end
    return current
end

local AttackRemote = { FireServer = function() end }
local AttackRemoteFound = false

task.spawn(function()
    while true do
        task.wait(0.5)

        if Fluent.Unloaded then break end

        if not AttackRemoteFound then
            local found = FindRemote(CFG.AttackRemote)
            if found then
                AttackRemote = found
                AttackRemoteFound = true
                print("[Zerose Hub] Attack remote found:", found:GetFullName())
            end
        end
    end
end)

local DungeonRemote = nil
local DungeonRemoteFound = false
if CFG.HasDungeon then
    task.spawn(function()
        while true do
            task.wait(0.5)

            if Fluent.Unloaded then break end

            if not DungeonRemoteFound then
                local found = FindRemote(CFG.DungeonRemote)
                if found then
                    DungeonRemote = found
                    DungeonRemoteFound = true
                    print("[Zerose Hub] Dungeon remote found:", found:GetFullName())
                end
            end
        end
    end)
end

local StartDungeonRemote = nil
local StartDungeonFound = false
if CFG.HasDungeon then
    task.spawn(function()
        while true do
            task.wait(0.5)

            if Fluent.Unloaded then break end

            if not StartDungeonFound then
                local found = FindRemote(CFG.StartDungeonRemote)
                if found then
                    StartDungeonRemote = found
                    StartDungeonFound = true
                    print("[Zerose Hub] StartDungeon remote found:", found:GetFullName())
                end
            end
        end
    end)
end

-- Build the FireServer args from the config template
local function BuildAttackArgs(weapon, dir)
    local args = {}
    for _, a in ipairs(CFG.AttackArgs) do
        if a == "%WEAPON%" then
            table.insert(args, weapon)
        elseif a == "%DIR%" then
            table.insert(args, dir)
        else
            table.insert(args, a)
        end
    end
    return table.unpack(args)
end

local function BuildSkillArgs(slot, skill)
    local args = {}
    for _, a in ipairs(CFG.SkillArgs) do
        if a == "%SLOT%" then
            table.insert(args, slot)
        elseif a == "%SKILL%" then
            table.insert(args, skill)
        else
            table.insert(args, a)
        end
    end
    return table.unpack(args)
end

local FixedDirection = Vector3.new(0.90122896432877, 0, 0.43334317207336) -- fallback aim

-- ============================================================
-- Enemy detection (per game config)
-- ============================================================
local EnemiesFolder = nil
local function FindEnemiesFolder()
    local current = workspace
    for _, part in ipairs(CFG.EnemiesFolderPath or {}) do
        current = current and current:FindFirstChild(part)
    end
    if current then return current end

    for _, folder in ipairs(workspace:GetDescendants()) do
        if folder.Name == (CFG.EnemiesFolderPath and CFG.EnemiesFolderPath[#CFG.EnemiesFolderPath]) then
            if folder:IsA("Folder") or folder:IsA("Model") then
                return folder
            end
        end
    end
    return nil
end

EnemiesFolder = FindEnemiesFolder()
print("[Zerose Hub] Enemies folder =", EnemiesFolder and EnemiesFolder:GetFullName() or "NOT FOUND yet (will re-check while farming)")

local lastFolderCheck = 0
local function EnsureEnemiesFolder()
    if not EnemiesFolder or os.clock() - lastFolderCheck > 5 then
        lastFolderCheck = os.clock()
        EnemiesFolder = FindEnemiesFolder()
    end
    return EnemiesFolder
end

-- True when the player is in the lobby: the lobby enemy keyword (e.g. "Dummy")
-- exists in the enemies list, or there are no enemies at all.
local function IsInLobby()
    for _, enemy in ipairs(GetEnemyList()) do
        if CFG.LobbyEnemyKeyword and enemy.Name:find(CFG.LobbyEnemyKeyword, 1, true) then
            return true
        end
    end
    return #GetEnemyList() == 0
end

-- Find enemy HRP: try each name from the config, then any BasePart
local function GetEnemyHRP(enemy)
    for _, name in ipairs(CFG.EnemyHRPNames) do
        local part = enemy:FindFirstChild(name, true)
        if part and part:IsA("BasePart") then return part end
    end
    if enemy.PrimaryPart then return enemy.PrimaryPart end

    for _, part in ipairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

-- Read enemy HP: Humanoid first, then the config Health NumberValue
local function GetEnemyHealth(enemy)
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid.Health end

    if CFG.HealthValueName then
        local health = enemy:FindFirstChild(CFG.HealthValueName, true)
        if health and health:IsA("ValueBase") then
            return health.Value
        end
    end
    return 0
end

local function GetAllEnemies(folder, result)
    result = result or {}
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then
            table.insert(result, v)
        elseif v:IsA("Folder") then
            GetAllEnemies(v, result)
        end
    end
    return result
end

local cachedEnemies = nil
local lastEnemyScan = 0
function GetEnemyList()
    if os.clock() - lastEnemyScan > 2 then
        lastEnemyScan = os.clock()
        cachedEnemies = {}

        local candidates
        local folder = EnsureEnemiesFolder()
        if folder then
            candidates = GetAllEnemies(folder)
        else
            candidates = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local health = v:FindFirstChild(CFG.HealthValueName, true)
                    if health and health:IsA("ValueBase") then
                        table.insert(candidates, v)
                    end
                end
            end
        end

        for _, enemy in ipairs(candidates) do
            local hrp = GetEnemyHRP(enemy)
            local health = GetEnemyHealth(enemy)
            local died = CFG.HasDiedName and enemy:FindFirstChild(CFG.HasDiedName)
            if hrp and health > 0 and not (died and died:IsA("BoolValue") and died.Value) then
                table.insert(cachedEnemies, enemy)
            end
        end
    end
    return cachedEnemies
end

-- Find the closest monster (returns target part + total enemy count)
local function GetClosestEnemy()
    local character = game.Players.LocalPlayer.Character
    if not character then return nil, 0 end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, 0 end

    local enemies = GetEnemyList()
    local closest, closestDist = nil, math.huge
    for _, enemy in ipairs(enemies) do
        local targetHRP = GetEnemyHRP(enemy)
        if targetHRP then
            local dist = (targetHRP.Position - hrp.Position).Magnitude
            if dist < closestDist then
                closest, closestDist = targetHRP, dist
            end
        end
    end
    return closest, #enemies
end

-- Calculate stand position relative to the monster
local function GetStandPosition(targetHRP)
    local look = targetHRP.CFrame.LookVector
    local right = targetHRP.CFrame.RightVector
    local dist = tonumber(Options.TeleportDistance.Value) or 5

    local mode = Options.TeleportPosition.Value
    if mode == "Back" then
        return targetHRP.Position - look * dist
    elseif mode == "Left" then
        return targetHRP.Position - right * dist
    elseif mode == "Right" then
        return targetHRP.Position + right * dist
    elseif mode == "Above" then
        return targetHRP.Position + Vector3.new(0, dist, 0)
    elseif mode == "Below" then
        return targetHRP.Position - Vector3.new(0, dist, 0)
    elseif mode == "Center" then
        return targetHRP.Position
    end
    return targetHRP.Position + look * dist -- Front (default)
end

-- ============================================================
-- In-game status bar
-- ============================================================
-- In-game status bar (visible without opening the console)
local StatusGui = Instance.new("ScreenGui")
StatusGui.Name = "ZeroseHubStatus"
StatusGui.ResetOnSpawn = false
StatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() StatusGui.Parent = game:GetService("CoreGui") end) then
    StatusGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 460, 0, 24)
StatusText.Position = UDim2.new(0, 10, 0, 10)
StatusText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusText.BackgroundTransparency = 0.4
StatusText.BorderSizePixel = 0
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextStrokeTransparency = 0.5
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 14
StatusText.Text = "[Zerose Hub] idle"
StatusText.Parent = StatusGui

local function SetStatus(text)
    if StatusText then
        StatusText.Text = "[Zerose Hub] " .. text
    end
end

-- ============================================================
-- Auto Attack (spam remote)
-- ============================================================
task.spawn(function()
    while true do
        task.wait()

        if Fluent.Unloaded then break end

        if Options.AutoAttack.Value then
            AttackRemote:FireServer(BuildAttackArgs(Options.WeaponSelect.Value, FixedDirection))
            task.wait(tonumber(Options.AttackDelay.Value) / 1000)
        end
    end
end)

-- ============================================================
-- Auto Skill
-- ============================================================
if CFG.HasSkills then
    task.spawn(function()
        while true do
            task.wait()

            if Fluent.Unloaded then break end

            if Options.AutoSkill.Value then
                local s1 = Options.Skill1Select.Value
                local s2 = Options.Skill2Select.Value
                local s3 = Options.Skill3Select.Value
                local delay = (tonumber(Options.SkillDelay.Value) or 500) / 1000

                if s1 ~= "None" then
                    AttackRemote:FireServer(BuildSkillArgs("Spell1", s1))
                    task.wait(delay)
                end
                if s2 ~= "None" then
                    AttackRemote:FireServer(BuildSkillArgs("Spell2", s2))
                    task.wait(delay)
                end
                if s3 ~= "None" then
                    AttackRemote:FireServer(BuildSkillArgs("Spell3", s3))
                    task.wait(delay)
                end
            end
        end
    end)
end

-- ============================================================
-- Auto Farm
-- ============================================================
local lastStatus = 0
task.spawn(function()
    while true do
        task.wait()

        if Fluent.Unloaded then break end

        if Options.AutoFarm.Value then
            local ok, err = pcall(function()
                local character = game.Players.LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local target = GetClosestEnemy()

                if hrp and target then
                    local standPos = GetStandPosition(target)

                    if (hrp.Position - standPos).Magnitude > 1 and not Options.AutoDodge.Value then
                        local toTarget = target.Position - standPos
                        if toTarget.Magnitude > 0.01 then
                            hrp.CFrame = CFrame.lookAt(standPos, target.Position)
                        else
                            hrp.CFrame = CFrame.new(standPos)
                        end
                    end

                    local d = target.Position - hrp.Position
                    local dir = Vector3.new(d.X, 0, d.Z)
                    if dir.Magnitude <= 0.01 then dir = FixedDirection end

                    AttackRemote:FireServer(BuildAttackArgs(Options.WeaponSelect.Value, dir))

                    if os.clock() - lastStatus > 0.5 then
                        lastStatus = os.clock()
                        SetStatus("Auto Farm: " .. (target.Parent and target.Parent.Name or "?") .. " | HP " .. math.floor(GetEnemyHealth(target.Parent)))
                    end
                elseif os.clock() - lastStatus > 0.5 then
                    lastStatus = os.clock()
                    if not character then
                        SetStatus("Auto Farm: character not spawned yet")
                    else
                        SetStatus("Auto Farm: no target found - scanning...")
                    end
                end
            end)
            if not ok then
                warn("[Zerose Hub] Auto Farm error:", err)
            end

            local delay = (tonumber(Options.AttackDelay.Value) or 0) / 1000
            if delay > 0 then
                task.wait(delay)
            end
        end
    end
end)

-- ============================================================
-- Auto Dodge
-- ============================================================
local dodgeAngle = 0
task.spawn(function()
    while true do
        task.wait()

        if Fluent.Unloaded then break end

        if Options.AutoDodge.Value and Options.AutoFarm.Value then
            local ok, err = pcall(function()
                local character = game.Players.LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local target = GetClosestEnemy()

                if hrp and target then
                    local radius = tonumber(Options.TeleportDistance.Value) or 5
                    local speed = tonumber(Options.DodgeSpeed.Value) or 8

                    dodgeAngle = dodgeAngle + speed * 0.03

                    local pos = target.Position + Vector3.new(math.cos(dodgeAngle), 0, math.sin(dodgeAngle)) * radius
                    if (hrp.Position - pos).Magnitude > 0.5 then
                        hrp.CFrame = CFrame.lookAt(pos, target.Position)
                    end
                end
            end)
            if not ok then
                warn("[Zerose Hub] Dodge error:", err)
            end
        end
    end
end)

-- ============================================================
-- Auto Play Again
-- ============================================================
if CFG.HasDungeon then
    local lastPlayAgain = 0
    task.spawn(function()
        while true do
            task.wait()

            if Fluent.Unloaded then break end

            if Options.AutoPlayAgain.Value then
                local ok, err = pcall(function()
                    if #GetEnemyList() == 0 then
                        if os.clock() - lastPlayAgain > 5 then
                            lastPlayAgain = os.clock()
                            if DungeonRemote then
                                DungeonRemote:FireServer("PlayAgain")
                                print("[Zerose Hub] PlayAgain fired")
                            end
                        end
                    end
                end)
                if not ok then
                    warn("[Zerose Hub] Play Again error:", err)
                end
            end
        end
    end)
end

-- ============================================================
-- Auto Start Dungeon
-- ============================================================
if CFG.HasDungeon then
    local lastDungeonStart = 0
    task.spawn(function()
        while true do
            task.wait()

            if Fluent.Unloaded then break end

            if Options.AutoStartDungeon.Value then
                local ok, err = pcall(function()
                    if IsInLobby() then
                        if os.clock() - lastDungeonStart > 5 then
                            lastDungeonStart = os.clock()
                            if StartDungeonRemote then
                                StartDungeonRemote:FireServer()
                                print("[Zerose Hub] StartDungeon fired")
                            end
                        end
                    end
                end)
                if not ok then
                    warn("[Zerose Hub] Auto Start Dungeon error:", err)
                end
            end
        end
    end)
end

-- ============================================================
-- Auto Create Room
-- ============================================================
if CFG.HasDungeon then
    local lastAutoCreate = -9999
    local autoCreating = false
    task.spawn(function()
        while true do
            task.wait()

            if Fluent.Unloaded then break end

            if Options.AutoCreateRoom.Value then
                local ok, err = pcall(function()
                    if IsInLobby() and not autoCreating then
                        if os.clock() - lastAutoCreate > 5 then
                            lastAutoCreate = os.clock()
                            autoCreating = true

                            -- 1) Teleport to the room's Walls child #6
                            local character = game.Players.LocalPlayer.Character
                            local hrp = character and character:FindFirstChild("HumanoidRootPart")
                            local target = nil
                            local playAreaPart = GetPlayAreaPart()
                            local walls = playAreaPart and playAreaPart:FindFirstChild(CFG.WallsName)
                            if walls then
                                local wallChildren = walls:GetChildren()
                                if wallChildren[CFG.WallsChildIndex] then
                                    target = wallChildren[CFG.WallsChildIndex]
                                end
                            end

                            if not hrp then
                                print("[Zerose Hub] Auto Create: character not spawned yet")
                            elseif not playAreaPart then
                                print("[Zerose Hub] Auto Create: PlayArea part not found")
                            elseif not walls then
                                print("[Zerose Hub] Auto Create: Walls not found in", playAreaPart:GetFullName())
                            elseif not target then
                                print("[Zerose Hub] Auto Create: Walls has only", #walls:GetChildren(), "children (need", CFG.WallsChildIndex, ")")
                            end

                            if hrp then
                                if target then
                                    hrp.CFrame = target.CFrame
                                    print("[Zerose Hub] Auto Create: teleported to", target:GetFullName())
                                    SetStatus("Auto Create: teleporting...")
                                else
                                    local slotIdx = GetSelectedSlotIndex()
                                    hrp.CFrame = SavedSlots[slotIdx]
                                    print("[Zerose Hub] Auto Create: Walls not found, using Slot", slotIdx, SavedSlots[slotIdx].Position)
                                    SetStatus("Auto Create: teleporting (Slot " .. slotIdx .. ")...")
                                end
                                -- Wait for the game to settle before touching the UI
                                task.wait(CFG.TeleportWait)
                            end

                            -- 2) Create the room through the in-game UI
                            CreateRoom()
                            task.wait(CFG.ClickWait)
                            autoCreating = false
                        end
                    end
                end)
                if not ok then
                    autoCreating = false
                    warn("[Zerose Hub] Auto Create Room error:", err)
                end
            end
        end
    end)
end

-- ============================================================
-- UI Click helper (select a GUI button and press Enter)
-- ============================================================
local function clicks(uis)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    game:GetService("GuiService").SelectedObject = uis
    task.wait(0.03)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.03)
    game:GetService("GuiService").SelectedObject = nil
end

-- Find a visible TextButton/ImageButton anywhere in the player's GUIs whose
-- name or text matches the given string
local function FindButtonByText(text)
    if not text or text == "" then return nil end
    for _, gui in ipairs({ game.Players.LocalPlayer:FindFirstChild("PlayerGui"), game:GetService("CoreGui") }) do
        if gui then
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    if child.Visible and child.Active then
                        local label = child:FindFirstChildOfClass("TextLabel")
                        local btnText = child:IsA("TextButton") and child.Text or (label and label.Text) or ""
                        if child.Name:find(text, 1, true) or btnText:find(text, 1, true) then
                            return child
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function ClickButtonByText(text)
    local btn = FindButtonByText(text)
    if btn then
        clicks(btn)
        return true
    end
    return false
end

-- ============================================================
-- Save Position / Teleport to Saved (slots from config)
-- ============================================================
SavedSlots = {}
for _, slot in ipairs(CFG.SaveSlots) do
    table.insert(SavedSlots, slot[2])
end

-- Index of the slot currently selected in the dropdown (1-#SavedSlots)
function GetSelectedSlotIndex()
    local v = Options.TeleportSlot and Options.TeleportSlot.Value
    if type(v) == "string" then
        local n = v:match("(%d+)$")
        if n then
            local idx = tonumber(n)
            if idx and idx >= 1 and idx <= #SavedSlots then
                return idx
            end
        end
    end
    return 1
end

function SavePosition()
    local ok, err = pcall(function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            SetStatus("Save Position: character not spawned yet")
            return
        end
        local idx = GetSelectedSlotIndex()
        SavedSlots[idx] = hrp.CFrame
        print("[Zerose Hub] Position saved to Slot", idx, ":", SavedSlots[idx].Position)
        SetStatus("Slot " .. idx .. " saved: " .. string.format("%.1f, %.1f, %.1f", SavedSlots[idx].Position.X, SavedSlots[idx].Position.Y, SavedSlots[idx].Position.Z))
    end)
    if not ok then
        warn("[Zerose Hub] Save Position error:", err)
    end
end

function TeleportToSaved()
    local ok, err = pcall(function()
        local idx = GetSelectedSlotIndex()
        local cf = SavedSlots[idx]
        if not cf then
            SetStatus("Teleport: no position saved in Slot " .. idx)
            return
        end
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            SetStatus("Teleport: character not spawned yet")
            return
        end
        hrp.CFrame = cf
        print("[Zerose Hub] Teleported to Slot", idx, ":", cf.Position)
        SetStatus("Teleported to Slot " .. idx)
    end)
    if not ok then
        warn("[Zerose Hub] Teleport error:", err)
    end
end

-- Find the player's PlayArea part (e.g. workspace.Game.PlayArea["<UserId>Dungeon"])
function GetPlayAreaPart()
    local current = workspace
    for _, part in ipairs(CFG.PlayAreaPath) do
        current = current and current:FindFirstChild(part)
    end
    local playArea = current
    if not playArea then return nil end

    local named = playArea:FindFirstChild(game.Players.LocalPlayer.UserId .. "Dungeon")
    if named then return named end

    for _, v in ipairs(playArea:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "Empty" then
            return v
        end
    end
    return nil
end

-- ============================================================
-- Create Room (walks the config UI click sequence)
-- ============================================================
function CreateRoom()
    local ok, err = pcall(function()
        local sequence = CFG.DungeonUIClickSequence or {}
        if #sequence == 0 then
            SetStatus("Room: no UI click sequence configured for this game")
            return
        end

        for _, step in ipairs(sequence) do
            local btnText = step[1]
            if not btnText and step.mode then
                btnText = Options[step.mode] and Options[step.mode].Value
            end
            if step.onlyIf and not Options[step.onlyIf].Value then
                -- skip this step (e.g. Private/Hardcore toggles that are off)
            elseif btnText then
                local retries = CFG.ClickRetries or 5
                local clicked = false
                for _ = 1, retries do
                    if ClickButtonByText(btnText) then
                        clicked = true
                        break
                    end
                    task.wait(1)
                end
                if not clicked then
                    print("[Zerose Hub] UI click: button (\"" .. tostring(btnText) .. "\") not found")
                end
                task.wait(CFG.ClickWait)
            end
        end

        print("[Zerose Hub] Room created via UI (mode:", Options.DungeonMode and Options.DungeonMode.Value or "?", "| difficulty:", Options.DungeonDifficulty and Options.DungeonDifficulty.Value or "?", ")")
        SetStatus("Room created: " .. (Options.DungeonMode and Options.DungeonMode.Value or "?") .. " (" .. (Options.DungeonDifficulty and Options.DungeonDifficulty.Value or "?") .. ")")
    end)
    if not ok then
        warn("[Zerose Hub] Create Room error:", err)
    end
end

-- ============================================================
-- SaveManager / InterfaceManager
-- ============================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/" .. GAME_NAME)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Zerose Hub",
    Content = "Loaded for: " .. GAME_NAME,
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
