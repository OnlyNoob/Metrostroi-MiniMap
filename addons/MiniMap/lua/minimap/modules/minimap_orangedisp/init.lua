--AddCSLuaFile("minimap/modules/minimap_orangedisp/cl_init.lua") --For client side render
if !MiniMap.OrangeDisp then MiniMap.OrangeDisp = {} end

function MiniMap.OrangeDisp.Init()
	--Load config
	include("minimap/configs/modules/minimap_orangedisp.lua")
	
	if MiniMap.OrangeDisp.Enabled and (game.GetMap() == "gm_mus_orange_metro_h") then
		MsgC(Color(20, 255, 20), "[MiniMap.OrangeDisp]: Module enabled.\n")
	else
		MsgC(Color(255, 20, 20), "[MiniMap.OrangeDisp]: Module disabled.\n")
		return
	end
end

function MiniMap.OrangeDisp.RegisterEnt()
	--local ENT = scripted_ents.Get( "base_gmodentity" ) --For client side render
	local ENT = scripted_ents.Get( "base_brush" )
	function ENT:Initialize()
		self:SetSolid(SOLID_BBOX)   
		self:SetCollisionBoundsWS(Vector(-91,12970,-1010),Vector(884,12476,-1265)) //Set the positions according to the world
		--self:SetCollisionBounds(Vector(-25,-25,-25),Vector(25,25,25))
		self:SetTrigger(true)
		--self:UseTriggerBounds(true,500)
		--self:SetCollisionGroup(COLLISION_GROUP_WORLD) --For client side render
		--self.PhysgunDisabled = true --For client side render
		--self.m_tblToolsAllowed = {"none"} --For client side render
	end
	function ENT:StartTouch(ent)
		if MiniMap.ActiveDispatcher and ent != MiniMap.ActiveDispatcher and ent:IsPlayer() then
			ent:Kill()
		end
		if (ent:IsValid()) and (ent.IsPlayer()) then
			MiniMap.NearPlayers[ent:UserID()] = self:EntIndex()
		end
	end
	function ENT:EndTouch(ent)
		if (ent:IsValid()) and (ent.IsPlayer()) then
			MiniMap.NearPlayers[ent:UserID()] = false
			if (MiniMap.ActiveDispatcher) and (ent:UserID() == MiniMap.ActiveDispatcher:UserID()) then
				MiniMap.ActiveDispatcher = nil
				MiniMap.ActiveEntity = nil
				MiniMap.SendActiveDispatcher("Нету")
				MiniMap.ResetSignalsOverride()
				if (MiniMap.Updated) then
					MiniMap.ChangeSignalsMode(false)
					MiniMap.ResetSwitchesOverride()
				end
			end
		end
	end
	
	scripted_ents.Register( ENT, "gmod_metrostroi_minimap_brush" )
	
	MiniMap.OrangeDisp.SpawnEnt()
end

function MiniMap.OrangeDisp.SpawnEnt()
	MiniMap.OrangeDisp.Entity = ents.Create("gmod_metrostroi_minimap_brush")
	MiniMap.OrangeDisp.Entity:SetPos(Vector(396,12723,-1189))
	MiniMap.OrangeDisp.Entity:Spawn()
	MiniMap.OrangeDisp.Entity:Activate()
end

hook.Add( "InitPostEntity", "MiniMap.OrangeDisp Autoload", function()
	if MiniMap.OrangeDisp.Enabled and (game.GetMap() == "gm_mus_orange_metro_h") then
		MiniMap.OrangeDisp.RegisterEnt()
	end
end)

MiniMap.OrangeDisp.Init()