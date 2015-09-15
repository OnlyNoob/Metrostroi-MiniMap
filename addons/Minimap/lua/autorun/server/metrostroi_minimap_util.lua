AddCSLuaFile("autorun/client/cl_metrostroi_minimap_util.lua")
AddCSLuaFile("autorun/client/3d2dimgui.lua")
AddCSLuaFile(string.format("configs/maps/%s.lua",game.GetMap()))

if !MiniMap then MiniMap = {} end
MiniMap.ActiveDispatcher = nil
MiniMap.NearPlayers = {}
MiniMap.Cache = {}

-----------------------------
--Load map config------------
-----------------------------

include(string.format("minimap/configs/maps/%s.lua",game.GetMap()))
resource.AddFile(string.format("models/minimap/%s.mdl",MiniMap.Model or (game.GetMap())))
resource.AddFile(string.format("materials/models/minimap/%s.vmt",MiniMap.Model or (game.GetMap())))
-----------------------------
--Load,Save,Reload-----------
-----------------------------

function MiniMap.LoadMinimapEnts()
	if (file.Exists(string.format("metrostroi_data/minimap_%s.txt",game.GetMap()),"DATA")) then
		local data = util.JSONToTable(file.Read(string.format("metrostroi_data/minimap_%s.txt",game.GetMap())))
		for k,v in pairs(data) do
			local minimap = ents.Create("gmod_metrostroi_minimap")
			minimap:SetPos(v.Pos - Vector(0,0,140))
			minimap:SetZOffset(v.ZOffset)
			minimap:Spawn()
			
			for k,v in pairs(Metrostroi.TrainClasses) do
				for k2,v2 in pairs(ents.FindByClass(v)) do
						local minitrain = ents.Create("gmod_metrostroi_minitrain")
						minitrain.BaseEnt = minimap:EntIndex()
						minitrain.TrainEnt = v2:EntIndex()
						minitrain:SetParent(minimap)
					
						minitrain:Spawn()
						minitrain:Activate()
				end
			end
		end
	end
end

function MiniMap.SaveMinimapEnts()
	if not file.Exists("metrostroi_data","DATA") then
		file.CreateDir("metrostroi_data")
	end
	local data = {}
	for k,v in pairs(ents.FindByClass("gmod_metrostroi_minimap")) do
		table.Add(data, {{Pos = v:GetPos(),ZOffset = v:GetZOffset()}})
	end
	file.Write(string.format("metrostroi_data/minimap_%s.txt",game.GetMap()), util.TableToJSON(data))
end

concommand.Add("metrostroi_minimap_save", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	MiniMap.SaveMinimapEnts()
end)

function MiniMap.ReloadMinimapEnts()
	for k,v in pairs(ents.FindByClass("gmod_metrostroi_minimap")) do
		v:Remove()
	end
	MiniMap.LoadMinimapEnts()
end

concommand.Add("metrostroi_minimap_reload", function(ply, _, args)
	if (ply:IsValid()) and (not ply:IsAdmin()) then return end
	MiniMap.ReloadMinimapEnts()
end)

--------------------------
--Dispatcher--------------
--------------------------

function MiniMap.BecomeDispatcher(ply)
	if(!MiniMap.ActiveDispatcher) then
		if(MiniMap.NearPlayers[ply:UserID()]) then
			MiniMap.ActiveDispatcher = ply
			MiniMap.SendActiveDispatcher(ply:GetName())
			if (MiniMap.Updated) then
				MiniMap.ChangeSignalsMode(true)
			end
		end
	end
end

function MiniMap.LeaveDispatcher(ply)
	if (MiniMap.ActiveDispatcher) and (ply == MiniMap.ActiveDispatcher) then
		MiniMap.ActiveDispatcher = nil
		MiniMap.SendActiveDispatcher("Нету")
		MiniMap.ResetSignalsOverride()
		if (MiniMap.Updated) then
			MiniMap.ChangeSignalsMode(false)
		end
	end
end

function MiniMap.ChangeSignalsMode(semiauto)
	if semiauto then
		if MiniMap.SemiAutoSignals then
			for k,v in pairs(MiniMap.SemiAutoSignals) do
				local signal = Metrostroi.GetSignalByName(v)
				if signal then
					signal.Routes[1].Manual = true
					signal:CloseRoute(1)
				end
			end
		end
	else
		if MiniMap.SemiAutoSignals then
			for k,v in pairs(MiniMap.SemiAutoSignals) do
				local signal = Metrostroi.GetSignalByName(v)
				if signal then
					signal.Routes[1].Manual = false
				end
			end
		end
	end
end

function MiniMap.ResetSignalsOverride()
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		v.Close = false
		if (MiniMap.Updated) then
			v.InvasionSignal = false
		end
	end
end

concommand.Add("metrostroi_minimap_becomedispatcher", function(ply, _, args)
	if (ply:IsValid()) and (!MiniMap.HasPermission(ply, "MiniMap DispatcherAccess", true)) then return end
	MiniMap.BecomeDispatcher(ply)
end)

concommand.Add("metrostroi_minimap_leavedispatcher", function(ply, _, args)
	if (ply:IsValid()) and (!MiniMap.HasPermission(ply, "MiniMap DispatcherAccess", true)) then return end
	MiniMap.LeaveDispatcher(ply)
end)

concommand.Add("metrostroi_minimap_resetsignals", function(ply, _, args)
	if (ply:IsValid()) and (!MiniMap.HasPermission(ply, "MiniMap DispatcherAccess", true)) then return end
	if (MiniMap.ActiveDispatcher) and (ply:UserID() == MiniMap.ActiveDispatcher:UserID()) then
		MiniMap.ResetSignalsOverride()
	end
end)

----------------------------
--Send Data to players------
----------------------------

util.AddNetworkString("gmod_minimap_sign_data")

function MiniMap.SendSignData(ply)
	if MiniMap.Cache.SignData then
		net.Start("gmod_minimap_sign_data")
		net.WriteTable(MiniMap.Cache.SignData)
		net.Send(ply)
	else
		local signents = ents.FindByClass("gmod_track_sign")
		local tbl = {}
		for k, v in pairs(signents) do
			local stname = v:GetNWString("Name","Error")
			if (stname == "Error" or stname == "") and MiniMap.StationNames then
				if MiniMap.StationNames[v:GetNWInt("ID")] then
					stname = MiniMap.StationNames[v:GetNWInt("ID")]
				end
			end
			table.Add(tbl, {{v:GetPos(),v:GetAngles(),stname}})
		end
		MiniMap.Cache.SignData = tbl
		net.Start("gmod_minimap_sign_data")
		net.WriteTable(tbl)
		net.Send(ply)
	end
end

util.AddNetworkString("gmod_minimap_activedispatcher")

function MiniMap.SendActiveDispatcher(name)
	net.Start("gmod_minimap_activedispatcher")
	net.WriteString(name)
	net.Broadcast()
end

----------------------------
--Sets up permissions
----------------------------
function MiniMap.SetupPermission(Permission, DefaultGroup, Help, Cat)
	if ULib then
		local grp = DefaultGroup or ULib.ACCESS_ALL
		
		return ULib.ucl.registerAccess( Permission, grp, Help, Cat )
	end
	if evolve and evolve.privileges then
		table.Add( evolve.privileges, {Permission} )
		table.sort( evolve.privileges )
		return
	end
	if exsto then
		exsto.CreateFlag( Permission:lower(), Help )
		return
	end
end
function MiniMap.HasPermission(ply, Permission, Default)
	if not IsValid(ply) then return Default end
	
	if ULib then
		return ULib.ucl.query( ply, Permission, true )
	end
	if ply.EV_HasPrivilege then
		return ply:EV_HasPrivilege( Permission )
	end
	if exsto then
		return ply:IsAllowed( Permission:lower() )
	end
	
	return Default
end

----------------------------
--Hooks---------------------
----------------------------

hook.Add( "InitPostEntity", "MiniMap Autoload", function()
	MiniMap.LoadMinimapEnts()
end )

hook.Add( "PlayerInitialSpawn", "MiniMap DataSent", function(ply)
	timer.Simple(15,function()
		if (ply:IsValid()) then
			MiniMap.SendSignData(ply)
			if(MiniMap.ActiveDispatcher and MiniMap.ActiveDispatcher:IsValid()) then
				MiniMap.SendActiveDispatcher(MiniMap.ActiveDispatcher:GetName())
			end
		end
	end)
end )

hook.Add( "Initialize", "MiniMap SetupPermissions", function()
	if not (MiniMap and MiniMap.SetupPermission) then return end
	
	--Main
	MiniMap.SetupPermission( "minimap dispatcheraccess", ULib and ULib.ACCESS_ADMIN, "User may be the Dispatcher", "MiniMap" )
end)

hook.Add( "OnEntityCreated", "MiniMap SpawnMiniTrains", function( ent )
	if Metrostroi.IsTrainClass[ent:GetClass()] and (ent:GetClass() != "gmod_subway_base") then
		for k2,v2 in pairs(ents.FindByClass("gmod_metrostroi_minimap")) do
			local minitrain = ents.Create("gmod_metrostroi_minitrain")
			minitrain.BaseEnt = v2:EntIndex()
			minitrain.TrainEnt = ent:EntIndex()
			minitrain:SetParent(v2)
			
			minitrain:Spawn()
			minitrain:Activate()
		end
	end
end )