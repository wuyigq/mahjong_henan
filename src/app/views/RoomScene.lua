
require("app.room.init")
local RoomScene = class("RoomScene", cc.load("mvc").ViewBase)
local CardView = require("app.room.card.cardview")

function RoomScene:onCreate()
    -- add background image
    display.newSprite("table.jpg")
        :move(display.center)
        :addTo(self)

    display.loadSpriteFrames("card/room_pin.plist","card/room_pin.png")
    display.loadSpriteFrames("card/card_pin.plist","card/card_pin.png")
    display.loadSpriteFrames("card/card_pin1.plist","card/card_pin1.png")
    display.loadSpriteFrames("card/card_word_pin.plist","card/card_word_pin.png")
    display.loadSpriteFrames("card/card_word_pin2.plist","card/card_word_pin2.png")

    self.m_cardviews = {}
    for i = 1, 1 do
    	self.m_cardviews = CardView.new(i)
    		:addTo(self)
    end
end

return RoomScene