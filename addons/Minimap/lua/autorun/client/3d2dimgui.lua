--[[
	The MIT License (MIT)

	Copyright (c) 2014 Wyozi <http://www.github.com/wyozi>

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

-- Localize globals
local bor, band, lshift = bit.bor, bit.band, bit.lshift

tdui = {}

-- Input constants.
-- We're not using GMod- versions, because they're not powers of two.
-- If you want to add a new input, see tdui:_UpdateInputStatus()
tdui.FMOUSE_LEFT =  lshift(1, 0)
tdui.FMOUSE_RIGHT = lshift(1, 1)
tdui.FKEY_USE     = lshift(1, 8)

-- Input constants that are make tdui:Button() return true etc.
tdui.FINPUT_PRESSED = bor(tdui.FMOUSE_LEFT, tdui.FKEY_USE)

-- Input state constants.
-- These are the bits returned from tdui:_CheckInputInRect()
tdui.FSTATE_HOVERING    = lshift(1, 0)
tdui.FSTATE_PRESSING    = lshift(1, 1) -- if input is pressed right now
tdui.FSTATE_JUSTPRESSED = lshift(1, 2) -- if input was pressed during this frame

-- Color constants
tdui.COLOR_BLACK = Color(0, 0, 0)
tdui.COLOR_BLACK_TRANSPARENT = Color(0, 0, 0, 0)

tdui.COLOR_WHITE = Color(255, 255, 255)
tdui.COLOR_WHITE_TRANSPARENT = Color(255, 255, 255, 0)
tdui.COLOR_WHITE_TRANSLUCENT = Color(255, 255, 255, 15)

tdui.COLOR_RED = Color(255, 0, 0)
tdui.COLOR_GREEN = Color(0, 255, 0)
tdui.COLOR_BLUE = Color(0, 0, 255)
tdui.COLOR_YELLOW = Color(255, 255, 0)

tdui.COLOR_ORANGE = Color(255, 127, 0)
tdui.COLOR_ORANGE_DARK = Color(220, 80, 0)
tdui.COLOR_ORANGE_LIGHT = Color(255, 180, 0)

-- Helper function. Call this inside a deprecated function as the first statement
local d = {}
function tdui.Deprecate(msg)
	local dbg = debug.getinfo(3, "Sl")
	local srcstr = string.format("%s@%d", dbg.source, dbg.currentline)
	
	if d[srcstr] then return end
	d[srcstr] = true
	
	if not msg then
		local thisdbg = debug.getinfo(2, "n")
		msg = thisdbg.name .. "() is deprecated"
	end
	print("[TDUI Deprecation Warning] " .. msg .. " (called at " .. srcstr .. ")")
end

-- The main function. See below for functions in tdui.Meta
function tdui.Create()
	return setmetatable({}, tdui.Meta)
end

local tdui_meta = {}
tdui_meta.__index = tdui_meta

tdui.Meta = tdui_meta

function tdui_meta:EnableRectStencil(x, y, w, h)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)

	render.OverrideColorWriteEnable(true, false)

	surface.SetDrawColor(tdui.COLOR_WHITE)
	surface.DrawRect(x, y, w, h)

	render.OverrideColorWriteEnable(false, false)

	render.SetStencilCompareFunction(STENCIL_EQUAL)
end

function tdui_meta:DisableStencil()
	render.SetStencilEnable(false)
end

function tdui_meta:DrawRect(x, y, w, h, clr, out_clr)
	clr = clr or tdui.COLOR_WHITE_TRANSLUCENT

	surface.SetDrawColor(clr)
	surface.DrawRect(x, y, w, h)

	if out_clr then
		surface.SetDrawColor(out_clr)
		surface.DrawOutlinedRect(x, y, w, h)
	end

	self:_ExpandRenderBounds(x, y, w, h)
end
function tdui_meta:Rect(x, y, w, h, clr, out_clr)
	self:_QueueRender(function()
		self:DrawRect(x, y, w, h, clr, out_clr)
	end)
end

function tdui_meta:DrawLine(x, y, x2, y2, clr)
	clr = clr or tdui.COLOR_WHITE

	surface.SetDrawColor(clr)
	surface.DrawLine(x, y, x2, y2)

	local bx, by = math.min(x, x2), math.min(y, y2)
	local bw, bh = math.max(x, x2)-bx, math.max(y, y2)-by
	self:_ExpandRenderBounds(bx, by, bw, bh)
end
function tdui_meta:Line(x, y, x2, y2, clr)
	self:_QueueRender(function()
		self:DrawLine(x, y, x2, y2, clr)
	end)
end

function tdui_meta:DrawPolygon(verts, clr, mat)
	clr = clr or tdui.COLOR_WHITE_TRANSLUCENT

	surface.SetDrawColor(clr)

	if mat then
		surface.SetMaterial(mat)
	else
		draw.NoTexture()
	end

	surface.DrawPoly(verts)
end
function tdui_meta:Polygon(verts, clr, mat)
	self:_QueueRender(function()
		self:DrawPolygon(verts, clr, mat)
	end)
end

function tdui_meta:DrawMat(mat, x, y, w, h)
	surface.SetMaterial(mat)
	surface.SetDrawColor(tdui.COLOR_WHITE)
	surface.DrawTexturedRect(x, y, w, h)

	self:_ExpandRenderBounds(x, y, w, h)
end
function tdui_meta:Mat(mat, x, y, w, h)
	self:_QueueRender(function()
		self:DrawMat(mat, x, y, w, h)
	end)
end

function tdui_meta:DrawText(str, font, x, y, clr, halign, valign, scissor_rect)
	clr = clr or tdui.COLOR_WHITE

	surface.SetFont(font)
	surface.SetTextColor(clr)

	local tw, th = surface.GetTextSize(str)

	-- Horizontal align default: TEXT_ALIGN_CENTER
	local aligned_x = x-tw/2
	if     halign == TEXT_ALIGN_LEFT then    aligned_x = x
	elseif halign == TEXT_ALIGN_RIGHT then   aligned_x = x-tw
	end

	-- Vertical align default: TEXT_ALIGN_TOP
	local aligned_y = y
	if     valign == TEXT_ALIGN_CENTER then  aligned_y = y-th/2
	elseif valign == TEXT_ALIGN_BOTTOM then  aligned_y = y-th
	end

	surface.SetTextPos(aligned_x, aligned_y)

	if scissor_rect then
		self:EnableRectStencil(scissor_rect.x, scissor_rect.y, scissor_rect.x2-scissor_rect.x, scissor_rect.y2-scissor_rect.y)
	end

	surface.DrawText(str)

	if scissor_rect then
		self:DisableStencil()
	end

	self:_ExpandRenderBounds(aligned_x, aligned_y, tw, th)
end
function tdui_meta:Text(str, font, x, y, clr, halign, valign, scissor_rect)
	self:_QueueRender(function()
		self:DrawText(str, font, x, y, clr, halign, valign, scissor_rect)
	end)
end

function tdui_meta:DrawButton(str, font, x, y, w, h, clr)
	clr = clr or tdui.COLOR_WHITE

	surface.SetFont(font)

	local inputstate = self:_CheckInputInRect(x, y, w, h)

	local just_pressed = band(inputstate, tdui.FSTATE_JUSTPRESSED) ~= 0
	local pressing = band(inputstate, tdui.FSTATE_PRESSING) ~= 0
	local hovering = band(inputstate, tdui.FSTATE_HOVERING) ~= 0

	if just_pressed or pressing then
		clr = tdui.COLOR_ORANGE_DARK
	elseif hovering then
		clr = tdui.COLOR_ORANGE
	end

	self:DrawText(str, font, x + w/2, y + h/2, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self:DrawRect(x, y, w, h, tdui.COLOR_BLACK_TRANSPARENT, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self:_ExpandRenderBounds(x, y, w, h)

	if not self:ShouldAcceptInput() then
		return false, false, false
	end
	return just_pressed, pressing, hovering
end
function tdui_meta:Button(str, font, x, y, w, h, clr)
	self:_QueueRender(function()
		self:DrawButton(str, font, x, y, w, h, clr)
	end)

	local just_pressed, pressing, hovering

	if self:ShouldAcceptInput() then
		local inputstate = self:_CheckInputInRect(x, y, w, h)

		just_pressed = band(inputstate, tdui.FSTATE_JUSTPRESSED) ~= 0
		pressing = band(inputstate, tdui.FSTATE_PRESSING) ~= 0
		hovering = band(inputstate, tdui.FSTATE_HOVERING) ~= 0
	else
		just_pressed, pressing, hovering = false, false, false
	end

	return just_pressed, pressing, hovering
end


function tdui_meta:DrawCursor()
	local rb = self._renderBounds

	local inputstate = self:_CheckInputInRect(rb.x, rb.y, rb.x2-rb.x, rb.y2-rb.y)

	-- If cursor is not within render bounds at all (is not hovering it)
	-- we should not draw a cursor
	if band(inputstate, tdui.FSTATE_HOVERING) == 0 then
		return
	end
	
	if band(inputstate, tdui.FSTATE_JUSTPRESSED) ~= 0 then
		surface.SetDrawColor(tdui.COLOR_RED)
	elseif band(inputstate, tdui.FSTATE_PRESSING) ~= 0 then
		surface.SetDrawColor(tdui.COLOR_ORANGE)
	else
		surface.SetDrawColor(tdui.COLOR_WHITE)
	end

	surface.DrawLine(self._mx-2, self._my, self._mx+2, self._my)
	surface.DrawLine(self._mx, self._my-2, self._mx, self._my+2)
end
function tdui_meta:Cursor()
	self:_QueueRender(function()
		self:DrawCursor()
	end)
end

function tdui_meta:Custom(fn)
	self:_QueueRender(fn)
end

function tdui_meta:_QueueRender(fn)
	if self._rendering then
		local r, e = pcall(fn, self)
		if not r then print("TDUI rendering error: ", e) end
		return
	end

	self.renderQueue = self.renderQueue or {}

	self.renderQueue[#self.renderQueue+1] = fn
end

--- Should be called every time something is drawn with an approximate bounding
-- box of the drawn area. Used for eg. determining where we should show the cursor
function tdui_meta:_ExpandRenderBounds(x, y, w, h)
	self._renderBounds.x = math.min(self._renderBounds.x, x)
	self._renderBounds.y = math.min(self._renderBounds.y, y)

	self._renderBounds.x2 = math.max(self._renderBounds.x2, x+w)
	self._renderBounds.y2 = math.max(self._renderBounds.y2, y+h)
end

function tdui_meta:_WorldToLocal(rayOrigin, rayDirection)
	local pos = self._pos
	local angles = self._angles
	local scale = self._scale

	local planePos = pos
	local planeNormal = angles:Up()

	local scale = self._scale

	local hitPos = util.IntersectRayWithPlane(rayOrigin, rayDirection, planePos, planeNormal)
	if hitPos then
		local diff = hitPos - planePos

		-- Magic
		diff:Rotate(Angle(0, -angles.y, 0))
		diff:Rotate(Angle(-angles.p, 0, 0))
		diff:Rotate(Angle(0, 0, -angles.r))

		local xchange = diff.x
		local ychange = diff.y

		xchange = xchange * (1/scale)
		ychange = ychange * (1/scale)

		local finalx, finaly = xchange, -ychange
		return finalx, finaly, hitPos
	end
end

function tdui_meta:_CheckInputInRect(x, y, w, h, input)
	-- Update input. If it's already been updated this frame, this'll NOP
	self:_UpdateInputStatus()

	input = input or tdui.FINPUT_PRESSED

	local state = 0

	if not self._mx or not self._my or self._mObscured then
		return state
	end

	if self._mx >= x and self._my >= y and self._mx <= (x+w) and self._my <= (y+h) then
		state = bor(state, tdui.FSTATE_HOVERING)

		if band(self._justPressed, input) ~= 0 then
			state = bor(state, tdui.FSTATE_JUSTPRESSED)
		end
		if band(self._inputDown, input) ~= 0 then
			state = bor(state, tdui.FSTATE_PRESSING)
		end
	end

	return state
end

local traceEntFilter = function(ent)
	if ent:GetClass() == "prop_physics" then
		return true
	end
end
function tdui_meta:_ComputeScreenMouse()
	local eyepos = LocalPlayer():EyePos()
	local eyenormal = gui.ScreenToVector(ScrW()/2, ScrH()/2)

	-- Calculate mouse position in local space
	local mx, my, hitPos = self:_WorldToLocal(eyepos, eyenormal)
	self._mx = mx
	self._my = my

	-- Input aspect ratio for rendering to texture
	if self._inputAspectRatio and self._my then
		self._my = self._my * self._inputAspectRatio
	end

	-- Dot product between eye direction and panel backward facing normal vector
	local backnormal = self:GetBackNormal()
	local plyLookingAtPanel = backnormal and (backnormal:Dot(eyenormal) > 0)

	-- If player is not even looking at the panel, it is obscured for sure
	-- This makes sure you cannot press buttons from the "back" side of the panel
	if not plyLookingAtPanel then
		self._mObscured = true

	-- Check for obstructions in the world (eg props or the worldspawn)
	elseif hitPos then

		-- If we're ignoring Z, it doesn't matter if we hit something
		if self._IgnoreZ then
			self._mObscured = false
			return
		end

		local tr = util.TraceLine({
			start = eyepos,
			endpos = hitPos,

			filter = traceEntFilter
		})

		self._mObscured = tr.Hit
	end
end

function tdui_meta:_ComputeInput()
	-- Update input down statuses
	local oldInput = self._inputDown
	local nowInput = 0
	local justPressed = 0

	local function CheckInput(code, isDown)
		if not isDown then return end

		nowInput = bor(nowInput, code)

		if oldInput and band(oldInput, code) == 0 then
			justPressed = bor(justPressed, code)
		end
	end
	local function CheckMouse(gm_code, code)
		CheckInput(code, input.IsMouseDown(gm_code) and not vgui.CursorVisible())
	end
	local function CheckInKey(gm_code, code)
		CheckInput(code, LocalPlayer():KeyDown(gm_code))
	end

	CheckMouse(MOUSE_LEFT, tdui.FMOUSE_LEFT)
	CheckMouse(MOUSE_RIGHT, tdui.FMOUSE_RIGHT)

	CheckInKey(IN_USE, tdui.FKEY_USE)

	self._inputDown = nowInput
	self._justPressed = justPressed
end

function tdui_meta:_UpdateInputStatus(forceUpdate, inputAspectRatio)
	-- Don't update input down statuses more than once during a frame
	local curFrame = FrameNumber()
	if self._lastInputFrame == curFrame and not forceUpdate then
		return
	end
	self._lastInputFrame = curFrame
	self._inputAspectRatio = inputAspectRatio

	self:_ComputeScreenMouse()
	self:_ComputeInput()
end

-- The default values for rendering params
tdui_meta._pos = Vector(0, 0, 0)
tdui_meta._angles = Angle(0, 0, 0)
tdui_meta._scale = 1

function tdui_meta:_UpdatePAS(pos, angles, scale)

	-- If updating the angle of the render context, we apply a transformation,
	-- which makes it so that if angles was EyeAngles(), it would face us directly.
	-- TODO: this might screw some people up?
	if angles then
		angles:RotateAroundAxis(angles:Right(), 90)
		angles:RotateAroundAxis(angles:Up(), -90)
	end

	self._pos    = pos    or self._pos
	self._angles = angles or self._angles
	self._scale  = scale  or self._scale
end

--- Returns a normal vector facing away from the TDUI panel towards the front of the panel
-- Due to angle rotations in _UpdatePAS this is not the obvious self._angles:Forward()
function tdui_meta:GetFrontNormal()
	if not self._angles then return end
	return self._angles:Up()
end

--- Returns a normal vector facing away from the TDUI panel towards the back of the panel
-- Example usecase: figuring out if the player is looking at the panel or not
function tdui_meta:GetBackNormal()
	local frontnormal = self:GetFrontNormal()
	if frontnormal then return -frontnormal end
end

function tdui_meta:SetIgnoreZ(b)
	self._IgnoreZ = b
end

function tdui_meta:PreRenderReset()
	self:_UpdatePAS(pos, angles, scale)

	-- Reset parameters
	self.renderQueue = self.renderQueue or {}
	self:_UpdateInputStatus()

	-- Reset render bounds
	self._renderBounds = self._renderBounds or {}
	self._renderBounds.x = 0
	self._renderBounds.y = 0
	self._renderBounds.x2 = 0
	self._renderBounds.y2 = 0

	-- Reset colors, materials
	surface.SetDrawColor(tdui.COLOR_WHITE)
	render.SetColorMaterial()
end

function tdui_meta:BeginRender()
	if self._rendering then error("Calling BeginRender() with an ongoing render") end
	
	self:PreRenderReset()

	-- Set IgnoreZ
	if self._IgnoreZ then
		cam.IgnoreZ(true)
		self._IgnoreZActive = true
	else
		self._IgnoreZActive = false
	end

	-- Start render context
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)

	cam.Start3D2D(self._pos, self._angles, self._scale)
	
	self._rendering = true
end

function tdui_meta:PostRenderReset()
	-- Reset parameters
	table.Empty(self.renderQueue)

	-- Count how many renders have been done this frame
	local curFrame = FrameNumber()
	if self._lastRenderFrame == curFrame then
		self._frameRenderCount = (self._frameRenderCount or 0) + 1
	else
		self._frameRenderCount = 1
	end
end

function tdui_meta:EndRender()
	if not self._rendering then error("Calling EndRender() without matching BeginRender()") end

	self._rendering = false
	
	-- End render context
	cam.End3D2D()

	render.PopFilterMin()
	render.PopFilterMag()

	if self._IgnoreZActive then
		cam.IgnoreZ(false)
	end

	self:PostRenderReset()

	self._lastRenderFrame = FrameNumber()
end

function tdui_meta:RenderQueued()
	for i=1, #self.renderQueue do
		local r, e = pcall(self.renderQueue[i], self)
		if not r then print("TDUI rendering error: ", e) end
	end
end

function tdui_meta:Render(pos, angles, scale)
	self:_UpdatePAS(pos, angles, scale)

	self:BeginRender()
		self:RenderQueued()
	self:EndRender()
end

-- EXPERIMENTAL rendering to texture
-- See examples/rendertomat.lua
function tdui_meta:RenderToTexture(rtw, rth)
	local id = "TDUIMat_" .. (string.match(tostring(self), "table: 0x(.*)"))

	local w, h = rtw or 512, rth or 512
	local rt = GetRenderTarget(id, w, h)

	render.PushRenderTarget(rt)
	render.Clear(0, 0, 0, 255)

		cam.Start2D()
			self:PreRenderReset()
			self:RenderQueued()
			self:PostRenderReset()
		cam.End2D()

	render.PopRenderTarget()

	return rt
end

-- Is this the first render during this frame
function tdui_meta:IsFirstRenderThisFrame()
	return not self._frameRenderCount or self._frameRenderCount == 1
end

-- Are we rendering to the "main" render target aka the screen
function tdui_meta:IsWorldRenderpass()
	return not IsValid(render.GetRenderTarget())
end

-- Note: does not affect return values from CheckInputInRect
function tdui_meta:ShouldAcceptInput()
	return self:IsFirstRenderThisFrame()
end

-- Create singleton instance of TDUI
-- It can be used for simplicity

local singleton = tdui.Create()

function tdui.Begin(pos, ang, scale)
	if not pos then error("pos expected", 2) end
	if not ang then error("ang expected", 2) end
	scale = scale or 1

	singleton:_UpdatePAS(pos, ang, scale)

	singleton:BeginRender()
end

-- Not real currying, I know
local function curry(f, x)
	return function(...)
		return f(x, ...)
	end
end

-- Drawing
tdui.Rect    = curry(singleton.DrawRect, singleton)
tdui.Line    = curry(singleton.DrawLine, singleton)
tdui.Mat     = curry(singleton.DrawMat, singleton)
tdui.Polygon = curry(singleton.DrawPolygon, singleton)
tdui.Text    = curry(singleton.DrawText, singleton)
tdui.Button  = curry(singleton.DrawButton, singleton)
tdui.Cursor  = curry(singleton.DrawCursor, singleton)
tdui.Custom  = curry(singleton.Custom, singleton)

-- Configuration
tdui.SetIgnoreZ  = curry(singleton.SetIgnoreZ, singleton)

function tdui.End()
	singleton:EndRender()
end