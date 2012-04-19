--[[ local function updatedamage()
	total = 0
	local GetTime, lag = GetTime(), select(3, GetNetStats())
	lag = lag/1000
	for k, v in pairs(recentdamage) do
		if (GetTime - tonumber(k) + lag) <= 5 then
			total = total + v
		end
	end
	total = 1.45*.2*total/UnitHealthMax("Player") < .07 and "|cff11FF117" or "|cff11FF11"..ceil(1.45*.2*total/UnitHealthMax("Player")*1000)/10
end

DS.predict:SetText(total.."%|r") ]]

--[[ 怪攻击我,服务器产生数据time_1
我接收到服务器数据time_2 相差delta_1
插件告诉我还有time_3秒后过期
我使用了死打time_4
服务器判定我的数据时限time_5 ]]

--[[
只分配5个数据空间用来保存对应的数据,发现过期数据覆盖,非过期数据合并
]]
local _,ns = ...
--if ns.myclass ~= "DEATHKNIGHT" then return end
local debug = false
local function p(...)
	if debug == true then
		print(...)
	end
end
local myname = UnitName("player")
local cfg = ns.cfg

local UnitHealthMax,strfind,GetTime,tinsert,tremove,GetNetStats = UnitHealthMax,strfind,GetTime,tinsert,tremove,GetNetStats

local SPIRIT_LINK_SPELL = GetSpellInfo(98017)
local SPIRIT_LINK_TOTEM = GetSpellInfo(98007)

local BloodShield = CreateFrame("Frame",nil,ns.bar)
BloodShield:SetSize(cfg.valueFontSize,cfg.valueFontSize)
BloodShield:SetPoint("BOTTOMLEFT",ns.bar,"TOPLEFT",0,3)

BloodShield.Value = BloodShield:CreateFontString(nil,"ARTWORK")
BloodShield.Value:SetFont(cfg.valueFont, cfg.valueFontSize*0.8,"THINOUTLINE")
BloodShield.Value:SetPoint("BOTTOMLEFT",BloodShield,"BOTTOMLEFT")

BloodShield.flushtime = 0
local damageTaken = {}
local point
--[[ local List = {first = 1,last = 0,true,true,true,true,true,true}
local DamageTaken = {}
local DamageTime
--local flushtime = 0
local function predict(self,elapsed)
	self.flushtime = self.flushtime + elapsed
	if self.flushtime > 0.2 then
		local timestamp = GetTime()
		local taken = 0
		for i = List.first,List.last do
			if List[i][1] < timestamp - 5 then --发现过期
				if List.first == List.last then
					BloodShield:SetScript("OnUpdate",nil)
				end
				List[List.first] = nil
				List.first = List.first + 1
			else
				taken = taken + List[i][2]
			end
		end
		taken = 1.45*.2*taken/UnitHealthMax("Player") < .07 and UnitHealthMax("Player")*.07 or 1.45*.2*taken
		BloodShield.Value:SetFormattedText("|cffff0000%d|r",taken)
		self.flushtime = 0
	end
end
local function pushList(value)
--总共建立5个格子,每次遇到伤害就把数据hash之后放到对应的格子中
--
	if not DamageTime then --重新启动
		id = 1
		wipe(DamageTaken)
	else
		id = ceil(value[1]-DamageTime)%5+1
	end
	if value[1] - DamageTaken[id][1] > 5 then --时间过期
		DamageTaken[id] = value --丢弃旧数据
	else 
		DamageTaken[id][2] = DamageTaken[id][2] + value[2] --整合旧数据
	end	
	if not BloodShield:GetScript("OnUpdate") then
		DamageTime = value[1]
		BloodShield:SetScript("OnUpdate",predict)
	end	
end]]
--predict函数,用于遍历表计算,返回输出
local function predict()
	local damageAmount = 0
	for i in ipairs (damageTaken) do
		damageAmount = damageAmount + damageTaken[i]
	end
	if damageAmount==0 then
		BloodShield:SetScript("OnUpdate",nil) 
		p("没有伤害,停止更新")
	end --没有数据 停止更新函数
	return damageAmount
	--1.45*.2*damageAmount/UnitHealthMax("Player") < .07 and UnitHealthMax("Player")*.07 or 1.45*.2*damageAmount
end
--update函数,用于移动指针,在有伤害承受之后启动,数据过期重置
local INTERVAL = 0.5 --默认刷新间隔

local function update(self,elapsed)
	self.flushtime = self.flushtime + elapsed
	if self.flushtime >= INTERVAL then --默认0.5秒刷新移动一次位置
		point = (point >= 5/INTERVAL) and 1 or (point + 1) --默认10格
		damageTaken[point] = 0 --初始化
		self.flushtime = 0 --重置时间
		BloodShield.Value:SetFormattedText("|cffff0000%d|r",predict())
		p("定期刷新,指针位置:"..point)
	end
end
--数据处理函数,用于新数据管理
local function damageIncome(timestamp,damage)
	if not BloodShield:GetScript("OnUpdate") then --启动更新函数
		BloodShield.flushtime = INTERVAL
		point = 1
		damageTaken[1] = 0 
		BloodShield:SetScript("OnUpdate",update)
	end
	damageTaken[point] = damageTaken[point] + damage
	p("位置:"..point.." 伤害:"..damage)
end
BloodShield:SetScript("OnUpdate",nil)
BloodShield:SetScript("OnEvent", function(self, event,...)
	--if event == "COMBAT_LOG_EVENT_UNFILTERED" then
	local timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, destGUID, destName, destFlags, destRaidFlags, param9, param10, param11, param12, param13, param14,  param15, param16, param17, param18, param19, param20 = ...
	if not eventtype or not destName then return end
	if strfind(eventtype,"_DAMAGE") and destName == myname then
		if strfind(eventtype,"SWING_") and param9 then
			-- local damage, absorb = param9, param14 or 0
			damageIncome(timestamp,param9)
		elseif (strfind(eventtype,"SPELL_") or strfind(eventtype,"RANGE_")) and srcName then
			-- local damage, absorb, school = param12 or 0, param17 or 0, param14 or 0
			local spellName = param10 or nil
			if param12 and not (spellName == SPIRIT_LINK_SPELL and srcName == SPIRIT_LINK_TOTEM) then damageIncome(timestamp,param12) end
		end
	end
end)

BloodShield:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

SlashCmdList["WBAR"] = function(cmd)
--[[ 	print("|cffff0000absorb的吸收列表:|r")
	for k,v in pairs(spellabsorb)do
		print(k,v)
	end ]]
	--print("测试伤害")
	debug = not debug
--[[ 	if cmd == "print" then
		for i in ipairs(List) do
			print("id:"..i.." GetTime="..List[i][1].." damage"..List[i][2])
		end
		for i = 1, List.last do
			if List[i] then
				p("id:"..List[i][1]..List[i][2])
			end
		end
		p("输出完毕"..List.last)
	else
		--print(GetTime().."前总数"..#List)
		for i = 1 , 300 do
			pushList({GetTime()+i/1000,100000})
		end
	--print("总数:"..List.last - List.first)
		--print((GetTime()+0.3).."后总数"..#List)
	end ]]
end
SLASH_WBAR1 = "/wbar"