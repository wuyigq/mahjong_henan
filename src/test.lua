
function writefile(path, content, mode)
	mode = mode or "w+b"
	local file = io.open(path, mode)
	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

function saveToPlist(data, path, name, width, height)
	print("path--------------", path)
	local str = [[<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>frames</key>]]
	for k, v in pairs(data) do
		str = str .. [[        <key>]] .. k .. [[</key>]] .. "\n"
		str = str .. [[        <dict>]] .. "\n"
		str = str .. [[            <key>frame</key>]] .. "\n"
		str = str .. [[            <string>{{]] .. v.x .. "," .. v.y ..[[},{]] .. v.width .. "," .. v.height  .. [[}}</string>]] .. "\n"
		str = str .. [[            <key>offset</key>]] .. "\n"
		str = str .. [[            <string>{0,0}</string>]] .. "\n"
		str = str .. [[            <key>rotated</key>]] .. "\n"
		str = str .. [[            <false/>]] .. "\n"
		str = str .. [[            <key>sourceColorRect</key>]] .. "\n"
		str = str .. [[            <string>{{0,0},{]] .. v.width .. "," .. v.height  .. [[}}</string>]] .. "\n"
		str = str .. [[            <key>sourceSize</key>]] .. "\n"
		str = str .. [[            <string>{]] .. v.width .. "," .. v.height  .. [[}</string>]] .. "\n"
		str = str .. [[        </dict>]] .. "\n"
	end
	local last =[[        <key>metadata</key>
        <dict>
            <key>format</key>
            <integer>2</integer>
            <key>realTextureFileName</key>
            <string>%s</string>
            <key>size</key>
            <string>{%d,%d}</string>
            <key>smartupdate</key>
            <string>$TexturePacker:SmartUpdate:f09d9e7818c8c54a156cd46da28b2cbe$</string>
            <key>textureFileName</key>
            <string>%s</string>
        </dict>
    </dict>
</plist>
]]
	str = str .. string.format(last, name, width, height, name)
	writefile(path, str)
end