-- local MahjongViewBase = import(_gamePathPrefix .. "mahjong/module/mahjongviewbase")
local Card = import("app.room.card.card")
local CardUtils = import("app.room.card.cardutils")

local CardView = class("CardView", function()
	local node = display.newNode();
	return node;
end)

CardView.Delegate = {
	colorCards 			= "colorCards";
}

function CardView:ctor(seat)
	if not seat then
		self.m_extraCardStartPos = MahjongCardViewCoord.extraCardStartPos[0]
	else
		self.m_extraCardStartPos 	= MahjongCardViewCoord.extraCardStartPos[seat]
	end
	seat = seat or MahjongConst.kSeatMine
	self.m_seat = seat

	local level = MahjongCardViewCoord.userPanelLayer[seat];
	self:setLevel(level)

	self.m_cardsVector = {}				--手上的牌
	self.m_outCardsVector = {}			--打出去的牌
	self.m_extraCardsVector = {}		--吃、碰、杠的牌
    self.m_myOutCards = {}
    self.m_beforeOutCards = {}  --上个玩家的

	self.m_cardAlign            = MahjongCardViewCoord.cardAlign[seat]
	self.m_gaiPaiFileName 		= MahjongCardViewCoord.gaiPaiFileName[seat]
	self.m_handCardBgFile 		= MahjongCardViewCoord.handCardBg[seat]
	self.m_handCardImgFileReg 	= MahjongCardViewCoord.handCardImage[seat]
	self.m_handCardDiff 		= MahjongCardViewCoord.handCardDiff[seat]
	self.m_handToExtraDiff 		= MahjongCardViewCoord.handToExtraDiff[seat]
	self.m_handCardScale  		= MahjongCardViewCoord.handCardScale[seat]
	self.m_extraHandCardDiff    = MahjongCardViewCoord.extraHandCardDiff[seat]
	-- 出牌配置
	self.m_outCardLine 			= 1
	self.m_outCardBgFile 		= MahjongCardViewCoord.outCardBg[seat]
	self.m_outCardImgFileReg 	= MahjongCardViewCoord.outCardImage[seat]
	self.m_outCardDiff 			= MahjongCardViewCoord.outCardDiff[seat]
	self.m_outCardScale 		= MahjongCardViewCoord.outCardScale[seat]

	self.m_bigOutCardBgFile 	= MahjongCardViewCoord.bigOutCardBg
	self.m_bigOutCardImgFileReg = MahjongCardViewCoord.bigOutCardImg

	self.m_extraCardBgFile 		= MahjongCardViewCoord.extraCardBg[seat]
	self.m_extraCardImgFileReg 	= MahjongCardViewCoord.extraCardImage[seat]
	self.m_extraCardDiff 		= MahjongCardViewCoord.extraCardDiff[seat]
	self.m_extraCardScale		= MahjongCardViewCoord.extraCardScale[seat]
	self.m_extraAnGangImageFile = MahjongCardViewCoord.extraAnGangImage[seat]
	self.m_extraCardGroupSpace  = MahjongCardViewCoord.extraCardGroupSpace[seat]
	self.m_extraToHandDiff 		= MahjongCardViewCoord.extraToHandDiff[seat]

	self.m_pointerDiff 			= MahjongCardViewCoord.pointerDiff[seat]
	self.m_bigOutCardPos 		= MahjongCardViewCoord.bigOutCardPos[seat]
	self.m_addCardDiff 			= MahjongCardViewCoord.addCardDiff[seat]

	self.m_outBigCard 			= nil

	self:clearTableForGame()

	self.s_operateMap = {
		self.dealCustomOperateCard;
		self.dealChiPengOperateCard;
		self.dealGangOperateCard;
		self.dealHuPaiOperateCard;
	}

	--test
	self:onDealCardBd(self.m_seat, nil, {1,1,1,1,2,2,2,2,3,3,3,3,4,4})
end

function CardView:playOutOneCard(index, value)
	local isTing = (self.m_isTing=="Doing") and 1 or 0
	local data = {card = value, isTing = isTing}
    MahjongBaseData.getInstance():send(MahjongCmd.RQ_OUT_CARD, data)
end

function CardView:clearTableForGame(seat, uid, info, isFast, isReconn)
	self.m_handCards 	= {}
	self.m_outCards 	= {}
	self.m_extraCards 	= {}
    self.m_myOutCards = {}
    self.m_beforeOutCards = {}  

	self:resetOutCardPosAndLayer()
	self:resetExtraCardPosAndLayer()
	self:resetHandCardPosAndLayer()

	self:clearHandCards()
	self:clearOutCards()
	self:clearExtraCards()

	self.m_lastOutHandCard = nil --最后出的手牌
	self.lastOutCard = nil       --最后显示在出牌栏的那张牌
	
	self.isDealCard = false
	self.m_isHu 	= false
	self.m_isTing = nil
	self.m_isAi = false
	self:setPickable(true)

	-- self:updateMineCards()
end

function CardView:onDealCardBd(seat, uid, info, isFast)
	self:clearHandCards()
	self:resetHandCardPosAndLayer()
	if seat == MahjongConst.kSeatMine then
		self.m_handCards = info
        self.m_disorder = clone( info )
        table.sort( self.m_handCards )
	else
        self.m_handCards = {}
        self.m_disorder = {}
        for i, v in pairs(info) do
            self.m_handCards[i] = 0
            self.m_disorder[i] = 0
        end
	end
	self:enableSelect(false)

    self.dealIndex = 1
    self:clearDealCardAnim()
    self:dealCardStep();
    self.dealCardAnim = new(AnimInt, kAnimRepeat, 0, 8, 300, -1)
    self.dealCardAnim:setDebugName("CardView.dealCardAnim")
    self.dealCardAnim:setEvent(self, self.dealCardStep)
end

function CardView:dealCardStep( )
    local max = MahjongConfig.HAND_CARD_NUM
    local endIndex = math.min(max, self.dealIndex+3)
    self:onDealCardStep(self.dealIndex, endIndex)
    if max <= endIndex then
        self:finishDealCardAnim()
    end
    self.dealIndex = self.dealIndex + 4
end

function CardView:finishDealCardAnim( )
    self:clearDealCardAnim()
    self:onDealCardOver(true)
end

function CardView:clearDealCardAnim( )
	if self.dealCardAnim then
	    delete(self.dealCardAnim);
	    self.dealCardAnim = nil;
	end
end

function CardView:onDealCardStep(cardIndexStart, cardIndexEnd)
	if cardIndexStart > MahjongConfig.HAND_CARD_NUM + 1 then
		return
	elseif cardIndexEnd > MahjongConfig.HAND_CARD_NUM + 1 then
		cardIndexEnd = MahjongConfig.HAND_CARD_NUM + 1
	end
	if self.m_seat ~= MahjongConst.kSeatMine then
		for i=cardIndexStart, cardIndexEnd do
			self:createOneHandCard(self.m_disorder[i], nil, i);
		end 
	else
		local cardAnimTb = {};
		for i=cardIndexStart, cardIndexEnd do
			local card = self:createOneHandCard(self.m_disorder[i], nil, i)
			if card then
				table.insert(cardAnimTb, card);
			end
		end 
		local startY = -80;
		for k,v in pairs(cardAnimTb) do
			-- local anim = v:addPropTranslate(0, kAnimNormal, 200, 0, 0, 0, startY, 0);
			-- anim:setDebugName("CardView.onDealCardStep")
			-- anim:setEvent(nil, function()
			-- 	v:removeProp(0)
			-- end)
			transition.moveBy(v, {x = 0;
				y = startY;
				time = 200;
				-- easing = "SINEIN";
				onComplete = function ()
					transition.stopTarget(v)
				end
			});

		end
	end
end

--发牌结束后
function CardView:sortByValue(hands)
    table.sort(hands)
    local ret = {}
    for i = 1, #hands do
        if MahjongBaseData.getInstance():isTingYong(hands[i]) then
            ret[1+#ret] = hands[i]
        end
    end
    for i = 1, #hands do
        if not MahjongBaseData.getInstance():isTingYong(hands[i]) then
            ret[1+#ret] = hands[i]
        end
    end
    return ret
end

-- 发牌结束
-- isNormal true 正常动画时间内结束 false 被抓牌中断
function CardView:onDealCardOver(isNormal)
	-- 动画
	if self.m_seat == MahjongConst.kSeatMine then
		self:enableSelect(false)
		if isNormal then
			for i,v in ipairs(self.m_cardsVector) do
				v:gaiPai(self.m_extraAnGangImageFile)
			end
			kEffectPlayer:play(MahjongEffectConfig.effectKeys.AUDIO_Deal_Card);
			delete(self.m_gaiPaiAnim)
			self.m_gaiPaiAnim = self:performWithDelay(function()
				self:onGaiPaiOver(isNormal)
			end, 600)
		else  --异常结束
			self:onGaiPaiOver(isNormal)
		end
	elseif not isNormal then
		self:onGaiPaiOver(isNormal)
	end
end

-- isNormal 是否正常结束
function CardView:onGaiPaiOver(isNormal)
	if self.m_gaiPaiAnim then
		delete(self.m_gaiPaiAnim)
		self.m_gaiPaiAnim = nil
	end
	self:reDrawHandCards(self.m_handCards)
	self:freshHandCardsPos(self.m_seat == MahjongConst.kSeatMine)
	if isNormal then
		kEffectPlayer:play(MahjongEffectConfig.effectKeys.AUDIO_Deal_Card);
	end

	self:updateMineCards()
end

function CardView:enableSelect(flag)
	self.m_selectFlag = flag
end

function CardView:setCanOut(flag)
	self.m_outFlag = flag
end

--广播出牌
function CardView:onOutCard(seat, uid, info, isFast)
	self:dealServerOutCard(info.card)
	-- 清除听牌tip图标
	self:clearTingTipIcon()
	self:updateMineCards()
end

--发牌动画期间卡顿，导致摸牌后出不了牌
--所以摸牌后先强制停止发牌动画
function CardView:checkDealCardAnim()
    if self.dealCardAnim or self.m_gaiPaiAnim then
        self:finishDealCardAnim()
        self:onGaiPaiOver(false)
    end
end

function CardView:onAddCard(seat, uid, info, isFast)
    self:checkDealCardAnim()
	local cardValue = info.card
	self.m_outFlag = true
	table.insert(self.m_handCards, cardValue)
	self:freshHandCardsPos(false)
	self:addCardView(cardValue, {})
    self:enableSelect(true)
	if info.operateValue and MahjongBaseData.getInstance():getForceHu() and 
		MahjongHelpFunc.getInstance():operatorValueHasHu(info.operateValue) then 
    	self:enableSelect(false)
    end 

    self:updateMineCards()

    self:checkForceHuByTingYong()
end

function CardView:checkForceHuByTingYong()
	if m_seat == MahjongConst.kSeatMine then 
	    if #self.m_cardsVector > 4 then
	        MahjongBaseData.getInstance():setForceHu(false)
	        return false
	    else
	        for _, card in ipairs(self.m_cardsVector) do
	            if not MahjongBaseData.getInstance():isTingYong(card.m_value) then
	                MahjongBaseData.getInstance():setForceHu(false)
	                return false
	            end
	        end
	        MahjongBaseData.getInstance():setForceHu(true)
	        return true
	    end
	end
end 

function CardView:onAddCardForFenZhang(cardValue)
	table.insert(self.m_handCards, cardValue)
	self:freshHandCardsPos(false)
	self:addCardView(cardValue, {})
	self.m_outFlag = false
    self:enableSelect(false)

    self:updateMineCards()
end 

--听牌、报叫、明牌后自动出牌
--如果不需要客户端自动出牌需要继承并修改这个函数
function CardView:autoOutCard()
    delete(self.animAuto)
	if self.m_seat ~= MahjongConst.kSeatMine or self.m_isAi or not self:isTingPai() then
		return
	end
    self.animAuto = new(AnimInt, kAnimNormal, 0, 1, 500, -1)
    self.animAuto:setDebugName("CardView:autoOutCard")
    self.animAuto:setEvent(nil, function()
    	if not self.m_isAi then
			local idx = #self.m_cardsVector
			self:dealLocalOutCard(self.m_cardsVector[idx], idx)
		end
        delete(self.animAuto)
        self.animAuto = nil
    end)
end

function CardView:updateMineCards()
    if self.m_seat == MahjongConst.kSeatMine then
        local hands = {}
        for _, v in pairs(self.m_cardsVector) do
            if not v:isOuted() then
                table.insert(hands, v:getValue())
            end
        end
        local extras = {}
        for _, v in pairs(self.m_extraCardsVector) do
            table.insert(extras, v)
        end
        CardUtils:setMineCards(hands, extras)
    end
end

function CardView:addCardView(cardValue)
	local diffY = self.m_seat == MahjongConst.kSeatMine and -80 or -50;
	local card = self:createOneHandCard(cardValue, true, #self.m_handCards)
	if not card then
		return 
	end
	
	local sequence1 = 431
	local sequence2 = 430
	local addCardAnim1 = card:addAtomPropTranslateEase(sequence1, kAnimNormal,"BounceOut", 250, 0, 0, -0, diffY, 0)
	addCardAnim1:setDebugName("CardView || addCardAnim1")
	addCardAnim1:setEvent(nil, function()
		if card and card:alive() then
			checkAndRemoveOneProp(card, sequence1)
		end
	end)

	local addCardAnim2 = card:addPropTransparency(sequence2, kAnimRepeat, 800, 0, 1.0, 1.0)
	addCardAnim2:setDebugName("CardView || addCardAnim2")
	addCardAnim2:setEvent(nil, function()
		if card and card:alive() then
			checkAndRemoveOneProp(card, sequence2)
		end
	end)
	return card
end

function CardView:onOperatePass(seat, uid, info, isFast)
	if seat == MahjongConst.kSeatMine and self:checkHandCardValid() then
		self:setCanOut(true)
	end
end 

function CardView:onOperateEnd(seat, uid, info, isFast)
	self:dealBeforeOperateCard(seat, uid, info, isFast)
	self.m_outFlag = true
	local extraTb, delTb, operateValue
	for _, v in ipairs(self.s_operateMap) do
		local continueFlag, retValue = v(self, seat, uid, info, isFast)
		if retValue then
			extraTb, delTb, operateValue = retValue.extraTb, retValue.delTb, retValue.operateValue
		end
		if not continueFlag then
			--continueFlag如果返回false，则下面的判断不会进行
			break
		end
	end
	self:dealOperateCardAndBlock(delTb, extraTb, operateValue)
    self:enableSelect(true)
	if self.m_outFlag then
		self:freshHandCardsPos(self.m_seat == MahjongConst.kSeatMine)
		if operateValue == MahjongConst.AN_KONG then
			self:playOutCardSwitchAnim(nil, true)
		end
	end
    self:updateMineCards()
end

--can override
--进行操作前的预处理
function CardView:dealBeforeOperateCard(seat, uid, info, isFast)
end

--can override
--特色操作，优先级比默认的高， 如果对默认的处理进行修改，第一个参数返回false即可
--第一个返回值为忽略默认操作标记，true则还会进行默认的操作判断处理，false则不会
--第二个返回值为表，有extraTb, delTb, operateValue字段，则表示有数据需后续处理
--delTb是从手牌中删去的牌数组，operateValue，extraTb是增加的牌堆的类型和牌数
function CardView:dealCustomOperateCard(seat, uid, info, isFast)
	return true;
end

--统一处理吃和碰操作,返回值同dealCustomOperateCard
function CardView:dealChiPengOperateCard(seat, uid, info, isFast)
    local card, iOpValue = info.card, info.iOpValue
	local extraTb, delTb, operateValue

	if MahjongHelpFunc.getInstance():left_chi(iOpValue) then
		extraTb = {card, card + 1, card + 2}
		delTb = {card + 1, card + 2}
		operateValue = MahjongConst.LEFT_CHOW
	elseif MahjongHelpFunc.getInstance():middle_chi(iOpValue) then
		extraTb = {card - 1, card, card + 1}
		delTb = {card - 1, card + 1}
		operateValue = MahjongConst.MIDDLE_CHOW
	elseif MahjongHelpFunc.getInstance():right_chi(iOpValue) then
		extraTb = {card - 2, card - 1, card}
		delTb = {card - 2, card - 1}
		operateValue = MahjongConst.RIGHT_CHOW
	elseif MahjongHelpFunc.getInstance():peng(iOpValue) then
		extraTb = {card, card, card}
		delTb = {card, card}
		operateValue = MahjongConst.PUNG
	else
		return true
	end
    return false, {extraTb = extraTb; delTb = delTb; operateValue = operateValue}
end

--统一处理杠操作,返回值同dealCustomOperateCard
function CardView:dealGangOperateCard(seat, uid, info, isFast)
    local card, iOpValue = info.card, info.iOpValue
	local extraTb, delTb, operateValue

	if bit.band(iOpValue, MahjongConst.PUNG_KONG) > 0 then
		extraTb = {card, card, card, card}
		delTb = {card, card, card}
		operateValue = MahjongConst.PUNG_KONG

	elseif bit.band(iOpValue, MahjongConst.AN_KONG) > 0 then
		extraTb = {card, card, card, card}
		delTb = {card, card, card, card}
		operateValue = MahjongConst.AN_KONG

	elseif bit.band(iOpValue, MahjongConst.BU_KONG) > 0 then
		delTb = {card}
		self:switchPengToBuGang(card)
		operateValue = MahjongConst.BU_KONG
	else
		return true
	end
    return false, {extraTb = extraTb; delTb = delTb; operateValue = operateValue}
end

--统一处理胡牌操作,返回值同dealCustomOperateCard
function CardView:dealHuPaiOperateCard(seat, uid, info, isFast)
    local card, iOpValue = info.card, info.iOpValue
	local extraTb, delTb, operateValue

	if bit.band(iOpValue, MahjongConst.ZI_MO) > 0 then
		operateValue = MahjongConst.ZI_MO
		self.m_outFlag = false
	elseif bit.band(iOpValue, MahjongConst.HU) > 0 then
		operateValue = MahjongConst.HU
		self.m_outFlag = false
	elseif bit.band(iOpValue, MahjongConst.QIANG_GANG_HU) > 0 then
		operateValue = MahjongConst.QIANG_GANG_HU
		self.m_outFlag = false
	else
		return true
	end
    return false, {extraTb = extraTb; delTb = delTb; operateValue = operateValue}
end

--处理操作后手牌和牌堆的显示
function CardView:dealOperateCardAndBlock(delTb, extraTb, operateValue)
	for _, value in ipairs(delTb or {}) do
		self:deleteCardImageAndValueByValue(value, nil, true)
	end
	if extraTb and #extraTb > 0 then
		local opTable = {
			operateValue = operateValue,
			cards = extraTb,
		}
		table.insert(self.m_extraCards, opTable)
		self:createOneExtraCardTb(opTable)
	end
end

--接着碰杠吃牌之后显示手牌、胡牌
--isLastFade是否半透明显示最后一张牌，一炮多响时用
function CardView:reDrawExtraHandHuCards(handCardsTb, isZiMo, isLastFade)
	self:clearHandCards()
	self.m_handCards = handCardsTb or {}
	self.m_handCardPosX = self.m_extraCardPosX + self.m_extraHandCardDiff.x
	self.m_handCardPosY	= self.m_extraCardPosY + self.m_extraHandCardDiff.y
	local preExtraNum = #self.m_extraCardsVector * 3
	local index, bgFile, needDiffFlag, extraBgFile, imgFileReg
	for i,v in ipairs(self.m_handCards) do
		index = i + preExtraNum 
		imgFileReg = nil
		-- if self.m_seat == MahjongConst.kSeatMine or (i == #self.m_handCards and not isZiMo) then
			bgFile = self.m_extraCardBgFile
			imgFileReg = self.m_extraCardImgFileReg
			extraBgFile = self:formatExtraCardBg(bgFile, math.ceil(index / 3), (index - 1) % 3 + 1, 14)
		-- else
		-- 	bgFile = self.m_extraAnGangImageFile
		-- 	extraBgFile = string.format(bgFile, math.min(index, 14))
		-- end
		needDiffFlag = i == #self.m_handCards and i % 3 == 2
		local card = self:createOneExtraHandHuCard(v, extraBgFile, imgFileReg, needDiffFlag, isZiMo)
		--一般情况下一炮多响，最后的牌会半透显示
		if isLastFade and needDiffFlag then
			card:setTransparency(0.5)
		end
	end
end

-- 显示胡
function CardView:onDisplayHu(hands, huCard, isZiMo, isLastFade)
	if self.m_isHu then
		return
	end

	-- 非自摸时 加进手牌列表
	self:setPickable(false)
	if huCard ~= nil and huCard ~= 0 then
	    if #hands % 3 == 2 then 
	    	for i = 1, #hands do 
	    		if hands[i] == huCard then
	    			table.remove(hands, i)
	                break
	    		end
	    	end
	    end
    	hands = self:sortByValue(hands)
    	table.insert(hands, huCard)
    else 
    	if #hands % 3 == 2 then 
    		local lastCard = table.remove(hands, #hands)
    		hands = self:sortByValue(hands)
    		table.insert(hands, lastCard)
    	else 
    		hands = self:sortByValue(hands)
    	end 
    end
	self:reDrawExtraHandHuCards(hands, isZiMo, isLastFade)
	self.m_isHu = true
end

function CardView:getSortedHandCard()
    local hand, seq = {}
    for i,v in ipairs(self.m_cardsVector) do
        seq = v:getSequence()
        seqs[seq] = i;
    end
end

--显示倒牌手牌
function CardView:showDaoPai(hands, huCard)
	if self.m_isHu then
		return
	end
	-- 有胡牌且 符合胡牌牌型 332
	if huCard ~= nil and huCard ~= 0 then
	    if #hands % 3 == 2 then 
	    	for i = 1, #hands do 
	    		if hands[i] == huCard then
	    			table.remove(hands, i)
	                break
	    		end
	    	end
	    end
	    hands = self:sortByValue(hands)
	    table.insert(hands, huCard)
	 else 
    	if #hands % 3 == 2 then 
    		local lastCard = table.remove(hands, #hands)
    		hands = self:sortByValue(hands)
    		table.insert(hands, lastCard)
    	else 
    		hands = self:sortByValue(hands)
    	end 
	end
	self:reDrawExtraHandHuCards(hands)
    self.m_isHu = true
end

function CardView:switchAnGangToMing()
	for k, v in pairs(self.m_extraCardsVector) do
		if bit.band(v.operateValue, MahjongConst.AN_KONG) > 0 then
			local card = table.remove(v.cards, 4)
			if card then card:removeSelf() end

			local secondCard = v.cards[2]
			local extraBgFile = self:formatExtraCardBg(self.m_extraCardBgFile, k, 4)
			local mingCard = new(Card, secondCard:getValue(), extraBgFile, self.m_extraCardImgFileReg, nil, self.m_seat, "out")
				:addTo1(self, secondCard:getLevel() + 3)
				:setBgAlign(self.m_cardAlign)

			mingCard:setScale(self.m_extraCardScale)
			self:adapterExtraCard(mingCard, k, 4)

			local width, height = mingCard:getOriginSize()
			local curPosX, curPosY = secondCard:getPos()
			mingCard:setOriginPos(curPosX + self.m_extraCardDiff.xGangDouble * width, 
				curPosY + self.m_extraCardDiff.yGangDouble * height)
			table.insert(v.cards, mingCard)
			break
		end	
	end
end

function CardView:resetExtraCardPosAndLayer()
	local pos = self.m_extraCardStartPos
	local startDiff = MahjongCardViewCoord.extraCardStartDiff[self.m_seat]
	self.m_extraCardPosX, self.m_extraCardPosY = pos.x, pos.y

	if self.m_seat == MahjongConst.kSeatMine then
		local width = 82 * math.abs(self.m_handCardDiff.xDouble * self.m_handCardScale) * 14
		self.m_extraCardPosX = display.cx - width / 2 + startDiff.x + 35
	elseif self.m_seat == MahjongConst.kSeatTop then
		local width = 48 * math.abs(self.m_handCardDiff.xDouble * self.m_handCardScale) * 14 - 15
		--self.m_extraCardPosX = display.cx + width / 2 + startDiff.x + 20
	-- 2 、 4
	elseif self.m_seat == MahjongConst.kSeatRight then
		local height = (60 * math.abs(self.m_handCardDiff.yDouble * self.m_handCardScale) * 14)
		self.m_extraCardPosY = display.cy + height / 2 + startDiff.y

	elseif self.m_seat == MahjongConst.kSeatLeft then
		local height = (60 * math.abs(self.m_handCardDiff.yDouble * self.m_handCardScale) * 14)
		self.m_extraCardPosY = display.cy - height / 2 + startDiff.y
	end
	if not avoidLayer then
		self.m_extraCardLayer = MahjongCardViewCoord.extraCardLayer[self.m_seat]
	end
end

function CardView:resetHandCardPosAndLayer()
	if not self.m_extraCardPosX or not self.m_extraCardLayer then
		self:resetExtraCardPosAndLayer()
	end

	self.m_handCardPosX = self.m_extraCardPosX + self.m_handToExtraDiff.x 
	self.m_handCardPosY = self.m_extraCardPosY + self.m_handToExtraDiff.y
	local groupNum = #self.m_extraCardsVector
	if self.m_seat == MahjongConst.kSeatRight then
		local diffX = MahjongCardViewCoord.extraCardsDiffX2[groupNum] or 120
		self.m_handCardPosX	= self.m_handCardPosX + diffX
	elseif self.m_seat == MahjongConst.kSeatLeft then
		local diffX = MahjongCardViewCoord.extraCardsDiffX4[groupNum] or 120
		self.m_handCardPosX	= self.m_handCardPosX + diffX
	end
	if not avoidLayer then
		-- 重置层
		self.m_cardLayer = MahjongCardViewCoord.handCardLayer[self.m_seat]
	end
end

function CardView:freshOutCardLineStartPos()
	local pos = MahjongCardViewCoord.outCardStartPos[self.m_seat]
	self.m_outCardLineNum = MahjongCardViewCoord.outCardLineNum + MahjongCardViewCoord.outCardLineStep * (self.m_outCardLine - 1)
	local outCardLineDiff = MahjongCardViewCoord.outCardLineDiff[self.m_seat]
	local half = math.floor(self.m_outCardLineNum / 2)
	local isDouble = self.m_outCardLineNum % 2 == 0
	local diff = isDouble and (half - 0.5) or half
	local cardDiff = self.m_outCardDiff
	local lineDiffX = MahjongCardViewCoord.lineDiff[self.m_seat].lineDiffX
	local lineDiffY = MahjongCardViewCoord.lineDiff[self.m_seat].lineDiffY
	if self.m_seat == MahjongConst.kSeatMine then
		self.m_outCardPosX = pos.x - cardDiff.xDouble * diff * 56 * self.m_outCardScale + (lineDiffX[self.m_outCardLine] or 0) - 25
		self.m_outCardPosY = pos.y + outCardLineDiff.yDouble * 74 * (self.m_outCardLine - 1) * self.m_outCardScale + (lineDiffY[self.m_outCardLine] or 0)
	elseif self.m_seat == MahjongConst.kSeatTop then
		self.m_outCardPosX = pos.x - cardDiff.xDouble * diff * 46 * self.m_outCardScale + (lineDiffX[self.m_outCardLine] or 0) - 25
		self.m_outCardPosY = pos.y + outCardLineDiff.yDouble * 58 * (self.m_outCardLine - 1) * self.m_outCardScale + (lineDiffY[self.m_outCardLine] or 0)
	else
		self.m_outCardPosX = pos.x + outCardLineDiff.xDouble * 46 * (self.m_outCardLine - 1) * self.m_outCardScale + (lineDiffX[self.m_outCardLine] or 0)
		self.m_outCardPosY = pos.y - cardDiff.yDouble * diff * 55 * self.m_outCardScale + (lineDiffY[self.m_outCardLine] or 0) - 20
	end
end

function CardView:resetOutCardPosAndLayer()
	self.m_outCardLine = 1
	self:freshOutCardLineStartPos()
	if not avoidLayer then
		self.m_outCardLayer = MahjongCardViewCoord.outCardLayer[self.m_seat]
	end
end

function CardView:clearHandCards()
	for k,v in pairs(self.m_cardsVector) do
		v:removeSelf()
	end
	self.m_cardsVector = {}
	self.m_handCards = {}
end

function CardView:clearOutCards()
	for k,v in pairs(self.m_outCardsVector) do
		v:removeSelf()
	end
	self.m_outCardsVector = {}
	self.m_outCards = {}
end

function CardView:clearExtraCards()
	for k,v in pairs(self.m_extraCardsVector) do
		for _, card in pairs(v.cards) do
			card:removeSelf()
		end
	end
	self.m_extraCardsVector = {}
	self.m_extraCards = {}
end

function CardView:formatBlock(info)
    local ret = {};
    local chi = table.verify( info.chis )
    for i,v in ipairs(chi) do
        table.insert(ret, {card = v; opValue = MahjongConst.LEFT_CHOW})
    end
    local peng = table.verify( info.pengs )
    for i,v in ipairs(peng) do
        table.insert(ret, {card = v; opValue = MahjongConst.PUNG})
    end
    local gang = table.verify( info.gangs )
    for i,v in ipairs(gang) do
        if v.isAnGang == 1 then
            table.insert(ret, {card = v.card; opValue = MahjongConst.AN_KONG})
        else
            table.insert(ret, {card = v.card; opValue = MahjongConst.PUNG_KONG})
        end
    end
    return ret;
end

function CardView:onReconnect(seat, uid, info, isFast)
    self:clearTableForGame()
    self:clearDealCardAnim()
	self:stopAllActions()
    self:reDrawExtraCards(info.blockInfo)
    self:reDrawHandCards(info.handCardList)
    self:freshHandCardsPos(self.m_seat == MahjongConst.kSeatMine)
    self:reDrawOutCards(info.outCardList)
    self:enableSelect(true)

    self:updateMineCards()
end

-- handCards 如果有则覆盖刷新  为nil则用缓存的手牌刷新显示
function CardView:reDrawHandCards(handCardsTb)
	self:clearHandCards()
	self.m_handCards = handCardsTb or {}
	self:resetHandCardPosAndLayer()
	for i,v in ipairs(self.m_handCards) do
		self:createOneHandCard(v, nil, i)
	end
end

--接着碰杠胡显示之后，显示手牌
function CardView:reDrawExtraHandCards(handCardsTb,isLastFade)
    self:clearHandCards()
    self.m_handCards = handCardsTb or {}
    self.m_handCardPosX = self.m_extraCardPosX + self.m_extraHandCardDiff.x
    self.m_handCardPosY = self.m_extraCardPosY + self.m_extraHandCardDiff.y
    local preExtraNum = #self.m_extraCardsVector * 3
    for i,v in ipairs(self.m_handCards) do
        local index = i + preExtraNum 
        local extraBgFile = self:formatExtraCardBg(self.m_extraCardBgFile, math.ceil(index / 3), (index - 1) % 3 + 1, 14)
        local needDiffFlag = i == #self.m_handCards and i % 3 == 2
        local card = self:createOneExtraHandCard(v, extraBgFile, self.m_extraCardImgFileReg, needDiffFlag)

        if isLastFade and needDiffFlag then
            card:setTransparency(0.5)
        end
    end
end

function CardView:reDrawOutCards(outCardsTb)
	self:clearOutCards()
	self:resetOutCardPosAndLayer()
	self.m_outCards = outCardsTb
	for i=1, #outCardsTb do
		local card = outCardsTb[i]
		self:createOneOutCard(card)
	end
end

local function getCardsTbByOpAndCard(opValue, card, laizi)
	local extraTb, operateValue = {}, 0
	
	if bit.band(opValue, MahjongConst.LEFT_CHOW) > 0 then
		extraTb = {card, card + 1, card + 2}
		operateValue = MahjongConst.LEFT_CHOW

	elseif bit.band(opValue, MahjongConst.MIDDLE_CHOW) > 0 then
		extraTb = {card - 1, card, card + 1}
		operateValue = MahjongConst.MIDDLE_CHOW

	elseif bit.band(opValue, MahjongConst.RIGHT_CHOW) > 0 then
		extraTb = {card - 2, card - 1, card}
		operateValue = MahjongConst.RIGHT_CHOW

	elseif bit.band(opValue, MahjongConst.PUNG) > 0 then
		extraTb = {card, card, card}
		operateValue = MahjongConst.PUNG

	elseif bit.band(opValue, MahjongConst.PUNG_KONG) > 0 then
		extraTb = {card, card, card, card}
		operateValue = MahjongConst.PUNG_KONG

	elseif bit.band(opValue, MahjongConst.AN_KONG) > 0 then
		extraTb = {0, 0, 0, card}
		operateValue = MahjongConst.AN_KONG

	elseif bit.band(opValue, MahjongConst.BU_KONG) > 0 then
		extraTb = {card, card, card, card}
		operateValue = MahjongConst.BU_KONG

	end
	return extraTb, operateValue
end

function CardView:reDrawExtraCards(extraCards)
	self:clearExtraCards()
	self:resetExtraCardPosAndLayer()
	for i=1, #extraCards do
		local info = extraCards[i]
		local card = info.card
		local opValue = info.opValue
		local cards = getCardsTbByOpAndCard(info.opValue, info.card)
		if #cards == 4 then
			for i=1, #cards do
				cards[i] = info.card
			end
		end
		local opTable = {
			operateValue = opValue,
			cards = cards,
		}
		table.insert(self.m_extraCards, opTable)
		self:createOneExtraCardTb(opTable)
	end
end

function CardView:setHandCards(byteCards)
	self.m_handCards = byteCards
end

function CardView:getHandCards()
	return self.m_handCards
end

function CardView:getExtraCards()
	return self.m_extraCards
end

function CardView:resetSequence()
	local cards = {};
	for k, v in pairs(self.m_cardsVector) do
		cards[k] = v
	end
	table.sort(cards, function(v1, v2)
		return v2:getOriginPos()>v1:getOriginPos()
	end)
	local fidx, bidx = 1, #self.m_cardsVector
	for i = 1, table.maxn(cards) do
		-- if not cards[i]:isOuted() then
			cards[i]:setSequence(fidx)
			fidx = fidx+1
		-- else
		-- 	cards[i]:setSequence(bidx)
		-- 	bidx = bidx-1;
		-- end
	end
end

function CardView:getCardBySequence(seq)
	for _,v in pairs(self.m_cardsVector) do
		if v:getSequence()==seq then
			return v
		end
	end
end

function CardView:_freshHandCardPos()
	self:resetHandCardPosAndLayer()
	-- 重置顺序
	local isMe = self.m_seat == MahjongConst.kSeatMine
	
	for i=1, #self.m_cardsVector do
		local card = isMe and self:getCardBySequence(i) or self.m_cardsVector[i]
		if card then
			card:setOriginPos(self.m_handCardPosX, self.m_handCardPosY)
			card:setLevel(self.m_cardLayer)
			if isMe then
				card:setDown()
			end
			local width, height = card:getOriginSize()
			self.m_handCardPosX = self.m_handCardPosX + self.m_handCardDiff.xDouble * width * self.m_handCardScale
			self.m_handCardPosY = self.m_handCardPosY + self.m_handCardDiff.yDouble * height * self.m_handCardScale
			if self.m_seat == MahjongConst.kSeatRight then
				self.m_cardLayer = self.m_cardLayer -1
			end
			if i == #self.m_cardsVector and i % 3 == 2 then
				card:shiftMove(self.m_addCardDiff.x, self.m_addCardDiff.y)
			end
		end
	end

	if isMe then
		self:resetSequence()
	end
end

function CardView:freshHandCardsPos(sortFlag)
	if self.m_isHu then
		return
	end
	if self.m_seat == MahjongConst.kSeatMine then
		self:resetHandCards()
	end
	if #self.m_cardsVector == 0 then return end

	if sortFlag and self.m_seat == MahjongConst.kSeatMine then
		for i,v in ipairs(self.m_cardsVector) do
			v.sortId = i
		end
		-- 稳定排序
		table.sort(self.m_cardsVector, function(card1, card2)
			local value1, value2 = card1:getValue(), card2:getValue()
			if card1:isOuted() and card2:isOuted() then
				return value1 < value2
			elseif card1:isOuted() then
				return false
			elseif card2:isOuted() then
				return true
			elseif value1 == value2 then
				return card1.sortId < card2.sortId
			else
				return value1 < value2
			end
		end)
	end
	self:_freshHandCardPos()
end

function CardView:checkError(values)
	if #self.m_cardsVector+3*#self.m_extraCards > MahjongConfig.HAND_CARD_NUM then 
		if _DEBUG then
			table.insert(values, "hands")
			for _, v in pairs(self.m_cardsVector) do
				table.insert(values, v:getValue())
			end
			table.insert(values, "extras")
			for _,v in pairs(self.m_extraCards) do
				for _, vv in pairs(v.cards) do
					table.insert(values, vv)
				end
			end
			-- Log.crash("cards count error:", self.m_seat, values)
		end
		return true
	end
end

-- isAddCard 是否摸牌
function CardView:createOneHandCard(value, isAddCard, idx)
	if self:checkError({value}) then return end
	if not self.m_handCardPosX or not self.m_cardLayer then
		self:resetHandCardPosAndLayer()
	end
	local diff 
	if isAddCard then
		diff = self.m_addCardDiff
		if self.m_seat == MahjongConst.kSeatRight and self:isTingPai() then
            diff = { x = -7, y = -40 }
        end
	else
		diff = { x = 0, y = 0} 
	end
	if self.m_seat ~= MahjongConst.kSeatMine and value ~= 0 then value = 0 end
	local card = new(Card, value, self.m_handCardBgFile, self.m_handCardImgFileReg, nil, self.m_seat, "hand")
			-- :setOriginPos(self.m_handCardPosX + diff.x, self.m_handCardPosY + diff.y)
			:setBgAlign(self.m_cardAlign)
			:setSequence(idx)
			:setPosition(100, 100)
	print("--------------------------------------------------createOneHandCard-", self.m_handCardPosX + diff.x, self.m_handCardPosY + diff.y)
	card:setScale(self.m_handCardScale)
	card:shiftCardMove(0, 6)

	table.insert(self.m_cardsVector, card)
	local width, height = card:getOriginSize()
	self.m_handCardPosX = self.m_handCardPosX + self.m_handCardDiff.xDouble * width * self.m_handCardScale + diff.x
	self.m_handCardPosY = self.m_handCardPosY + self.m_handCardDiff.yDouble * height * self.m_handCardScale + diff.y
	-- 第二号玩家的手牌受顺序影响 需要处理层级关系
	if self.m_seat == MahjongConst.kSeatRight then
		self.m_cardLayer = self.m_cardLayer - 1
	end
	card:addTo1(self, self.m_cardLayer)
	if self.m_seat == MahjongConst.kSeatMine then
		card:setEventTouch(self, self.onTouch);
		card:setLevel(41)
		card:setOriginScale(self.m_handCardScale, self.m_handCardScale)
	end
	return card
end

function CardView:changeExtraLayer(group, index)
	local num = (group - 1) * 3 + (index == 4 and 2 or index)
	if self.m_seat == MahjongConst.kSeatRight then 
		self.m_extraCardLayer = self.m_extraCardLayer - 1
	elseif self.m_seat == MahjongConst.kSeatTop and num > 4 then
		self.m_extraCardLayer = self.m_extraCardLayer - 1
	end
end

-- 胡之后显示手牌
function CardView:createOneExtraHandCard(value, bgFile, imgFileReg, isLastCard)
	if not self.m_handCardPosX or not self.m_cardLayer then
		self:resetHandCardPosAndLayer()
	end
	local diff 
	if isLastCard then
		diff = self.m_addCardDiff
	else
		diff = { x = 0, y = 0} 
	end
	-- 该张牌的数量
	local num = #self.m_cardsVector + 1
	-- 换算成组
	local groupNum = math.ceil(num / 3) + #self.m_extraCardsVector
	local index = (num - 1) % 3 + 1
	local card = new(Card, value, bgFile, imgFileReg, self:getExtraCardIndex(groupNum, index), self.m_seat, "hand")
		:setOriginPos(self.m_handCardPosX + self.m_extraToHandDiff.x + diff.x, self.m_handCardPosY + self.m_extraToHandDiff.y + diff.y)
		:addTo1(self, self.m_extraCardLayer)
		:setBgAlign(self.m_cardAlign)

	table.insert(self.m_cardsVector, card)

	local index = (#self.m_cardsVector - 1) % 3 + 1
	if self.m_seat == MahjongConst.kSeatMine then
		self:adapterExtraCard(card, groupNum, index)
		card:setScale(1.2)
		card:scaleCardTo(0.9)
		card:setOriginScale(1.2, 0.9)
	else
		card:setScale(self.m_extraCardScale)
		self:adapterExtraCard(card, groupNum, index, num)
	end
	local width, height = card:getOriginSize()
	self.m_handCardPosX = self.m_handCardPosX + self.m_extraCardDiff.xDouble * width + diff.x
	self.m_handCardPosY = self.m_handCardPosY + self.m_extraCardDiff.yDouble * height + diff.y

	-- 第二号玩家的手牌受顺序影响 需要处理层级关系
	self:changeExtraLayer(groupNum,	index)
	return card
end

-- hu吃碰杠
function CardView:createOneExtraHandHuCard(value, bgFile, imgFileReg, isLastCard, isZiMo)
	if not self.m_handCardPosX or not self.m_cardLayer then
		self:resetHandCardPosAndLayer()
	end
	local diff = { x = 0, y = 0}
	if isLastCard then
		diff = self.m_addCardDiff
	elseif self.m_seat==MahjongConst.kSeatTop then
		diff = { x = 5, y = 0} 
	end
	local cardType = "hand"
	-- 该张牌的数量
	local num = #self.m_cardsVector + 1
	-- 换算成组
	local groupNum = math.ceil(num / 3) + #self.m_extraCardsVector
	local index = (num - 1) % 3 + 1
	local card = new(Card, value, bgFile, imgFileReg, self:getExtraCardIndex(groupNum, index), self.m_seat, cardType)
		:setOriginPos(self.m_handCardPosX + self.m_extraToHandDiff.x + diff.x, self.m_handCardPosY + self.m_extraToHandDiff.y + diff.y)
		:addTo1(self, self.m_extraCardLayer)
		:setBgAlign(self.m_cardAlign)

	table.insert(self.m_cardsVector, card)

	local index = (#self.m_cardsVector - 1) % 3 + 1
	if self.m_seat == MahjongConst.kSeatMine then
		card:setScale(1.2)
		self:adapterExtraCard(card, groupNum, index)
		card:scaleCardTo(1.1, 1.1)
	elseif self.m_seat == MahjongConst.kSeatTop then
		card:setScale(self.m_extraCardScale)
		self:adapterHuExtraCardForSeat3(card, groupNum, index, isLastCard, isZiMo)
	else
		self:adapterExtraCard(card, groupNum, index)
	end
	local width, height = card:getOriginSize()
	self.m_handCardPosX = self.m_handCardPosX + self.m_extraCardDiff.xDouble * width + diff.x
	self.m_handCardPosY = self.m_handCardPosY + self.m_extraCardDiff.yDouble * height + diff.y

	-- 第二号玩家的手牌受顺序影响 需要处理层级关系
	self:changeExtraLayer(groupNum,	index)
	return card
end

function CardView:getTotalLineCardNeed()
	local num = MahjongCardViewCoord.outCardLineNum
	local step = MahjongCardViewCoord.outCardLineStep
	local needNum = (num + num + (self.m_outCardLine - 1) * step) * self.m_outCardLine / 2
	return needNum
end

function CardView:getOutLineAndRow(index)
	local line = outCardLineNum
end

function CardView:getOutRowAndLine(index)
	local line, row = self.m_outCardLine, index
	if index>30 then
		row = 1
		line = 4
	elseif index>28 then
		line = 4
		row = index-28
	elseif index>24 then
		row = index-24
	elseif index>18 then
		row = index-18
	elseif index>10 then
		row = index-10
	end
	return row, line
end

function CardView:createOneOutCard(value)
	if not self.m_outCardPosX or not self.m_outCardLayer then
		self:resetOutCardPosAndLayer()
	end
	local line = self.m_outCardLine  -- 当前多少行
	local originLineNum = MahjongCardViewCoord.outCardLineNum
	local nowNum = 0
	if line == 1 then 
		nowNum = #self.m_outCardsVector+1
	else
		local lines = line - 1
		local step = MahjongCardViewCoord.outCardLineStep
		local preNum = originLineNum * lines + (lines - 1) * step
		nowNum = #self.m_outCardsVector+1 - preNum
	end
	if line > 4 then line = 4 end  --麻将子多于三行 显示容错
	if nowNum > 10 then nowNum = 10 end
	nowNum = math.max(0, nowNum)
	local newNowNum = self:getOutRowAndLine(#self.m_outCardsVector+1)
	local cardImgIdx = newNowNum+line-1
	local bgFile = string.format(self.m_outCardBgFile, line, newNowNum)
	local _index = #self.m_outCardsVector+1
	local bgDiffX = MahjongCardViewCoord.cardBgDiffX[self.m_seat] or {}
	local bgDiffY = MahjongCardViewCoord.cardBgDiffY[self.m_seat] or {}

	local diffX = bgDiffX[self.m_outCardLine] and bgDiffX[self.m_outCardLine][newNowNum] or 0
	local diffY = bgDiffY[self.m_outCardLine] and bgDiffY[self.m_outCardLine][newNowNum] or 0 
	local card = new(Card, value, bgFile, self.m_outCardImgFileReg, cardImgIdx, self.m_seat, "out")
			:setOriginPos(self.m_outCardPosX + diffX, self.m_outCardPosY + diffY)
			:addTo1(self, self.m_outCardLayer)
			:setBgAlign(self.m_cardAlign)

	-- card:setScale(self.m_outCardScale)
	table.insert(self.m_outCardsVector, card)

	local needNum = self:getTotalLineCardNeed()	
	self:adapterOutCard(card, needNum, newNowNum)

	-- 备份上一次的层和麻将子数
	self.m_lastOutCardLayer = self.m_outCardLayer
	self.m_lastOutCardLine  = self.m_outCardLine
	self.m_lastOutCardPosX, self.m_lastOutCardPosY = self.m_outCardPosX, self.m_outCardPosY

	local width, height = card:getOriginSize()
	self.m_outCardPosX = self.m_outCardPosX + self.m_outCardDiff.xDouble * width * self.m_outCardScale
	self.m_outCardPosY = self.m_outCardPosY + self.m_outCardDiff.yDouble * height * self.m_outCardScale
	-- 换行

	if #self.m_outCardsVector == needNum then
		self.m_outCardLine = self.m_outCardLine + 1
		self:freshOutCardLineStartPos()
		if self.m_seat == MahjongConst.kSeatMine then
			self.m_outCardLayer = self.m_outCardLayer - (self.m_outCardLineNum - MahjongCardViewCoord.outCardLineStep) - 2
		elseif self.m_seat == MahjongConst.kSeatRight then
			self.m_outCardLayer = self.m_outCardLayer + (self.m_outCardLineNum - MahjongCardViewCoord.outCardLineStep) + 2
		elseif self.m_seat == MahjongConst.kSeatTop then
			self.m_outCardLayer = self.m_outCardLayer + (self.m_outCardLineNum - MahjongCardViewCoord.outCardLineStep) + 2
		elseif self.m_seat == MahjongConst.kSeatLeft then
			self.m_outCardLayer = self.m_outCardLayer + (self.m_outCardLineNum - MahjongCardViewCoord.outCardLineStep) + 2
		end
	elseif self.m_seat == MahjongConst.kSeatRight then
		self.m_outCardLayer = self.m_outCardLayer - 1
	elseif self.m_seat == MahjongConst.kSeatMine then
		if nowNum < self.m_outCardLineNum / 2 then
			self.m_outCardLayer = self.m_outCardLayer + 1
		else
			self.m_outCardLayer = self.m_outCardLayer - 1
		end
	elseif self.m_seat == MahjongConst.kSeatTop then
		if nowNum < self.m_outCardLineNum / 2 then
			self.m_outCardLayer = self.m_outCardLayer + 1
		else
			self.m_outCardLayer = self.m_outCardLayer - 1
		end
	end
	return card
end

function CardView:getExtraCardIndex(groupNum, k)
	if self.m_seat ~= MahjongConst.kSeatTop then return 1 end
	-- 自己的花色固定返回格式串1
	local index = (groupNum - 1) * 3 + (k == 4 and 2 or k)
	local totalNum = 14
	-- 对家花色逆序，另外多两个花色
	if index > totalNum then index = totalNum end
	return index
end

function CardView:formatExtraCardBg(bgRegFile, groupNum, k, totalNum)
	if self.m_seat == MahjongConst.kSeatMine then return bgRegFile end
	local index = (groupNum - 1) * 3 + (k == 4 and 2 or k)
	totalNum = totalNum or 14
	if index > totalNum then index = totalNum end
	local imgFileName = string.format(bgRegFile, index)
	return imgFileName
end

function CardView:adapterOutCard(card, needNum, nowNum)
	local lineNum = self.m_outCardLineNum
	local outCardDiffX = MahjongCardViewCoord.outCardDiffXTb[self.m_seat] or {}
	local outCardDiffY = MahjongCardViewCoord.outCardDiffYTb[self.m_seat] or {}

	local diffXTb = outCardDiffX[self.m_outCardLine] or {}
	local diffYTb = outCardDiffY[self.m_outCardLine] or {}

	local diffX = diffXTb[nowNum] or 0
	
	local diffY = diffYTb[nowNum] or -5
	if self.m_seat == MahjongConst.kSeatRight then
		card:shiftCardMove(diffX-3, diffY)
	elseif self.m_seat == MahjongConst.kSeatLeft then
		card:shiftCardMove(diffX-2, diffY)
	elseif self.m_seat == MahjongConst.kSeatTop then
		-- card:scaleCardTo(0.87, 0.725)
		card:shiftCardMove(diffX, diffY-2)
	elseif self.m_seat == MahjongConst.kSeatMine then
		card:shiftCardMove(diffX, diffY+9)
	end
end

function CardView:adapterExtraCard(card, groupNum, index)
	local diffX, diffY = 0, 0	
	local num = (groupNum - 1) * 3 + (index == 4 and 2 or index)
	diffX = MahjongCardViewCoord.extraCardPosDiff[self.m_seat].diffX[num] or 0
	diffY = MahjongCardViewCoord.extraCardPosDiff[self.m_seat].diffY[num] or 0
	local huaDiffX = MahjongCardViewCoord.extraHuaDiffXTb[self.m_seat]
	local huaDiffY = MahjongCardViewCoord.extraHuaDiffYTb[self.m_seat]
	if self.m_seat == MahjongConst.kSeatRight then	--
		card:shiftMove(diffX, diffY)
		card:shiftCardMove(huaDiffX[num], huaDiffY[num])
	elseif self.m_seat == MahjongConst.kSeatLeft then --
		card:shiftMove(diffX, diffY)
		card:shiftCardMove(huaDiffX[num], huaDiffY[num])
	elseif self.m_seat == MahjongConst.kSeatTop then --
		card:shiftMove(diffX, diffY)
		card:shiftCardMove(huaDiffX[num], huaDiffY[num]+2)
	elseif self.m_seat == MahjongConst.kSeatMine then 
		card:shiftMove(diffX, diffY)
		card:scaleCardTo(0.8, 0.8)
		card:shiftCardMove(0, -14)
	end
end

function CardView:adapterHuExtraCardForSeat3(card, groupNum, index, isLastCard, isZiMo)
	local diffX, diffY = 0, 0	
	local num = (groupNum - 1) * 3 + (index == 4 and 2 or index)
	diffX = MahjongCardViewCoord.extraHuCardDiff3.diffX[num] or 0
	diffY = MahjongCardViewCoord.extraHuCardDiff3.diffY[num] or 0
	local huaDiffX = MahjongCardViewCoord.extraHuaDiffXTb[self.m_seat]
	local huaDiffY = MahjongCardViewCoord.extraHuaDiffYTb[self.m_seat]
	card:shiftMove(diffX, diffY)
	card:shiftCardMove(huaDiffX[num], huaDiffY[num])
	if isLastCard then
		if isZiMo then
			card:setScale(1, 1)
		else
			card:scaleCardTo(0.9, 0.75)
		end
	else
		card:setScale(1, 1)
	end
end

function CardView:createAnGangCardTb(opTable, cards, cardType, operateValue, groupNum)
    for k,value in ipairs(opTable.cards) do
        local card 
        if k ~= 4 then
            card = new(Card, 0, self:formatExtraCardBg(self.m_extraAnGangImageFile, groupNum, k), nil, nil, self.m_seat, cardType)
                :setOriginPos(self.m_extraCardPosX + self.m_extraToHandDiff.x, self.m_extraCardPosY + self.m_extraToHandDiff.y)
                :addTo1(self, self.m_extraCardLayer)
                :setBgAlign(self.m_cardAlign)
                :setValue(value)
                
            local scaleDiff,xDiff = 1,0
            local xDiffTb = {20, 10, 0}
            if self.m_seat == MahjongConst.kSeatTop then
                scaleDiff = 1.0
                xDiff = xDiffTb[k] or 0
            end
            card:setScale(self.m_extraCardScale*scaleDiff)

            local width, height = card:getOriginSize()
            self.m_extraCardPosX = self.m_extraCardPosX + self.m_extraCardDiff.xDouble * width
            self.m_extraCardPosY = self.m_extraCardPosY + self.m_extraCardDiff.yDouble * height
            self:changeExtraLayer(groupNum, k)
        else
            --自己的暗杠最上面的明牌
            card = new(Card, value, self:formatExtraCardBg(self.m_extraCardBgFile, groupNum, k), self.m_extraCardImgFileReg, self:getExtraCardIndex(groupNum, k), self.m_seat, cardType)
            local curLayer = self.m_extraCardLayer + 3
            card:setBgAlign(self.m_cardAlign)
                :addTo1(self, curLayer)
                :setValue(value)
                
            card:setScale(self.m_extraCardScale)
            local width, height = card:getOriginSize()
            local curPosX = self.m_extraCardPosX - 2*self.m_extraCardDiff.xDouble * width
            local curPosY = self.m_extraCardPosY - 2*self.m_extraCardDiff.yDouble * height
            card:setOriginPos(curPosX + self.m_extraCardDiff.xGangDouble * width + self.m_extraToHandDiff.x, 
                curPosY + self.m_extraCardDiff.yGangDouble * height + self.m_extraToHandDiff.y)
            card:setLevel(40)
        end
        self:adapterExtraCard(card, groupNum, k)
        table.insert(cards, card)
    end
end

function CardView:createOneExtraCardTb(opTable)
	if not self.m_extraCardPosX or not self.m_extraCardLayer then
		self:resetExtraCardPosAndLayer()
	end
	local cards = {}
	local cardType = "hand"
	local operateValue = opTable.operateValue
	local groupNum = #self.m_extraCardsVector + 1
	if MahjongHelpFunc.getInstance():operatorValueHasPeng(operateValue) or
		MahjongHelpFunc.getInstance():operatorValueHasChi(operateValue) then
		for k,value in ipairs(opTable.cards) do
			local card = new(Card, value, self:formatExtraCardBg(self.m_extraCardBgFile, groupNum, k), self.m_extraCardImgFileReg, self:getExtraCardIndex(groupNum, k), self.m_seat, cardType)
				:setOriginPos(self.m_extraCardPosX + self.m_extraToHandDiff.x, self.m_extraCardPosY + self.m_extraToHandDiff.y)
				:addTo1(self, self.m_extraCardLayer)
				:setBgAlign(self.m_cardAlign)

			card:setScale(self.m_extraCardScale)
			self:adapterExtraCard(card, groupNum, k)
			local width, height = card:getOriginSize()
			self.m_extraCardPosX = self.m_extraCardPosX + self.m_extraCardDiff.xDouble * width
			self.m_extraCardPosY = self.m_extraCardPosY + self.m_extraCardDiff.yDouble * height

			table.insert(cards, card)

			self:changeExtraLayer(groupNum, k)
		end
	elseif bit.band(operateValue, MahjongConst.PUNG_KONG) > 0 or bit.band(operateValue, MahjongConst.BU_KONG) > 0 then
		for k,value in ipairs(opTable.cards) do
			local card 
			if k ~= 4 then
				card = new(Card, value, self:formatExtraCardBg(self.m_extraCardBgFile, groupNum, k), self.m_extraCardImgFileReg, self:getExtraCardIndex(groupNum, k), self.m_seat, cardType)
					:setOriginPos(self.m_extraCardPosX + self.m_extraToHandDiff.x, self.m_extraCardPosY + self.m_extraToHandDiff.y)
					:addTo1(self, self.m_extraCardLayer)
					:setBgAlign(self.m_cardAlign)

				card:setScale(self.m_extraCardScale)
				local width, height = card:getOriginSize()
				self.m_extraCardPosX = self.m_extraCardPosX + self.m_extraCardDiff.xDouble * width
				self.m_extraCardPosY = self.m_extraCardPosY + self.m_extraCardDiff.yDouble * height
				self:changeExtraLayer(groupNum, k)
			else
				local curLayer = self.m_extraCardLayer + 3
				card = new(Card, value, self:formatExtraCardBg(self.m_extraCardBgFile, groupNum, k), self.m_extraCardImgFileReg, self:getExtraCardIndex(groupNum, k), self.m_seat, cardType)
					:addTo1(self, curLayer)
					:setBgAlign(self.m_cardAlign)

				card:setScale(self.m_extraCardScale)
				local width, height = card:getOriginSize()
				local curPosX = self.m_extraCardPosX - 2*self.m_extraCardDiff.xDouble * width
				local curPosY = self.m_extraCardPosY - 2*self.m_extraCardDiff.yDouble * height
				card:setOriginPos(curPosX + self.m_extraCardDiff.xGangDouble * width + self.m_extraToHandDiff.x, 
					curPosY + self.m_extraCardDiff.yGangDouble * height + self.m_extraToHandDiff.y)
				card:setLevel(40)
			end
			self:adapterExtraCard(card, groupNum, k)
			table.insert(cards, card)
		end
    elseif bit.band(operateValue, MahjongConst.AN_KONG) > 0 then
        self:createAnGangCardTb(opTable, cards, cardType, operateValue, groupNum)
	end
	self.m_extraCardPosX = self.m_extraCardPosX + self.m_extraCardGroupSpace.x
	self.m_extraCardPosY = self.m_extraCardPosY + self.m_extraCardGroupSpace.y
	table.insert(self.m_extraCardsVector, {
		operateValue = operateValue,
		cards = cards
	})
	return card
end

function CardView:switchPengToBuGang(card)
	local cardType = self.m_seat==MahjongConst.kSeatMine and "hand" or "out"
	for k, v in pairs(self.m_extraCardsVector) do
		if bit.band(v.operateValue, MahjongConst.PUNG) > 0 and v.cards[1]:getValue() == card then
			local secondCard = v.cards[2]
			local extraBgFile = self:formatExtraCardBg(self.m_extraCardBgFile, k, 4)
			local buCard = new(Card, card, extraBgFile, self.m_extraCardImgFileReg, k*3-1, self.m_seat, cardType)
				:addTo1(self, secondCard:getLevel())
				:setBgAlign(self.m_cardAlign)

			buCard:setScale(self.m_extraCardScale)
			self:adapterExtraCard(buCard, k, 4)

			local width, height = buCard:getOriginSize()
			local curPosX, curPosY = secondCard:getPos()
			buCard:setOriginPos(curPosX + self.m_extraCardDiff.xGangDouble * width, 
				curPosY + self.m_extraCardDiff.yGangDouble * height)
			-- 去掉杠 加补杠
			v.operateValue = bit.bxor(v.operateValue, MahjongConst.PUNG)
			v.operateValue = bit.bor(v.operateValue, MahjongConst.BU_KONG)
			table.insert(v.cards, buCard)

			break
		end	
	end

	for k,v in pairs(self.m_extraCards) do
		-- 找到了碰 转成 暗杠
		if bit.band(v.operateValue, MahjongConst.PUNG) > 0 and v.cards[1] == card then
			-- 去掉杠 加补杠
			v.operateValue = bit.bxor(v.operateValue, MahjongConst.PUNG)
			v.operateValue = bit.bor(v.operateValue, MahjongConst.BU_KONG)
			v.cards = {card, card, card, card}
			break
		end
	end	
end

function CardView:switchBuGangToPeng(card)
	for k, v in pairs(self.m_extraCardsVector) do
		if bit.band(v.operateValue, MahjongConst.BU_KONG) > 0 and v.cards[1]:getValue() == card then
			local lastCard = table.remove(v.cards, 4)
			if lastCard then
				lastCard:removeSelf()
			end
			v.operateValue = bit.bxor(v.operateValue, MahjongConst.BU_KONG)
			v.operateValue = bit.bor(v.operateValue, MahjongConst.PUNG)
			break
		end	
	end

	for k,v in pairs(self.m_extraCards) do
		-- 找到了碰 转成 暗杠
		if bit.band(v.operateValue, MahjongConst.BU_KONG) > 0 and v.cards[1] == card then
			table.remove(v.cards, 4)
			v.operateValue = bit.bxor(v.operateValue, MahjongConst.BU_KONG)
			v.operateValue = bit.bor(v.operateValue, MahjongConst.PUNG)
			break
		end
	end
end

--播放出牌动画，从手牌到出牌
function CardView:playOutCardAnim(cardValue, card)
	if self.lastOutCard and card then
		local dstX, dstY = self.lastOutCard:getPos()
		local posX, posY = card:getPos()
		local diffX, diffY = posX - dstX, posY - dstY
		local width1 = self.lastOutCard:getSize().width
		local width2 = card:getSize().width
		local scale  = width2 / width1
		local animTime = 250
		local isDouble = self.m_seat % 2 == 0
		local lastOutCard = self.lastOutCard
		local anim1 = lastOutCard:addAtomPropTranslateEase(1001, kAnimNormal, isDouble and ResDoubleArraySinOut or ResDoubleArraySinIn, animTime, 0, diffX, 0, 0, 0)
		local anim2 = lastOutCard:addAtomPropTranslateEase(1002, kAnimNormal, isDouble and ResDoubleArraySinIn or ResDoubleArraySinOut, animTime, 0, 0, 0, diffY, 0)
		local anim3 = lastOutCard:addPropScale(1003, kAnimNormal, animTime, 0, scale, 1.0, scale, 1.0)
		local level = lastOutCard:getLevel()
		if self.m_seat == MahjongConst.kSeatMine then
			lastOutCard:setLevel(35)
		end
		if anim3 then 
			anim3:setEvent(nil, function() 
				lastOutCard:removeProp(1001) 
				lastOutCard:removeProp(1002)
				lastOutCard:removeProp(1003)
				-- 调用房间 将 出牌指针 放到该出牌的麻将子上面
				local x, y = lastOutCard:getImgPos()
				local width, height = lastOutCard:getImgSize()
				if self.m_seat == MahjongConst.kSeatMine then
					y = y - 45
				elseif self.m_seat == MahjongConst.kSeatRight then
					x = x + width / 8
					y = y - 45
				elseif self.m_seat == MahjongConst.kSeatTop then
					y = y - 45
				elseif self.m_seat == MahjongConst.kSeatLeft then
					x = x + width / 8
					y = y - 45
				end
				local fingerPos = {x=x, y=y, visible = true}
				self:showOutCardFinger(fingerPos)
				lastOutCard:setLevel(level)
				-- kEffectPlayer:play(Effects.AudioCardOut)
			end) 
		end
	end
end

function CardView:dealServerOutCard(cardValue)
	table.insert(self.m_outCards, cardValue)
	-- self.m_gameData:freshHuaNum()

	if self.m_seat ~= MahjongConst.kSeatMine then
		local card, index = self:findCardByValue(cardValue)
		self:doNormalCardOut(cardValue, card)
		--本地删除一张牌
		self:deleteCardImageAndValueByValue(cardValue)
		self:freshHandCardsPos(false)
	else
		-- 我的
		local forceReconn = false
		-- 出牌成功
		if self.m_lastOutHandCard then
			local lastValue = self.m_lastOutHandCard:getValue()
                       
            table.insert(self.m_myOutCards, lastValue)

			if lastValue == cardValue then
				-- 删除最后出的这个牌
				self:deleteCardImageByCard(self.m_lastOutHandCard)
				self:deleteCardValueByValue(cardValue)
			else  --不匹配
				-- 恢复 手动出的牌
				self.m_lastOutHandCard:show()
				self.m_lastOutHandCard:setOuted(false)
				-- 同时删除server出的 麻将子和值
				if self.lastOutCard then
					self.lastOutCard:resetImageByValueAndType(cardValue, self.m_outCardImgFileReg, nil, self.m_seat)
				end
				self:deleteCardImageAndValueByValue(cardValue)
				self:resetSequence()
				self:freshHandCardsPos(true)
			end
		else -- 托管出牌
			local card, cardIndex = self:findCardByValue(cardValue)
			self:doNormalCardOut(cardValue, card)
			-- 找到了牌
			if cardIndex then
				card:setOuted(true)
				self:playOutCardSwitchAnim(cardIndex)
				self:deleteCardImageAndValueByValue(cardValue)
			else --托管出的牌手牌中没有。则重连重置一次
				forceReconn = true
			end
		end
		if forceReconn then
			--TODO GameSocketMgr:closeSocketSync(true)
		end
		-- 出了一张牌
		self.m_lastOutHandCard = nil
		--printInfo("当前手牌麻将子数目=%d, 麻将子值数目%d", #self.m_cardsVector, #self.m_handCards)
	end
end

--doSearch 是否强制到手牌中找到cardValue再删除
--明牌后别人的摸的牌一般doSearch为false
--而操作后需要删除牌则需要doSearch为true
function CardView:deleteCardImageAndValueByValue(cardValue, repeatNum, doSearch)
	repeatNum = repeatNum or 1
	local result = false
	for i=1, repeatNum do
		-- 删除麻将子
		result = self:deleteCardImageByValue(cardValue, doSearch)
		-- 删除麻将子的值
		result = self:deleteCardValueByValue(cardValue, doSearch)
	end
	return result
end

function CardView:deleteCardImageByValue(cardValue, doSearch)
	if self.m_seat == MahjongConst.kSeatMine or (doSearch and self:isTingPai()) then
		for i=#self.m_cardsVector, 1, -1 do
			local card = self.m_cardsVector[i]
			if card:getValue() == cardValue then
				local card = table.remove(self.m_cardsVector, i)
				card:removeSelf()
				break
			end
		end
		self:resetSequence()
	else
		local card = table.remove(self.m_cardsVector, #self.m_cardsVector)
		if card then 
			card:removeSelf() 
		end
	end
end

function CardView:deleteCardValueByValue(cardValue)
	if self.m_seat == MahjongConst.kSeatMine then
		for i=1, #self.m_handCards do
			if self.m_handCards[i] == cardValue then
				return table.remove(self.m_handCards, i)
			end
		end
	else
		return table.remove(self.m_handCards, #self.m_handCards)
	end
end


function CardView:findCardByValue(cardValue)
	if self.m_seat == MahjongConst.kSeatMine then
		-- 从后面往前面找
		for i = #self.m_cardsVector, 1, -1 do
			local card = self.m_cardsVector[i]
			-- 根据值找到麻将子
			if card:getValue() == cardValue then
				return card, i
			end
		end
	else
		return self.m_cardsVector[#self.m_cardsVector], #self.m_cardsVector
	end	
end

-----------玩家自己专用的方法 -------------
function CardView:resetHandCards(force)
	for k,v in pairs(self.m_cardsVector) do
		v:setDown()
	end
    if self.m_delegate then
	self.m_delegate:colorCards()
    end
end

function CardView:setCardUp(index, card, noScale)
	local diffX = card:setUp(noScale)
	-- 参数为空时所有出的麻将子不灰显示
	local seq = card:getSequence()
	for k, v in pairs(self.m_cardsVector) do
		if seq < v:getSequence() then
			v:shiftMove(diffX, 0)
		end
	end
	if self.m_delegate then
		self.m_delegate:colorCards(card:getValue())
	end
end

function CardView:onRemoveOperateCard(seat, uid, info, isFast)
	local iOpValue = info.iOpValue
    if not (bit.band(iOpValue, MahjongConst.HU)>0 or bit.band(iOpValue, MahjongConst.HU)>0 or bit.band(iOpValue, MahjongConst.QIANG_GANG_HU)>0) then
		self:judgeRemoveOperateCard(info.card, info.iOpValue)
	end
end

function CardView:judgeRemoveOperateCard(card, iOpValue)
	local lastOutCard = self.m_outCardsVector[#self.m_outCardsVector]
	if not lastOutCard then return end
	local value = lastOutCard:getValue()
	if value ~= card then return end
	
	if MahjongHelpFunc.getInstance():peng(iOpValue) or MahjongHelpFunc.getInstance():operatorValueHasChi(iOpValue) or 
		MahjongHelpFunc.getInstance():peng_gang(iOpValue) or MahjongHelpFunc.getInstance():hu_qiang(iOpValue) then
		self.m_outCardLine = self.m_lastOutCardLine
		self.m_outCardLayer = self.m_lastOutCardLayer 
		self.m_outCardPosX, self.m_outCardPosY = self.m_lastOutCardPosX, self.m_lastOutCardPosY
		local card = table.remove(self.m_outCardsVector, #self.m_outCardsVector)
		card:removeSelf()
	end
end

function CardView:_getUpCards()
	local tb = {}
	for i, card in ipairs(self.m_cardsVector) do
		if card:isUp() then
			table.insert(tb, card)
		end
	end
	return tb
end

function CardView:onSwapCardStartBd(huanCardsTb)
	self:enableSelect(true)
	local indexTb = {}
	for i,value in ipairs(huanCardsTb) do
		for index=#self.m_cardsVector, 1, -1 do
			local card = self.m_cardsVector[index]
			if not indexTb[index] and not card:isUp() and card:getValue() == value then 
				card:setUp(true)
				indexTb[index] = true
				break
			end
		end
	end
end

function CardView:setSelectCardUp(index, card, action)
	if not index or not card then return end
	if self.m_cardsVector[index] ~= card then return end
	self:resetHandCards();
	self:setCardUp(index, card)
	GameEffect.getInstance():play("AUDIO_CC")
end

function CardView:checkSequence(originPosArr, dstSeq, idx, cards)
	if originPosArr[dstSeq] then
		cards[idx]:setOriginPos(unpack(originPosArr[dstSeq]))
		cards[idx]:setSequence(dstSeq)
	else
		local sqs = {}
		for _, c in pairs(self.m_cardsVector) do
			sqs[c:getSequence()] = true
		end
		for ii = 1, #self.m_cardsVector do
			if not sqs[ii] and originPosArr[ii] then
				cards[idx]:setOriginPos(unpack(originPosArr[ii]))
				cards[idx]:setSequence(ii)
				break
			end
		end
	end
end


--拖牌过程中，手牌动态变化
function CardView:resortDragingHands(dragingCard, doFinal)
	if self.m_isTing then
		return
	end
	local cards, poss, firstCard, seq = {}, {}
	for k,v in pairs(self.m_cardsVector) do
		seq = v:getSequence()
		cards[seq] = v
		poss[seq] = {v:getOriginPos()}
		if seq==1 then
			firstCard = v
		end
	end
	if not firstCard then return end

	local wf = firstCard:getOriginSize()
	local xf = firstCard:getOriginPos()
	local xd, yd = dragingCard:getPos()
	local dstSeq = math.floor(1.66+(xd-xf)/wf)
	local curSeq = dragingCard:getSequence()
	dstSeq = math.max(1, dstSeq)
	dstSeq = math.min(#self.m_cardsVector, dstSeq)

	local step = dstSeq>curSeq and -1 or 1
	if dstSeq==curSeq then
		step = 0
	end
	for i = 1, table.maxn(cards) do
		if cards[i] then
			if dragingCard~=cards[i] then
				if (curSeq-i)*(dstSeq-i)<=0 then
					if doFinal then
						self:checkSequence(poss, i+step, i, cards)
					else
						cards[i]:move(wf*step, 0)
					end
				else
					cards[i]:move(0, 0)
				end
			elseif doFinal then
				self:checkSequence(poss, dstSeq, i, cards)
			end
		end
	end
end

function CardView:onRoomBgTouched(seat, uid, info, isFast)
    if info.finger_action==kFingerDown and not self.m_isHu and self:getPickable() then 
        self:resetHandCards()
    end
end

function CardView:onTouch(action, x, y, id_first, id_current)
	-- 用来标记手指移动时是优先站起的牌还是优先没站起来的牌
	local canResort = self.m_isTing
	if action == kFingerDown then
		self.m_fingerY = y
	end
	local upIndex, upCard = self:_getUpCard()
	-- local index, card = self:_getTouchCardByPos(x, y, upIndex)
	local index, card = self:_getTouchCardByPos(id_first)
	local canOutCard = self.m_outFlag
	if action == kFingerDown then
		self.m_touchBegin = true
		if upCard and upIndex then
			if upCard == card and upIndex == index then  -- 这张就是站起的牌
				if canOutCard and self:dealLocalOutCard(card, index) then
				else
					self:resetHandCards()
					self.m_touchBegin = false
				end
			elseif index and upIndex ~= index then  -- 
				self:setSelectCardUp(index, card, action);
				self.m_selectX, self.m_selectY = x, y
			elseif not card then
				self:resetHandCards()
				self.m_touchBegin = false
			end
		elseif card then  -- 不是站起的牌
			-- 设置麻将子站起啦
			self:setSelectCardUp(index, card, action);
			self.m_selectX, self.m_selectY = x, y
		else
			self:resetHandCards()
			self.m_touchBegin = false
		end
        self.orgDownX, self.orgDownY = x, y
        self.m_hasDraged = false;
	elseif action == kFingerMove then
		if not self.m_touchBegin then 
			return true 
		end
        if (self.orgDownX and math.abs(x - self.orgDownX) > 20) or (self.orgDownY and math.abs(y - self.orgDownY) > 20) then
            self.m_hasDraged = true;
            self.m_dragingCard = card
        end
		local idx_c, card_c = self:_getTouchCardByPos(id_current)
        if not (self.m_hasDraged or canResort) or not idx_c then
			if idx_c and idx_c ~= upIndex then  -- 停留在某张牌 两个牌不一致
				self:setSelectCardUp(idx_c, card_c, action); -- 选中的牌站起
				self.m_selectX, self.m_selectY = x, y
            	return;
			end
        end
        -- 有拖起的牌
        if not self.m_dragingCard then
        	return
        end
        self.m_dragingCard:setScale(self.m_handCardScale)
        self.m_dragingCard:move(x-self.orgDownX, y-self.orgDownY)
    	if math.abs(y-self.orgDownY) < 130 then--resort
    		self:resortDragingHands(self.m_dragingCard)
    		self.m_awayX = nil
		elseif not self.m_awayX then
			self.m_awayX = x
    	end
	elseif action == kFingerUp then
        self.m_hasDraged = false
        if self.m_dragingCard then
        	local flag = false
        	if math.abs(y-self.orgDownY) > 130 then
        		if canOutCard then--and isMyTurn
					for k,v in pairs(self.m_cardsVector) do
						if self.m_dragingCard==v then
							flag = self:dealLocalOutCard(v, k)
							break
						end
					end
				else
					--reset draging card
					self.m_awayX = self.m_awayX or x
        			self.m_dragingCard:move(self.m_awayX-self.orgDownX, 0)
				end
			end
			if not flag then
				self:resortDragingHands(self.m_dragingCard, true)
			end
        	self.m_dragingCard:setScale(self.m_handCardScale)
        	self.m_dragingCard:move(0, 0)
			self.m_dragingCard = nil
			return
        end
		if not self.m_touchBegin then return end
		if upIndex and upCard then  -- 有站起的牌
			--如果有站起的牌 且位置已经离开了一定区域 则手指up后判断是否出牌
			local m_x, m_y = upCard:getPos();
			local m_originX, m_originY = upCard:getOriginPos();
			local isOutSide = m_originY - m_y > MahjongCardViewCoord.outCardDiffY;
			if isOutSide and canOutCard then
				self:dealLocalOutCard(upCard, upIndex);
			else
				upCard:setUp(true);
			end
		end
	end
	return true
end

function CardView:clearTingTipIcon()
	for i,v in ipairs(self.m_cardsVector) do
		v:clearTingTipIcon()
	end
end


-- 单独抽离出来 方便武汉麻将出赖子牌做适配
function CardView:doNormalCardOut(cardValue, card)
	self.lastOutCard = self:createOneOutCard(cardValue)
	if card then
		self:playOutCardAnim(cardValue, card)
	end
end

--can override
--打牌前检测是否能出这张牌
--能，返回true, 则会请求出牌
--不能，则给出提示并返回false
function CardView:checkCanOutCard(card, cardIndex)
	return true
end

--检查手牌是否有效
function CardView:checkHandCardValid()
	if #self:getHandCards() % 3 ~= 2  then
		return false
	end

	local cardNum = 0
	for k,v in ipairs(self.m_cardsVector) do
		if not v:isOuted() then
			cardNum = cardNum + 1
		end
	end
	if cardNum % 3 ~= 2 then
		return false
	end

	return true
end

function CardView:createTips()
    if not self.tips then
        self.tips = new(Image, _gamePathPrefix .. "mahjong/room/tips_bg.png", nil, nil, 32, 32, 32, 32)
        	:addTo1(self)
        self.tips:setLevel(100)

        local txt = new(Image, _gamePathPrefix .. "mahjong/room/no_tingyong_out.png")
        	:addTo1(self.tips)
        local w, h = txt:getSize()
        self.tips:setSize(w+100, nil)
        w, h = self.tips:getSize()
        txt:setAlign(kAlignCenter)
        self.tips:setPos((System.getScreenScaleWidth()-w)/2, (System.getScreenScaleHeight()-h+250)/2)
    end
end

function CardView:showTips()
    self:createTips()
    self.tips:setVisible(true)
    self.tips:removeProp(1)
    self.tipsAnim = self.tips:addPropTransparency(1, kAnimNormal, 500, 300, 1.0, 0)
    self.tipsAnim:setEvent(self, self.hideTips)
end

function CardView:hideTips()
    if self.tips then
        self.tips:setVisible(false)
    end
end

--本地出牌处理，不等svr确认先播动画
function CardView:dealLocalOutCard(card, cardIndex)
    -- 大小相公重连
    if not self:checkHandCardValid() then
        -- 重连
        MechineManage.getInstance():receiveAction(MechineConfig.ACTION_NS_STATUS_ERROR);
        MechineManage.getInstance():receiveAction(MechineConfig.ACTION_REFRESH_MAINSTATUS, 
            MechineConfig.STATUS_RECONNECT, -1);
        return false    
    end

    if not self:checkCanOutCard(card, cardIndex) then
        return false
    end
    
    self.m_lastOutHandCard = card
    self.m_touchBegin = false

    local cardValue = card:getValue()
    self:doNormalCardOut(cardValue, card)

    card:hide()
    card:setOuted(true)
    self:playOutCardSwitchAnim(cardIndex)

    -- 请求出牌
    self:playOutOneCard(cardIndex, cardValue)
    return true
end

function CardView:getLastCard()
	local last, lastX
	for i,v in ipairs(self.m_cardsVector) do
		if not lastX or lastX<v:getOriginPos() then
			last = v
			lastX = v:getOriginPos()
		end
	end
	return last
end

--大于等于这个seq的要往后移
function CardView:getNewSequence(card)
    local value = card:getValue()
    if MahjongBaseData.getInstance():isTingYong(value) then
        return 1
    end
    local seqs, cur, seq, outIdx = {}
    for i = 1, #self.m_cardsVector do
        seq = self.m_cardsVector[i]:getSequence()
        seqs[seq] = self.m_cardsVector[i]:getValue()
        if card == self.m_cardsVector[i] then
            outIdx = seq
        end
    end
    --find a non-tingyong mj and and less than card
    for i = table.maxn(seqs), 1, -1 do
        cur = seqs[i]
        if cur and cur <= value and i ~= outIdx and not MahjongBaseData.getInstance():isTingYong(cur) then
            return math.min(i+1, #self.m_handCards) 
        end
    end
    for i = 1, table.maxn(seqs) do
        cur = seqs[i]
        if not MahjongBaseData.getInstance():isTingYong(cur) then
            return math.min(i, #self.m_handCards) 
        end
    end
    return 1
end

--插牌动画前插入最后的手牌
--isOut是出牌还是暗杠导致重排
function CardView:sortHands(card, index, isAnGang)
	if card:isOuted() or not (card and self.m_seat == MahjongConst.kSeatMine) then
		return
	end
	self:resetHandCardPosAndLayer()

	if isAnGang then
		self:sortAfterAnGang(card)
	else
		self:sortBeforeOutCard(card, index)
	end
end

--暗杠后排序
function CardView:sortAfterAnGang(card)
	local count = #self.m_cardsVector
	local pos, seq = {}
	for i = 1, count do
		seq = self.m_cardsVector[i]:getSequence()
		pos[seq] = {self.m_cardsVector[i]:getOriginPos()}
	end
	--最后一张要插入的sequence
	local addIdx = self:getNewSequence(card)
	local newSeqs = {}
	for i = 1, count do
		seq = self.m_cardsVector[i]:getSequence()
		if card == self.m_cardsVector[i] then
			newSeqs[i] = addIdx
		elseif seq >= addIdx then
			newSeqs[i] = seq + 1
		end
	end
	for k, v in pairs(newSeqs) do
		self.m_cardsVector[k]:setSequence(v)
		self.m_cardsVector[k]:setOriginPos(pos[v][1], pos[v][2])
	end
end

--出牌前排序
function CardView:sortBeforeOutCard(card, index)
	if not self.m_cardsVector[index] then
		return
	end
	local count = #self.m_cardsVector
	local pos, seq = {}
	for i = 1, count do
		seq = self.m_cardsVector[i]:getSequence()
		pos[seq] = {self.m_cardsVector[i]:getOriginPos()}
	end
	--要出的牌的sequence
	local outIdx = self.m_cardsVector[index]:getSequence()
	--最后一张要插入的sequence
	local addIdx = self:getNewSequence(card)
	local newSeqs = {}
	for i = 1, count do
		seq = self.m_cardsVector[i]:getSequence()
		if outIdx == addIdx then
			if card == self.m_cardsVector[i] then
				newSeqs[i] = addIdx
			end
		elseif outIdx < addIdx then
			if card == self.m_cardsVector[i] then
				newSeqs[i] = addIdx - 1
			elseif seq > outIdx and seq < addIdx then
				newSeqs[i] = seq-1
			end
		else
			if card == self.m_cardsVector[i] then
				newSeqs[i] = addIdx
			elseif seq >= addIdx and seq < outIdx then
				newSeqs[i] = seq + 1
			end
		end
	end

	local flag = false;
	for k, v in pairs(newSeqs) do
		if pos[v] then
			self.m_cardsVector[k]:setSequence(v)
			self.m_cardsVector[k]:setOriginPos(pos[v][1], pos[v][2])
		else
			flag = true
		end
	end
	if flag then
		self:resetSequence()
	end
end

--插牌动画
function CardView:playOutCardSwitchAnim(index, isAnGang)
	self.m_outFlag = false
	local lastCard = self:getLastCard()
	if not lastCard or lastCard:isOuted() then
		self:freshHandCardsPos(true)
		return
	end
	for i,v in ipairs(self.m_cardsVector) do
		v:savePos()
	end
	self:resetHandCards()
	self:sortHands(lastCard, index, isAnGang)
	local width, height = lastCard:getSize()
	for i,v in ipairs(self.m_cardsVector) do
		if v:isPosChanged() and not v:isOuted() then
			local pX, pY = v:getSavePos()
			local x, y = v:getPos()
			local diffX = pX - x
			if v ~= lastCard or math.abs(diffX) < 1.5 * width then
				local moveTime = math.abs(diffX * 2)
				local anim = v:addPropTranslate(1111, kAnimNormal, moveTime, 0, diffX, 0, 0, 0)
				if anim then
					anim:setEvent(nil, function()
						if v and v:alive() then
							v:removeProp(1111)
						end
					end)
				end
			else
				local moveTime = math.abs(diffX) * 3 / 5
				local anim = v:addAtomPropTranslateEase(1111, kAnimNormal, ResDoubleArrayBackOut, 167, 0, diffX, diffX, 0, -130)
				anim:setEvent(nil, function()
					v:removeProp(1111)
					local anim = v:addAtomPropTranslateEase(1111, kAnimNormal, ResDoubleArraySinIn, moveTime, 0, diffX, 0, -130, -130)
					anim:setEvent(nil, function()
						v:removeProp(1111)
						local anim = v:addAtomPropTranslateEase(1111, kAnimNormal, ResDoubleArrayBackIn, 167, 0, 0, 0, -130, 0)
						anim:setEvent(nil, function()
							v:removeProp(1111)
						end)
					end)
				end)
			end
		end
	end
end

-- 删除指定手牌
function CardView:deleteCardImageByCard(handCard)
	for i,v in pairs(self.m_cardsVector) do
		if v == handCard then
			local card = table.remove(self.m_cardsVector, i)
			card:removeSelf()
		end
	end
	self:resetSequence()
end

--优先没有站起的牌
function CardView:_getTouchCardByPos(x, y, upIndex)
	-- 有站起的牌 且手指在y方向向上移动超过20像素
	-- 则表示移动的时候应该还是优先一起站起的牌
	-- 否则优先未站起的牌
	if upIndex and self.m_fingerY and self.m_fingerY - y > 30 then
		--优先站起的牌
		local card = self.m_cardsVector[upIndex]
		if card and card:containsPoint(x, y) then
			return upIndex, card
		end
		for k,v in pairs(self.m_cardsVector) do
			if v:containsPoint(x, y) then
				return k, v
			end
		end
	else --优先未站起的牌
		for k,v in pairs(self.m_cardsVector) do
			if k ~= upIndex and v:containsPoint(x, y) then
				return k, v
			end
		end
		local card = self.m_cardsVector[upIndex]
		if card and card:containsPoint(x, y) then
			return upIndex, card
		end
	end
end

function CardView:_getTouchCardByPos(id)
	for k,v in pairs(self.m_cardsVector) do
		if v:checkTouchID(id) then
			return k, v;
		end
	end
end

function CardView:_findCardByDrawingId(drawingId)
	for k,v in ipairs(self.m_cardsVector) do
		if v:getDrawingId() == drawingId then
			return k, v
		end
	end
end

--拿到站起的牌
function CardView:_getUpCard()
	for k,v in pairs(self.m_cardsVector) do
		if v:isUp() then
			return k, v
		end
	end
end

function CardView:_addAnim(animLoop, animTime, delayTime)
	self._anims = self._anims or {}
	local anim = AnimFactory.createAnimDouble(animLoop, 0, 1, animTime, delayTime or 0)
	local animId = anim:getID()
	self._anims[animId] = anim
	return anim
end

function CardView:stopAllActions()
	if type(self.m_props) == "table" then
		for sequence, v in pairs(self.m_props) do 
			drawing_prop_remove(self.m_drawingID, sequence)
			delete(v["prop"]);
			if v["anim"] then
				for _,anim in pairs(v["anim"]) do 
					delete(anim);
				end
			end
			if v["res"] then
				for _,res in pairs(v["res"]) do 
					delete(res);
				end
			end
		end
	end
	self.m_props = {};

	if type(self._anims) == "table" then
		for k,v in pairs(self._anims) do
			delete(v)
		end
	end
	self._anims = {}
end

function CardView:dtor()
    self:clearDealCardAnim()
	self:stopAllActions()

	delete(self.m_gaiPaiAnim)
    self.m_gaiPaiAnim = nil
end


function CardView:setColor(value)
	local function doColor(card) 
		if value==nil or value~=card:getValue() then
			card:setLightColor()
		else
			card:setDarkColor()
		end
	end
	for _, card in pairs(self.m_outCardsVector) do
		doColor(card)
	end
	if not self.m_isTing then
		for k,v in pairs(self.m_extraCardsVector) do
			for _, card in pairs(v.cards) do
				doColor(card)
			end
		end
	end
end

function CardView:performWithDelay(func, delayTime)
	local anim = self:_addAnim(kAnimNormal, delayTime)
	anim:setEvent(nil, func)
	return anim
end

function checkAndRemoveOneProp(node, propId)
	if node and node:alive() and node.m_props[propId] then  
		node:removeProp(propId);
	end
end

function CardView:getHuAnimCardPos(isQiangGang, card)
	if isQiangGang then
		for k, v in pairs(self.m_extraCardsVector) do
			if (bit.band(v.operateValue, MahjongConst.BU_KONG) > 0 or bit.band(v.operateValue, MahjongConst.PUNG) > 0) and v.cards[1]:getValue() == card then
				return v.cards[2]:getImgPos()
			end	
		end
	else
		local card = self.m_outCardsVector[#self.m_outCardsVector]
        if card then
            return card:getImgPos()
        end
	end
end

function CardView:setTingPai(tingInfo)
	local function isTing(value)
		for i, v in pairs(tingInfo or {}) do
			if v.tingCard==value then
				return v.huCardInfoArr
			end
		end
	end
	local huCardInfoArr 
	for _, card in pairs(self.m_cardsVector) do
		huCardInfoArr = isTing(card:getValue())
		if huCardInfoArr then
			card:setTingInfo(huCardInfoArr)
		else
			card:setDarkColor()
			card:setPickable(false)
		end
	end
end

function CardView:backTingPai()
    for _, card in pairs(self.m_cardsVector) do
		card:setLightColor()
		card:setPickable(true)
	end
end

--these params need change if image(tingwindow.png) changed.
function CardView:getGridParams(index, count, info)
    if count-index<=3 and #info>1 then
        return -#info*48+34, 14, 64, 14, 40;
    elseif index<=3 and count>10 and #info>1 then 
        return 0, 64, 14, 14, 40;
    else
        return -#info*24+23, 14, 14, 14, 40;
    end
end

function CardView:showOutCardFinger(data)
	MechineManage.getInstance():receiveAction(MahjongMechineConfig.ACTION_NS_SHOW_FINGER, data);
end

function CardView:onBroadCastAi(seat, uid, info, isFast)
    self.m_isAi = info.isAi == 1 and true or false;
end

--此函数如有需要要自己重写覆盖
function CardView:isTingPai()
	return false;
end

--听牌后需要倒牌时调用
function CardView:reDrawTingHands(cards)
	self:clearHandCards()
	self.m_handCards = cards or {}
	self.m_handCardPosX = self.m_extraCardPosX + self.m_extraHandCardDiff.x
	self.m_handCardPosY	= self.m_extraCardPosY + self.m_extraHandCardDiff.y
	local preExtraNum = #self.m_extraCardsVector * 3
	for i,v in ipairs(self.m_handCards) do
		local index = i + preExtraNum 
		local extraBgFile = self:formatExtraCardBg(self.m_extraCardBgFile, math.ceil(index / 3), (index - 1) % 3 + 1)
		-- local needDiffFlag = i == #self.m_handCards
		local card = self:createOneTingHandCard(v, extraBgFile, self.m_extraCardImgFileReg)
		card:setSequence(i);
		if self.m_seat==MahjongConst.kSeatTop or self.m_seat==MahjongConst.kSeatMine then 
			card:setLevel(MahjongCardViewCoord.tingCardLayer[self.m_seat])
		end
	end
end

-- 明牌显示
function CardView:createOneTingHandCard(value, bgFile, imgFileReg, isLastCard)
	if not self.m_handCardPosX or not self.m_cardLayer then
		self:resetHandCardPosAndLayer()
	end
	local diff 
	if isLastCard then
		diff = self.m_addCardDiff
	else
		diff = { x = 0, y = 0} 
	end
	-- 该张牌的数量
	local num = #self.m_cardsVector + 1
	-- 换算成组
	local groupNum = math.ceil(num / 3) + #self.m_extraCardsVector
	local index = (num - 1) % 3 + 1
	local card = new(Card, value, bgFile, imgFileReg, self:getExtraCardIndex(groupNum, index), self.m_seat, "hand")
		:setOriginPos(self.m_handCardPosX + self.m_extraToHandDiff.x + diff.x, self.m_handCardPosY + self.m_extraToHandDiff.y + diff.y)
		:addTo1(self, self.m_extraCardLayer)
		:setBgAlign(self.m_cardAlign)

	table.insert(self.m_cardsVector, card)

	local index = (#self.m_cardsVector - 1) % 3 + 1
	if self.m_seat == MahjongConst.kSeatMine then
		self:adapterExtraCard(card, groupNum, index)
		card:setScale(1.2)
		card:scaleCardTo(0.9)
		card:setOriginScale(1.2, 0.9)
	else
		card:setScale(self.m_extraCardScale)
		self:adapterExtraCard(card, groupNum, index, num)
	end
	local width, height = card:getOriginSize()
	self.m_handCardPosX = self.m_handCardPosX + self.m_extraCardDiff.xDouble * width + diff.x
	self.m_handCardPosY = self.m_handCardPosY + self.m_extraCardDiff.yDouble * height + diff.y

	-- 第二号玩家的手牌受顺序影响 需要处理层级关系
	self:changeExtraLayer(groupNum,	index)
	return card
end

--服务器返回出牌错误
function CardView:outCardError(seat, uid, info, isFast)
	self:forceReconn()
end

function CardView:updateRoomBg(seat, uid, info, isFast)
	local resetFunc = import(_gamePathPrefix .. "mahjong/pin_map/card_pin")
	resetFunc(info.bg_chess_one, info.bg_chess_two)
end

--这个函数是在听牌之后，手牌扑倒后刷新手牌用的
function CardView:freshHandCardPosAfterTing(extra)
    self.m_handCardPosX = self.m_extraCardPosX + self.m_extraHandCardDiff.x
    self.m_handCardPosY = self.m_extraCardPosY + self.m_extraHandCardDiff.y
    -- 重置顺序
    local isMe = self.m_seat == MahjongConst.kSeatMine
    

    local diff = { x = 0, y = 0}
	if self.m_seat==MahjongConst.kSeatTop then
		diff = { x = 5, y = 0} 
	end


    for i=1, #self.m_cardsVector do
        local card = self.m_cardsVector[i]
        if card then
            if extra then
                card:setOriginPos(self.m_handCardPosX + self.m_extraToHandDiff.x, self.m_handCardPosY + self.m_extraToHandDiff.y)
            end
            card:setLevel(self.m_cardLayer)
            local width, height = card:getOriginSize()
            self.m_handCardPosX = self.m_handCardPosX + self.m_extraCardDiff.xDouble * width + diff.x
            self.m_handCardPosY = self.m_handCardPosY + self.m_extraCardDiff.yDouble * height + diff.y
            if self.m_seat == MahjongConst.kSeatRight then
                self.m_cardLayer = self.m_cardLayer -1
            end
        end
    end
end

function CardView:onLaiZi(seat, uid, info, isFast)
    if self.m_seat == MahjongConst.kSeatMine then
        self:colorTiYong()
        self:reDrawHandCards(self:sortByValue(self.m_handCards))
    end
end

function CardView:colorTiYong()
    for _, card in pairs(self.m_outCardsVector) do
        card:colorTiYong()
    end
    for k,v in pairs(self.m_extraCardsVector) do
        for _, card in pairs(v.cards) do
            card:colorTiYong()
        end
    end
   
    for _, card in ipairs(self.m_cardsVector) do
        card:colorTiYong()
    end
end
---------------------------------------------------------------------------------------------------------------------
-- CardView.s_actionFuncMap = {
--     [MechineConfig.ACTION_NS_ROBOT]      				= "onBroadCastAi";  
    
--     [MahjongMechineConfig.ACTION_START]					= "clearTableForGame";  
--     [MahjongMechineConfig.ACTION_DEAL_START]			= "onDealCardBd";   
--     [MahjongMechineConfig.ACTION_GRAB_CARD]      		= "onAddCard";  
--     [MahjongMechineConfig.ACTION_OUT_CARD]      		= "onOutCard";
--     [MahjongMechineConfig.ACTION_OPERATE_END]      		= "onOperateEnd"; 
--     [MechineConfig.ACTION_NS_CLICK_DESKTOP]      		= "onRoomBgTouched";  
--     [MahjongMechineConfig.ACTION_NS_DEL_OPERATE_CARD]   = "onRemoveOperateCard";  
--     [MahjongMechineConfig.ACTION_DEALCARD_REC]      	= "onReconnect";  
--     [MahjongMechineConfig.ACTION_FORCE_HU]				= "onActionForceHu";
--     [MahjongMechineConfig.ACTION_NS_LAIZI]        		= "onLaiZi";
-- };

return CardView
