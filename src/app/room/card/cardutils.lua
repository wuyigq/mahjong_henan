local CardUtils = class()

local cardValueMap = {
    YIWAN = 0x01;
    JIUWAN = 0x09;
    YIBING = 0x11;
    JIUBING = 0x19;
    YITIAO = 0x21;
    JIUTIAO = 0x29;
    DONG = 0x31;
    NAN = 0x32;
    XI = 0x33;
    BEI = 0x34;
    ZHONG = 0x41;
    FA = 0x42;
    BAI = 0x43;
}

-- 对子将牌
local duizi = function(hands, isTing)
    for i, c in ipairs(hands) do
        if isTing then
            if MahjongBaseData.getInstance():isTingYong(c) then 
                return true
            end
        end 
        if hands[i+1] then
            if hands[i+1] == c then
                if hands[i+2] then
                    if hands[i+2] ~= c then 
                        if hands[i-1] ~= c then
                            return true 
                        end
                    end
                else
                    return true
                end
            end
        end
    end
    return false
end 

-- 中发白对子
local hasZFBDuizi = function(hands, isTing)
    local temp = {z=0,f=0,b=0}
    local tingYongCount = 0
    for i, c in ipairs( hands ) do
        if isTing then 
            if MahjongBaseData.getInstance():isTingYong(c) then
                tingYongCount = tingYongCount + 1
            elseif c == cardValueMap.ZHONG then 
                temp.z = temp.z + 1 
            elseif c == cardValueMap.FA then 
                temp.f = temp.f + 1
            elseif c == cardValueMap.BAI then 
                temp.b = temp.b + 1
            end
        else
            if c == cardValueMap.ZHONG then temp.z = temp.z + 1 end
            if c == cardValueMap.FA then temp.f = temp.f + 1 end
            if c == cardValueMap.BAI then temp.b = temp.b + 1 end
        end
    end
    local  ret = temp.z==2 or temp.f==2 or temp.b==2
    if not ret then
        ret = tingYongCount >= 1 and (temp.z == 1 or temp.f == 1 or temp.b == 1)
    end
    return ret
end

-- 是否有刻子或杠
local kezi = function(hands, extras, isTing)
    for i, block in ipairs( extras ) do
        if block.operateValue == MahjongConst.PUNG or block.operateValue == MahjongConst.PUNG_KONG or 
            block.operateValue == MahjongConst.AN_KONG or block.operateValue == MahjongConst.BU_KONG then
            return true
        end
    end
    -- 手牌中只用判断碰牌类型就行了
    local tingYongCount = 0
    local isDuiZi = false
    for i, c in ipairs(hands) do
        if isTing then 
            if MahjongBaseData.getInstance():isTingYong(c) then
                tingYongCount = tingYongCount + 1
            end
        end
        if hands[i+1] and hands[i+2] then
            if c == hands[i+1] and c == hands[i+2] then
                return true
            elseif c == hands[i+1] or c == hands[i+2] then
                isDuiZi = true
            end
        end
        if tingYongCount >= 2 or (tingYongCount >= 1 and isDuiZi)then return true end
    end
    return false
end

-- 三色全(isTing:是否考虑听用牌)
local sanse = function(hands, extras, isTing)
    local hasWan, hasBing, hasTiao = false, false, false
    for i, c in ipairs( hands ) do
        if not hasWan then
            if isTing then
                if MahjongBaseData.getInstance():isTingYong(c) == false then
                    hasWan = c >= cardValueMap.YIWAN and c <= cardValueMap.JIUWAN
                end
            else
                hasWan = c >= cardValueMap.YIWAN and c <= cardValueMap.JIUWAN
            end
        end
        if not hasBing then
            if isTing then
                if MahjongBaseData.getInstance():isTingYong(c) == false then
                    hasBing = c >= cardValueMap.YIBING and c <= cardValueMap.JIUBING
                end
            else
                hasBing = c >= cardValueMap.YIBING and c <= cardValueMap.JIUBING
            end
        end
        if not hasTiao then
            if isTing then
                if MahjongBaseData.getInstance():isTingYong(c) == false then
                    hasTiao = c >= cardValueMap.YITIAO and c <= cardValueMap.JIUTIAO
                end
            else
                hasTiao = c >= cardValueMap.YITIAO and c <= cardValueMap.JIUTIAO
            end
        end
    end
    if hasWan and hasBing and hasTiao then return true end
    for i, block in ipairs( extras ) do
        if block.cards[1] then
            local vaule = block.cards[1]:getValue()
            if not hasWan then
                if isTing then
                    if MahjongBaseData.getInstance():isTingYong(c) == false then
                        hasWan = vaule >= cardValueMap.YIWAN and vaule <= cardValueMap.JIUWAN
                    end
                else
                    hasWan = vaule >= cardValueMap.YIWAN and vaule <= cardValueMap.JIUWAN
                end
            end
            if not hasBing then
                if isTing then
                    if MahjongBaseData.getInstance():isTingYong(c) == false then
                        hasBing = vaule >= cardValueMap.YIBING and vaule <= cardValueMap.JIUBING
                    end
                else
                    hasBing = vaule >= cardValueMap.YIBING and vaule <= cardValueMap.JIUBING
                end
            end
            if not hasTiao then
                if isTing then
                    if MahjongBaseData.getInstance():isTingYong(c) == false then
                       hasTiao = vaule >= cardValueMap.YITIAO and vaule <= cardValueMap.JIUTIAO
                    end
                else
                    hasTiao = vaule >= cardValueMap.YITIAO and vaule <= cardValueMap.JIUTIAO
                end
            end
        end
    end

    local seCount = 0
    if hasWan then
        seCount = seCount+1
    end
    if hasBing then
        seCount = seCount+1
    end
    if hasTiao then
        seCount = seCount+1
    end

    if isDuanMen then
        if seCount == 2 then
            return true
        else
            return false
        end
    else
        if seCount == 3 then
            return true
        else
            return false
        end
    end
end

-- 有幺九
local yaojiu = function(hands, extras, isTing)
    for i, c in ipairs( hands ) do
        if isTing and MahjongBaseData.getInstance():isTingYong(c) then
            Log.i("yaojiu ting")
        else
            if c == cardValueMap.YIWAN
                or c == cardValueMap.JIUWAN
                or c == cardValueMap.YIBING
                or c == cardValueMap.JIUBING
                or c == cardValueMap.YITIAO
                or c == cardValueMap.JIUTIAO
                or c == cardValueMap.DONG
                or c == cardValueMap.NAN
                or c == cardValueMap.XI
                or c == cardValueMap.BEI 
                or c == cardValueMap.ZHONG
                or c == cardValueMap.FA 
                or c == cardValueMap.BAI then
                return true
            end
        end
    end
    for i, c in ipairs(extras) do
        local len = 1
        if MahjongHelpFunc.getInstance():operatorValueHasChi(c.operateValue) then
            len = #c.cards
        end
        for j = 1, len do
            if c.cards[j] then
                local vaule = c.cards[j]:getValue()
                if vaule == cardValueMap.YIWAN
                    or vaule == cardValueMap.JIUWAN
                    or vaule == cardValueMap.YIBING
                    or vaule == cardValueMap.JIUBING
                    or vaule == cardValueMap.YITIAO
                    or vaule == cardValueMap.JIUTIAO
                    or vaule == cardValueMap.DONG
                    or vaule == cardValueMap.NAN
                    or vaule == cardValueMap.XI
                    or vaule == cardValueMap.BEI 
                    or vaule == cardValueMap.ZHONG
                    or vaule == cardValueMap.FA 
                    or vaule == cardValueMap.BAI then
                    return true
                end
            end
        end
    end
    return false
end

-- 开门(吃碰杠)
local kaimen = function(extras)
    for i, block in ipairs(extras) do
        if block.operateValue ~= MahjongConst.AN_KONG then
            return true
        end
    end
    return false
end

-- 七对（六对就听牌）
local qiduihu = function(hands, extras)
	if #extras <= 0 and #hands == 13 then 
		for i = 1, #hands do
			local tempHands = table.copyTab(hands)
			table.remove(tempHands, i)
			if tempHands[1] == tempHands[2] and tempHands[3] == tempHands[4] and tempHands[5] == tempHands[6] and 
				tempHands[7] == tempHands[8] and tempHands[9] == tempHands[10] and tempHands[11] == tempHands[12] then
				return true
			end
		end
	end
	return false
end 

-- 飘胡(对对胡)
local piaohu = function(hands, extras)
	for i, block in ipairs(extras) do
		if block.operateValue ~= MahjongConst.PUNG then 
			return false
		end
	end 

	if #hands == 1 then 
		return true 
	end 

	for i = 1, #hands do
		local tempHands = table.copyTab(hands)
		table.remove(tempHands, i)

		if #tempHands >= 3 and tempHands[1] == tempHands[2] == tempHands[3] then 
			if #tempHands >= 6 then
				if tempHands[4] == tempHands[5] == tempHands[6] then
					if #tempHands >= 9 then 
						if tempHands[7] == tempHands[8] == tempHands[9] then 
							if #tempHands >= 12 then
								if tempHands[10] == tempHands[11] == tempHands[12] then
									return true
								end
							end
							return true
						end
					end
					return true
				end
			end
			return true
		end 
	end
	return false
end

CardUtils.duizi = duizi
CardUtils.hasZFBDuizi = hasZFBDuizi
CardUtils.kezi = kezi
CardUtils.sanse = sanse
CardUtils.yaojiu = yaojiu
CardUtils.kaimen = kaimen
CardUtils.qiduihu = qiduihu
CardUtils.piaohu = piaohu

--整理胡牌要求
function CardUtils:setMineCards(hands, extras)
    table.sort(hands)

    local data = {
                    [1] = {check = self.duizi(hands, true)};
                    [2] = {check = self.sanse(hands, extras, true);};
                    [3] = {check = self.kezi(hands, extras, true) or self.hasZFBDuizi(hands, true)};
                    [4] = {check = self.yaojiu(hands, extras, true)};
                };  
    MahjongBaseData.getInstance():setHuRequirement(data)
end

--不知道有其他子麻将用到没，先保留这个接口
function CardUtils:clearMineCards()
     local data = {
                    [1] = {check = false};
                    [2] = {check = false};
                    [3] = {check = false};
                    [4] = {check = false};
                };  
    MahjongBaseData.getInstance():setHuRequirement(data)
end

return CardUtils