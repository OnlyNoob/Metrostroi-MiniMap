--Register Client Ent
if !MiniMap.OrangeDisp then MiniMap.OrangeDisp = {} end

function MiniMap.OrangeDisp.RegisterEnt()
	local ENT = scripted_ents.Get( "base_gmodentity" )

	function ENT:Initialize()
		timer.Simple(30,function()
			if (self:IsValid()) then
				--self:SetRenderBounds( self:OBBMins(), self:OBBMaxs(), (MiniMap.RenderBoundsAdd or Vector( 150, 150, 100 )) )
				self:SetRenderBounds( self:OBBMins(), self:OBBMaxs(), Vector( 150, 150, 100 ) )
			end
		end)
	end

	function ENT:Draw()
		--self.BaseClass.Draw(self)
		--self:DrawModel()
		--local offset = self:GetZOffset()

		self.Panel = self.Panel or tdui.Create()

		-- Draw a rectangle (x, y, w, h, [fill_color], [outline_color])
		self.Panel:Rect(-80, 0, 560, 250, _, Color(255, 255, 255))

		-- Draw a line of text (text, font, x, y, [color], [halign], [valign])
		-- Note: text is implicitly horizontally centered
		self.Panel:Text("Диспетчер:", "DermaLarge", 0, 5)
		self.Panel:Text(MiniMap.ActiveDispatcher, "DermaLarge", 70, 5, _, TEXT_ALIGN_LEFT)
		self.Panel:Text("Светофоры:", "DermaLarge", 0, 70)
		self.Panel:Text("Всего вагонов:", "DermaLarge", -70, 100, _, TEXT_ALIGN_LEFT)
		self.Panel:Text(GetGlobalInt("metrostroi_train_count", 0),"DermaLarge", 120, 100, _, TEXT_ALIGN_LEFT)
		self.Panel:Text("TIP: Нажмите 'C' и наведите на минивагон", "DermaLarge", -70, 130, _, TEXT_ALIGN_LEFT)
		self.Panel:Text("если табличка над ним не отображается.", "DermaLarge", -70, 155, _, TEXT_ALIGN_LEFT)
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
		if self.Panel:Button("Исправить отображение", "DermaDefaultBold", -70, 190, 160, 25) then
			self:FixRender()
		end

		-- Draws a simple crosshair cursor at current mouse position
		self.Panel:Cursor()

		self.Panel:SetIgnoreZ(true)
		-- Renders all the queued draw commands
		--self.Panel:Render(self:GetPos() + (MiniMap.PanelRenderOffset or Vector(150,80,100)), self:GetAngles(), 0.4)
		self.Panel:Render(self:GetPos() + Vector(0,45,0), self:GetAngles() + Angle(0,90,0), 0.4)
	end
	
	function ENT:FixRender()
		if (self:IsValid()) then
			self:SetRenderBounds( self:OBBMins(), self:OBBMaxs(), Vector( 150, 150, 100 ) )
		end
	end

	scripted_ents.Register( ENT, "gmod_metrostroi_minimap_brush" )
end

hook.Add( "InitPostEntity", "MiniMap.OrangeDisp Autoload", function()
	if game.GetMap() == "gm_mus_orange_metro_h" then
		MiniMap.OrangeDisp.RegisterEnt()
	end
end)