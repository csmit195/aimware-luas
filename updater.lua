--[[
                           _   _     __    ___    _____                             __  
                          (_) | |   /_ |  / _ \  | ____|                           / /
   ___   ___   _ __ ___    _  | |_   | | | (_) | | |__         _ __ ___   ___     / / 
  / __| / __| | '_ ` _ \  | | | __|  | |  \__, | |___ \       | '_ ` _ \ / _ \   / /  
 | (__  \__ \ | | | | | | | | | |_   | |    / /   ___) |  _   | | | | | |  __/  / /   
  \___| |___/ |_| |_| |_| |_|  \__|  |_|   /_/   |____/  (_)  |_| |_| |_|\___| /_/    
	
	
	Script Name: Auto Updater for my Aimware Trash Luas
	Script Author: csmit195
	Script Description: Shouldn't need a description...
]]

local updater = {
	scripts = {},
	ui = {
		buttons = {}
	}
}

updater.AutoUpdate = true
updater.GithubUsername = 'csmit195'
updater.GithubProject = 'aimware-luas'
updater.BasePath = 'https://raw.githubusercontent.com/' .. updater.GithubUsername .. '/' .. updater.GithubProject .. '/master/'
updater.InstallLocation = '$csmit195\\'

updater.scanGithub = function()
	http.Get(updater.BasePath .. 'files.txt', function(contents)
		for line in updater.magiclines(contents) do
			if ( line and not line:find('404: Not Found') ) then
				local FileInfo = line:split(',')
				updater.scripts[#updater.scripts + 1] = {
					FileName = FileInfo[1],
					FileVersion = FileInfo[2],
					FileLocation = updater.BasePath .. FileInfo[3],
					FileEnabled = FileInfo[4]
				}
			end
		end	
		updater.InitiateScript()
	end)
end

updater.downloadScript = function(FileName, callback)
	for index, script in ipairs(updater.scripts) do
		if ( script.FileName == FileName ) then
			http.Get(script.FileLocation, function(contents)
				local f = file.Open(updater.InstallLocation .. FileName, "w+")
				f:Write(contents)
				f:Close()
				if callback then
					callback()
				end
			end)
		end
	end
	return false
end

updater.InitiateScript = function()	
	-- UI Code
	local MiscRef = gui.Reference("Misc")
	local UpdateTab = gui.Tab(MiscRef, "CUS.tab", "Csmit195's Scripts")
	local Groupbox = gui.Groupbox(UpdateTab, "Updater and Downloader", 16, 16, 600)
	for index, script in ipairs(updater.scripts) do
		local method = 'Install'
		if ( file.Exists( ( updater.InstallLocation:sub(1, #updater.InstallLocation - 1) .. '/' ) .. script.FileName) ) then
			method = 'Update'
		end
		
		local label = script.FileName:sub(1,#script.FileName-4)
		
		local updateFunc = function()
			updater.downloadScript(script.FileName)
		end
		
		updater.ui.buttons[script.FileName] = {}
		updater.ui.buttons[script.FileName].Install = gui.Button(Groupbox, 'Install ' .. label, updateFunc)
		updater.ui.buttons[script.FileName].Update = gui.Button(Groupbox, 'Update ' .. label, updateFunc)
		
		updater.ui.buttons[script.FileName].Install:SetInvisible(method == 'Update')
		updater.ui.buttons[script.FileName].Update:SetInvisible(method == 'Install')
	end
end

-- Utilities
updater.magiclines = function(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

function file.Exists(file_name)
  local exists = false
  file.Enumerate(function(_name)
    if file_name == _name then
      exists = true
    end
  end)
  return exists
end

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

-- Scans Github First, then once retrieved, the script will initiate.
updater.scanGithub()

C_Update = updater