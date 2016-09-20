include("shared.lua")


--------------------------------------------------------------------------------
function ENT:Initialize() self.Models = {} end
function ENT:OnRemove() self:RemoveModels() end
function ENT:RemoveModels()
	if self.Models ~= nil then
	for k,v in pairs(self.Models) do v:Remove() end
	self.Models = {}
	end
end

function ENT:Think()
	self.LightType = self:GetNWInt("LightType") - 2
	self.Lenses = self:GetNWString("Lenses")
	self.Left = self:GetNWBool("Left")
	self.Double = self:GetNWBool("Double")

	local models = self.TrafficLightModels[self.LightType] or {}
	local ID = 0

	if (GetConVarNumber("metrostroi_minimap_displaysignalmodels") == 1) then
		-- Create new clientside models
		if self.Lenses ~= "ARSOnly" then
			if self.Lenses ~= self.OldLenses then
				for k,v in pairs(self.Models) do
					if IsValid(v) then
						v:Remove()
					end
					self.Models[k] = nil
				end
			end
			if not self.LensesTBL or self.Lenses ~= self.OldLenses then
				self.LensesTBL = string.Explode("-",self.Lenses)
			end
			for k,v in pairs(models) do
				if type(v) == "string" then
					if not self.Models[k] then
						self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
						self.Models[k]:SetPos(self:LocalToWorld(self.Left and self.BasePosition * Vector(-1,1,1) or self.BasePosition))
						self.Models[k]:SetAngles(self:GetAngles())
						self.Models[k]:SetModelScale(0.02, 0)
						self.Models[k]:SetParent(self)
						if self.Double then
							self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
							self.Models[k]:SetPos(self:LocalToWorld(self.Left and self.BasePosition or self.BasePosition * Vector(-1,1,1)))
							self.Models[k]:SetAngles(self:GetAngles())
							self.Models[k]:SetModelScale(0.02, 0)
							self.Models[k]:SetParent(self)
						end
					end
				end
			end
			if self.LightType > 2 then self.LightType = 2 end
			if self.LightType < 0 then self.LightType = 0 end
			
			-- Create traffic light models
			local offset = self.RenderOffset[self.LightType] or Vector(0,0,0)
			for k,v in ipairs(self.LensesTBL) do
				if not IsValid(self.Models[ID]) then
					local data	
					if v ~= "M" then
						data = #v ~= 1 and self.TrafficLightModels[self.LightType][#v-1] or self.TrafficLightModels[self.LightType][Metrostroi.Signal_IS]
					else
						data = self.TrafficLightModels[self.LightType][Metrostroi.Signal_RP]
					end
					if not data then continue end
					offset = offset - Vector(0,0,data[1])

					self.Models[ID] = ClientsideModel(self.Left and data[2]:Replace(".mdl","_mirror.mdl") or data[2],RENDERGROUP_OPAQUE)
					self.Models[ID]:SetPos(self:LocalToWorld(self.Left and (self.BasePosition + offset) * Vector(-1,1,1) or self.BasePosition + offset))
					self.Models[ID]:SetAngles(self.Left and self:GetAngles() + Angle(0,0,0) or self:GetAngles())
					self.Models[ID]:SetModelScale(0.02, 0)
					self.Models[ID]:SetParent(self)
					if self.Double then
						self.Models[ID] = ClientsideModel(self.Left and data[2]:Replace(".mdl","_mirror.mdl") or data[2],RENDERGROUP_OPAQUE)
						self.Models[ID]:SetPos(self:LocalToWorld(not self.Left and (self.BasePosition + offset) * Vector(-1,1,1) or self.BasePosition + offset))
						self.Models[ID]:SetAngles(self.Left and self:GetAngles() + Angle(0,0,0) or self:GetAngles())
						self.Models[ID]:SetModelScale(0.02, 0)
						self.Models[ID]:SetParent(self)
					end
				end
				ID = ID + 1
			end
		else
			local k = "m1"
			local v = self.TrafficLightModels[0]["m1"]

			if not self.Models[k] then
				self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
				self.Models[k]:SetPos(self:LocalToWorld(self.Left and self.BasePosition * Vector(-1,1,1) or self.BasePosition))
				self.Models[k]:SetAngles(self:GetAngles())
				self.Models[k]:SetModelScale(0.02, 0)
				self.Models[k]:SetParent(self)
			end
		end
	else
		self:RemoveModels()
	end
	
	self.OldLenses = self.Lenses
	
	self:NextThink(CurTime() + 0.25)
	return true
end

function ENT:Draw()
	-- Draw model
	--self:DrawModel()
end