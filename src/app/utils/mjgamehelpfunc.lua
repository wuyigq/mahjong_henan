import(MahjongPathPrefix .. "utils/mahjonghelpfunc")

MjGameUtils = {}

function MjGameUtils.operatorValueHasTing(operatorValue)
    local value = bit.band(operatorValue, MjGameConstant.TING);
    return value == MjGameConstant.TING;
end

function MjGameUtils.operatorValueIsNormalTing(operatorValue)
    return operatorValue == MjGameConstant.INTER_NOMARL_TING;
end

function MjGameUtils.operatorValueIsJiaTing(operatorValue)
    return operatorValue == MjGameConstant.INTER_JIA_TING;
end

return MjGameUtils
