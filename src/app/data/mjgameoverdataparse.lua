
local mjRoleFiles = {
    [MahjongConst.kSeatMine] = "";
    [MahjongConst.kSeatRight] = "games/common/game_result/game_result_mahjong_xiajia_icon.png";
    [MahjongConst.kSeatLeft] = "games/common/game_result/game_result_mahjon_shagnjia_icon.png";
};

GameOverDataParse = class("GameOverDataParse");

GameOverDataParse.roles = {
    [MahjongConst.kSeatMine] = "mine";
    [MahjongConst.kSeatRight] = "right";
    [MahjongConst.kSeatLeft] = "left"; 
    [MahjongConst.kSeatTop] = "top"; 
} 

GameOverDataParse.s_huType = {
    TianHu      =    0x01;    
    DiHu        =    0x02;  
    AnQiDui     =    0x03;
    QingYiSe    =    0x04;
    DaDuiZi     =    0x05; 
    JinGouPao   =    0x06;   
    JinGouDiao      =    0x07;   
    HaiDi       =    0x08;
    QiangGang     =    0x09;   
    GangShangKaiHua =    0x0a;      
    GangShangPao    =    0x0b;
    KaErTiao      =    0x0c;
    PingHu          =    0x0E;
    QingYiSeKaErTiao    =    0x0F;     
    QingLongQiDui   =     0x10;
    QingQiDui       =     0x11;
    QingDaDui       =     0x12;
    LongQiDui       =     0x13;
};

--胡的方法
GameOverDataParse.s_huWay = {
    PING_HU = 1;        --平胡
    ZI_MO = 2;          --自摸
}

GameOverDataParse.gouNum = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};

GameOverDataParse.ctor = function(self)
    self.name = 0;
    self.sex = 0;
    self.totalMoney = 0;
    self.turnMoney = 0;
    self.mid = 0;
    self.turnExp = 0;
    self.roleFile = 0;
    self.avatar = 0;
    self.roomTotal = nil;
    self.rightTable = {};
    self.multiple = -1;
    self.detail = {};
end

local addDetail = function (details, seat, name, content)
    local item = {seat = seat; content = content; name = name}
    table.insert(details[seat], item); 
end

local addHuInfo = function (details, seat, name, mySeat)
    local content = GameOverDataParse.roles[mySeat] or "";
    addDetail(details, seat, name, content)
end

local addFan = function (details, seat, name, fan)
    addDetail(details, seat, name, (fan or "") .. "番")
end

local function findWinner(info, id)
    for _, p in pairs(info) do
        if p.userId == id then
            return p
        end
    end
end

GameOverDataParse.parse = function(data, baseChip)
    GameOverDataParse.isDouble = nil
    baseChip = MahjongBaseData.getInstance():getDi()
    local baseData = {baseChip = baseChip};
    if not data then
        return {}, baseData;
    end 
    local dataList = MahjongConst.initSeatTb({})
    local dataDetails = MahjongConst.initSeatTb({})
    local others = MahjongConst.initSeatTb({})
    local streams = {}
    local stamps = {};
    local wujiaos = {};
    local winnerInfo = findWinner(data.playerInfo, data.winnerId)
    if data.roundResult~=0 then
        winnerInfo.huCard = data.huCard
        baseData.winnerId = winnerInfo.userId;
        baseData.winnerSeat = data.winnerSeat;
    end

    local huFan
    
    for k,v in pairs(data.playerInfo) do
        local player = GameOverDataParse.getPlayerById(v.userId);
        if player then 
            local rdata = new(GameOverDataParse);
            rdata.name = player:getNick();
            rdata.avatar = player:getAvatar_s();
            rdata.sex = player:getSex();
            rdata.mid = v.userId;
            rdata.seat = GamePlayerManager2.getInstance():getLocalSeatByMid(v.userId);
            rdata.roleFile = mjRoleFiles[rdata.seat];
            rdata.turnExp = v.turnExp;
            rdata.exp = v.turnExp;
            rdata.poChan = v.isPochan;
            --rdata.score = v.realWinMoney;--实际赢钱 
            rdata.winMoney = v.winMoney or 0;
            rdata.turnMoney = v.turnMoney or 0;
            -- rdata.roomTotal = v.totalMoney;
            rdata.totalMoney = v.leftMoney;
            rdata.huNum = v.huNum;
            rdata.m_vip = player:getIdentity();
            rdata.multiple = v.huFan and math.pow(2, v.huFan)
            dataList[rdata.seat] = rdata;
            if data.roundResult~=0 then
                local detail, huFan = GameOverDataParse.getFanList(v, winnerInfo, data, baseChip, dataDetails, stamps)
                if rdata.seat==MahjongConst.kSeatMine then
                    local winnerSeat = GamePlayerManager2.getInstance():getLocalSeatByMid(winnerInfo.userId)
                    totalMoney = v.leftMoney;
                    dataDetails[MahjongConst.kSeatMine].totalFan = (dataDetails[MahjongConst.kSeatMine].totalFan or 0)+huFan
                    dataDetails[MahjongConst.kSeatMine].direct = GameOverDataParse.roles[winnerSeat]
                end
            end
            others[rdata.seat].isBankrupt = rdata.poChan==1
            others[rdata.seat].gold = rdata.turnMoney
            others[rdata.seat].name = rdata.name
            others[rdata.seat].fan = v.huFan
            GameOverDataParse.parseStream(rdata.seat, v, streams)
        end  
    end
    baseData.others = others
    baseData.streams = streams
    baseData.wujiaos = wujiaos

    --如果只有2，则把2移掉前面
    local  stamps1 = stamps[1];
    local  stamps2 = stamps[2];
    if not stamps1 and stamps2 then
        stamps = {};
        stamps[1] = stamps2;
    end

    baseData.stamps = stamps;
    table.sort( dataList, function(data1,data2)
        if data1.seat and data2.seat and data1.seat < data2.seat then 
            return true;
        end
        return false;
    end);
    for k,v in pairs(dataList) do
        for kk,vv in ipairs(dataDetails[k]) do
            if vv.name~="庄" then
                local item = table.remove(dataDetails[k], kk)
                table.insert(dataDetails[k], 1, item)
                break
            end
        end
        v.detail = dataDetails[k];        
    end
    
    return dataList, baseData
end

GameOverDataParse.parseStream = function(seat, data, streams)
    local info = {}
    for k, v in ipairs(data.streams or {}) do
        local stream = {}
        local player = GameOverDataParse.getPlayerById(v.userId)
        if player then
            stream.name = player:getNick()
            stream.content = ""
            if v.type==4 then
                stream.fan = v.fan
            end
            stream.gold = v.gold
            table.insert(info, stream)
        end
    end

    streams[seat] = info
    Log.i("GameOverDataParse.parseStream----", streams)
end

local RoleType = {
    PING = 1,                                                   --别人放炮，别人胡
    ZIMOHU = 2,                                                 --自摸胡牌
    HUPAI = 3,                                                  --胡牌
    FANGPAO = 4,                                                --放炮
    BIERENZIMO = 5,                                              --别人自摸
    LIUJU = 6,                                                  --流局
}

local function setStames(winnerId, pos, value, stamps)
    local myID = UserBaseInfoIsolater.getInstance():getUserId()
    if myID==winnerId then
        stamps[pos] = value
    end
end

function GameOverDataParse.getFanList(playerInfo, winnerInfo, data, chip, detail, stamps)
    if not data or not data.huFan  then
        Log.w("error")
        return
    end

    winnerInfo = winnerInfo or {};
    local seat = GamePlayerManager2.getInstance():getLocalSeatByMid(playerInfo.userId)
    local fan = 0
    if playerInfo.isKaiMen == 0 then
        fan = fan + 1
        addDetail(detail, seat, "未开门", "1番")
    end
    if (playerInfo.role == RoleType.FANGPAO) then
        fan = fan + 1
        addDetail(detail, seat, "放炮", "1番")
    end
    if data.chongBao == 1 then
        addDetail(detail, seat, "冲宝", data.chongbaoFan.."番")
        fan = fan + data.chongbaoFan
        setStames(data.winnerId, 2, "chongbao", stamps)
    elseif data.zhuaBao == 1 then
        addDetail(detail, seat, "摸宝", data.mobaoFan.."番")
        addDetail(detail, seat, "自摸", data.huFan.."番")
        setStames(data.winnerId, 2, "mobao", stamps)
        fan = fan + data.mobaoFan
        fan = fan + data.huFan
    elseif winnerInfo.role == RoleType.ZIMOHU then
        addDetail(detail, seat, "自摸", data.huFan.."番")
        setStames(data.winnerId, 1, "zimo", stamps)
        fan = fan + data.huFan
    end
    if winnerInfo.isGangShangHua == 1 then
        addDetail(detail, seat, "杠上开花", data.gangkaihuaFan.."番")
        setStames(data.winnerId, 1, "gangshangkai", stamps)
        fan = fan + data.gangkaihuaFan
    end
    if winnerInfo.isQiangGangHu == 1 then
        addDetail(detail, seat, "抢杠胡", data.qiangganghuFan.."番")
        fan = fan + data.qiangganghuFan
    end
    if data.isSanMenQing == 1 then
        addDetail(detail, seat, "三家门清", data.sanmenqingFan.."番")
        fan = fan + data.sanmenqingFan
    end
    if winnerInfo.isJiating == MjGameConstant.TING_TYPE.JIATING then
        addDetail(detail, seat, "夹", data.jiaFan.."番")
        fan = fan + data.jiaFan
    end
    addDetail(detail, seat, "平胡", data.huFan.."番")
    fan = fan + data.huFan
    if playerInfo.banker == 1 and not GameOverDataParse.isDouble then
        if MahjongConst.kSeatMine==seat then
            GameOverDataParse.isDouble = 1
            addFan(detail, MahjongConst.kSeatMine, "庄", 1)
            fan = fan + 1
        elseif playerInfo.userId == data.winnerId then
            GameOverDataParse.isDouble = 1
            addFan(detail, MahjongConst.kSeatMine, "庄", 1)
            detail[MahjongConst.kSeatMine].totalFan = (detail[MahjongConst.kSeatMine].totalFan or 0)+1
            fan = fan + 1
        end
    end
    -- 杠现在不算番数，只显示分数。
    if tonumber(winnerInfo.mingGangFan) > 0 and tonumber(winnerInfo.angangFan) > 0 then
        local score = winnerInfo.mingGangFan/3 * chip + winnerInfo.angangFan/3 * chip
        addDetail(detail, seat, "明暗杠+", score)
    elseif tonumber(winnerInfo.mingGangFan) > 0 then
        local score = winnerInfo.mingGangFan/3 * chip
        addDetail(detail, seat, "明杠+", score)
    elseif tonumber(winnerInfo.angangFan) > 0 then
        local score = winnerInfo.angangFan/3 * chip
        addDetail(detail, seat, "暗杠+", score)
    end
    return detail, fan
end

GameOverDataParse.getPlayerById = function ( mid )
    return GamePlayerManager2.getInstance():getPlayerByMid(mid);
end

GameOverDataParse.formatCardsInfo = function(seat, data, allInfo)
    local info = {seat=seat, blocks = data.blocks}
    info.handCardList = table.copyTab(data.handCardList)
    local winSeat = GamePlayerManager2.getInstance():getLocalSeatByMid(allInfo.winnerId)
    if winSeat==seat and 3*#data.blocks+#info.handCardList>MahjongConfig.HAND_CARD_NUM then
        for i = #info.handCardList, 1, -1 do
            if info.handCardList[i]==allInfo.huCard then
                table.remove(info.handCardList, i)
                info.huCard = allInfo.huCard
                break
            end
        end
    end

    return info
end

return GameOverDataParse
