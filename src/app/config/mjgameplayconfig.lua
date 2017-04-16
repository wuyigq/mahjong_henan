--配置不同玩法之间的一些属性或显示方式

local PlayConfig = class("PlayConfig");

function PlayConfig:ctor()
end

-- Singleton(PlayConfig, "kPlayConfig");

--是否暗杠牌全部背面朝上
function PlayConfig:isAnGangAllUpSideDown()
    return PlayConfig.s_map.AngangShowStyle=="all_back";
end

--是否胡牌后需要铺倒手牌
function PlayConfig:isInhandPushDown()
    return PlayConfig.s_map.InhandStyleAfterHu=="push_down";
end

--是否杠牌后从牌堆中补牌
function PlayConfig:isCardFromGrabsAfterGang()
    return PlayConfig.s_map.GrabCardAfterGang=="from_grabs";
end

--个人信息界面是否显示平局
function PlayConfig:isShowTimerDirection()
    return true;
end

--最后几张牌是必胡的，nil表示没有这个设定
function PlayConfig:numMustHu()
    return PlayConfig.s_map.NumMustHu;
end

PlayConfig.s_map =
{
    AngangShowStyle     = "one_up";                     --暗杠的显示方式：all_back全部背面;one_up一个朝上
    InhandStyleAfterHu  = "push_down";               --胡牌后手牌显示方式：push_down推到;stand_up站起
    GrabCardAfterGang   = "from_grabs";               --杠牌后补牌方式:from_grabs从要抓的牌堆里:from_adds从额外的牌堆里
    IsShowDraw          = true;                               --个人信息界面是否显示平局
    NumMustHu           = 3;
}

return PlayConfig;