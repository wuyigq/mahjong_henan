--麻将读牌和聊天声音
MahjongEffectConfig = {};

--[[音效路径和文件名需要遵守如下规则：
读牌音效：effects/woman/w_牌型_牌值_序号；effects/man/m_牌型_牌值_序号
聊天音效：effects/woman/chat/chat序号;effects/man/chat/chat序号
操作音效：effects/woman/w_操作_序号；effects/man/m_操作_序号
]]
--参数格式如下：
--mjEffectMap 麻将读牌配置:牌型,牌值,音效数
--[[mjEffectMap = {
    ["tiao"] = 
    {
        [1] = 5;--1条有5个配音
        [2] = 3;--2条有3个配音
        ...
    };
    ["tong"] = {...};--筒
    ["wan"] = {...}; --万
}]]
--mjChatMap 聊天配置
--[[mjChatMap = {
    ["start"] = 100; --
    ["count"] = 17;  --聊天数量
}]]
--mjOperateMap 操作配置：吃碰杠胡...
--[[mjOperateMap = {
    ["chi"] = 4;
    ["peng"] = 3;
    ...
}]]
--prefix 路径前缀，一般可以不传
--majianziPrefix是读牌音效的添加路径，默认是"majiangzi/"，
--已经上线的版本，如本来没有这路径也没有音效改变，避免更新包过大可以传""

--背景音乐配置
local musickKeys = {
    backGround = "bgm";
}
local musicConfig = {
    [musickKeys.backGround] = _gamePathPrefix .. "music/audio_game_back"
}
MahjongEffectConfig.music = musickKeys;
MahjongEffectConfig.mjEffectMap = {};
MahjongEffectConfig.mjOperateMap = {};

----公共的音效
MahjongEffectConfig.effectKeys = {
    ["BUTTON_CLICK"] = "BUTTON_CLICK", --按钮点击--
    ["AUDIO_TG"]     = "AUDIO_TG",     --托管--
    ["AUDIO_COMEIN"] = "AUDIO_COMEIN", --进入--
    ["AUDIO_LEFT"]   = "AUDIO_LEFT",   --离开
    ["AUDIO_READY"]  = "AUDIO_READY",  --准备
    ["AUDIO_WIN"]    = "AUDIO_WIN",  --赢了
    ["AUDIO_LOST"]   = "AUDIO_LOST", --失败
    ["AUDIO_SZ"]     = "AUDIO_SZ",   --筛子
    ["AUDIO_OC"]     = "AUDIO_OC",   --出牌
    ["AUDIO_DC"]     = "AUDIO_DC",   --发牌
    ["AUDIO_PC"]     = "AUDIO_PC",   --破产--
    ["AUDIO_CC"]     = "card_click", --牌点击
    ["AudioWarning"]   = "AudioWarning",  --警告声音
    ["AUDIO_ENTERROOM"] = "AUDIO_ENTERROOM",  --进入房间
    ["AUDIO_ZIMO"] = "AUDIO_ZIMO",    --自摸--
    ["AUDIO_PENG"] = "AUDIO_PENG",    --碰--
    ["AUDIO_FP"]   = "AUDIO_FP",      --放炮--
    ["AUDIO_OPER"] = "AUDIO_OPER",    --提示操作--
    ["AUDIO_OpAnim"] = "AUDIO_OpAnim", --操作动画的音效
    ["AUDIO_Hu_Btn"] = "AUDIO_Hu_Btn",  --胡牌按钮出现
    ["AUDIO_Deal_Card"] = "AUDIO_Deal_Card",   --发牌最后倒牌
    ["AUDIO_Liu_Ju"] = "AUDIO_Liu_Ju",   --流局
    ["AUDIO_GrapCard"] = "AUDIO_GrapCard", --抓牌
    ["AUDIO_FLASH"]  = "AUDIO_FLASH",  --闪电
    ["AUDIO_ZHUANG"]  = "AUDIO_ZHUANG",  --庄
    ["AUDIO_DaPaiXing"] = "AUDIO_DaPaiXing", --大牌型动画的音效
}

local mahjongEffectConfig = {
    --其他音效
    ["BUTTON_CLICK"] = _gamePathPrefix.."effects/mahjong/audio_button_click", --按钮点击
    ["AUDIO_TG"]     = _gamePathPrefix.."effects/mahjong/audio_tg",     --托管
    ["AUDIO_COMEIN"] = _gamePathPrefix.."effects/mahjong/audio_comein", --进入
    ["AUDIO_LEFT"]   = _gamePathPrefix.."effects/mahjong/audio_left",   --离开
    ["AUDIO_READY"]  = _gamePathPrefix.."effects/mahjong/audio_ready",  --准备
    ["AUDIO_WIN"]    = _gamePathPrefix.."effects/mahjong/audio_win",  --赢了
    ["AUDIO_LOST"]   = _gamePathPrefix.."effects/mahjong/audio_lost", --失败
    ["AUDIO_SZ"]     = _gamePathPrefix.."effects/mahjong/audio_sz",   --筛子
    ["AUDIO_OC"]     = _gamePathPrefix.."effects/mahjong/audio_uc",   --出牌
    ["AUDIO_DC"]     = _gamePathPrefix.."effects/mahjong/audio_dc",   --发牌
    ["AUDIO_PC"]     = _gamePathPrefix.."effects/mahjong/audio_pc",   --破产
    ["AUDIO_CC"]     = _gamePathPrefix.."effects/mahjong/card_click", --牌点击
    ["AudioWarning"]   = _gamePathPrefix.."effects/mahjong/audio_warning",  --警告声音
    ["AUDIO_ENTERROOM"] = _gamePathPrefix.."effects/mahjong/audio_enterroom",  --进入房间

    ["AUDIO_ZIMO"] = _gamePathPrefix.."effects/mahjong/audio_zimo",    --自摸
    ["AUDIO_PENG"] = _gamePathPrefix.."effects/mahjong/audio_peng",    --碰
    ["AUDIO_FP"]   = _gamePathPrefix.."effects/mahjong/audio_fangpao",   --放炮
    ["AUDIO_OPER"] = _gamePathPrefix.."effects/mahjong/tips_oper",     --提示操作
    ["AUDIO_ZHUANG"] = _gamePathPrefix.."effects/mahjong/audio_zhuang",     --庄动画
    ["AUDIO_GAMESTART"] = _gamePathPrefix.."effects/mahjong/audio_gamestart",     --游戏开始动画
    ["AUDIO_FLASH"] = _gamePathPrefix.."effects/mahjong/audio_flash",     --闪电动画
    ["AUDIO_OpAnim"] =_gamePathPrefix.."effects/mahjong/audio_operate"; 
    ["AUDIO_Hu_Btn"] =_gamePathPrefix.."effects/mahjong/audio_hu_btn"; 
    ["AUDIO_Deal_Card"] =_gamePathPrefix.."effects/mahjong/audio_deal_card"; 
    ["AUDIO_Liu_Ju"] =_gamePathPrefix.."effects/mahjong/audio_liuju"; 
    ["AUDIO_GrapCard"] = _gamePathPrefix.."effects/mahjong/audio_get_card"; 
    ["AUDIO_DaPaiXing"] = _gamePathPrefix.."effects/mahjong/audio_dapaixing"; 
}

function MahjongEffectConfig.init(mjEffectMap, mjChatMap, mjOperateMap, prefix, majianziPrefix)
    prefix = prefix or _gamePathPrefix;
    majianziPrefix = majianziPrefix or "majiangzi/"
    MahjongEffectConfig.mjEffectMap = mjEffectMap;
    MahjongEffectConfig.mjOperateMap = mjOperateMap;

    --麻将读牌配置
    local w,m
    local wp = prefix .. "effects/woman/" .. majianziPrefix;
    local mp = prefix .. "effects/man/" .. majianziPrefix;

    local effectKeys = Copy(MahjongEffectConfig.effectKeys)
    local effectConfig = Copy(mahjongEffectConfig)
    for k, values in pairs(mjEffectMap) do
        for value, num in pairs(values) do
            for i = 1, num do
                w = string.format("w_%s_%d_%d", k, value, i);
                m = string.format("m_%s_%d_%d", k, value, i);
                effectKeys[w] = w;
                effectKeys[m] = m;
                effectConfig[w] = wp .. w;
                effectConfig[m] = mp .. m;
            end
        end
    end
    wp= prefix .. "effects/woman/";
    mp= prefix .. "effects/man/";
    --操作配置：吃碰杠胡...
    local ws,ms;
    for operate, num in pairs(mjOperateMap) do
        w = string.format("wAUDIO_%s_", string.upper(operate));
        m = string.format("mAUDIO_%s_", string.upper(operate));
        for i = 1, num do
            ws = w .. i;
            ms = m .. i;
            effectKeys[ws] = ws;
            effectKeys[ms] = ms;
            effectConfig[ws] = wp .. operate .. "_" .. i;
            effectConfig[ms] = mp .. operate .. "_" .. i;
        end
    end

    --聊天配置
    wp = prefix .. "effects/woman/chat/chat";
    mp = prefix .. "effects/man/chat/chat";
    local start = mjChatMap.start or 0;
    local count = mjChatMap.count or 0;
    for i = 1, count, 1 do
        w = "AudioChatString" .. i .. "W";
        m = "AudioChatString" .. i .. "M";
        effectKeys[w] = start+i*2-1;
        effectConfig[effectKeys[w]] = wp .. i;
        effectKeys[m] =  start+i*2;
        effectConfig[effectKeys[m]] = mp .. i;
    end

    return {
        music = musickKeys; musicFileMap = musicConfig;
        effects = effectKeys; effectsFileMap = effectConfig;
    };
end 

--用来生成操作音效配置表，供子游戏使用
--返回值为，{"AUDIO_KEY_1","AUDIO_KEY_2",...,"AUDIO_KEY_n"},n为key在表map中的值
function MahjongEffectConfig.createOpAudioMapByKey(map, key)
    local ret = {}
    if type(map) == "table" and type(key) == "string" and type(map[key]) == "number" then
        for i = 1, map[key] do
            ret[i] = "AUDIO_" .. string.upper(key) .. "_" .. i
        end
    end
    return ret
end

return MahjongEffectConfig;
