
function new(cls, ...)
	if type(cls.new) == "function" then
		return cls.new(...) 
	end
end

function delete(obj)
	if type(obj.dtor) == "function" then
		obj:dtor()
	end
end

local Node = cc.Node

function Node:setLevel(lv)
	self:setLocalZOrder(lv)
end

function Node:setPickable(flag)
	--TODO self:setTouchEnabled(flag)
end