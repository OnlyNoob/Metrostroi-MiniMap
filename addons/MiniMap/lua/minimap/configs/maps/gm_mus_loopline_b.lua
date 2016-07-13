--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 1
	MiniMap.Model = nil
	MiniMap.Updated = true -- New signals, updated trains?
	MiniMap.StationNames = {
	[651] = "First april",
	[652] = "Park",
	[653] = "Metrobuilder station",
	[654] = "Marine",
	[655] = "The glorious country",
	[656] = "Pioneer station"}
	MiniMap.SemiAutoSignals = {}
	MiniMap.BlockSwitches = true
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 150, 80, 100 )
end
