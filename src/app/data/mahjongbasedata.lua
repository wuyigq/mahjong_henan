--麻将公共数据源

MahjongBaseData = class("MahjongBaseData")

MahjongBaseData.OUT_CARD = 1;
MahjongBaseData.OPERATION = 2;
MahjongBaseData.TIME_OUT = 3;

function MahjongBaseData.getInstance()
    if not MahjongBaseData.s_instance then
        MahjongBaseData.s_instance = new(MahjongBaseData)
    end
    return MahjongBaseData.s_instance
end

function MahjongBaseData.releaseInstance()
    delete(MahjongBaseData.s_instance)
    MahjongBaseData.s_instance = nil
end

function MahjongBaseData:ctor()
    self:reset()
end

function MahjongBaseData:dtor()
    self.controller = nil
end

function MahjongBaseData:reset()
    self.zhuangSeat = nil
    self.zhuangNode = nil
    self.m_forceHu = false
    self.leftCard = 0
    self.m_benjin = nil
    self.m_tingyongTable = {}   
    self.m_requirement = {}
end

function MahjongBaseData:send(cmd, param)
    SocketIsolater.getInstance():sendMsg(cmd, param)
end

--设置/获取庄家的本地座位号
function MahjongBaseData:setZhuangSeat(seat)
    self.zhuangSeat = seat;
end
function MahjongBaseData:getZhuangSeat()
    return self.zhuangSeat;
end

-- 设置/获取庄节点，用于播放庄动画
function MahjongBaseData:setZhuangNode(zhuangNode)
    self.zhuangNode = zhuangNode;
end
function MahjongBaseData:getZhuangNode()
    return self.zhuangNode;
end 

function MahjongBaseData:setBenJin(benjin)
    self.m_benjin = benjin
end

function MahjongBaseData:getBenJin()
    return self.m_benjin
end

--设置癞子牌
function MahjongBaseData:setTingYong(tingyongTable)
    self.m_tingyongTable = tingyongTable;
end

--获取癞子牌
function MahjongBaseData:getTingYong()
    return self.m_tingyongTable;
end

--判断是否癞子牌
function MahjongBaseData:isTingYong(card)
    if self.m_tingyongTable == nil then
        return false
    end
    for i, v in ipairs(self.m_tingyongTable) do 
        if card == v then
            return true
        end 
    end 
    return false
end

--设置/获取/自减剩余牌数
function MahjongBaseData:setLeftCard(leftCard)
    if leftCard ~= nil and leftCard ~= self.leftCard then
        -- local action = MahjongMechineConfig.ACTION_NS_LEFT_CARD
        local myID = UserBaseInfoIsolater.getInstance():getUserId()
        self.leftCard = leftCard;
        -- MechineManage.getInstance():receiveAction(action, {leftCard=leftCard}, myID)

        self:checkFroceHuByLeftCard()
    end
end
function MahjongBaseData:getLeftCard()
    return self.leftCard or 0;
end
function MahjongBaseData:decLeftCard()
    local leftCard = self.leftCard - 1;
    if leftCard < 0 then
        leftCard = 0 
    end
    self:setLeftCard(leftCard);

    self:checkFroceHuByLeftCard()
end

function MahjongBaseData:checkFroceHuByLeftCard()
    if self.leftCard > MahjongConst.NumMustHu then 
        self:setForceHu(false)
    else
        self:setForceHu(true)
    end
end 

--设置/获取出牌时间
function MahjongBaseData:setOutCardTime(time)
    self.outCardTimeLimit = time
end
function MahjongBaseData:getOutCardTime()
    return self.outCardTimeLimit or 8
end

--设置/获取操作时间
function MahjongBaseData:setOperateTime(time)
    self.operationTimeLimit = time
end
function MahjongBaseData:getOperateTime()
    return self.operationTimeLimit or 8
end

--设置出牌时间和操作时间
function MahjongBaseData:setOutCardAndOperateTime(outcardTime, operateTime)
    self.outCardTimeLimit = outcardTime
    self.operationTimeLimit = operateTime
end

--设置/获取房间截屏
function MahjongBaseData:setScreenShot(shot)
    self.screenShot = shot
end
function MahjongBaseData:getScreenShot()
    return self.screenShot
end

--设置/获取台费
function MahjongBaseData:setTai(tai)
    self.tai = tai or 0
end
function MahjongBaseData:getTai()
    return self.tai or 0
end

--设置/获取底注
function MahjongBaseData:setDi(di)
    self.di = di or 0;
end
function MahjongBaseData:getDi()
    return self.di or 0
end

--设置台费和底注
function MahjongBaseData:setTaiAndDi(tai, di)
    self.di = di or 0;
    self.tai = tai or 0
end

--设置房间flag，如宜宾自摸/点炮场
--济南的乱将/非乱将场
function MahjongBaseData:getRoomFlag(defaultValue)
    return MahjongBaseData.getDictData("room_flag", defaultValue)
end
function MahjongBaseData:setRoomFlag(flag)
    MahjongBaseData.setDictData("room_flag", flag)
end

--设置/获取强制胡牌标记
function MahjongBaseData:setForceHu(flag)
    if not self.m_forceHu then
        self.m_forceHu = flag
    end
end
function MahjongBaseData:getForceHu()
    return self.m_forceHu
end

--重连后设置剩牌/底注/剩余牌数/出牌和操作超时时间
function MahjongBaseData:setReconnectInfo(info)
    self:setDi(info.di)
    self:setTai(info.tai)
    self:setLeftCard(info.remainCardCount)
    self:setOutCardTime(info.outCardTimeLimit)
    self:setOperateTime(info.operationTimeLimit)  
    self:setBenJin(info.benjin)
    self:setTingYong(info.laiziTable)
end

--设置/获取CardView类路径
function MahjongBaseData:setCardViewPath( path )
    self.m_cardViewPath = path
end
function MahjongBaseData:getCardViewPath()
    if self.m_cardViewPath then
        return self.m_cardViewPath
    else
        return _gamePathPrefix .. "mahjong/module/card/cardview"
    end
end

--设置/获取Card类路径
function MahjongBaseData:setCardPath( path )
    self.m_cardPath = path
end
function MahjongBaseData:getCardPath()
    if self.m_cardPath then
        return self.m_cardPath
    else
        return _gamePathPrefix .. "mahjong/module/card/card"
    end
end

--------------状态机路径相关 start -------------------------------------------------
--设置/获取PlayingOpt类路径
function MahjongBaseData:setPlayingOptPath(path)
    self.m_playingOptPath = path
end
function MahjongBaseData:getPlayingOptPath()
    if self.m_playingOptPath then
        return self.m_playingOptPath
    else
        return _gamePathPrefix .. "mahjong/mechine/mahjongplayingopt"
    end
end

--设置/获取NoneOpt类路径
function MahjongBaseData:setNoneOptPath(path)
    self.m_noneOptPath = path
end
function MahjongBaseData:getNoneOptPath()
    if self.m_noneOptPath then
        return self.m_noneOptPath
    else
        return _gamePathPrefix .. "mahjong/mechine/mahjongnoneopt"
    end
end

function MahjongBaseData:setNoStationActionPath(path)
    MechineConfig.mechineConfig[MechineConfig.STATUS_NOSTATUS] = {path}
end
--------------状态机路径相关 end ---------------------------------------------------

function MahjongBaseData:getHuRequirement()
    return self.m_requirement or {}
end
function MahjongBaseData:setHuRequirement(requirement)
    self.m_requirement = requirement or {}
    -- local action = MahjongMechineConfig.ACTION_NS_REQUIREMENT
    -- MechineManage.getInstance():receiveAction(action, {data = self.m_requirement})
end

--这个接口可以用来保存数据到文件
--在游戏内和游戏外都可以使用
function MahjongBaseData.getDictData( key, defaultValue )
    dict_load("mahjong_dict")
    return dict_get_int("mahjong_dict", key, defaultValue or 0)
end
function MahjongBaseData.setDictData( key, value )
    dict_load("mahjong_dict");
    dict_set_int("mahjong_dict", key, value);
    dict_save("mahjong_dict");
end

return MahjongBaseData
