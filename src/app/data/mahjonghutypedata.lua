MahjongHuTypeData = class("MahjongHuTypeData")

function MahjongHuTypeData.getInstance()
    if not MahjongHuTypeData.s_instance then
        MahjongHuTypeData.s_instance = new(MahjongHuTypeData)
    end
    return MahjongHuTypeData.s_instance
end

function MahjongHuTypeData.releaseInstance()
    delete(MahjongHuTypeData.s_instance)
    MahjongHuTypeData.s_instance = nil
end

function MahjongHuTypeData:ctor()
    self:init()
end

function MahjongHuTypeData:dtor()
    self.m_huType = {};
    self.m_huTypeList = {};
end

function MahjongHuTypeData:init()
    --胡牌类型(默认是按照顺序匹配，扩展时可以增加cmd的标记字段)
    self.m_huType = {
        PingHu          = 0x01; 
        QiDui           = 0x02; 
        PiaoHu          = 0x03; 
        ZuoZhuang       = 0x04; 
        DianPao         = 0x05; 
        ZhanLi          = 0x06; 
        QiongHu         = 0x07; 
        GangShangHua    = 0x08; 
        DaGeDa          = 0x09; 
        SiGuiYi         = 0x0A; 
        SanCha          = 0x0B; 
        Qiang           = 0x0C; 
        ErBaJiang       = 0x0D; 
        LiuLei          = 0x0E; 
        ZiMo            = 0x0F; 
    }

    self.m_huTypeList = {
        [self.m_huType.PingHu]        = {huTypeName = "平胡",     fanNum = 1},
        [self.m_huType.QiDui]         = {huTypeName = "七对",     fanNum = 1},
        [self.m_huType.PiaoHu]        = {huTypeName = "飘胡",     fanNum = 1},
        [self.m_huType.ZuoZhuang]     = {huTypeName = "坐庄",     fanNum = 1},
        [self.m_huType.DianPao]       = {huTypeName = "点炮",     fanNum = 1},
        [self.m_huType.ZhanLi]        = {huTypeName = "站立",     fanNum = 1},
        [self.m_huType.QiongHu]       = {huTypeName = "穷胡",     fanNum = 1},
        [self.m_huType.GangShangHua]  = {huTypeName = "杠上花",   fanNum = 1},
        [self.m_huType.DaGeDa]        = {huTypeName = "大哥大",   fanNum = 1},
        [self.m_huType.SiGuiYi]       = {huTypeName = "四归一",   fanNum = 1},
        [self.m_huType.SanCha]        = {huTypeName = "三叉",     fanNum = 1},
        [self.m_huType.Qiang]         = {huTypeName = "枪",       fanNum = 1},
        [self.m_huType.ErBaJiang]     = {huTypeName = "二八将",   fanNum = 1},
        [self.m_huType.LiuLei]        = {huTypeName = "流泪",     fanNum = 1},
        [self.m_huType.ZiMo]          = {huTypeName = "自摸",     fanNum = 1},
    }
end

--新游戏根据服务端的数据自己重新配置
function MahjongHuTypeData:sethuType(table)
    if table ~= nil or #table < 1 then
        Log.i("error setHuTypeCmd param is nil")
    end
    self.m_huType = table
end 

function MahjongHuTypeData:gethuType(table)
    return self.m_huType or {};
end 

--新游戏根据产品提供的文档和描述自己重新配置
function MahjongHuTypeData:sethuTypeList(table)
    if table ~= nil or #table < 1 then
        Log.i("error setHuTypeCmd param is nil")
    end
    self.m_huTypeList = table
end 

function MahjongHuTypeData:gethuTypeList(table)
    return self.m_huTypeList or {};
end 

return MahjongHuTypeData