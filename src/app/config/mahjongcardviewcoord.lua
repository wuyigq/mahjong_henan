
-- import(_gamePathPrefix .. "mahjong/config/display");

local bgPath = ""
local imgPath = ""
local leftImgPath = ""
local rightImgPath = ""
local leftExtraImgPath = ""
local rightExtraImgPath = ""

MahjongCardViewCoord = {
	tingCardBg = bgPath .. "ting_card_bg.png",
	-- 吃碰杠牌的背景
	extraCardBg = {  -- 出牌动画 麻将子背景
		[1] = bgPath .. "my_extra_bg.png",
		[2] = bgPath .. "right_extra_bg_%d.png",
		[3] = bgPath .. "oppo_out_bg_1-%d.png",
		[4] = bgPath .. "left_extra_bg_%d.png",
	},
	-- 吃碰杠牌的麻将子
	extraCardImage = {
		[1] = imgPath .. "my_hand_%d_0x%02x.png",
		[2] = rightExtraImgPath .. "little_extra_right_%d_0x%02x.png",
		[3] = imgPath .. "little_%d_0x%02x.png",
		[4] = leftExtraImgPath .. "little_extra_left_%d_0x%02x.png",
	},
	-- 暗杠的麻将子（整个）
	extraAnGangImage = {
		[1] = bgPath .. "my_extra_an.png",
		[2] = bgPath .. "right_extra_an_%d.png",
		[3] = bgPath .. "oppo_extra_an_%d.png",
		[4] = bgPath .. "left_extra_an_%d.png",
	},
	-- 吃碰杠的牌 相对手牌位置的偏移量
	extraToHandDiff = {
		[1] = {x = 0, y = 0},
		[2] = {x = 0, y = 0},
		[3] = {x = 0, y = 20},
		[4] = {x = 20, y = 0},
	},
	-- 每个碰杠牌间隔的距离
	extraCardDiff = {
		[1] = { xDouble = 0.965, 	yDouble = 0, 		xGangDouble = 0, 		yGangDouble = -0.2},
		[2] = { xDouble = 0, 		yDouble = -0.53, 	xGangDouble = 0, 		yGangDouble = -0.3},
		[3] = { xDouble = -0.83, 	yDouble = 0, 		xGangDouble = 0.05, 	yGangDouble = -0.3},
		[4] = { xDouble = 0	, 		yDouble = 0.53, 	xGangDouble = 0, 		yGangDouble = -0.3},
	},
	extraCardGroupSpace = {
		[1] = {x = 20, y = 0},
		[2] = {x = 0, y = -8},
		[3] = {x = -10, y = 0},
		[4] = {x = -2, y = 8},
	},
	--碰杠牌的缩放比例
	extraCardScale = {
		[1] = 1.0,
		[2] = 1.0,
		[3] = 1.0,
		[4] = 1.0,
	},
	-- 手牌背景
	handCardBg = {
		[1] = bgPath .. "my_hand_bg.png", 
		[2] = bgPath .. "right_hand_1.png",
		[3] = bgPath .. "oppo_hand_1.png", 
		[4] = bgPath .. "left_hand_1.png", 
	},
	-- 手牌麻将子
	handCardImage = {
		[1] = imgPath .. "my_hand_%d_0x%02x.png",
		[2] = imgPath .. "little_%d_0x%02x.png", 
		[3] = imgPath .. "little_%d_0x%02x.png", 
		[4] = imgPath .. "little_%d_0x%02x.png", 
	},
	-- 手牌间隔比例
	handCardDiff = {
		[1] = { xDouble = 0.993, yDouble = 0 },
		[2] = { xDouble = -0.145, yDouble = -0.3 },
		[3] = { xDouble = -0.93, yDouble = 0 },
		[4] = { xDouble = -0.145, yDouble = 0.3 },
	},
	extraHandCardDiff = {
		[1] = { x = 0, y = 0 },
		[2] = { x = -6, y = -10 },
		[3] = { x = -10, y = 0 },
		[4] = { x = 0, y = 10 },
	},
	-- 手牌缩放比例
	handCardScale = {
		[1] = 0.97,
		[2] = 1.0,
		[3] = 1.0,
		[4] = 1.0,
	},
	-- 手牌和碰杠牌间隔
	handToExtraDiff = {
		[1] = { x = 10, y = 8 },
		[2] = { x = 0, y = -30 },
		[3] = { x = -10, y = 0 },
		[4] = { x = 0, y = -10 },
	},
	--盖牌麻将子（整个）
	gaiPaiFileName = {
		[1] = bgPath .. "my_extra_back.png",
		[2] = bgPath .. "l_r_gang.png",
		[3] = bgPath .. "oppo_extra_back.png",
		[4] = bgPath .. "l_r_gang.png",
	},
	-- 吃碰杠牌的起始位置（同时会在程序运行时根据座位重新自动计算某一坐标的值）
	extraCardStartPos = {
		[0] = { x = display.left, 	y = display.top }, 
		[1] = { x = display.left + 100, 	y = display.bottom - 60 }, 
		[2] = { x = display.right - 270, 	y = display.bottom - 150 }, 
		[3] = { x = display.right - 420, 	y = (display.top + 115) * display.y_scale },     
		[4] = { x = display.left + 80, 	y = display.top + 170 },    	
	},
	TingIconPos = {
		[1] = { x = display.cx, 			y = display.bottom - 120 },
		[2] = { x = display.right - 170, 	y = display.cy },
		[3] = { x = display.cx,	 			y = (display.top + 160) * display.y_scale },
		[4] = { x = display.left + 170, 	y = display.cy },
	},
	-- 吃碰杠牌起始偏移量
	extraCardStartDiff = {
		[1] = { x = 0, y = 0},
		[2] = { x = 0, y = 0},
		[3] = { x = 0, y = 0},
		[4] = { x = 0, y = -70},
	},
	-- 出牌起始位置（同时会在程序运行时根据座位重新自动计算某一坐标的值）
	outCardStartPos = {
		[1] = { x = display.cx, 			y = display.bottom - 180 }, 	
		[2] = { x = display.right - 330, 	y = display.cy - 10 }, 	
		[3] = { x = display.cx, 			y = (display.top + 178) * display.y_scale },	
		[4] = { x = display.left + 200, 	y = display.cy + 13 },	
	},
	-- 出牌背景
	outCardBg = {  -- 出牌动画 麻将子背景
		[1] = bgPath .. "my_out_bg_%d-%d.png",
		[2] = bgPath .. "right_out_bg_%d-%d.png",
		[3] = bgPath .. "oppo_out_bg_%d-%d.png",   -- 行- 个数
		[4] = bgPath .. "left_out_bg_%d-%d.png",
	},
	-- 出牌麻将子
	outCardImage = {
		[1] = imgPath .. "little_%d_0x%02x.png",
		[2] = rightImgPath .. "little_right_%d_0x%02x.png",
		[3] = imgPath .. "little_%d_0x%02x.png",
		[4] = leftImgPath .. "little_left_%d_0x%02x.png",
	},
	--重置手牌位置
	extraCardsDiffX2 = {95, 70, 40, 15, -10},
	extraCardsDiffX4 = {95, 70, 40, 15, -10},

	lineDiff = {
		{
			lineDiffX = {0, 3, 6},
			lineDiffY = {0, 0, 3},
		},
		{
			lineDiffX = {-1, 0, 0},
			lineDiffY = {0, 0, 0},
		},
		{
			lineDiffX = {-8, -3, 0},
			lineDiffY = {1, 1, 6},
		},
		{
			lineDiffX = {0, 0, -2},
			lineDiffY = {0, 0, 0},
		},
	},

	-- 出牌位移
	outCardDiff = {
		[1] = { xDouble = 0.85, yDouble = 0 },
		[2] = { xDouble = 0, yDouble = -0.52 },
		[3] = { xDouble = -0.88, yDouble = 0 },
		[4] = { xDouble = 0, yDouble = 0.52 },
	},
	-- 出牌换行位移
	outCardLineDiff = {
		[1] = { xDouble = 0, yDouble = -0.58 },
		[2] = { xDouble = -0.88, yDouble = 0 },
		[3] = { xDouble = 0, yDouble = 0.49 },
		[4] = { xDouble = 1.36, yDouble = 0 },
	},
	-- 出牌缩放
	outCardScale = {
		[1] = 1.0,
		[2] = 1.0,
		[3] = 1.0,
		[4] = 1.0,
	},
	outCardDiffY = 130,
	-- 每行出牌数目
	outCardLineNum = 10,
	-- 每行出牌增加的数目
	outCardLineStep = -2,
	-- 出牌大牌显示
	bigOutCardBg = bgPath .. "my_hand_bg.png",
	-- 出牌麻将子
	bigOutCardImg = imgPath .. "own_hand_0x%02x.png",
	-- 出牌大牌坐标
	bigOutCardPos = {
		[1] = { x = display.width / 2, 		y = display.cy + 100 },
		[2] = { x = display.width * 3 / 4, 	y = display.cy - 20 },
		[3] = { x = display.width / 2, 		y = display.cy - 150},
		[4] = { x = display.width / 4, 		y = display.cy - 20 },
	},
	-- 抓牌 位移
	addCardDiff = {
		[1] = { x = 20, y = 0 },
		[2] = { x = -7, y = -25 },
		[3] = { x = -15, y = 0 },
		[4] = { x = -5, y = 15 },
	},
	-- 手牌层
	handCardLayer = {
		[1] = 40,
		[2] = 1,
		[3] = 1,
		[4] = 2,
	},
	-- 吃碰杠牌 层
	extraCardLayer = {
		[1] = 1,
		[2] = 20,  -- 玩家二需要递减
		[3] = 1,
		[4] = 1,
	},
	-- 出牌层
	outCardLayer = {
		[1] = 30,
		[2] = 30,
		[3] = 30,
		[4] = 30,
	},
	--出牌动画层
	outCardAnimLayer = 22,
	-- 房间动画层
	aiLayer = 23,
	-- 出牌箭头偏移
	pointerDiff = {
		[1] =	25,
		[2] = 	15,
		[3] = 	25,
		[4] =   15,
	},
	cardAlign = {
		[1] = kAlignBottomLeft,
		[2] = kAlignTopLeft,
		[3] = kAlignTopLeft,
		[4] = kAlignTopLeft,
	},
	userPanelLayer  = {
		[1] = 4,
		[2] = 3,
		[3] = 2,
		[4] = 3,
	},
	tingCardLayer  = {
		[1] = 4,
		[2] = 3,
		[3] = 2,
		[4] = 3,
	},
------------------------------------------------------------------
	--牌背景
	cardBgDiffX = { 
		{
			{6, 8, 10, 10, 11, 12, 12, 13, 14, 15}, 
			{5, 6, 7, 8, 7, 8, 8, 10}, 
			{1, 4, 6, 8, 11, 13}, 
			{6, 9, 12, 15}, 
			{-8, -7}, 
		}, 
		{
			{2, 1, 0, -1, -2, -3, -4, -5, -6, -7}, 
			{-2, -3, -4, -5, -6, -7, -8, -9}, 
			{-6, -7, -8, -9, -10, -11}, 
			{-13, -15, -14, -14}, 
			{-33, -32}, 
		}, 
		{
			{-1, 2, 4, 6, 9, 12, 13, 16, 19, 20}, 
			{-2, -3, -4, -6, -8, -10, -12, -14}, 
			{-2, -3, -4, -5, -6, -7}, 
			{-2, -3, -4, -5, -6, -7}, 
			{-2, -2, -2, -2}, 
		}, 
		{
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{1, 1, 1, 1, 1, 1, 1, 1}, 
			{1, 1, 1, 1, 1, 1}, 
			{-10, -9, -8, -8}, 
			{-25, -24}, 
		}
	},
	cardBgDiffY = {
		{
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{4, 4, 4, 4, 4, 0, 0, 0, 0, 0}, 
			{4, 4, 4, 4, 4, 0, 0, 0, 0, 0}, 
		},
		{
			{-10, -13, -14, -16, -18, -20, -22, -24, -26, -28}, 
			{-10, -13, -14, -16, -18, -20, -22, -24}, 
			{-10, -13, -14, -16, -18, -20}, 
			{-10, -12, -13, -15}, 
			{-9, -13}, 
		},
		{
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{2, 2, 2, 2, 2, 2, 2, 2}, 
			{2, 2, 2, 2, 2, 2},
			{13, 13, 13, 13}, 
			{13, 13, 13, 13}, 
		},
		{
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
			{-10, -10, -10, -10, -10, -10, -10, -10}, 
			{-15, -15, -15, -15, -15, -15}, 
			{-17, -17, -17, -17}, 
			{-27, -26}, 
		}
	},

	--出牌层
	outCardDiffXTb = {
		{
			{-2, -1, -1, -1, 1, 0, -1, -1, -1, 1},
			{-1, -1, -1, -1, 1, 1, 1, 0},
			{-2, -1, 0, 0, 0, 0},
			{-1, -1, -1, -1},
			{-1, -1},
		},
		{
			--从右到左
			{32, 25, 16, 9, 5, -3, -10, -17, -24, -31},
			{23, 18, 13, 6, 0, -4, -13, -18},
			{15, 9, 3, -3, -8, -12},
			{12, 6, -1, -5},
			{12, 6},
		},
		{
			--从右到左
			{0, -1, 0, -1, -1, -1, 0, 0, 0, 0},
			{0, 0, 0, 1, 1, 0, 1, 2},
			{1, 1, 1, 1, 0, 0},
			{1, 2, 1, 1},
		},
		{
			--从右到左
			{35, 29, 22, 15, 7, -1, -8, -14, -22, -29},
			{24, 16, 11, 4, -2, -9, -15, -22, -26},
			{15, 9, 5, -3, -8, -14},
			{10, 5, 0, -4},
			{7, 3},
		}
	},
	outCardDiffYTb = {
		{
			{-16, -16, -16, -16, -16, -16, -16, -16, -16, -16},
			{-16, -16, -16, -16, -16, -16, -16, -16, -16, -16},
			{-17, -17, -17, -17, -17, -17, -17, -17, -17, -17},
			{-17, -17, -17, -17, -18, -18, -18, -18, -18, -18},
			{-17, -17, -17, -17, -18, -18, -18, -18, -18, -18},
		},
		{
			{-10, -10, -9, -9, -9, -9, -8, -8, -8, -7},
			{-10, -10, -9, -9, -9, -9, -8, -8, -8, -7},
			{-10, -10, -9, -8, -8, -8},
			{-10, -8, -8, -8},
			{-8, -8},
		},
		{
			{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7},
			{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7},
			{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7},
			{-7, -7, -7, -7},
		},
		{
			{-6, -8, -8, -8, -8, -9, -9, -9, -9, -9},
			{-8, -8, -8, -8, -8, -9, -9, -9, -9, -9},
			{-8, -8, -8, -8, -8, -9, -9, -9, -9, -9},
			{-8, -8, -8, -8, -8, -9, -9, -9, -9, -9},
			{-8, -8},
		}
	},

	-- 吃碰杠的牌坐标偏移  玩家 2 4 固定
	extraCardPosDiff = {
		{
			diffX = {},
			diffY = {},
		},
		{
			diffX = {},--0, -1, -2,  -5, -6, -6,  -7 -3, -9,   -10, -11, -12, -13, -15,  -16, -17
			diffY = {},
		},
		{				
			diffX = {-3, -3, -3,  -3, -3, -3,  -2, -2, -1,  -1, 0, 0,  0, 0, 0,  0,0},
			diffY = {},
		},
		{
			diffX = {},--13, 12, 10,  8, 6, 4,  2, 0, 0,  0, 0, 0,  -9, -15, 0,  
			diffY = {6,4,3, 2,1},
		},
	},

	-- 吃碰杠的牌坐标偏移  玩家 2 4 固定
	extraHuCardDiff3 = {
		diffX = {0, 0, 0,  0, 0, 0,  -1, -1, 0,  0, 1, 1,  1, 1, 1,  1,1},
		diffY = {0,0,0,0,0,0,-0.5,-0.5},
	},

	extraHuaDiffXTb = {
		{
			1, 2, 3, 3, 4, 4, -2, -1, -1, -1, -1,-1,-1,-1,-1,
		},
		{--从右到左
			
			47, 39, 33,    24, 17, 9,    -1, -8, -15,     -24, -30, -38,   -45, -51
		},
		{
			1, 0, -1,  0, 0, -1,  0, 1, 0,  1, 1, 1, 0, 0,
		},
		{
			51, 44, 38,    30, 24, 17,    10, 1, -8,     -15, -23, -32,   -40, -46
		}
	},
	extraHuaDiffYTb ={
		{
			-14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14,-14,-14,-14,-14,
		},
		{
			-9,-9,-9, -9,-9,-8, -8,-7,-7, -7,-6,-6, -6,-6, 
		},
		{
			-10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
		},
		{
			-6,-5,-5, -5,-8,-8, -7,-7,-8, -8,-8,-8, -9,-11
		}
	},

}

return MahjongCardViewCoord