--Map config--
--set nil to use default value--
if SERVER then
	--Server side config--
	--MiniMap minitrains offset--
	MiniMap.MiniTrainsOffset = 1
	MiniMap.Model = nil
	MiniMap.Updated = false -- New signals, updated trains?
	MiniMap.StationNames = {}
	MiniMap.SemiAutoSignals = {}
	MiniMap.BlockSwitches = true
else
	--Client side config--
	--MiniMap custom render bounds--
	MiniMap.RenderBoundsAdd = Vector( 150, 150, 100 )
	--MiniMap Panel render position offset--
	MiniMap.PanelRenderOffset = Vector( 200, 80, 100 )
end
