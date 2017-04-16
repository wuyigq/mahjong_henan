local MahjongEffectConfig = import("app.config.mahjongeffectconfig");

---------声音配置表-------------
--麻将读牌配置
local mjEffectMap = {
    ["wan"] = {1,1,1,1,1,1,1,1,1};--1-9万读牌数
    ["tong"] = {1,1,1,1,1,1,1,1,1};--1-9筒读牌数
    ["tiao"] = {1,1,1,1,1,1,1,1,1};--1-9条读牌数
    ["zi"]   = {1,1,1};--中发白
    ["feng"] = {1,1,1,1};--东南西北
}
--聊天配置
local mjChatMap = {
    ["start"] = 100; --
    ["count"] = 10;  --聊天数量
}
--操作配置
local mjOperateMap = {
    ["peng"] = 4;  
    ["gang"] = 4; 
    ["hu"] = 4;
    ["chi"] = 4;    
    ["jia"] = 1;    
    ["ting"] = 4;    
    ["zimo"] = 1;  
    
    ["gangshanghua"] = 1;
    ["huanbao"] = 1;   
}

MjGameOPAudioConfig = {
    [MahjongConst.RIGHT_CHOW]    = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "chi");     -- 右吃
    [MahjongConst.MIDDLE_CHOW]   = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "chi");     -- 中吃
    [MahjongConst.LEFT_CHOW]     = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "chi");     -- 左吃
    [MahjongConst.PUNG]          = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "peng");    -- 碰
    [MahjongConst.PUNG_KONG]     = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "gang");    -- 碰杠
    [MahjongConst.AN_KONG]       = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "gang");    -- 暗杠
    [MahjongConst.BU_KONG]       = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "gang");    -- 补杠
    [MahjongConst.ZI_MO]         = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "zimo");      -- 自摸
    [MahjongConst.HU]            = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "hu");      -- 放枪
    [MahjongConst.QIANG_GANG_HU] = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "hu");      -- 抢杠胡

    ["gangshanghua"]                 = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "gangshanghua");  --杠上花
    ["huanbao"]                 = MahjongEffectConfig.createOpAudioMapByKey(mjOperateMap, "huanbao");  --换宝
}

----一般只需要修改上面配置即可

local mjCfg = MahjongEffectConfig.init(mjEffectMap, mjChatMap, mjOperateMap, nil, "");
local mjGameEffectKeys = {}
local mjGameEffectConfig = {}

MjGameEffectKeys = CombineTables(Effects or {}, mjCfg.effects, mjGameEffectKeys or {});
MjGameEffectConfig = CombineTables(EffectsFileMap or {}, mjCfg.effectsFileMap, mjGameEffectConfig or {});

MjGameSoundTab = {};
MjGameSoundTab.setSoundTab = function()
    MjGameSoundTab.music = mjCfg.music;
    MjGameSoundTab.musicFileMap = mjCfg.musicFileMap;
    MjGameSoundTab.effects = MjGameEffectKeys;
    MjGameSoundTab.effectsFileMap = MjGameEffectConfig;
    return MjGameSoundTab;
end

return MjGameSoundTab.setSoundTab();


