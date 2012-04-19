local _,ns = ...
local cfg = ns.cfg
local _,myclass = UnitClass("player")
local UnitPower,UnitPowerMax,UnitPowerType = UnitPower,UnitPowerMax,UnitPowerType
local tColor = nil

local bar = CreateFrame("StatusBar", "wBar_Bar", UIParent)--8~9k
bar:SetScale(1)
bar:SetPoint(unpack(cfg.position))
bar:SetSize(cfg.sizeWidth, 3)
bar:SetStatusBarTexture(cfg.statusbar)

bar.Value = bar:CreateFontString(nil, "ARTWORK")
bar.Value:SetFont(cfg.valueFont, cfg.valueFontSize,"THINOUTLINE")
bar.Value:SetPoint("CENTER", bar, 0, cfg.valueFontAdjustmentX)
bar.Value:SetVertexColor(1, 1, 1)

bar.Shadow = ns.MakeShadow(bar)

local function UpdateBarValue(self)
	local curValue = UnitPower("player")
	local percent = curValue/UnitPowerMax("player")
	self:SetValue(curValue)
	if curValue > 10000 then
		self.Value:SetFormattedText("%.1f萬 %d%%",curValue/10000,percent*100)
	else
		self.Value:SetFormattedText("%d",curValue)
	end
	if tColor and UnitPowerType("player") == 0 then
		if percent > tColor[1] then
			self:SetStatusBarColor(0,0,1)
			self.Shadow:SetBackdropBorderColor(0,0,0)
		elseif percent > tColor[2] then
			self:SetStatusBarColor(1,0,1)
			self.Shadow:SetBackdropBorderColor(1,0,1)
		else
			self:SetStatusBarColor(1,0,0)
			self.Shadow:SetBackdropBorderColor(1,0,0)
		end
	end
end
local function UpdateBarMaxValue(self)
	self:SetMinMaxValues(0, UnitPowerMax("player"))
end
local function UpdateBarColor(self)
    local _, powerType, altR, altG, altB = UnitPowerType("player")
    local unitPower = PowerBarColor[powerType]
    
	if (unitPower) then
        self:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
    else
        self:SetStatusBarColor(altR, altG, altB)
    end
end
local barflushtime = 0
local function FlushBar(self,elapsed)
	barflushtime = barflushtime + elapsed
	if barflushtime > 0.2 then
		UpdateBarValue(self)
	end
end
bar:SetScript("OnEvent",function(self,event,arg1)
	if event == "UNIT_POWER" then
		if arg1 ~= "player" then return end
		UpdateBarValue(self)
	elseif event == "UNIT_MAXPOWER" then
		if arg1 ~= "player" then return end
		UpdateBarMaxValue(self)
	elseif event == "PLAYER_REGEN_ENABLED" then--脱离战斗
		self:SetAlpha(cfg.inactiveAlpha)
		self:SetScript("OnUpdate",nil)
	elseif event == "PLAYER_REGEN_DISABLED" then--进入战斗
		self:SetAlpha(cfg.activeAlpha)
		self:SetScript("OnUpdate",FlushBar)
	elseif event == "UNIT_DISPLAYPOWER" then
		if arg1 ~= "player" then return end
		UpdateBarColor(self)
		UpdateBarMaxValue(self)
		UpdateBarValue(self)
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		local tree = GetPrimaryTalentTree()
		tColor = cfg.thresholdColor[myclass] and (cfg.thresholdColor[myclass][tree] or cfg.thresholdColor[myclass][0]) or nil
	elseif event == "PLAYER_LOGIN" then
		local tree = GetPrimaryTalentTree()
		tColor = cfg.thresholdColor[myclass] and (cfg.thresholdColor[myclass][tree] or cfg.thresholdColor[myclass][0]) or nil
		UpdateBarMaxValue(self)
		UpdateBarColor(self)
		self:SetAlpha(cfg.inactiveAlpha)
		UpdateBarValue(self)
	end
end)
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_REGEN_ENABLED")--進入戰鬥
bar:RegisterEvent("PLAYER_REGEN_DISABLED")--脫離戰鬥
bar:RegisterEvent("UNIT_MAXPOWER")--最大能量
bar:RegisterEvent("UNIT_POWER")--能量
bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")--天赋改变
if myclass == "DRUID" then
	bar:RegisterEvent("UNIT_DISPLAYPOWER")
end

if cfg.showComboPoints and (myclass == "DRUID" or myclass == "ROGUE") then --连击点2k
	local Points = {}--间距4 和父框体间距8
	local GetComboPoints = GetComboPoints
	for i = 1, MAX_COMBO_POINTS do
		Points[i] = CreateFrame("Frame",nil,bar)
		Points[i]:SetSize(cfg.comboSize, cfg.comboSize/2)
		if i > 1 then Points[i]:SetPoint("LEFT", Points[i - 1], "RIGHT",4,0) end
		local bg = Points[i]:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(Points[i])
		bg:SetTexture(cfg.statusbar)
		bg:SetVertexColor(cfg.comboColor[i].r,cfg.comboColor[i].g,cfg.comboColor[i].b)
		F.MakeShadow(Points[i])
		Points[i]:Hide()
	end
	Points[1]:SetPoint("TOP", bar, "BOTTOM",-cfg.comboSize * 2-8,-8)

	Points[1]:SetScript("OnEvent",function(self,event,...)
		local cp = GetComboPoints("player", "target")
		for i=1, MAX_COMBO_POINTS do
		if i <= cp then
			Points[i]:Show()
		else
			Points[i]:Hide()
		end
	end
	end)
	Points[1]:RegisterEvent("UNIT_COMBO_POINTS") --连击点
	Points[1]:RegisterEvent("PLAYER_TARGET_CHANGED") --改变目标
elseif cfg.showRune and myclass == "DEATHKNIGHT" then --符文 4~5k
	for i = 1, 6 do 
		RuneFrame:UnregisterAllEvents()
		_G["RuneButtonIndividual"..i]:Hide()
	end
	local GetTime = GetTime
	local Rune = {}
	for i = 1, 6 do
		Rune[i] = CreateFrame("StatusBar",nil,bar)
		Rune[i]:SetSize(cfg.runeFontSize, cfg.runeFontSize/2)
		Rune[i]:SetStatusBarTexture(cfg.statusbar)
		Rune[i]:SetStatusBarColor(1,1,1,0)
		Rune[i].Value = Rune[i]:CreateFontString(nil, "ARTWORK")
		Rune[i].Value:SetPoint("CENTER",Rune[i],"CENTER")
		Rune[i].Value:SetFont(cfg.runeFont, cfg.runeFontSize,"THINOUTLINE")
	end
	-----------------
	-- 冰5 邪3 血1 --
	-- 冰6 邪4 血2 --
	-----------------
	Rune[3]:SetPoint("TOP",bar,"BOTTOM", 0, -8)--邪 
	Rune[4]:SetPoint("TOP",Rune[3],"BOTTOM",0, -4)--邪 
	Rune[5]:SetPoint("CENTER",Rune[3],"CENTER", - cfg.runeFontSize-4, 0)--血
	Rune[6]:SetPoint("TOP",Rune[5],"BOTTOM",0, -4)--血
	Rune[1]:SetPoint("CENTER",Rune[3],"CENTER", cfg.runeFontSize+4,0)--冰
	Rune[2]:SetPoint("TOP",Rune[1],"BOTTOM",0, -4)--冰
	

	local allendtime= 0
	local function GetRuneEndTime(index)
		local start, duration, runeReady = GetRuneCooldown(index)
		local endtime =  start + duration
		if endtime > allendtime then
			allendtime = endtime
		end
		return endtime
	end
	local updatetime = 0
	local function FlushRune(self,elapsed)
		updatetime = updatetime + elapsed
		if updatetime > 0.1 then --0.1秒刷新一次
			local timenow = GetTime()
			for i = 1,6 do
				if Rune[i].cooling then --冷却中
					local time = ceil(Rune[i].endtime-timenow)
					if time > 0 then
						Rune[i].Value:SetText(time)
					else
						Rune[i].Value:SetText("#")
						Rune[i].coolding = false
					end
				end
			end
			if timenow > allendtime then
				Rune[1]:SetScript("OnUpdate",nil)
				--print("|cffff0000全部冷却|r")
			end
		end
	end
	local function UpdateRuneColor(self,index)
		local runetype = GetRuneType(index)
		self.Value:SetTextColor(cfg.runeColor[runetype].r,cfg.runeColor[runetype].g,cfg.runeColor[runetype].b)
	end
	local function UpdateRuneTime(self,index,isEnergize)
		if isEnergize then
			self.cooling = false
		else
			self.endtime = GetRuneEndTime(index)
			self.cooling = true
		end
		Rune[1]:SetScript("OnUpdate",FlushRune)
	end
	Rune[1]:SetScript("OnEvent",function(self,event,index,arg1)
		if event == "RUNE_TYPE_UPDATE" then
			UpdateRuneColor(Rune[index],index)
		elseif event == "RUNE_POWER_UPDATE" then
			UpdateRuneTime(Rune[index],index,arg1)
		else
			for i = 1,6 do
				UpdateRuneColor(Rune[i],i)
				UpdateRuneTime(Rune[i],i)
			end
		end
	end)
	Rune[1]:RegisterEvent("RUNE_TYPE_UPDATE")
	Rune[1]:RegisterEvent("RUNE_POWER_UPDATE")
	Rune[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
end

ns.bar = bar
ns.myclass = myclass