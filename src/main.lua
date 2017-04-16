
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

local function test()
    require("test")
    require("room_pin")
    saveToPlist(room_pin_map, "room.plist", "room_pin.png", 512, 404)
    require("card_word_pin")
    saveToPlist(card_word_pin_map, "card_word.plist", "card_word_pin.png", 1024, 1024)
    require("card_word_pin1")
    saveToPlist(card_word_pin_map1, "card_word2.plist", "card_word_pin2.png", 1024, 1024)
    require("card_pin")
    saveToPlist(card_pin_map, "card_pin.plist", "card_pin.png", 1024, 1024)
    require("card_pin1")
    saveToPlist(card_pin_map, "card_pin1.plist", "card_pin1.png", 512, 1024)
end