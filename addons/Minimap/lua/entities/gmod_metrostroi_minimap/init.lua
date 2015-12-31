AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 	0, "ZOffset", { KeyName = "zoffset", Edit = { type = "Int", title="Z Offset", min = -500, max = 500, order = 1 } } )
end

function ENT:Initialize()
	self.minitrainsoffset = MiniMap.MiniTrainsOffset or 0

	self:SetModel("models/scenery/structural/gio_rail/endpiece.mdl")
	self:SetPos(self:GetPos() + Vector(0,0,140))
	self:SetAngles(Angle(0,0,0))

	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	if NADMOD then
		timer.Simple(10,function()
			NADMOD.SetOwnerWorld(self)
		end)
	end
	
	self.PhysgunDisabled = true

	local track = ents.Create("base_anim")
	track:SetModel(string.format("models/minimap/%s.mdl",MiniMap.Model or (game.GetMap())))
	track:SetPos(Vector(0, 0, self:GetZOffset() - 1))
	track:SetAngles(Angle(0, -90, 0))

	track:SetMoveParent(self)

	track:Spawn()

	self:SetTrigger(true)
	self:UseTriggerBounds(true,200)
	
	--Signal spawn--
	timer.Simple(10,function()
		if (self:IsValid()) then
			if (MiniMap.Updated) then
				local map_signals_ents = ents.FindByClass("gmod_track_signal")
				for k,v in pairs(map_signals_ents) do 
					local ent = ents.Create("gmod_metrostroi_minimap_signaln")
					if IsValid(ent) then
						ent:SetPos(Vector(self:GetPos().x + (v:GetPos().x / 100),self:GetPos().y + (v:GetPos().y / 100),self:GetPos().z + (v:GetPos().z / 100) + self:GetZOffset() + self.minitrainsoffset))
						ent:SetAngles(v:GetAngles())
						ent:SetParent(self)
						ent:Spawn()
					
						ent.OrigSignal = v:EntIndex()
					end
				end
			else 
				local map_signals_ents = ents.FindByClass("gmod_track_signal")
				for k,v in pairs(map_signals_ents) do 
					local ent = ents.Create("gmod_metrostroi_minimap_signal")
					if IsValid(ent) then
						ent:SetPos(Vector(self:GetPos().x + (v:GetPos().x / 100),self:GetPos().y + (v:GetPos().y / 100),self:GetPos().z + (v:GetPos().z / 100) + self:GetZOffset() + self.minitrainsoffset))
						ent:SetAngles(v:GetAngles())
						ent:SetParent(self)
						ent:Spawn()
					
						ent.OrigSignal = v:EntIndex()

						ent:SetSettings(v:GetSettings())
						ent:SetTrafficLights(v:GetTrafficLights())
						ent:SetLightsStyle(v:GetLightsStyle())
					end
				end
			end
			--Load switches--
			local map_switchs_ents = ents.FindByClass("gmod_track_switch")
			for k,v in pairs(map_switchs_ents) do 
				local ent = ents.Create("gmod_metrostroi_minimap_switch")
				if IsValid(ent) then
					ent:SetPos(Vector(self:GetPos().x + (v:GetPos().x / 100),self:GetPos().y + (v:GetPos().y / 100),self:GetPos().z + (v:GetPos().z / 100) + self:GetZOffset() + self.minitrainsoffset))
					ent:SetAngles(v:GetAngles())
					ent:SetParent(self)
					ent:Spawn()
					
					ent.OrigSwitch = v:EntIndex()
				end
			end
			--Load already spawned trains--
			for k,v in pairs(Metrostroi.TrainClasses) do
				for k2,v2 in pairs(ents.FindByClass(v)) do
						local minitrain = ents.Create("gmod_metrostroi_minitrain")
						minitrain.BaseEnt = self:EntIndex()
						minitrain.TrainEnt = v2:EntIndex()
						minitrain:SetParent(self)
					
						minitrain:Spawn()
						minitrain:Activate()
				end
			end
		end
	end)
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