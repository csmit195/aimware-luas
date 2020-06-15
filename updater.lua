-- Auto Updater by csmit195
local updater = {}

updater.BasePath = 'https://raw.githubusercontent.com/csmit195/aimware-luas/master/'

updater.scanGithub = function()
	http.Get(updater.BasePath .. 'files.txt', function(contents)
		for line in contents:lines() do
			print(line)
		end
	end)
end

updater.magiclines = function(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end


--[[
http.Get('skeet2AW_LobbyFucker.lua', function(text)
	local f = file.Open('csmit195\\LobbyFucker.lua', "w+")
	f:Write(text)
	f:Close()
end)]]