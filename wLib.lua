local _,ns = ...
local function MakeShadow(parent)
	local Shadow = CreateFrame("Frame", nil, parent)
	Shadow:SetFrameStrata("BACKGROUND")
	Shadow:SetPoint("TOPLEFT", -4, 4)
	Shadow:SetPoint("BOTTOMRIGHT", 4, -4)
	Shadow:SetBackdrop({
	BgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\AddOns\\wBar\\media\\glowTex", edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	Shadow:SetBackdropColor(1, 1, 1, 1)--阴影颜色
	Shadow:SetBackdropBorderColor(0, 0, 0,1)--阴影边框
	return Shadow
end
ns.MakeShadow = MakeShadow