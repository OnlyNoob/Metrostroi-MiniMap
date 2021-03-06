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
				if MiniMap.BlockSwitches then
					Entity(self.OrigSwitch).LockedSignal = "main"
					caller:PrintMessage( HUD_PRINTCENTER, "Main (Blocked)" )
				else
					Entity(self.OrigSwitch):SendSignal("main",Entity(self.OrigSwitch):GetChannel())
					caller:PrintMessage( HUD_PRINTCENTER, "Main" )
				end
			else
				if MiniMap.BlockSwitches then
					Entity(self.OrigSwitch).LockedSignal = "alt"
					caller:PrintMessage( HUD_PRINTCENTER, "Alt (Blocked)" )
				else
					Entity(self.OrigSwitch):SendSignal("alt",Entity(self.OrigSwitch):GetChannel())
					caller:PrintMessage( HUD_PRINTCENTER, "Alt" )
				end
			end
		end
	end
end

function ENT:Think()
	if Entity(self.OrigSwitch):IsValid() then
		if MiniMap.BlockSwitches then
			if Entity(self.OrigSwitch).AlternateTrack then
				self:SetNWString( "TrackInfo", "Alt(Blocked)" )
			else
				self:SetNWString( "TrackInfo", "Main(Blocked)" )
			end
		else
			if Entity(self.OrigSwitch).AlternateTrack then
				self:SetNWString( "TrackInfo", "Alt" )
			else
				self:SetNWString( "TrackInfo", "Main" )
			end
		end
	else
		self:Remove()
		return
	end

	self:NextThink(CurTime() + 1)
	return true
end