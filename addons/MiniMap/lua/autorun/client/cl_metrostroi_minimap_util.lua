-----------------------------
--Check config for map-------
-----------------------------

if(file.Exists( string.format("minimap/configs/maps/%s.lua",game.GetMap()), "LUA" )) then
	MsgC(Color(20, 255, 20), "[MiniMap]: Config found.\n")
else
	MsgC(Color(255, 20, 20), "[MiniMap]: Config not found. MiniMap disabled.\n")
	return
end

CreateClientConVar( "metrostroi_minimap_drawsigns", 1, true, false )
CreateClientConVar( "metrostroi_minimap_displaysignalmodels", 1, true, false )

if !MiniMap then 
	MiniMap = {}
	MiniMap.ActiveDispatcher = "Нету"
end

-------------------
--Load map config--
-------------------

include(string.format("minimap/configs/maps/%s.lua",game.GetMap()))

-----------------------------
--Load modules --------------
-----------------------------
MsgC(Color(20, 255, 20), "[MiniMap]: Loading... Starting client modules.\n")

--include("minimap/modules/minimap_orangedisp/cl_init.lua") --For client side render

-------------------
--Receive data-----
-------------------

net.Receive("gmod_minimap_activedispatcher", function( len, ply )

	MiniMap.ActiveDispatcher = nil
	MiniMap.ActiveDispatcher = net.ReadString()
	 
 end) 

----------------------
--Build MiniMap menu--
----------------------

function MiniMap.ToolPanel(Panel)
	Panel:ClearControls()
	Panel:SetName("MiniMap - Настройки")
	Panel:CheckBox(	"Показывать названия станций (Toggle Signs)", "metrostroi_minimap_drawsigns")
	Panel:CheckBox(	"Отображать модели сигналов (Toggle Display Signal Models)", "metrostroi_minimap_displaysignalmodels")
end

function MiniMap.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Metrostroi", "metrostroi_minimap_panel", "Minimap", "", "", MiniMap.ToolPanel)
end

-------------
--Hooks------
-------------

hook.Add("HUDPaint", "Minimap Hud Paint", function()
	local font = "ChatFont"
	local text = "Диспетчер: " .. MiniMap.ActiveDispatcher
	local text2 = "Клиент: ..."
	surface.SetFont(font)
	local Width, Height = surface.GetTextSize(text)
	local w2,h2 = surface.GetTextSize(text2)
	local boxHeight = Height + h2 + 16
	local boxWidth = math.Max(Width,w2) + 25
	draw.RoundedBox(4, ScrW() - (boxWidth + 4), (ScrH()/2 - 100) - 16, boxWidth, boxHeight, Color(0, 0, 0, 150))
	draw.SimpleText(text, font, ScrW() - (Width / 2) - 20, ScrH()/2 - 100, Color(255, 255, 255, 255), 1, 1)
	draw.SimpleText(text2, font, ScrW() - (w2 / 2) - 20, ScrH()/2 - 100 + Height, Color(255, 255, 255, 255), 1, 1)
end)

hook.Add("PopulateToolMenu", "Minimap Tool Menu", MiniMap.PopulateToolMenu)