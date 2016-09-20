AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/ars_box.mdl")
	self:SetModelScale(0.02, 0)
	self.Sprites = {}
	self.CacheData = {}
	self.OrigSignal = nil
	
	-- Setup nominal signals (give it few seconds to establish)
	self.NominalSignals = 0
	self.NoNominalSignals = true
	self.GetNominalSignals = function(self) return self.NominalSignals end
	self.SkipCache = true
	timer.Simple(16.0,function()
		if IsValid(self) and self.GetActiveSignals then
			self.SkipCache = false
			self.NoNominalSignals = false
			self.NominalSignals = self:GetActiveSignals()
		end
	end)
	self:SetSolid(SOLID_OBB)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType( SIMPLE_USE )
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = {"none"}
	if NADMOD then
		NADMOD.SetOwnerWorld(self)
	end
end

function ENT:Use( activator, caller, useType, value )
	if Entity(self.OrigSignal):IsValid() then
		if (MiniMap.ActiveDispatcher) and (caller:UserID() == MiniMap.ActiveDispatcher:UserID()) then
			if Entity(self.OrigSignal).OverrideTrackOccupied then
				Entity(self.OrigSignal).OverrideTrackOccupied = false
			else
				Entity(self.OrigSignal).OverrideTrackOccupied = true
			end
		end
	end
end

function ENT:SetSprite(index,active,model,scale,brightness,pos,color)
	if active and self.Sprites[index] then return end
	SafeRemoveEntity(self.Sprites[index])
	self.Sprites[index] = nil
	
	if active then
		local sprite = ents.Create("env_sprite")
		sprite:SetParent(self)
		sprite:SetLocalPos(pos)
		sprite:SetLocalAngles(self:GetAngles())
	
		-- Set parameters
		sprite:SetKeyValue("rendercolor",
			Format("%i %i %i",
				color.r*brightness,
				color.g*brightness,
				color.b*brightness
			)
		)
		sprite:SetKeyValue("rendermode", 9) -- 9: WGlow, 3: Glow
		sprite:SetKeyValue("renderfx", 14)
		sprite:SetKeyValue("model", model)
		sprite:SetKeyValue("scale", scale)
		sprite:SetKeyValue("spawnflags", 1)
	
		-- Turn sprite on
		sprite:Spawn()
		self.Sprites[index] = sprite
	end
end

function ENT:GetNoFreq()
	if self:GetActiveSignalsBit(14) or
	   self:GetActiveSignalsBit(13) or
	   self:GetActiveSignalsBit(12) or
	   self:GetActiveSignalsBit(11) or
	   self:GetActiveSignalsBit(10) then return false end
	
	return true
end

function ENT:Cache(name,value_func)
	-- Old entry
	self.CacheData = self.CacheData or {}
	if self.CacheData[name] and (not self.SkipCache) and IsValid(self.CacheData[name]) then return self.CacheData[name] end
	
	-- New entry
	self.CacheData[name] = value_func()
	return self.CacheData[name]
end

function ENT:Think()
	if !Entity(self.OrigSignal):IsValid() then 
		self:Remove()
		return
	end
	-- Create sprites and manage lamps
	local index = 1
	local models = self.TrafficLightModels[self:GetLightsStyle()] or {}	
	local offset = self.RenderOffset[self:GetLightsStyle()] or Vector(0,0,0)
	for k,v in ipairs(models) do	
		if self:GetTrafficLightsBit(k-1) and v[3] then
			offset = offset - Vector(0,0,v[1])
			for light,data in pairs(v[3]) do
				local state = Entity(self.OrigSignal):GetActiveSignalsBit(light)
				if light == 4 then state = state and ((CurTime() % 1.00) > 0.25) end
				if Metrostroi.Voltage < 50 then state = false end
				
				-- The LED glow
				self:SetSprite(k..light.."a",state,
					"models/metrostroi_signals/signal_sprite_001.vmt",0.008,1.0,
					self.BasePosition + offset + data[1],data[2])
				
				-- Overall glow
				self:SetSprite(k..light.."b",state,
					"models/metrostroi_signals/signal_sprite_002.vmt",0.0050,0.6,
					self.BasePosition + offset + data[1],data[2])
				index = index + 1
			end
		end
	end
	
	self:NextThink(CurTime() + 0.50)
	return true
end
