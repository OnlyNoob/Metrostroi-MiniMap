--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 0
	MiniMap.Model = nil
	MiniMap.Updated = true -- New signals, updated trains?
	MiniMap.StationNames = {
	[408] = "Garry's Mod Workers",
	[407] = "VHE",
	[406] = "Wallace Breen",
	[405] = "GCFScape",
	[404] = "Park",
	[403] = "Lithium",
	[402] = "Glorious Country",
	[401] = "Airport",
	[504] = "Metro Builders",
	[503] = "Lithium",
	[502] = "Pionerskaya",
	[501] = "Airport",
	[601] = "Brateevo"}
	MiniMap.SemiAutoSignals = {"E2","D2","D4","D6","D21","D","D1","D3","D5","P1","AE1","AE11","AE9","AE7","AE2","AE12","AE10","AE8"}
	MiniMap.BlockSwitches = true
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 150, 80, 100 )
end
