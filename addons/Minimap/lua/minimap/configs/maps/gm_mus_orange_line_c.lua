--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 0
	MiniMap.Model = "gm_mus_orange_line_long_f"
	MiniMap.Updated = false -- New signals, updated trains?
	MiniMap.StationNames = {
	[110] = "Garry's Mod Workers",
	[111] = "VHE",
	[112] = "Wallace Breen",
	[113] = "GCFScape",
	[114] = "Workshop",
	[115] = "Park",
	[116] = "Lithium",
	[117] = "Glorious Country",
	[200] = "Lithium",
	[201] = "SENT Factory Station",
	[202] = "Airport"}
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 150, 80, 100 )
end
