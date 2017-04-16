
require("app.adapter.object")
require("app.adapter.anim")

display.c_left             = -display.width / 2
display.c_right            = display.width / 2
display.c_top              = -display.height / 2
display.c_bottom           = display.height / 2
display.y_scale 		   = display.height / 720

_gamePathPrefix = ""
MahjongPathPrefix = ""

--config
require("app.config.mahjongconst");
require("app.config.mjgameconstant");
require("app.config.mjgameplayconfig");
require("app.config.mahjongreportconfig");
require("app.config.mahjongeffectconfig");
require("app.config.mahjongcardviewcoord");

--data
require("app.data.mahjongbasedata");
require("app.data.mahjonghutypedata");
require("app.data.mahjongliushuidata");
-- require("app.data.mahjongroombgdata");
require("app.data.mjgameoverdataparse");
