--[[
    Zerose Hub - UI Loader (main loader, hosted on GitHub)
    =======================================================
    Loaded by Run.lua AFTER it sets getgenv().ZeroseHub:
      hub       = hub name
      discord   = discord invite code
      name      = the matched game's name
      script_id = URL or dply.me paste id of the game's script

    What this loader does:
      1. Validates that getgenv().ZeroseHub exists (i.e. Run.lua ran first)
      2. Prints the logo + game name + discord
      3. Resolves script_id -> a URL
      4. Fetches, compiles and runs the game's script

    No key system: this loader is open. If you want a key system later,
    add the check here (or in Run.lua) before executing.
]]

-- 1) Validate config
local Hub = getgenv().ZeroseHub
if not Hub or not Hub.script_id then
	warn("[Zerose Hub] Missing config. Run the Run.lua script first!")
	return
end

-- 2) Logo
local Logo = getgenv().logo or ([[
    Welcome to
        ____   ____                             _________            .__        __
        \   \ /   /____   ____   _______  ___  /   _____/ ___________|__|______/  |_  ______
         \   Y   // __ \ /    \ /  _ \  \/  /  \_____  \_/ ___\_  __ \  \____ \   __\/  ___/
          \     /\  ___/|   |  (  <_> >    <   /        \  \___|  |  \/  |  |_> >  |  \___ \
           \___/  \___  >___|  /\____/__/\_ \ /_______  /\___  >__|  |__|   __/|__| /____  >
                      \/     \/            \/         \/     \/         |__|             \/
]])
print(Logo)
print("[Zerose Hub] " .. (Hub.name or "?") .. " | " .. (Hub.discord and "discord.gg/" .. Hub.discord or ""))
task.wait(0.5)

-- 3) Resolve script_id -> URL
local function ResolveScriptURL(id)
	if type(id) ~= "string" then return nil end
	if id:sub(1, 4) == "http" then
		return id
	end
	-- Assume a dply.me paste id
	return "https://api.dply.me/" .. id .. "/raw"
end

local url = ResolveScriptURL(Hub.script_id)
if not url then
	warn("[Zerose Hub] Invalid script_id:", tostring(Hub.script_id))
	return
end

-- 4) Fetch, compile, run
local code, fetchErr = pcall(function()
	return game:HttpGet(url)
end)

if not code then
	warn("[Zerose Hub] Failed to fetch script:", fetchErr)
	return
end

local fn, compileErr = loadstring(code)
if not fn then
	warn("[Zerose Hub] Failed to compile script:", compileErr)
	return
end

local ok, runErr = pcall(fn)
if not ok then
	warn("[Zerose Hub] Script error:", runErr)
end
