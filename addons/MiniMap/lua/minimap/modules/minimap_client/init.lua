--Need minimap module to work!
if !MiniMap.Client then MiniMap.Client = {} end
if !MiniMapServer then MiniMapServer = {} end
MiniMapServer.Cache = {}

--local _R = debug.getregistry()

function MiniMap.Client.Init()
	--Load config
	include("minimap/configs/modules/minimap_client.lua")
	
	if MiniMap.Client.Enabled then
		MsgC(Color(20, 255, 20), "[MiniMap.Client]: Module enabled. Starting server.\n")
		require("minimap")
		MiniMapServer.SetMode(MiniMap.Client.Mode)
		MiniMapServer.Start(MiniMap.Client.Port or 5890)
		MiniMapServer.SetMetrostroiHooks()
	else
		MsgC(Color(255, 20, 20), "[MiniMap.Client]: Module disabled.\n")
		return
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Print Dispatcher message in chat.
----------------------------------------------------------------------

function MiniMapServer.DispMessage(msg)
	for _, player in ipairs( player.GetAll() ) do
		player:ChatPrint( "Диспетчер: " .. msg )
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Install Signal hooks to send data in client.
----------------------------------------------------------------------

function MiniMapServer.SetMetrostroiHooks()
	if not Metrostroi.Load then 
		timer.Simple(0.25, MiniMapServer.SetMetrostroiHooks) 
		return 
	end
	Metrostroi.OldLoad = Metrostroi.OldLoad or Metrostroi.Load
	Metrostroi.Load = function( ... )
		--before
		
		--orig
		Metrostroi.OldLoad( ... )
		--after
		timer.Simple(1.0, MiniMapServer.SetSignalHooks)
	end
end

function MiniMapServer.SetSignalHooks()
	MsgC(Color(20, 255, 20), "[MiniMap.Client]: Hooking Metrostroi.\n")
	local signals_ents = ents.FindByClass("gmod_track_signal")
	for k,v in pairs(signals_ents) do 
		if v.Occupied ~= nil then
			v.oldARSLogic = v.oldARSLogic or v.ARSLogic
			v.ARSLogic = function( ... ) 
				--before
				local oldState = v.Occupied
				--orig
				v.oldARSLogic( ... )
				--after
				local newState = v.Occupied
				if (newState ~= oldState and v.NextSignalLink) then
					local Signals = v.Name.."-"..(v.NextSignalLink.Name or "")
					MiniMapServer.Cache[Signals] = newState
					--Send to client ^)
					MiniMapServer.SendMessage(2, Signals, newState)
				end
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Send other chat messages to client.
----------------------------------------------------------------------

hook.Add( "PlayerSay", "MiniMapServer.PlayerSay", function( ply, text, team )
	if MiniMap.Client.Enabled then
		MiniMapServer.SendMessage(1, ply:GetName(), text)
	end
end )

hook.Add( "MetrostroiPlombBroken", "MiniMapServer.PlombBroken", function( train, button, driver)
	if MiniMap.Client.Enabled then
		MiniMapServer.SendMessage(1, "SERVER", driver.." broke seal on "..button.." !")
	end
end )

MiniMap.Client.Init()