local MahjongConst = require("app.config.mahjongconst")

MjGameConstant = {}

MjGameConstant.PAITYPE = {
    
}

MjGameConstant.TING_TYPE =
{
    NONE = 0;
    TING = 1;
    JIATING = 2;
};

MjGameConstant.TING = 0x1000          -- 听

--内部操作码
MjGameConstant.INTER_NOMARL_TING = 0x2000; --一般听
MjGameConstant.INTER_JIA_TING    = 0x4000; --夹听

return MjGameConstant