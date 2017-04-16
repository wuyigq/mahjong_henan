-- require("atomAnim/drawingEx")
-- import(_gamePathPrefix .. "mahjong/pin_map/card_pin")
-- import(_gamePathPrefix .. "mahjong/pin_map/card_word_pin")
-- local room_pin_map = require(_gamePathPrefix .. "mahjong/pin_map/room_pin")

local CardImage;

local Card = class("Card", function()
	return display.newNode();
end)

--设置是否可点击
Card.TOUCH_TYPE = {
	NONE 		= 0;  	--不能点击
	CAN_TOUCH 	= 1; 	--能点击
	CAN_DRAG 	= 2;  	--能拖动
}

function Card:ctor(value, bgImage, _, index, seat, type)
	self.bgPath = ""
	self.m_value = value or 0
	self.m_bgFile = bgImage
	self.m_index = index or 1
	self.m_type = type
	self.m_seat = seat
	self.m_bgCard = new(CardImage, "#" .. bgImage)
		:addTo(self)

	if self.m_value > 0 then
        local cardFile = self:getCardPathByValueAndIndex(seat, self.m_value, self.m_index, type)
        if cardFile == nil then 
             print("cardFile is error:", seat, value, index, type)
        else
            self.m_card = self:createImgCard(cardFile)
        end
	end
	self.m_scale = 1.0
	self.m_alive = true;
	self:setTouchType(Card.TOUCH_TYPE.CAN_TOUCH);
	
	self.m_isTingYong = false
	self:colorTiYong()
end

function Card:setBgAlign(align)
	if self.m_bgCard then
		self.m_bgCard:setAlign(align)
	end
	self.m_bgAlign = align
	return self
end

function Card:addTouchEvent(obj, func)
	if self.m_bgCard then
		self.m_bgCard:setEventTouch(obj, func)
	end
end

function Card:getCardImage()
	return self.m_card
end

function Card:getDrawingId()
	return self.m_bgCard and self.m_bgCard.m_drawingID
end

local function containsPoint(rect, p)
	return p.x >= rect.x and p.x <= rect.x + rect.width 
		and p.y >= rect.y and p.y <= rect.y + rect.height
end

local function ccrect(x, y, width, height)
	return {x=x, y=y, width=width, height=height}
end

function Card:containsPoint(x, y)
	local tx, ty = self:getPos()
	local width, height = self:getOriginSize()
	local rect
	local bottomDiffY = self.m_isUp and 15 - 40 or 15
	if self.m_bgAlign == kAlignBottomLeft then
		rect = ccrect(tx, ty - height, width, height - bottomDiffY)
	elseif self.m_bgAlign == kAlignBottom then
		rect = ccrect(tx - width / 2, ty - height, width, height - bottomDiffY)
	elseif self.m_bgAlign == kAlignTopLeft then
		rect = ccrect(tx, ty, width, height - bottomDiffY)
	elseif self.m_bgAlign == kAlignTop then
		rect = ccrect(tx - width / 2, ty, width, height - bottomDiffY)
	elseif self.m_bgAlign == kAlignCenter then
		rect = ccrect(tx - width / 2, ty - height / 2, width, height - bottomDiffY)
	else
		rect = ccrect(tx, ty, width, height - bottomDiffY)
	end
	return containsPoint(rect, {x=x, y=y})
end

function Card:setOriginPos(x, y)
	self.m_originX = x
	self.m_originY = y
	self:pos(x, y)
	return self
end

function Card:saveDstPos(x, y)
	self.m_savePosX = x
	self.m_savePosY = y
end

function Card:isPosChanged()
	local x, y = self:getPos()
	return self.m_savePosX ~= x or self.m_savePosY ~= y
end

function Card:getDstPos()
	return {x = self.m_savePosX, y = self.m_savePosY}
end

function Card:getValue()
	return self.m_value
end

function Card:setValue(value)
	self.m_value = value
	return self
end

function Card:getCardIndex()
	return bit.brshift(self.m_value or 0, 4), bit.band(self.m_value or 0, 0x0F)
end

function Card:getOriginPos()
	return self.m_originX, self.m_originY
end

--缩放花色
function Card:scaleCardTo(scaleWidth, scaleHeight)
	if self.m_card then
		local width, height = self.m_card:getOriginSize()
		width = width * (scaleWidth or 1)
		height = height * (scaleHeight or 1) 
		self.m_card:setContentSize(width, height)
	end
	return self
end

-- 缩放背景
function Card:scaleBgTo(scaleWidth, scaleHeight)
	if self.m_bgCard then
		local width, height = self.m_bgCard:getOriginSize()
		width = width * (scaleWidth or 1)
		height = height * (scaleHeight or 1) 
		self.m_bgCard:setContentSize(width, height)
	end
	if self.laiziAnimImage then
		local width, height = self.laiziAnimImage:getOriginSize()
		width = width * (scaleWidth or 1)
		height = height * (scaleHeight or 1) 
		self.laiziAnimImage:setContentSize(width, height)
	end
	if self.laiziAnimBg then
		local width, height = self.laiziAnimBg:getOriginSize()
		width = width * (scaleWidth or 1)
		height = height * (scaleHeight or 1) 
		self.laiziAnimBg:setContentSize(width, height)
	end
	return self
end

function Card:setScale(scale)
	self.m_scale = scale
	self:scaleBgTo(scale, scale)
	self:scaleCardTo(scale, scale)
	return self
end

function Card:setOriginScale(bgScale, cardScale)
	self.m_originBgScale = bgScale
	self.m_originCardScale = cardScale
end

function Card:getOriginSize()
	local size = self.m_bgCard:getContentSize()
	return size.width, size.height
end

-- 获取bgCard的size
function Card:getSize()
	local size = self.m_bgCard:getContentSize()
	return size.width, size.height
	-- return self.m_bgCard:getContentSize()
end

-- 用于相对初始位置做平移
function Card:selectCardUpDiff(diffX, diffY)
	local width, height = self:getOriginSize()
	local x, y = self:getOriginPos()
	y = y - 40
	self:pos(x + diffX, y + diffY);
	return self
end

function Card:shiftMove(diffX, diffY)
	local x, y = self:getPosition()
	self:pos(x + diffX, y + diffY)
	return self
end

function Card:move(diffX, diffY)
	local x, y = self:getOriginPos()
	self:pos(x + diffX, y + diffY)
	return self
end

function Card:savePos()
	self.lastPosX = self.m_originX
	self.lastPosY = self.m_originY
	return self
end

function Card:getSavePos()
	return self.lastPosX, self.lastPosY
end

function Card:createImgCard(cardFile)
	local img = new(CardImage, cardFile)
		:addTo(self.m_bgCard)
	img:setAlign(kAlignCenter)
	return img;
end

-------------------------------------------------------------
------------------操作动画所有 start-------------------------
function Card:hideDesign()
    if self.m_card then
       self.m_card:setVisible(false);
    end	
end

function Card:showDesign()
    if self.m_card then
       self.m_card:setVisible(true);
    end	
end	

function Card:durationShowDesin(duration)
	local function m_showDesign()
        self:showDesign()
        delete(self.m_timer)
	end
	self.m_timer = new(AnimInt,kAnimNormal,0, 1,duration,-1);
	self.m_timer:setDebugName("Card || m_timer");
	self.m_timer:setEvent(self,m_showDesign);
end	

------------------操作动画所有 end-------------------------
-----------------------------------------------------------
function Card:resetImageByValueAndType(value, _, bgFile, seat)
	self.m_isGaiPai = false
	value = value or 0
	if bgFile then
		self.m_bgFile = bgFile
		self.m_bgCard:setFile(self.bgPath .. bgFile)
		self.m_bgCard:setContentSize(self.m_bgCard:getResSize())
		self.m_bgCard:setVisible(true)
	end
	if value > 0 then
		-- 不被花牌覆盖
		if value < 0x50 then self.m_value = value end
		self:resetImageCard(self:getCardPathByValueAndIndex(seat, value, self.m_index, self.m_type))
	end
	if MahjongBaseData.getInstance():isTingYong(self.m_value) and self.m_value~=0 then
		self.m_bgCard:setColor(MahjongConst.LAIZI_R, MahjongConst.LAIZI_G, MahjongConst.LAIZI_B)
		self.m_isTingYong = true
	else
		self.m_bgCard:setColor(255, 255, 255)
		self.m_isTingYong = false
	end
	return self
end

function Card:resetImageCard(imgFile)
	if not self.m_card then
		self.m_card = self:createImgCard(imgFile)
	else
		self.m_card:setFile(imgFile)
	end
	self.m_card:setVisible(true)
end

function Card:setRotation(rotation)
	if self.m_card then
		if not self.m_card:checkAddProp(123) then
			self.m_card:removeProp(123)
		end
		self.m_card:addPropRotateSolid(123, rotation, kCenterXY)
	end
	return self
end

function Card:shiftCardMove(x, y)
	if self.m_card then
		self.m_card:setPosition(x, y)
	end
	return self
end

function Card:getImgPos()
	if self.m_card then
		return self.m_card:getAbsolutePos()
	end
	return 0, 0
end

function Card:getImgSize()
	if self.m_card then
		return self.m_card:getContentSize()
	end
	return 0, 0
end

-- 还原位置
function Card:resetPos(animFlag, time, callback)
	self:pos(self.m_originY + (self.m_isUp and 40 or 0), self.m_originY)
	return self
end

function Card:setUp(noScale)
	self.m_isUp = true
	local width, height = self:getOriginSize()
	local diffX = 0
	self:pos(self.m_originX, self.m_originY - 40)
	self:setLevel(MahjongCardViewCoord.handCardLayer[1] + 1)
	if not noScale then
		self:setScale(1.10)
		diffX = width - self:getOriginSize()
	end
	return -diffX
end

-- 只有自己才会用
function Card:gaiPai(fileName)
	self.m_bgCard:setFile(self.bgPath .. fileName)
	self.isGaiPai = true
	if self.m_card then
		self.m_card:setVisible(false)
	end
end

function Card:gaiPaiOver()
	self.m_bgCard:setFile(self.bgPath .. self.m_bgFile)
	if self.m_card then
		self.m_card:setVisible(true)
	end
end

function Card:setDown()
	self.m_isUp = false
	self.m_scale = scale
	self:scaleBgTo(self.m_originBgScale, self.m_originBgScale)
	self:scaleCardTo(self.m_originCardScale, self.m_originCardScale)
	self:pos(self.m_originX, self.m_originY)
	self:setLevel(MahjongCardViewCoord.handCardLayer[1])
	if self.m_tingtipIcon then
		self.m_tingtipIcon:setVisible(true)
	end
end

function Card:isUp()
	return self.m_isUp
end

-- 设置该牌已经被出了
function Card:setOuted(flag)
	self.m_outed = flag;
end

function Card:setTingInfo(tingInfo)
	self.m_tingInfo = tingInfo
end

function Card:getTingInfo()
	return self.m_tingInfo
end

function Card:isOuted()
	return self.m_outed;
end

function Card:setLightColor()
	self:setColor({255,255,255});
end

function Card:setTingTipIcon()
	if not self.m_tingtipIcon then
		self.m_tingtipIcon = new(CardImage, "#ting_tip.png")
			:addTo(self.m_bgCard)
	end
	self.m_tingtipIcon:setVisible(true)
	self.m_tingtipIcon:setAlign(kAlignCenter)
	self.m_tingtipIcon:pos(0, -120)
end

function Card:clearTingTipIcon()
	if self.m_tingtipIcon then
		delete(self.m_tingtipIcon)
		self.m_tingtipIcon = nil
	end
end

function Card:setDarkColor()
	self:setColor({128, 128, 128});
end

function Card:setColor(c)
	if not self.m_isTingYong then
		self.m_bgCard:setColor(c[1], c[2], c[3]);
	end
end

function Card:addTo1(parent, level)
	self.addTo(self, parent)
	if level then self:setLevel(level) end
	return self
end

function Card:pos(x, y)
	self:setPosition(x, y)
	return self
end

function Card:align(align, x, y)
	self:setAlign(align)
	if x and y then
		self:pos(x, y)
	end
	return self
end

function Card:hide()
	self:setVisible(false)
end

function Card:show()
	self:setVisible(true)
end

function Card:removeSelf()
	local parent = self:getParent()
	if parent then
		return parent:removeChild(self, true)
	else
		delete(self)
	end
end

function Card:alive()
	return self.m_alive
end

function Card:dtor(x, y)
	self.m_alive = false
end

function Card:setEventTouch(...)
	-- self.m_bgCard:setEventTouch(...)
end

function Card:checkTouchID(id)
	return id==self.m_bgCard.m_drawingID
end

function Card:setTouchType(touchType)
	self.m_touchType = touchType;
end

function Card:getTouchType()
	return self.m_touchType;
end

--for resorting
function Card:getSequence()
	return self.m_sequence
end

function Card:setSequence(seq)
	self.m_sequence = seq
	return self
end

function Card:colorTiYong()
	if MahjongBaseData.getInstance():isTingYong(self.m_value) and self.m_value ~= 0 then
		self.m_bgCard:setColor(MahjongConst.LAIZI_R, MahjongConst.LAIZI_G, MahjongConst.LAIZI_B)
		self.m_isTingYong = true
	end
end
function Card:backColorTiYong()
    if MahjongBaseData.getInstance():isTingYong(self.m_value) and self.m_value ~= 0 then
		self.m_bgCard:setColor(255, 255, 255);
		self.m_isTingYong = false
	end
end
function Card:clone()
	local card = new(Card, self.m_value, self.m_bgFile, _, self.m_index)
				:pos(self:getPos())
				:setBgAlign(self.m_bgAlign)

	card.m_card:pos(self.m_card:getPos())
	card.m_card:setContentSize(self.m_card:getContentSize())

	return card
end

function Card:getCardPathByValueAndIndex(seat, value, index, type)
	local ret = nil
	if value < 42 then
		local typeMap = {"W", "O", "T"}
		local t = math.floor(value/16)
		local n = math.mod(value, 16)
		if seat == MahjongConst.kSeatMine then
			if type == "out" then
				ret = n .. typeMap[t+1] .. "_" .. index .. ".png"
			else
				ret = string.format("my_hand_1_0x%02x.png", value)
			end
		elseif seat == 3 then
			if type == "out" then
				index = index+2
			end
			ret = typeMap[t+1] .. n .. "_" .. index .. ".png"
		else
			local prefix = seat == 2 and "left_" or "right_"
			local tt = string.lower(typeMap[t+1] or "")
			ret = prefix .. tt .. "_" .. n .. ".png"
		end
		-- return card_word_pin_map[ret]
		return "#" .. ret
	else
		if seat == MahjongConst.kSeatMine then
			if type == "out" then
				ret = string.format("m_0x%02x_%d.png", value,index)
			else
				ret = string.format("my_hand_1_0x%02x.png", value)
			end
		elseif seat == 4 then
			ret = string.format("left_0x%02x.png",value);
		elseif seat == 2 then
			ret = string.format("right_0x%02x.png",value);
		else
			if type == "out" then
				index = index+2
			end
			ret = string.format("op_0x%02x_%d.png",value,index);
		end
		return "#" .. ret
	end
end

---------------------------------------
CardImage = class("CardImage", function(file)
	return display.newSprite(file)
end)

function CardImage:ctor()
	self.m_originWidth = self.m_width
	self.m_originHeight = self.m_height
end

function CardImage:getOriginSize()
	return self.m_originWidth or 1, self.m_originHeight or 1
end

function CardImage:setColor(r, g, b)
	self.super.setColor(self, cc.c3b(r, g, b))
end

function CardImage:setFile(file)
	self:setSpriteFrame(file)
end
-- CardImage.addPropTranslateEase = DrawingBase.addAtomPropTranslateEase
return Card