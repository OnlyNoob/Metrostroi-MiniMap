ENT.Type			= "anim"
ENT.PrintName		= "MiniMap Signal New"
ENT.Category		= "Metrostroi (utility)"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.TrafficLightModels = {}
ENT.RenderOffset = {}
ENT.BasePosition = Vector(-1.10,0.32,0)

Metrostroi.Signal_2 = 1
Metrostroi.Signal_3 = 2
Metrostroi.Signal_IS = 3
Metrostroi.Signal_RP = 4


-- Lamp indexes
-- 0 Red
-- 1 Yellow
-- 2 Green
-- 3 Blue
-- 4 Second yellow (flashing yellow)
-- 5 White

Metrostroi.Lenses = {
	["R"] = Color(255,0,0),
	["Y"] = Color(255,127,0),
	["G"] = Color(0,255,0),
	["W"] = Color(255,255,255),
	["B"] = Color(0,0,255),
}

--------------------------------------------------------------------------------
-- Inside
--------------------------------------------------------------------------------
ENT.RenderOffset[0] = Vector(0,0,2.24+0.64)
ENT.TrafficLightModels[0] = {
	["m1"]	= "models/metrostroi/signals/box.mdl",
	["m2"]	= "models/metrostroi/signals/pole_2.mdl",
--	["name"]	= Vector(-2,2.5,-25),
	[1]	= { 0.64, "models/metrostroi/signals/light_2.mdl", {
				[0] = Vector(0.16,0.10,0.50),
				[1] = Vector(0.16,0.10,0.28), 
				}},
	[2]	= { 0.80, "models/metrostroi/signals/light_3.mdl", {
				[0] = Vector(0.16,0.10,0.70),
				[1] = Vector(0.16,0.10,0.50),
				[2] = Vector(0.16,0.10,0.28), 
				}},

--	[4] = { 0.18, "models/metrostroi/signals/light_path.mdl",  Vector(13.1,2, 19.5), 1.75, 2.05, 4},
}


--------------------------------------------------------------------------------
-- Outside
--------------------------------------------------------------------------------
ENT.RenderOffset[1] = Vector(0,0,5.28)
ENT.TrafficLightModels[1] = {
	["m1"]	= "models/metrostroi/signals/pole_1.mdl",
--	["name"]	= Vector(0,2,-15),
	[1]	= { 1.00, "models/metrostroi/signals/light_outside_2.mdl", {
				[0] = Vector(0,0.30,0.40),
				[1] = Vector(0,0.30, 0.18),
				}},
	[2]	= { 1.20, "models/metrostroi/signals/light_outside_3.mdl", {
				[0] = Vector(0,0.30,0.62), 
				[1] = Vector(0,0.30,0.40), 			
				[2] = Vector(0,0.30, 0.18),
				} },

	[3] = { 0.50, "models/metrostroi/signals/light_outside_1.mdl" , {
				[0] = Vector(0,0.30, 0.18)
				}},
--	[4] = { 40, "models/metrostroi/signals/light_outside_path.mdl",  Vector(7,11, 25), 3.6, 3.4, 5},
}


--------------------------------------------------------------------------------
-- Outside box
--------------------------------------------------------------------------------
ENT.RenderOffset[2] = Vector(0,0,2.24+0.60)
ENT.TrafficLightModels[2] = {
	["m1"]	= "models/metrostroi/signals/box_outside.mdl",
	["m2"]	= "models/metrostroi/signals/pole_3.mdl",
--	["name"]	= Vector(-4,2.5,-20),
	[1]	= { 0.64, "models/metrostroi/signals/light_outside2_2.mdl", {
				[0] = Vector(0.20,0.10,0.56),
				[1] = Vector(0.20,0.10,0.32),
				}},
	[2]	= { 0.90, "models/metrostroi/signals/light_outside2_3.mdl", {
				[0] = Vector(0.20,0.10,0.76),
				[1] = Vector(0.20,0.10,0.56), 		
				[2] = Vector(0.20,0.10,0.32),
				}},

--	[4] = { 20, "models/metrostroi/signals/light_outside2_path.mdl",  Vector(13.8,2, 22.8), 1.8, 2.1, 4},
}