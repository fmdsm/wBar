--占用 2~3k
local _,ns = ...
local cfg,myclass = ns.cfg,ns.myclass
local UnitBuff,GetTime,select,pairs,GetSpellInfo,UnitHealthMax = UnitBuff,GetTime,select,pairs,GetSpellInfo,UnitHealthMax
local spellabsorb = {}
spellabsorb[GetSpellInfo(17)] = true--牧师盾
spellabsorb[GetSpellInfo(47515)] = true--牧师泡泡盾 
spellabsorb[GetSpellInfo(86273)] = true--奶骑精通盾

if myclass == "DRUID" then
	spellabsorb[GetSpellInfo(62606)] = true --熊罩
elseif myclass == "DEATHKNIGHT" then
	spellabsorb[GetSpellInfo(77535)] = true --死打盾
elseif myclass == "MAGE" then
	spellabsorb[GetSpellInfo(543)] = true --法師結界
	spellabsorb[GetSpellInfo(1463)] = true --法力護盾
	spellabsorb[GetSpellInfo(11426)] = true --寒冰護體
elseif myclass == "WARLOCK" then
	spellabsorb[GetSpellInfo(91711)] = true --虛空結界
	spellabsorb[GetSpellInfo(6229)] = true --防護暗影結界
elseif myclass == "PALADIN" then
	spellabsorb[GetSpellInfo(96263)] = true --崇聖護盾
end

local Absorb = CreateFrame("Frame",nil,ns.bar)
Absorb:SetSize(cfg.valueFontSize,cfg.valueFontSize)
Absorb:SetPoint("BOTTOMRIGHT",ns.bar,"TOPRIGHT",0,3)

Absorb.Cooldown = CreateFrame("Cooldown",nil,Absorb)
Absorb.Cooldown:SetAllPoints(Absorb)
Absorb.Cooldown:SetFrameLevel(Absorb:GetFrameLevel()+1)

Absorb.Value = Absorb:CreateFontString(nil,"ARTWORK")
Absorb.Value:SetFont(cfg.valueFont, cfg.valueFontSize*0.8,"THINOUTLINE")
Absorb.Value:SetPoint("BOTTOMRIGHT",Absorb,"BOTTOMLEFT")
Absorb.Value:SetJustifyH("RIGHT")
--Absorb.Icon = Absorb:CreateTexture(nil,"ARTWORK")
--Absorb.Icon:SetAllPoints(Absorb)

Absorb:SetScript("OnEvent",function(self,event,arg1,...)
	if arg1 ~= "player" then return end
	local maxvalue,maxduration,timeStart = 0,0,0
	local curicon
	for spell in pairs(spellabsorb) do
		if UnitBuff("player",spell) then
			local _,_,icon,_,_,duration,expires,_,_,_,_,_,_,value = UnitBuff("player",spell)
			if value > maxvalue then
				timeStart = expires -duration
				maxduration = duration
				maxvalue = value
				curicon = icon
			end
		end
	end
	if maxvalue > 0 then
		Absorb.Value:SetFormattedText("%.1f%%",maxvalue/UnitHealthMax("player")*100 )
		Absorb:SetBackdrop({bgFile = curicon})
		--Absorb:SetCooldown(timeStart,maxduration)
		Absorb.Cooldown:SetCooldown(timeStart,maxduration)
		Absorb:Show()
	else
		Absorb:Hide()
	end
	
end)

Absorb:RegisterEvent("UNIT_AURA")

