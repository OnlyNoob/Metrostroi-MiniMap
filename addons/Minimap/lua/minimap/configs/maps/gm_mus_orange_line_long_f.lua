--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 0
	MiniMap.Model = nil
	MiniMap.Updated = true -- New signals, updated trains?
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
	MiniMap.SemiAutoSignals = {"D3","D4","D5","D2 1","D2 3","D2 5","D2 7","D2 2","D2 4","D2 6","D2 8"}
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 150, 80, 100 )
end
