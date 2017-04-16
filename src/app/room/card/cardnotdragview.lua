--[[
*author:WentGuo
*date: 2016/6/15
*description: 手牌栏不支持拖动换位置
]]
local CardView = import(_gamePathPrefix .. "mahjong/module/card/cardview")
local Card = import(MahjongBaseData.getInstance():getCardPath())

local CardNotDragView = class(CardView)

function CardNotDragView:getCardCanTouch(card)
    if card then
        return card:getTouchType() == Card.TOUCH_TYPE.CAN_TOUCH or card:getTouchType() == Card.TOUCH_TYPE.CAN_DRAG;
    else
        return false;
    end
end

function CardNotDragView:getCardCanDrag(card)
    if card then
        return card:getTouchType() == Card.TOUCH_TYPE.CAN_DRAG;
    else
        return false;
    end
end

function CardNotDragView:touchDown(action, x, y, id_first, id_current)
    local upIndex, upCard = self:_getUpCard()
    local index, card = self:_getTouchCardByPos(id_first)

    self.m_touchBegin = true

    if upCard and upIndex then
        if upCard == card and upIndex == index then  -- 这张就是站起的牌
            if self:getCardCanDrag(card) and self:dealLocalOutCard(card, index) then

            else
                self:resetHandCards()
                self.m_touchBegin = false
            end
        elseif index and upIndex ~= index then  -- 
            if self:getCardCanTouch(card) then
                self:setSelectCardUp(index, card, action);
            else
                 self:resetHandCards();
            end
        elseif not card then
            self:resetHandCards()
            self.m_touchBegin = false
        end
    elseif card then  -- 没有站起的牌
            -- 设置麻将子站起啦
        if self:getCardCanTouch(card) then
            self:setSelectCardUp(index, card, action);
        end
    else
        self:resetHandCards()
        self.m_touchBegin = false
    end
    self.orgDownX, self.orgDownY = x, y
    self.m_hasDraged = false;

    return false;
end

function CardNotDragView:touchMove(action, x, y, id_first, id_current)
    local upIndex, upCard = self:_getUpCard()
    local index, card = self:_getTouchCardByPos(id_first)

    --判断是否拖动了
    if (self.orgDownX and math.abs(x - self.orgDownX) > 20) or (self.orgDownY and math.abs(y - self.orgDownY) > 20) then
        if self:getCardCanDrag(card)then  --一定要在出牌阶段才能拖动
            self.m_hasDraged = true;
            self.m_dragingCard = card
        end
    end
        -- 有拖起的牌`
    if not self.m_dragingCard then
        local idx_c, card_c = self:_getTouchCardByPos(id_current)
        if idx_c and idx_c ~= upIndex then  -- 停留在某张牌 两个牌不一致
            if self:getCardCanTouch(card_c) then
                self:setSelectCardUp(idx_c, card_c, action); -- 选中的牌站起
            else
                self:resetHandCards();
            end
            return false;
        end
    else
        self.m_dragingCard:setScale(self.m_handCardScale)
        self.m_dragingCard:move(x-self.orgDownX, y-self.orgDownY)
    end
   
    return false
end


function CardNotDragView:touchUp(action, x, y, id_first, id_current)
    if self.m_dragingCard then
        local flag = false
        if math.abs(y-self.orgDownY)>MahjongCardViewCoord.outCardDiffY then
            if self:getCardCanDrag(self.m_dragingCard) then
                for k,v in pairs(self.m_cardsVector) do
                    if self.m_dragingCard==v then
                        flag = self:dealLocalOutCard(v, k)
                        break
                    end
                end
            else
                self.m_dragingCard:setScale(self.m_handCardScale)
                self.m_dragingCard:move(0, 0)
                self.m_dragingCard = nil
            end
        else
            self.m_dragingCard:setScale(self.m_handCardScale)
            self.m_dragingCard:move(0, 0)
            self.m_dragingCard = nil
        end
        return false
    end
    return false
end

function CardNotDragView:onTouch(action, x, y, id_first, id_current)
    -- 用来标记手指移动时是优先站起的牌还是优先没站起来的牌
    if action == kFingerDown then
        return self:touchDown(action, x, y, id_first, id_current)
    elseif action == kFingerMove then
        if not self.m_touchBegin then 
            return true 
        end
        return self:touchMove(action, x, y, id_first, id_current)
    elseif action == kFingerUp then
        self.m_hasDraged = false

        return self:touchUp(action, x, y, id_first, id_current)       
    end
    return true
end



--插牌动画前插入最后的手牌
--isOut是出牌还是暗杠导致重排
function CardNotDragView:sortHands(card, index, isAnGang)
    local isMe = self.m_seat == MahjongConst.kSeatMine
    if card:isOuted() or not (card and isMe) then
        return
    end
    self:resetHandCardPosAndLayer()

    self:freshHandCardsPos(true);   --由于昆明麻将是不能拖动的，这里每次都直接排序刷新一下
end

function CardNotDragView:_freshHandCardPos()
    self:resetHandCardPosAndLayer()
    -- 重置顺序
    local isMe = self.m_seat == MahjongConst.kSeatMine
    
    for i=1, #self.m_cardsVector do
        ----由于前面对m_cardsVector已经排过序了，而昆明麻将是不能拖动的，所以不管序号，下面这行改成后面
        --local card = isMe and self:getCardBySequence(i) or self.m_cardsVector[i]  
        local card = self.m_cardsVector[i]
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

function CardNotDragView:onAddCard(seat, uid, info, isFast)
    CardView.onAddCard(self,seat, uid, info, isFast)

    --如果子类重写本函数的逻辑，最后要加上如下代码（如果有其他触摸规则的需要按需求自己处理）
    --能拖动
    self:setAllHandCardTouchType(Card.TOUCH_TYPE.CAN_DRAG)
end

function CardNotDragView:onOutCard(seat, uid, info, isFast)
    CardView.onOutCard(self,seat, uid, info, isFast)

    --如果子类重写本函数的逻辑，最后要加上如下代码（如果有其他触摸规则的需要按需求自己处理）
   --只能触摸了
    self:setAllHandCardTouchType(Card.TOUCH_TYPE.CAN_TOUCH)
end

--设置手牌触摸状态
function CardNotDragView:setAllHandCardTouchType(touchType)
     for _,card in ipairs(self.m_cardsVector) do 
        card:setTouchType(touchType);  
    end
end

function CardNotDragView:onOperateEnd(seat, uid, info, isFast)
    CardView.onOperateEnd(self,seat, uid, info, isFast)

    --如果子类重写本函数的逻辑，最后要加上如下代码（如果有其他触摸规则的需要按需求自己处理）
    if not self.m_isHu then
        self:_freshHandCardPos()
        --能拖动
        self:setAllHandCardTouchType(Card.TOUCH_TYPE.CAN_DRAG)   
    end
end

return CardNotDragView