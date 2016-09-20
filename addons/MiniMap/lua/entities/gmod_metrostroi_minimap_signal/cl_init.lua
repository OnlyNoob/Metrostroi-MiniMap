include("shared.lua")


--------------------------------------------------------------------------------
function ENT:Initialize() self.Models = {} end
function ENT:OnRemove() self:RemoveModels() end
function ENT:RemoveModels()
	for k,v in pairs(self.Models) do v:Remove() end
	self.Models = {}
end

function ENT:Think()
	local models = self.TrafficLightModels[self:GetLightsStyle()] or {}
	
	-- Remove old models
	if self:GetLightsStyle() ~= self.PreviousLightsStyle then
		self.PreviousLightsStyle = self:GetLightsStyle()
		self:RemoveModels()
	end
	if (GetConVarNumber("metrostroi_minimap_displaysignalmodels") == 1) then
		-- Create new clientside models
		if self:GetTrafficLights() > 0 then
			for k,v in pairs(models) do
				if type(v) == "string" then
					if not self.Models[k] then
						self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
						self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition))
						self.Models[k]:SetAngles(self:GetAngles())
						self.Models[k]:SetModelScale(0.02, 0)
						self.Models[k]:SetParent(self)
					end
				end
			end
			
			-- Create traffic light models
			local offset = self.RenderOffset[self:GetLightsStyle()] or Vector(0,0,0)
			for k,v in ipairs(models) do
				if self:GetTrafficLightsBit(k-1) then
					offset = offset - Vector(0,0,v[1])
					if not self.Models[k] then
						self.Models[k] = ClientsideModel(v[2],RENDERGROUP_OPAQUE)
						self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition + offset))
						self.Models[k]:SetAngles(self:GetAngles())
						self.Models[k]:SetModelScale(0.02, 0)
						self.Models[k]:SetParent(self)
					end
				end
			end
		--else
			--local k = "m1"
			--local v = self.TrafficLightModels[0]["m1"]

			--if not self.Models[k] then
			--	self.Models[k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
			--	self.Models[k]:SetPos(self:LocalToWorld(self.BasePosition))
			--	self.Models[k]:SetAngles(self:GetAngles())
			--	self.Models[k]:SetModelScale(0.01, 0)
			--	self.Models[k]:SetParent(self)
			--end
		end
	else
		self:RemoveModels()
	end
	
	self:NextThink(CurTime() + 0.25)
	return true
end

function ENT:Draw()
	-- Draw model
	--self:DrawModel()
end