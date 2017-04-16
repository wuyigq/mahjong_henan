LiuShuiData = class("LiuShuiData");

function LiuShuiData.getInstance()
    if not LiuShuiData.s_instance then
        LiuShuiData.s_instance = new(LiuShuiData)
    end
    return LiuShuiData.s_instance
end

function LiuShuiData.releaseInstance()
    delete(LiuShuiData.s_instance)
    LiuShuiData.s_instance = nil
end

function LiuShuiData:ctor()
    self:reset()
end

function LiuShuiData:dtor()
    
end

function LiuShuiData:reset()
    self.m_streamsData = {};
    self.m_totalMoney = 0;
end

LiuShuiData.typeContentMap = {
    ["10"] = "我查叫%s"; 
    ["11"] = "被%s查叫";
    ["20"] = "%s刮风"; 
    ["21"] = "被%s刮风";
    ["30"] = "%s下雨"; 
    ["31"] = "被%s下雨";
    ["40"] = "%s刮风下雨"; 
    ["41"] = "被%s刮风下雨";
    ["50"] = "%s呼叫转移"; 
    ["51"] = "被%s呼叫转移";
    ["60"] = "%s胡牌"; 
    ["61"] = "被%s胡";
}

LiuShuiData.seatNameTbl = {
    [MahjongConst.kSeatMine] = "我";
    [MahjongConst.kSeatRight] = "下家";
    [MahjongConst.kSeatTop] = "对家";
    [MahjongConst.kSeatLeft] = "上家"; 
};


function LiuShuiData:parseStreamData( streams )
    local streamsData = {};
    Log.d("parseStreamData streams",streams);
    for k, v in ipairs(streams or {}) do
        local keys = tostring(v.type);
        if v.type == 1 then
            if v.details and #v.details > 0 then
                for index,info in ipairs(v.details) do
                    local player = self:getPlayerById(info.userId)
                    local seat =  self:getPlayerSeatById(info.userId);
                    local seatName = self:getSeatName(seat);
                    if player then
                        local stream = {};
                        keys = keys .. (info.money > 0 and "0" or "1")
                        stream.name = string.format(LiuShuiData.typeContentMap[keys] or "",seatName)  
                        stream.fan = v.fan;
                        stream.type = v.type;
                        stream.piao = v.showNum;
                        stream.gold = info.money;
                        table.insert(streamsData, stream)
                    end
                end
            end
        else
            keys = keys .. (v.gold > 0 and "0" or "1")
            if v.gold > 0 then
                local stream = {}
                local seatName = self:getSeatName(MahjongConst.kSeatMine);
                stream.name = string.format(LiuShuiData.typeContentMap[keys] or "",seatName);
                stream.fan = v.fan;
                stream.type = v.type;
                stream.piao = v.showNum;
                stream.gold = v.gold;
                table.insert(streamsData, stream)
            else
                if v.details and #v.details > 0 then
                    for index,info in ipairs(v.details) do
                        local player = self:getPlayerById(info.userId)
                        local seat =  self:getPlayerSeatById(info.userId);
                        local relationName = self:getSeatName(seat);
                        local seatName = relationName;
                        if player then
                            local stream = {};
                            stream.name = string.format(LiuShuiData.typeContentMap[keys] or "",seatName);
                            stream.fan = v.fan;
                            stream.type = v.type;
                            stream.piao = v.showNum;
                            stream.gold = info.money;
                            table.insert(streamsData, stream)
                        end
                        
                    end
                end
            end
        end
    end
    return streamsData;
end

function LiuShuiData:getPlayerById( mid )
    return GamePlayerManager2.getInstance():getPlayerByMid(mid);
end

function LiuShuiData:getPlayerSeatById( mid )
    return GamePlayerManager2.getInstance():getLocalSeatByMid(mid);
end

function LiuShuiData:getSeatName( seat )
        if LiuShuiData.seatNameTbl[seat] then
            return LiuShuiData.seatNameTbl[seat]
        end
        return "";
end

LiuShuiData.setTypeContentMap = function ( self,contentMap )
    if not contentMap then return end;
    for k, v in pairs(contentMap) do
        LiuShuiData.typeContentMap[k] = v;
    end
end

LiuShuiData.setSeatNameTbl = function ( self,seatNameTbl )
    if not seatNameTbl then return end;
    LiuShuiData.seatNameTbl = seatNameTbl;
end

function LiuShuiData:checkIsShowFan( typeValue )
 
    if typeValue == 1 then
        return true;
    elseif typeValue == 6 then
        return true;
    elseif typeValue == 4 then
        return true;
    end
    return false;
end

function LiuShuiData:setShowFan( showFanTypes )
   self.m_showFanTypes = showFanTypes ;
    return false;
end

function LiuShuiData:setStreamData( streamsData  )
    self.m_streamsData = Copy(streamsData);
end

function LiuShuiData:getStreamData(  )
    return self.m_streamsData or {};
end

function LiuShuiData:setTotalMoney( money )
    self.m_totalMoney = money or 0;
end

function LiuShuiData:getTotalMoney(  )
    return self.m_totalMoney;
end