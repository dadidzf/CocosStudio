-- 网络消息封包解包
local Utils = import ".Utils"
local MsgDefine = import ".MsgDefine"

local Packer = {}

-- 包格式
-- 两字节包长
-- 两字节协议号
-- 两字符字符串长度
-- 字符串内容
function Packer.pack(protoName, msg)
	local protoId = MsgDefine.nameToId(protoName)
    local paramsStr = Utils.tableToStr(msg)
	print("Packer.pack - content:", protoName, paramsStr)

	local len = 2 + 2 + #paramsStr
	local data = Utils.int16ToBytes(len) .. Utils.int16ToBytes(protoId) .. Utils.int16ToBytes(#paramsStr) .. paramsStr
    return data	
end

function Packer.unpack(data)
	local protoId = data:byte(1) * 256 + data:byte(2)
	local paramsStr = data:sub(3+2)
	local protoName = MsgDefine.idToName(protoId)
    print("Packer.unpack - content", protoName, paramsStr)

	local params = Utils.strToTable(paramsStr)
    return protoName, params	
end

return Packer
