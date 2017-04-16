
MahjongReportConfig = {}
local gameid = ""--GameInfoIsolater.getInstance():getCurGameId() or ""
local regionid = ""--ClientInfoIsolater.getInstance():getRegionId() or ""
local prefix = "ID(" .. gameid .. ")_R(" .. regionid .. ")_"

MahjongReportConfig.kReadyBtnClick             = prefix .. "0001"       --开始时点击[准备]次数
MahjongReportConfig.kChangeTableBtnClick       = prefix .. "0002"       --开始时点击[换桌]次数  
MahjongReportConfig.kOverChangeTableBtnClick   = prefix .. "0003"       --结束时点击[换桌] 次数
MahjongReportConfig.kOverShareBtnClick         = prefix .. "0004"       --结束时点击[分享]次数  
MahjongReportConfig.kOverPlayAgainBtnClick     = prefix .. "0005"       --结束时点击[再来一局]次数 
MahjongReportConfig.kOverDetailBtnClick        = prefix .. "0006"       --提前胡牌点击[详情]次数
MahjongReportConfig.kOverStreamBtnClick        = prefix .. "0007"       --牌局结束点击[金币流水]次数  
MahjongReportConfig.kOverOtherBtnClick         = prefix .. "0008"       --牌局结束点击[牌友结算]次数  
MahjongReportConfig.kPengBtnClick              = prefix .. "0009"       --点击“碰”次数  
MahjongReportConfig.kGangBtnClick              = prefix .. "0010"       --点击“杠”次数
MahjongReportConfig.kCancleBtnClick            = prefix .. "0011"       --点击“取消”次数
MahjongReportConfig.kDetailChangeTableBtnClick = prefix .. "0012"       --提前胡牌点击[换桌]次数
MahjongReportConfig.kStreamBtnClick            = prefix .. "0013"       --点击“对局流水”次数
MahjongReportConfig.kRequireBtnClick           = prefix .. "0014"       --点击“胡牌查询”次数

return MahjongReportConfig
