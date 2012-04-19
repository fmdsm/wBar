local _,ns = ...

local cfg = {
    position = {'CENTER', UIParent, 0, -70},
	statusbar = "Interface\\Addons\\wBar\\media\\minimalist",
    sizeWidth = 200,
    activeAlpha = 1,
    inactiveAlpha = 0.3,
    emptyAlpha = 0,
        
    valueFont = "Fonts\\ARIALN.ttf",
    valueFontSize = 18,
    valueFontAdjustmentX = 9,

	showRune = true,
	showComboPoints = true,
	comboSize = 20,
	comboColor = {
		[1] = {r = 1.0, g = 1.0, b = 0.0},
		[2] = {r = 1.0, g = 1.0, b = 0.0},
		[3] = {r = 1.0, g = 1.0, b = 0.0},
		[4] = {r = 1.0, g = 0.5, b = 0.0},
		[5] = {r = 1.0, g = 0.0, b = 0.0},
	},
	showRuneCooldown = true,
	runeFont = "Fonts\\ARIALN.ttf",
	runeFontSize = 20,
	runeColor = {
		[1] = {r = 0.7,g = 0.1,b = 0.1},--Ñª
		[2] = {r = 0.4,g = 0.8,b = 0.2},--Ð°
		[3] = {r = 0.0,g = 0.6,b = 0.8},--±ù
		[4] = {r = 1.0,g = 0.0,b = 1.0},--ËÀ
		[5] = {r = 0.0,g = 0.0,b = 0.0},
		[6] = {r = 0.0,g = 0.0,b = 0.0},
		[7] = {r = 0.0,g = 0.0,b = 0.0},
		[8] = {r = 0.0,g = 0.0,b = 0.0},
	},
	thresholdColor = {
		["MAGE"] = {[1] = {0.8,0.35}},
		["PALADIN"] = {[1] = {0.8,0.3}},
		["SHAMAN"] = {[3] = {0.8,0.3}},
		["PRIEST"] = {[0] = {0.8,0.35}},
		["DRUID"] = {[3] = {0.8,0.35}},
		["WARLOCK"] = {[0] = {0.5,0.2}},
		--[""]
	},
}
ns.cfg = cfg