
require("app.room.init")
local RoomScene = class("RoomScene", cc.load("mvc").ViewBase)
local CardView = require("app.room.card.cardview")

function RoomScene:onCreate()
    -- add background image
    display.newSprite("table.jpg")
        :move(display.center)
        :addTo(self)

    self.m_cardviews = {}
    for i = 1, 4 do
    	self.m_cardviews = CardView.new(i)
    		:addTo(self)
    end
end

return RoomScene