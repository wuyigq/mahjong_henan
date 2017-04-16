-- MjGameBaseData.lua

MjGameBaseData = class("MjGameBaseData")

function MjGameBaseData.getInstance()
    if not MjGameBaseData.s_instance then
        MjGameBaseData.s_instance = new(MjGameBaseData)
    end
    return MjGameBaseData.s_instance
end

function MjGameBaseData:ctor()
    --self:resetHuRequireMent()
end

function MjGameBaseData:reset()
    self.m_tingType = nil
    self.m_tingInfo = nil
    self.m_tingState = nil
end

function MjGameBaseData:setTingInfo(info)
    self.m_tingInfo = info
end

function MjGameBaseData:getTingInfo()
    return self.m_tingInfo
end

function MjGameBaseData:setTingType(opValue)
    self.m_tingType = opValue
end

function MjGameBaseData:getTingType()
    return self.m_tingType
end

--设置/获取听牌状态，有无听/夹听
function MjGameBaseData:setTingState(uid, state)
    if not self.m_tingState then
        self.m_tingState = {}
    end
    self.m_tingState[uid] = state
end
function MjGameBaseData:getTingState(uid)
    if self.m_tingState and self.m_tingState[uid] then   --self.m_tingState[uid]  == false的情况，是返回false，所有这里相当只有等于true才会进
        return self.m_tingState[uid]
    end

    return false
end

-- 听牌信息在这里分解，听牌操作码被分解为内部定义的听，夹操作码。
function MjGameBaseData:getShowTingInfo()
    local jiatingCardArr = {};
    local normalTingCardArr = {};

    for k, v in pairs( table.verify(self.m_tingInfo) ) do
        if not table.isEmpty(v.huCardInfoArr) then
            for i = 1, #v.huCardInfoArr do
                if v.huCardInfoArr[i].fans == MjGameConstant.TING_TYPE.JIATING then
                    table.insert(jiatingCardArr, v);
                elseif v.huCardInfoArr[i].fans == MjGameConstant.TING_TYPE.TING then
                    table.insert(normalTingCardArr, v);
                end
            end
        end
    end

    if self.m_tingType == MjGameConstant.TING_TYPE.TING then
        return normalTingCardArr
    else
        return jiatingCardArr
    end
end

--获取/设置胡牌要求 
--是否有对子 "duizi" 1
--是否有刻或杠或中、发、白做将 "kezi" 2
--是否三色全 "sanse" 3
--是否有顺子 "shunzi" 4
--是否开门   "kaimen" 5
--是否有幺九或风牌 "yaojiu" 6
--[[function MjGameBaseData:getHuRequirement()
    return requirement
end
function MjGameBaseData:setHuRequirement(tags)
    local isChanged = false
    local changes = {}
    for tag, flag in pairs(tags or {}) do
        if self.m_requirement[tag]~=flag then
            self.m_requirement[tag] = flag
            isChanged = true
            changes[k] = v
        end
    end
    if isChanged then
        -- local action = 
        
        MahjongBaseData.getInstance():updateHuRequirement()
    end
end
function MjGameBaseData:resetHuRequireMent()
    self.m_requirement = {
        {["duizi"]  = false};
        {["kezi"]   = false};
        {["sanse"]  = false};
        {["shunzi"] = false};
        {["kaimen"] = false};
        {["yaojiu"] = false};
    }
end]]

--是否
function MjGameBaseData:setReconnectInfo(roomInfo)
    self:reset()
    MahjongBaseData.getInstance():setReconnectInfo(roomInfo)  
end

return MjGameBaseData
