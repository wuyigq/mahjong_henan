
local MahjongRoomBgData = class("MahjongRoomBgData");

MahjongRoomBgData.Delegate = {
    onGetMahjongRoomBgDataCallBack = "onGetMahjongRoomBgDataCallBack";
}

function MahjongRoomBgData:initData()
    self.version = -1;
    self.records = {}
end

function MahjongRoomBgData:loadDictData(dict)
    local gameInfo = GameInfoIsolater.getInstance()
    local list = gameInfo:getGameLevelListByGameId(gameInfo:getCurGameId())
    for _, v in pairs(table.verify(list)) do
        local str = dict:getString(tostring(v.levelId))
        local info = json.decode(str)
        if info then
            local tb = {"bg_game", "bg_chess_one", "bg_chess_two"}
            for _, vv in pairs(tb) do
                info[vv].url = tostring(info[vv].url)
                -- vv.path = tostring(vv.path)
            end
            self.records[tonumber(v.levelId)] = info
        end
    end
    Log.v("MahjongRoomBgData.loadDictData", self.records)
end

function MahjongRoomBgData:resetRecord(info)
    self.records[(info or self).level] = {
        bg_game         = {url = (info or self).bg_game}; 
        bg_chess_one    = {url = (info or self).bg_chess_one;}; 
        bg_chess_two    = {url = (info or self).bg_chess_two;}; 
    }
    --fix useless url
    for k, v in pairs(self.records[self.level]) do
        if string.trim(v.url)=="" then
            v.path = ""
        end
    end
end

function MahjongRoomBgData:saveDictData(dict)
    for level, v in pairs(self.records) do
        local str = json.encode(v)
        dict:setString(tostring(level), str);
    end
end

function MahjongRoomBgData:getLocalDictName()
    return "MahjongRoomBgData_" .. NETWORK_TYPE .. "_" .. GameInfoIsolater.getInstance():getCurGameId()
end

function MahjongRoomBgData:requestData()
    local game_id = GameInfoIsolater.getInstance():getCurGameId();
	local game_ver = GameInfoIsolater.getInstance():getGameVersion();
    local level = self:getLevel()
    local param = {game_id = game_id; game_ver = game_ver; level = level; };
    Log.i("MahjongRoomBgData.requestData", game_id, game_ver, level, param);
    OnlineSocketManager.getInstance():sendMsg(PHP_ROOM_GET_GAME_BG, param);
end

--[[{
	"status": 0,	//状态
	"type": 0,	//错误码
	"msg": "",	//错误信息
	"act": 0,	//固定参数
	"index": 0,	//固定参数
	"cmd": 1,	//客户端发送过来的cmd字段值
	"info": {
		"level": 12,		    //房间级别
		"cfg_time": 1450684339,	//最新配置时间(用于缓存图片)
		"bg_game": "",	        //游戏背景图片
		"bg_table": "",	        //桌子背景图片
		"bg_watermark": "",	    //水印背景图片
     "bg_chess_one",             //棋牌背景图片
     "bg_chess_two",             //棋牌背景图片
	} 
}]]
function MahjongRoomBgData:onGetMahjongRoomBgDataCallBack(isSuccess, info)
    Log.v("MahjongRoomBgData.onGetMahjongRoomBgDataCallBack", "isSuccess = ", isSuccess, " info = ", info);
    if isSuccess then
        -- self:updateDataByCompareVersion(info.cfg_time, false, info);
        self:updateMemData(info)
    end
end

function MahjongRoomBgData:getLocalVersion()
    return self.version;
end

function MahjongRoomBgData:resetRecord(info)
    self.records[(info or self).level] = {
        bg_game         = {url = (info or self).bg_game}; 
        bg_chess_one    = {url = (info or self).bg_chess_one;}; 
        bg_chess_two    = {url = (info or self).bg_chess_two;}; 
    }
    --fix useless url
    for k, v in pairs(self.records[self.level]) do
        if string.trim(v.url)=="" then
            v.path = ""
        end
    end
end

function MahjongRoomBgData:updateMemData(info)
    self.level = tonumber(info.level) or 0
    self.version = info.version or -1;
    self.bg_game = info.bg_game or "";
    self.bg_table = info.bg_table or "";
    self.bg_chess_one = info.bg_chess_one or "";
    self.bg_chess_two = info.bg_chess_two or "";
    -- self.records[level] = {bg_game=false; bg_chess_one=true; bg_chess_two=true}--TODO
    self:resetRecord()
    self:saveData()
    self:updateImages()
end

function MahjongRoomBgData:updateImages(info)
    ImageCache.getInstance():request(self.bg_game, self, MahjongRoomBgData.onDownload)
    ImageCache.getInstance():request(self.bg_chess_one, self, MahjongRoomBgData.onDownload)
    ImageCache.getInstance():request(self.bg_chess_two, self, MahjongRoomBgData.onDownload)
end

function MahjongRoomBgData:onDownload(url, imagePath)
    Log.v("MahjongRoomBgData.onDownload", url, imagePath)
    local changed = false
    for level, record in pairs(self.records) do
        for _, v in pairs(record) do
            if v.url==url and v.path~=imagePath then
                v.path = imagePath
                changed = true
            end
        end
    end
    if changed then
        self:saveData()
        -- self:checkAllDownloaded(true)
    end
end

function MahjongRoomBgData:checkAllDownloaded(feedback)
    local level = self:getLevel()
    local flag = true
    if level and self.records[level] then
        local info = self.records[level]
        for k, v in pairs(info) do
            if not v.path then
                flag = false
            end
        end
        if flag and self:checkPath(info) then
            local ret =  {
                bg_game      = info.bg_game.path;
                bg_chess_one = info.bg_chess_one.path;
                bg_chess_two = info.bg_chess_two.path; }

            local myID = UserBaseInfoIsolater.getInstance():getUserId()
            local action = MahjongMechineConfig.ACTION_NS_ROOM_BG
            MechineManage.getInstance():receiveAction(action, ret, myID)
        end
    end
end

function MahjongRoomBgData:getLevel()
    local gameInfo = GameInfoIsolater.getInstance()
    local level = gameInfo:getCurRoomLevelId()
    local gameId = gameInfo:getCurGameId()
    local info = gameInfo:getGameLevelInfo(gameId, level)
    if not info then
        local list = gameInfo:getGameLevelListByGameId(gameId)
        for _, v in pairs(table.verify(list)) do
            return v.levelId
        end
    end
    return level
end

function MahjongRoomBgData:checkPath(info)
    local function isValid(cfg)
        if cfg and cfg.path and not string.isEmpty(string.trim(cfg.path)) then
            return true;
        end
        return false;
    end
    return info and isValid(info.bg_game) and isValid(info.bg_chess_one) and isValid(info.bg_chess_two)
end

function MahjongRoomBgData:getCacheInfo()
    return self:checkAllDownloaded(true)
end

---------------------------------------------------------------------------------------------------------------------
MahjongRoomBgData.s_socketCmdFuncMap = {
    [PHP_ROOM_GET_GAME_BG] = "onGetMahjongRoomBgDataCallBack";
}

return MahjongRoomBgData;