AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.minitrainsoffset = MiniMap.MiniTrainsOffset or 0
	
	timer.Simple(0.1, function () 
	if Entity(self.TrainEnt):IsValid() then
		self:SetModel(Entity(self.TrainEnt):GetModel()) 
		self:SetPlayer(Entity(self.TrainEnt).Owner)
		self.head = (Entity(self.TrainEnt).SubwayTrain.Name == "81-717" or Entity(self.TrainEnt).SubwayTrain.Name == "Ezh3" or Entity(self.TrainEnt).SubwayTrain.Name == "81-717.5m" or Entity(self.TrainEnt).SubwayTrain.Name == "E" or Entity(self.TrainEnt).SubwayTrain.Name == "Ema") or false
	end
	if NADMOD then
		NADMOD.SetOwnerWorld(self)
	end
	end)
	self:SetSolid(SOLID_OBB)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = {"none"}
	self:SetModelScale(self:GetModelScale() / 100, 0)
	self.sync = false
end

function ENT:Think()
	if Entity(self.TrainEnt):IsValid() then
		--Update pos
		local BasePos = Entity(self.BaseEnt):GetPos()
		local pos = Entity(self.TrainEnt):GetPos()
		self:SetPos(Vector(BasePos.x + (pos.x / 100),BasePos.y + (pos.y / 100),BasePos.z + (pos.z / 100) + Entity(self.BaseEnt):GetZOffset() + self.minitrainsoffset))
		self:SetAngles(Entity(self.TrainEnt):GetAngles())
		--Update info
		if MiniMap.Updated then
			if self.head then
				self:SetOverlayText(string.format("Speed: %i\nLimit: %s | NextLimit: %s\nRouteNumber: %s",math.floor(Entity(self.TrainEnt).Speed),Entity(self.TrainEnt).ALS_ARS.SpeedLimit or "-",Entity(self.TrainEnt).ALS_ARS.NextLimit or "-",Entity(self.TrainEnt).RouteNumber or "-"))
			else
				self:SetOverlayText(string.format("Speed: %i",math.floor(Entity(self.TrainEnt).Speed)))
			end
		else
			if self.head then
				self:SetOverlayText(string.format("Speed: %i\nLimit: %s | NextLimit: %s",math.floor(Entity(self.TrainEnt).Speed),Entity(self.TrainEnt).ALS_ARS.SpeedLimit or "-",Entity(self.TrainEnt).ALS_ARS.NextLimit or "-"))
			else
				self:SetOverlayText(string.format("Speed: %i",math.floor(Entity(self.TrainEnt).Speed)))
			end
		end
		self.BaseClass.Think(self)
	else
		self:Remove()
		return
	end

	if !self.sync then
		self.sync = true
		self:NextThink(math.ceil(CurTime()) + 1)
		return true
	else
		self:NextThink(CurTime() + 1)
		return true
	end
end