panorama.RunScript([[
	if ( typeof collectedSteamIDS === 'undefined' ) {
		$.Msg('Sorry cant find');
		collectedSteamIDS = [];
		collectedSteamIDS.push("123");
	}
]])


local timers = {}
local function timerCreate(name, delay, times, func)
    table.insert(timers, {["name"] = name, ["delay"] = delay, ["times"] = times, ["func"] = func, ["lastTime"] = globals.RealTime()})
end
local function timerRemove(name)
    for k,v in pairs(timers or {}) do
        if (name == v["name"]) then table.remove(timers, k) end
    end
end
local function timerTick()
    for k,v in pairs(timers or {}) do
        if (v["times"] <= 0) then table.remove(timers, k) end
        if (v["lastTime"] + v["delay"] <= globals.RealTime()) then 
            timers[k]["lastTime"] = globals.RealTime()
            timers[k]["times"] = timers[k]["times"] - 1
            v["func"]() 
        end
    end
end
callbacks.Register( "Draw", "timerTick", timerTick);


local function executeScript(script)
	panorama.RunScript([[
		if ( typeof collectedSteamIDS === 'undefined' ) {
			$.Msg('Sorry cant find');
			collectedSteamIDS = [];
			collectedSteamIDS.push("123");
		}
	]]..script)
end

local refresh = false
local function refresh_nearbies()
	timerCreate('refresh_nearbies', 5, 1, refresh_nearbies)
	print(refresh, 'Refreshing Nearbys!')
    if not refresh then 
        return
    end
    executeScript([[
        PartyBrowserAPI.Refresh();
        var lobbies = PartyBrowserAPI.GetResultsCount();
        for (var lobbyid = 0; lobbyid < lobbies; lobbyid++) {
            var xuid = PartyBrowserAPI.GetXuidByIndex(lobbyid);
            if (!collectedSteamIDS.includes(xuid)) {
                if (collectedSteamIDS.includes('123')) {
                    collectedSteamIDS.splice(collectedSteamIDS.indexOf('123'), 1);
                }
                collectedSteamIDS.push(xuid);
                $.Msg(`Adding ${xuid} to the collection..`);
            }
        }
        $.Msg(`Mass invite collection: ${collectedSteamIDS.length}`);
    ]]) 
end
refresh_nearbies()

local MainRef = gui.Reference("Misc")
local LITab = gui.Tab(MainRef, "LI.tab", "LobbyInviter")
local LIGroupbox = gui.Groupbox(LITab, "Inviter", 16, 16, 600)

local auto_refresh_nearbies = gui.Checkbox(LIGroupbox, "LI.auto_refresh_nearbies", "Auto refresh nearbies", false)

local originalValue = {}
originalValue[auto_refresh_nearbies] = auto_refresh_nearbies:GetValue()
callbacks.Register("Draw", "LF.Draw", function()
    if ( auto_refresh_nearbies:GetValue() ~= ( originalValue[auto_refresh_nearbies] == nil and '' or originalValue[auto_refresh_nearbies] ) ) then 
		refresh = auto_refresh_nearbies:GetValue()
		print('refreshChange', refresh)
		originalValue[auto_refresh_nearbies] = auto_refresh_nearbies:GetValue()
	end
end)

gui.Button(LIGroupbox, 'Refresh nearbies', function()
    executeScript([[
        PartyBrowserAPI.Refresh();
        var lobbies = PartyBrowserAPI.GetResultsCount();
        for (var lobbyid = 0; lobbyid < lobbies; lobbyid++) {
            var xuid = PartyBrowserAPI.GetXuidByIndex(lobbyid);
            if (!collectedSteamIDS.includes(xuid)) {
                if (collectedSteamIDS.includes('123')) {
                    collectedSteamIDS.splice(collectedSteamIDS.indexOf('123'), 1);
                }
                collectedSteamIDS.push(xuid);
                $.Msg(`Adding ${xuid} to the collection..`);
            }
        }
        $.Msg(`Mass invite collection: ${collectedSteamIDS.length}`);
    ]])
end)

gui.Button(LIGroupbox, 'Mass invite nearbies', function()
    executeScript([[
        collectedSteamIDS.forEach(xuid => {
            FriendsListAPI.ActionInviteFriend(xuid, "");
        });
    ]])
end)

gui.Button(LIGroupbox, 'Print invite collection', function()
    executeScript([[
        $.Msg(collectedSteamIDS);
    ]])
end)

gui.Button(LIGroupbox, 'Invite all recents', function()
    executeScript([[
		for (i=0; i < TeammatesAPI.GetCount(); i++) {
			var xuid = TeammatesAPI.GetXuidByIndex(i);
			FriendsListAPI.ActionInviteFriend(xuid, "");
		}
    ]]) 
end)

gui.Button(LIGroupbox, 'Invite all friends', function()
    executeScript([[
        var friends = FriendsListAPI.GetCount();
        for (var id = 0; id < friends; id++) {
            var xuid = FriendsListAPI.GetXuidByIndex(id);
            FriendsListAPI.ActionInviteFriend(xuid, "");
        }
    ]]) 
end)