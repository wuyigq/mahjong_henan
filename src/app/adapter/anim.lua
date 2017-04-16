--- anim完成后即停止。
kAnimNormal	= 0;
--- anim会无限重复。
kAnimRepeat	= 1;
--- anim完成一次后倒序一次，如此反复。
kAnimLoop	    = 2;

local scheduler = require("cocos.framework.scheduler")

AnimBase = class("AnimBase");

function AnimBase:getID()
	return self.m_animID;
end

---
-- 构造函数.
--
function AnimBase:ctor(animType, startValue, endValue, duration, delay)
	self.m_animType = animType;
	self.m_startValue = startValue;
	self.m_endValue = endValue;
	self.m_duration = duration;
	self.m_delay = delay;
	self.count = 0

	self.m_animID = scheduler.scheduleGlobal (function()
		self:onEvent()
	end, duration/1000);	
	self.m_eventCallback = {};
end

---
-- 析构函数.
--
AnimBase.dtor = function(self)
	if self.m_animID then
		scheduler.unscheduleGlobal(self.m_animID);
		self.m_animID = nil
	end
end

---
-- 设置一个DebugName,便于调试.如果出现错误日志中会打印出这个名字，便于定位问题.
-- 
AnimBase.setDebugName = function(self, name)	
    self.m_debugName=name or ""
	-- anim_set_debug_name(self.m_animID,self.m_debugName);
end

---
-- 返回DebugName,便于调试.
-- 
AnimBase.getDebugName = function(self)
    return self.m_debugName
end


---
-- 获取AnimBase对象的当前值.<a href="#001">详见：anim的当前值。</a>
--
AnimBase.getCurValue = function(self, defaultValue)
	return anim_get_value(self.m_animID,defaultValue or 0)
end

---
-- 设置AnimBase对象回调函数. 
--
AnimBase.setEvent = function(self, obj, func)
	-- anim_set_event(self.m_animID,kTrue,self,self.onEvent);
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

AnimBase.onEvent = function(self)
	if self.m_animType == kAnimNormal and self.m_animID then
		scheduler.unscheduleGlobal(self.m_animID)
	end	
	self.count = self.count + 1
	if self.m_eventCallback.func then
		 self.m_eventCallback.func(self.m_eventCallback.obj, self.m_animType, self.m_animID, self.count);
	end
end

AnimInt = AnimBase
AnimDouble = AnimBase

AnimIndex = class("AnimIndex", AnimBase);

AnimIndex.ctor = function(self, animType, startValue, endValue, duration, res, delay)
	anim_create_index(0, self.m_animID, animType, startValue, endValue, duration, res.m_resID,delay or 0); 
end

AnimFactory = {}

function AnimFactory.createAnimDouble(...)
	local anim = new(AnimBase, ...)
	return anim
end

function AnimFactory.createAnimInt(...)
	local anim = new(AnimBase, ...)
	return anim
end

function AnimFactory.createAnimIndex(...)
	local anim = new(AnimIndex, ...)
	return anim
end
