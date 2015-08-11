AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	timer.Simple(0.1, function () 
	if Entity(self.OrigSwitch):IsValid() then
		self:SetModel(Entity(self.OrigSwitch):GetModel()) 
		self:SetPlayer(Entity(self.OrigSwitch).Owner)
	end
	if NADMOD then
		NADMOD.SetOwnerWorld(self)
	end
	end)
	self:SetSolid(SOLID_OBB)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = {"none"}
	self:SetModelScale(0.02, 0)
	self:SetUseType( SIMPLE_USE )
	self.OrigSwitch = nil
end

function ENT:Use( activator, caller, useType, value )
	if Entity(self.OrigSwitch):IsValid() then
		if (MiniMap.ActiveDispatcher) and (caller:UserID() == MiniMap.ActiveDispatcher:UserID()) then
			if Entity(self.OrigSwitch).AlternateTrack then
				Entity(self.OrigSwitch):SendSignal("main",Entity(self.OrigSwitch):GetChannel())
			else
				Entity(self.OrigSwitch):SendSignal("alt",Entity(self.OrigSwitch):GetChannel())
			end
		end
	end
end

function ENT:Think()
	if Entity(self.OrigSwitch):IsValid() then
		if Entity(self.OrigSwitch).AlternateTrack then
			self:SetNWString( "TrackInfo", "Alt" )
		else
			self:SetNWString( "TrackInfo", "Main" )
		end
	else
		self:Remove()
		return
	end

	self:NextThink(CurTime() + 1)
	return true
end