require("app.config.mahjongconfig")

MahjongConst = {}

-- 座位编号
local function init3Seat()
    MahjongConst.kSeatMine       = 1;
    MahjongConst.kSeatRight      = 2;
    MahjongConst.kSeatLeft       = 3;

    MahjongConst.kSeatTop        = 4;

    MahjongConst.SEAT_TBL = {
        MahjongConst.kSeatMine,
        MahjongConst.kSeatRight,
        MahjongConst.kSeatLeft,
    }
end

local function init4Seat()
    MahjongConst.kSeatMine       = 1;
    MahjongConst.kSeatRight      = 2;
    MahjongConst.kSeatTop        = 3;
    MahjongConst.kSeatLeft       = 4;

    MahjongConst.SEAT_TBL = {
        MahjongConst.kSeatMine,
        MahjongConst.kSeatRight,
        MahjongConst.kSeatTop,
        MahjongConst.kSeatLeft,
    }
end

local function init5Seat()
    MahjongConst.kSeatMine       = 1;
    MahjongConst.kSeatRight      = 2;
    MahjongConst.kSeatTopRight   = 3;
    MahjongConst.kSeatTopLeft    = 4;
    MahjongConst.kSeatLeft       = 5;

    MahjongConst.kSeatTop        = 6;

    MahjongConst.SEAT_TBL = {
        MahjongConst.kSeatMine,
        MahjongConst.kSeatRight,
        MahjongConst.kSeatTopRight,
        MahjongConst.kSeatTopLeft,
        MahjongConst.kSeatLeft,
    }
end

local function init6Seat()
    MahjongConst.kSeatMine       = 1;
    MahjongConst.kSeatRight      = 2;
    MahjongConst.kSeatTopRight   = 3;
    MahjongConst.kSeatTop        = 4;
    MahjongConst.kSeatTopLeft    = 5;
    MahjongConst.kSeatLeft       = 6;

    MahjongConst.SEAT_TBL = {
        MahjongConst.kSeatMine,
        MahjongConst.kSeatRight,
        MahjongConst.kSeatTopRight,
        MahjongConst.kSeatTop,
        MahjongConst.kSeatTopLeft,
        MahjongConst.kSeatLeft,
    }
end

---操作类型
MahjongConst.PASS               = 0x0000  -- 过
MahjongConst.RIGHT_CHOW         = 0x0001  -- 右吃
MahjongConst.MIDDLE_CHOW        = 0x0002  -- 中吃
MahjongConst.LEFT_CHOW          = 0x0004  -- 左吃
MahjongConst.PUNG               = 0x0008  -- 碰
MahjongConst.PUNG_KONG          = 0x0010  -- 碰杠
MahjongConst.AN_KONG            = 0x0200  -- 暗杠
MahjongConst.BU_KONG            = 0x0400  -- 补杠
MahjongConst.HU                 = 0x0040  -- 胡
MahjongConst.ZI_MO              = 0x0800  -- 自摸
MahjongConst.QIANG_GANG_HU      = 0x0080  -- 抢杠胡
MahjongConst.TING               = 0x1000  -- 听

MahjongConst.HU_PAI_TYPE = {
    HU = 1;
    ZIMO = 2;
}

-- 性别常量
MahjongConst.kSexMan = 1;
MahjongConst.kSexWomen = 2;
MahjongConst.kSexUnknow = 0;

-- 麻将类型
MahjongConst.kWanMahjongType = 0;
MahjongConst.kTongMahjongType = 1;
MahjongConst.kTiaoMahjongType = 2;

--癞子(听)牌颜色
MahjongConst.LAIZI_R = 255;
MahjongConst.LAIZI_G = 223;
MahjongConst.LAIZI_B = 108;

-- 必须胡的牌个数
MahjongConst.NumMustHu = 4;

MahjongConst.init = function ()
    if MahjongConst.m_init then return end
    local seat_num = MahjongConfig.playerNumer
    if seat_num == 3 then
        init3Seat()
    elseif seat_num == 4 then
        init4Seat()
    elseif seat_num == 5 then
        init5Seat()
    elseif seat_num == 6 then 
        init6Seat();
    end
end

MahjongConst.initSeatTb = function(value)
    local seats = {};
    local t = type(value);
    for _, v in pairs(MahjongConst.SEAT_TBL) do
        if t=="table" then
            seats[v] = table.copyTab(value);
        else
            seats[v] = value;
        end
    end
    return seats;
end

MahjongConst:init()

return MahjongConst;