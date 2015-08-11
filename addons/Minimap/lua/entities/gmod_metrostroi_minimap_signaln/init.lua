AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/metrostroi/signals/ars_box.mdl")
	self:SetModelScale(0.02, 0)
	self.Sprites = {}
	self.OrigSignal = nil
	self.EnableDelay = {}
	
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
			if Entity(self.OrigSignal).Routes[1] and Entity(self.OrigSignal).Routes[1].Manual then
				if Entity(self.OrigSignal).Routes[1].IsOpened then
					Entity(self.OrigSignal):CloseRoute(1)
				else 
					Entity(self.OrigSignal):OpenRoute(1)
				end
			elseif Entity(self.OrigSignal).RedSignal and string.match( Entity(self.OrigSignal).LensesStr, "W", 0 ) and !Entity(self.OrigSignal).OverrideTrackOccupied then
				Entity(self.OrigSignal).InvasionSignal = !Entity(self.OrigSignal).InvasionSignal
			elseif !Entity(self.OrigSignal).Routes[1].Manual then
				Entity(self.OrigSignal).OverrideTrackOccupied = !Entity(self.OrigSignal).OverrideTrackOccupied
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

function ENT:Think()
	if !Entity(self.OrigSignal):IsValid() then 
		self:Remove()
		return
	end
	self:SetNWInt("LightType", (Entity(self.OrigSignal).SignalType or 0) + 2)
	self:SetNWString("Lenses", Entity(self.OrigSignal).LensesStr or "RRR-RRR")
	-- Create sprites and manage lamps
	local index = 1
	local offset = self.RenderOffset[Entity(self.OrigSignal).SignalType] or Vector(0,0,0)
	for k,v in ipairs(Entity(self.OrigSignal).Lenses) do
		local Lights = string.Explode("-",Entity(self.OrigSignal).Routes[Entity(self.OrigSignal).Route or 1].Lights)

		if v ~= "M" then
			--get the some models data
			local data = #v ~= 1 and self.TrafficLightModels[Entity(self.OrigSignal).SignalType][#v-1] or self.TrafficLightModels[Entity(self.OrigSignal).SignalType][Metrostroi.Signal_IS]
			if not data then continue end
			offset = offset - Vector(0,0,data[1])
			for i = 1,#v do
				--Get the LightID and check, is this light must light up
				local LightID = IsValid(Entity(self.OrigSignal).NextSignalLink) and math.min(#Lights,Entity(self.OrigSignal).FreeBS+1) or 1
				local AverageState = Lights[LightID]:find(tostring(index)) or (v[i] == "W" and Entity(self.OrigSignal).InvasionSignal)
				local MustBlink = (v[i] == "W" and Entity(self.OrigSignal).InvasionSignal) or (AverageState and Lights[LightID][AverageState+1] == "b") --Blinking, when next is "b" (or it's invasion signal')
				local TimeToOff = not (RealTime() % 0.8 > 0.25)
				--if v[i] == "R" and #Lights[LightID] == 1 and AverageState then self.RedSignal = true end
				--if v[i] == "R" and #Lights[LightID] <= 2 and AverageState then self.AutoEnabled = true end
				if MustBlink and TimeToOff then AverageState = false end
				
				--Simulate signal changing delay
				if not self.Sprites[index.."a"] and Lights[LightID]:find(tostring(index)) and not self.EnableDelay[index] then
					self.EnableDelay[index] = true
				else
					-- The LED glow
					self:SetSprite(index.."a",AverageState,
						"models/metrostroi_signals/signal_sprite_001.vmt",0.008,1.0,
						self.BasePosition + offset + data[3][i-1], Metrostroi.Lenses[v[i]])

					-- Overall glow
					self:SetSprite(index.."b",AverageState,
						"models/metrostroi_signals/signal_sprite_002.vmt",0.0050,0.6,
						self.BasePosition + offset + data[3][i-1], Metrostroi.Lenses[v[i]])
					self.EnableDelay[index] = nil
				end
				index = index + 1
			end
		end
	end
	
	self:NextThink(CurTime() + 0.25)
	return true
end
