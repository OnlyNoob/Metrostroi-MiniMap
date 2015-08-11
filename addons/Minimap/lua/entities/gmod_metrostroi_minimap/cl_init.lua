include("shared.lua")

--local trackdata = {}
local signdata = {}

net.Receive("gmod_minimap_sign_data", function( len, ply )

	signdata = {}
	signdata = net.ReadTable()
	 
 end) 

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 	0, "ZOffset", { KeyName = "zoffset", Edit = { type = "Int", title="Z Offset", min = -500, max = 500, order = 1 } } )
end

function ENT:Initialize()
	timer.Simple(30,function()
		if (self:IsValid()) then
			self:SetRenderBounds( self:OBBMins(), self:OBBMaxs(), (MiniMap.RenderBoundsAdd or Vector( 150, 150, 100 )) )
		end
	end)
end

function ENT:Draw()
	self.BaseClass.Draw(self)
    self:DrawModel()
    local offset = self:GetZOffset()

    self.Panel = self.Panel or tdui.Create()

    -- Draw a rectangle (x, y, w, h, [fill_color], [outline_color])
    self.Panel:Rect(-80, 0, 560, 250, _, Color(255, 255, 255))

    -- Draw a line of text (text, font, x, y, [color], [halign], [valign])
    -- Note: text is implicitly horizontally centered
    self.Panel:Text("Диспетчер:", "DermaLarge", 0, 5)
    self.Panel:Text(MiniMap.ActiveDispatcher, "DermaLarge", 70, 5, _, TEXT_ALIGN_LEFT)
	self.Panel:Text("Светофоры:", "DermaLarge", 0, 70)
    self.Panel:Text("TIP: Нажмите 'C' и наведите на минивагон", "DermaLarge", -70, 100, _, TEXT_ALIGN_LEFT)
    self.Panel:Text("если табличка над ним не отображается.", "DermaLarge", -70, 125, _, TEXT_ALIGN_LEFT)
    -- Draw a button (text, font, x, y, w, h, [color])
    -- Return value is boolean indicating whether left mouse or +use was pressed during this frame
    if self.Panel:Button("Занять пост", "DermaDefaultBold", -70, 40, 100, 25) then
        RunConsoleCommand("metrostroi_minimap_becomedispatcher")
    end
    if self.Panel:Button("Освободить пост", "DermaDefaultBold", 40, 40, 120, 25) then
        RunConsoleCommand("metrostroi_minimap_leavedispatcher")
    end
    if self.Panel:Button("Сбросить", "DermaDefaultBold", 75, 75, 120, 25) then
        RunConsoleCommand("metrostroi_minimap_resetsignals")
    end

    -- Draws a simple crosshair cursor at current mouse position
    self.Panel:Cursor()

    -- Renders all the queued draw commands
    self.Panel:Render(self:GetPos() + (MiniMap.PanelRenderOffset or Vector(150,80,100)), self:GetAngles(), 0.4)

	if (GetConVarNumber("metrostroi_minimap_drawsigns") == 1) then
		for k,sign in pairs(signdata) do
			local signpos = sign[1]
			local signang = sign[2]
			cam.Start3D2D(Vector(self:GetPos().x + (signpos.x / 100),self:GetPos().y + (signpos.y / 100),self:GetPos().z + (signpos.z / 100) + offset + 2), Angle(0,signang.y+90,90), 0.20);
	       		cam.IgnoreZ(false);
	        	draw.DrawText(sign[3], "DermaDefault", 0, 0, color_white);
	    	cam.End3D2D()
		end
	end
end