--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 0
	MiniMap.Model = nil
	MiniMap.Updated = true -- New signals, updated trains?
	MiniMap.StationNames = {
	[501] = "Airport",
	[502] = "Pionerskaya",
	[503] = "Lithium",
	[504] = "Metrostroiteley",
	[505] = "Masterskaya",
	[506] = "Kahovskaya"}
	MiniMap.SemiAutoSignals = {"D11","D5","D22","D10","D3","D13","D15","D17","D1","D2","D26","D4","D6","D8"}
	MiniMap.BlockSwitches = true
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 150, 80, 100 )
end
