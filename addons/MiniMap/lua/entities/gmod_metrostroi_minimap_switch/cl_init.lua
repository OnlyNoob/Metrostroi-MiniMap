include("shared.lua")

function ENT:Initialize()
	self.Track = nil
end

function ENT:Think()
	self.Track = self:GetNWString( "TrackInfo" )
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Draw()
	self:DrawModel()
	cam.Start3D2D(self:GetPos() + Vector(0,0,5), self:GetAngles() + Angle(0,0,90), 0.20);
	cam.IgnoreZ(false);
	draw.DrawText(self.Track, "DermaDefault", 0, 0, Color(0,255,0));
	cam.End3D2D()
	cam.Start3D2D(self:GetPos() + Vector(0,0,5), self:GetAngles() + Angle(0,180,90), 0.20);
	cam.IgnoreZ(false);
	draw.DrawText(self.Track, "DermaDefault", 0, 0, Color(0,255,0));
	cam.End3D2D()
end