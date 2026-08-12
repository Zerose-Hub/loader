--[[
    Zerose Hub - RUN THIS SCRIPT (paste into your executor)
    ========================================================
    Hina Hub style loader, WITHOUT a key system:
      1. Waits for the game to load
      2. Anti re-execute flag (running it twice does nothing)
      3. Scripts table: game id -> { name, script_id }
      4. If the current game is not in the table -> notification + stop
      5. Sets getgenv().ZeroseHub (hub info + matched game)
      6. Loads the UI loader from GitHub, which runs the game's script
]]

-- 1) Wait for the game to load, then a tiny random delay
if not game:IsLoaded() then
	game.Loaded:Wait()
end
task.wait(math.random())

-- 2) Anti re-execute
if getgenv().ZeroseHub_Executed then return end
getgenv().ZeroseHub_Executed = true

-- 3) Hub info
local Hub = "Zerose Hub"
local Discord_Invite = "YOUR_DISCORD_INVITE"     -- e.g. "abc123" -> discord.gg/abc123

-- The UI loader hosted on GitHub (edit the URL to your repo)
local UI_LOADER = "https://raw.githubusercontent.com/<YOUR_USERNAME>/<YOUR_REPO>/main/Loader.lua"

-- 4) Scripts table: key by game.PlaceId or game.CreatorId.
--    script_id = the script to run for that game. It can be:
--      - a full URL (e.g. your GitHub raw URL of the config script)
--      - a dply.me paste id (e.g. "abc123" -> https://api.dply.me/abc123/raw)
local Scripts = {
	-- Anime Dungeons (by PlaceId)
	[70863683083739] = { name = "Anime Dungeons", script_id = "https://raw.githubusercontent.com/<YOUR_USERNAME>/<YOUR_REPO>/main/ZeroseHub_Loader.lua" },
	-- Add more games below (you can key by CreatorId too, like Hina Hub):
	-- [game.CreatorId] = { name = "Another Game", script_id = "paste_id_or_url" },
}

-- 5) Check if the current game is supported (PlaceId first, then CreatorId)
local current = Scripts[game.PlaceId] or Scripts[game.CreatorId]
if not current then
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = Hub, Text = "This game is not supported!", Duration = 5
		})
	end)
	return
end

-- 6) Pass the info to the loader
getgenv().ZeroseHub = {
	hub = Hub,
	discord = Discord_Invite,
	name = current.name,
	script_id = current.script_id,
}

-- 7) Load the UI loader
loadstring(game:HttpGet(UI_LOADER))()
