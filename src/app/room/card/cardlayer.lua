-- local MahjongLayerBase = import(_gamePathPrefix .. "mahjong/module/mahjonglayerbase")
local AnimHuPai = import(_gamePathPrefix .. "mahjong/anim/animhupai")

--麻将手牌和出牌层
local CardLayer = class(MahjongLayerBase)

CardLayer.arrowPath = _gamePathPrefix .. "mahjong/room/arrow.png"

function CardLayer:ctor()
    self:setFillParent(true, true)

    -- self:setOvrrideStateAction(true)

    self.m_huPaiAnim = nil  --点炮胡，闪电劈的特效
end

function CardLayer:dtor()
    self:clearDes()
    AnimHuPai.release()
    delete(self.m_huPaiAnim)
    if self.m_animDelay then
        delete(self.m_animDelay)
        self.m_animDelay = nil;
    end
 
    if self.m_fenzhangDelay1 then
        delete(self.m_fenzhangDelay1)
        self.m_fenzhangDelay1 = nil;
    end
    if self.m_fenzhangDelay2 then
        delete(self.m_fenzhangDelay2)
        self.m_fenzhangDelay2 = nil;
    end
end

-- 初始化layer的配置
function CardLayer:initViewConfig()
    self.m_viewConfig = {}
    local path = MahjongBaseData.getInstance():getCardViewPath()
    for k, v in pairs(self.s_seatMap) do
        self.m_viewConfig[v] = {path = path}
    end
end

function CardLayer:changeMahjongSeat(seat)
    return self.s_seatMap[seat]
end

function CardLayer:clearDes()
    self:hideOutCardFinger()
    self:hideBigOutCard()
end

function CardLayer:onReconnect(seat, uid, info, isFast)
    self:hideOutCardFinger()
    self:hideBigOutCard()
end

function CardLayer:onGrabCard(seat, uid, info, isFast)
    self:hideBigOutCard(true)
end

function CardLayer:onOutCard(seat, uid, info, isFast)
    local myID = UserBaseInfoIsolater.getInstance():getUserId()
    if uid ~= myID then
        self:showBigOutCard(info.card, seat)
    else
        self:hideBigOutCard()
    end
end

function CardLayer:onOperateEnd(seat, uid, info, isFast)
    self:hideBigOutCard()
    self:hideOutCardFinger();
end

function CardLayer:showOutCardFinger(_, uid, info, isFast)
    if not self.m_outCardFinger then
        self.m_outCardFinger = UIFactory.createImage(CardLayer.arrowPath)
        self.m_outCardFinger:addPropTranslate(121, kAnimLoop, 500, 0, 0, 0, 0, -10)
        self.m_outCardFinger:setLevel(10)
        self:addChild(self.m_outCardFinger)
    else
        self.m_outCardFinger:setVisible(true)
    end
    self.m_outCardFinger:setPos(info.x, info.y)
end

function CardLayer:hideOutCardFinger()
    if self.m_outCardFinger then
        self.m_outCardFinger:setVisible(false)
    end
end

function CardLayer:showBigOutCard(cardValue, seat)
    local Card = import(MahjongBaseData.getInstance():getCardPath())

    if not self.m_bigOutCardBg then
        self.m_bigOutCardBg = UIFactory.createImage(_gamePathPrefix .. "mahjong/room/out_bg.png")
        self.m_bigOutCardBg:setLevel(21)
        self:addChild(self.m_bigOutCardBg)

        local width, height = self.m_bigOutCardBg:getSize()
        self.m_bigOutCardBg:setSize(width*0.7, height*0.75)
    else
        self.m_bigOutCardBg:setVisible(true)
        self.m_bigOutCardBg:removeProp(1002)
        self.m_bigOutCard:resetImageByValueAndType(cardValue, extraCardImgFileReg)
    end
    delete(self.m_bigOutCard)--避免换了麻将背景后，这个牌的背景没换
    local extraCardBgFile       = MahjongCardViewCoord.extraCardBg[MahjongConst.kSeatMine]
    local extraCardImgFileReg   = MahjongCardViewCoord.extraCardImage[MahjongConst.kSeatMine]
    self.m_bigOutCard = new(Card, cardValue, extraCardBgFile, nil, 1, MahjongConst.kSeatMine, "hand")
        :setBgAlign(kAlignCenter)
        :shiftCardMove(0, -15)
        :addTo(self.m_bigOutCardBg)
        :align(kAlignCenter, 0, 5)
    self.m_bigOutCard:scaleCardTo(0.8, 0.8)
    local bigOutCardPos = MahjongCardViewCoord.bigOutCardPos[seat]
    local width, height = self.m_bigOutCardBg:getSize()
    self.m_bigOutCardBg:setPos(bigOutCardPos.x - width/2, bigOutCardPos.y - height/2)
end

function CardLayer:hideBigOutCard(animFlag)
    if self.m_bigOutCardBg then
        if animFlag then
            self.m_bigOutCardBg:removeProp(1002)
            self.m_bigOutCardBg:addPropTransparency(1002, kAnimNormal, 100, 1000, 1.0, 0.0)
        else
            self.m_bigOutCardBg:setVisible(false)
        end
    end
end

function CardLayer:colorCards(value)
    for k,panel in pairs(self.m_views) do
        panel:setColor(value)
    end
end

function CardLayer:onClearTable(seat, uid, info, isFast)
    self:hideBigOutCard()
    self:hideOutCardFinger()
    for k,panel in pairs(self.m_views) do
        panel:clearTableForGame();
    end
end

function CardLayer:onHuPai(seat, uid, info, isFast)
    self:hideOutCardFinger();
    self:hideBigOutCard();

    if seat ~= -1 and info.roundResult ~= 0 then
        local huCardNodeList = {}
        for i = 1, #info.winPlayerInfoList do
            local playerData = info.winPlayerInfoList[i] 
            local playerSeat = GamePlayerManager2.getInstance():getLocalSeatByMid(playerData.userId);
            
            self.m_views[playerSeat]:onDisplayHu(playerData.handCardList, info.huCard, playerData.isZimo == 1, i ~= 1)

            if info.dianPaoUserId then 
                local cardsVector = self.m_views[playerSeat].m_cardsVector
                local cardNode = cardsVector[#cardsVector]
                if cardNode then 
                    cardNode:setVisible(false)
                    table.insert(huCardNodeList, cardNode)
                end 
            end
        end

        if info.dianPaoUserId then
            local dianpaoSeat = GamePlayerManager2.getInstance():getLocalSeatByMid(info.dianPaoUserId);
            if info.isQiangGangHu == 1 then 
                self.m_views[dianpaoSeat]:switchBuGangToPeng(info.huCard)
            end
            local x,y = self.m_views[dianpaoSeat]:getHuAnimCardPos(info.isQiangGangHu == 1, info.huCard)
            if x and y then
                delete(self.m_huPaiAnim)
                self.m_huPaiAnim = new(AnimHuPai):play(dianpaoSeat, x, y, isQiangGang, function()
                    for i = 1, #huCardNodeList do
                        huCardNodeList[i]:setVisible(true);
                    end
                end)
                self.m_huPaiAnim:setLevel(1000);
                self.m_views[dianpaoSeat]:addChild(self.m_huPaiAnim);
            end
            delete(self.m_animDelay)
            self.m_animDelay = nil;
            self.m_animDelay = new(AnimInt, kAnimNormal, 0, 1, 800, -1)
            self.m_animDelay:setDebugName("CardLayer.m_animDelay")
            self.m_animDelay:setEvent(nil, function()
                self.m_views[dianpaoSeat]:judgeRemoveOperateCard(info.huCard, MahjongConst.HU)
                delete(self.m_animDelay)
                self.m_animDelay = nil
            end)
            
        end
    end
end

function CardLayer:onShowDaoPai(seat, uid, info, isFast)
    for k, v in pairs(info) do
        local seatid = GamePlayerManager2.getInstance():getLocalSeatByMid(v.userId)
        local tempSeat = self:changeMahjongSeat(seatid)
        if self.m_views[tempSeat] then
            self.m_views[tempSeat]:showDaoPai(v.handCardList)
        end
    end
end

function CardLayer:onLogin(seat, uid, info, isFast)
    if seat == MahjongConst.kSeatMine then
        self:onClearTable(seat, uid, info, isFast)
    end
end

function CardLayer:onGameOver(seat, uid, info, isFast)
    self:hideOutCardFinger();
    self:hideBigOutCard();

    MahjongBaseData.getInstance():setHuRequirement()
end

function CardLayer:onShowFenZhang(seat, uid, info, isFast)
    if seat == MahjongConst.kSeatMine then 
        self:hideOutCardFinger();
        self:hideBigOutCard();

        self.m_fenzhangDelay1 = new(AnimInt, kAnimNormal, 0, 1, 2000, -1)
        self.m_fenzhangDelay1:setDebugName("CardLayer.m_fenzhangDelay1")
        self.m_fenzhangDelay1:setEvent(nil, function()
            if self.m_fenzhangDelay1 then 
                delete(self.m_fenzhangDelay1)
                self.m_fenzhangDelay1 = nil
            end
            self.m_views[MahjongConst.kSeatMine]:onAddCardForFenZhang(info.selfInfo.card) 
            if info.selfInfo.operateValue > 0 and MahjongHelpFunc.getInstance():operatorValueHasHu(info.selfInfo.operateValue) then 
                local action = MahjongMechineConfig.ACTION_OPERATE_START
                local myID = UserBaseInfoIsolater.getInstance():getUserId()
                MechineManage.getInstance():receiveAction(action, {cur = {{card = info.selfInfo.card, operatype = MahjongConst.ZI_MO}}}, myID)
            end
            MahjongBaseData.getInstance():decLeftCard()

            self.curFenZhangTimes = 1 
            self.m_fenzhangDelay2 = new(AnimInt, kAnimRepeat, 0, 1, 300, -1)
            self.m_fenzhangDelay2:setDebugName("CardLayer.m_fenzhangDelay1")
            self.m_fenzhangDelay2:setEvent(nil, function()
                MahjongBaseData.getInstance():decLeftCard()             
                local playerInfoData = info.otherPlayerInfo[self.curFenZhangTimes]
                local seatid = GamePlayerManager2.getInstance():getLocalSeatByMid(playerInfoData.userId)
                local tempSeat = self:changeMahjongSeat(seatid)
                if self.m_views[tempSeat] then
                    self.m_views[tempSeat]:onAddCardForFenZhang(playerInfoData.card)
                end
                if self.curFenZhangTimes == #info.otherPlayerInfo then 
                    if self.m_fenzhangDelay2 then 
                        delete(self.m_fenzhangDelay2)
                        self.m_fenzhangDelay2 = nil
                    end
                else 
                    self.curFenZhangTimes = self.curFenZhangTimes + 1
                end 
            end)
        end)
    end
end 

CardLayer.s_seatMap = {
    [MahjongConst.kSeatMine]       = MahjongConst.kSeatMine;
    [MahjongConst.kSeatRight]      = MahjongConst.kSeatRight;
    [MahjongConst.kSeatLeft]       = MahjongConst.kSeatLeft;
    [MahjongConst.kSeatTop]        = MahjongConst.kSeatTop;
}
CardLayer.s_stateFuncMap = { 
    [MahjongMechineConfig.STATUS_OPERATE_END ] = "onOperateEnd";
    [MechineConfig.STATUS_LOGOUT]          = "onClearTable"; 
};
------------------------------------------------------------------------------------------------
CardLayer.s_actionFuncMap = {
    [MechineConfig.ACTION_LOGIN]                        = "onLogin";
    [MechineConfig.ACTION_NS_CLEAR_TABLE]               = "onClearTable";  
    [MechineConfig.ACTION_LOGOUT]                       = "onClearTable"; 
    [MahjongMechineConfig.ACTION_NS_GAME_OVER_SHOW]     = "onGameOver";
    
    [MahjongMechineConfig.ACTION_NS_DAOPAI]             = "onShowDaoPai";
    [MahjongMechineConfig.ACTION_GRAB_CARD]             = "onGrabCard";  
    [MahjongMechineConfig.ACTION_OUT_CARD]              = "onOutCard";  
    [MahjongMechineConfig.ACTION_OPERATE_END]           = "onOperateEnd";  
    [MahjongMechineConfig.ACTION_NS_HU]                 = "onHuPai"; 
    [MahjongMechineConfig.ACTION_START]                 = "clearDes"; 
    [MahjongMechineConfig.ACTION_NS_SHOW_FINGER]        = "showOutCardFinger";  
    [MahjongMechineConfig.ACTION_FEN_ZHANG]             = "onShowFenZhang"; 
}

return CardLayer;