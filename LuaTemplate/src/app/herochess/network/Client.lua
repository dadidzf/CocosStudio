local Socket = require "socket"
local Packer = import ".Packer"
local Mask = import ".Mask"
local MsgDefine = import ".MsgDefine"

local _maskInst = nil

local Client = {}

Client.__index = Client

function Client.new(...)
    local o = {}
	setmetatable(o, Client)
	Client.init(o, ...)
	return o
end

function Client:init()
	self.m_last = ""
	self.m_packList = {}
	self.m_head = nil
	self.m_callbackTbl = {}
    self.m_protoNameMapMasks = {}
end

function Client:showMask(protoName)
    if _maskInst == nil or tolua.isnull(_maskInst) then
        _maskInst = Mask:create()
    end

    local curVal = self.m_protoNameMapMasks[protoName]
    if curVal then
        self.m_protoNameMapMasks[protoName] = curVal + 1
    else
        self.m_protoNameMapMasks[protoName] = 1
    end
end

function Client:hideMask(protoName)
    local curVal = self.m_protoNameMapMasks[protoName] 
    if curVal then
        curVal = curVal - 1
        if curVal <= 0 then
            self.m_protoNameMapMasks[protoName] = nil

            if next(self.m_protoNameMapMasks) == nil then
                if _maskInst then
                    if not tolua.isnull(_maskInst) then
                        _maskInst:removeFromParent()
                    end
                    _maskInst = nil
                end
            end
        else
            self.m_protoNameMapMasks[protoName] = curVal
        end
    end
end

function Client:connect(ip, port)
    local isipv6_only = false

    local addrifo = socket.dns.getaddrinfo(ip)
    if addrifo ~= nil then
        for k,v in pairs(addrifo) do
            if v.family == "inet6" then
                isipv6_only = true
                break
            end
        end
    end

    if isipv6_only then
        self.m_tcp = socket.tcp6()
    else
        self.m_tcp = socket.tcp()
    end

    self.m_tcp:settimeout(3)
    local n, e = self.m_tcp:connect(ip, port)
    self.m_tcp:settimeout(0)

    self.m_ip = ip
    self.m_port = port

    if n then
        self:startRecvSheduler()
    end

    return n
end

function Client:sendBlockMsg(proto_name, msg, callback)
    self:sendQuickMsg(proto_name, msg)
    self:showMask(proto_name)

    if callback then
        if self.m_callbackTbl[proto_name] then
            print("Client:sendBlockMsg - Be careful, there is already a block msg callback function, it will be replaced !")
        end

        self:register(proto_name, function ( ... )
            callback(...)
            self:unregister(proto_name)
        end)
    else
        assert(self.m_callbackTbl[proto_name], "No callback function to deal block messages !")
    end
end

function Client:sendQuickMsg(proto_name, msg)
    local packet = Packer.pack(proto_name, msg)
    self.m_tcp:send(packet)
end

function Client:dealMsgs()
	self:recv()
	self:splitPack()
	self:dispatchOne()
end

function Client:startRecvSheduler()
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.dealMsgs), 0.01, false)
end

function Client:removeRecvSheduler()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function Client:recv()
	local reads, writes = socket.select({self.m_tcp}, {}, 0)
	if #reads == 0 then
		return
	end

	-- 读包头,两字节长度
	if #self.m_last < 2 then
		local r, s = self.m_tcp:receive(2 - #self.m_last)
		if s == "closed" then
			self:onClose()
			return
		end
			
		if not r then
			return
		end
		
		self.m_last = self.m_last .. r
		if #self.m_last < 2 then
			return
		end
	end
	
	local len = self.m_last:byte(1) * 256 + self.m_last:byte(2)
	
	local r, s = self.m_tcp:receive(len + 2 - #self.m_last)
	if s == "closed" then
		self:onClose()
		return
	end
	
    if not r then
        print("Client:recv - socket empty", s)
        return
    end
	
	self.m_last = self.m_last .. r
end

function Client:splitPack()
	local last = self.m_last
    local len
    repeat
        if #last < 2 then
            break
        end
        len = last:byte(1) * 256 + last:byte(2)
        if #last < len + 2 then
            break
        end
        table.insert(self.m_packList, last:sub(3, 2 + len))
        last = last:sub(3 + len) or ""
    until(false)
	self.m_last = last
end

function Client:dispatchOne()
	if not next(self.m_packList) then
		return
	end

	local data = table.remove(self.m_packList, 1)
	local proto_name, params = Packer.unpack(data)
	local callback = self.m_callbackTbl[proto_name]

    if callback then
        self:hideMask(proto_name)
        callback(params)
    end
	return
end

function Client:register(name, callback)
	self.m_callbackTbl[name] = callback 
end

function Client:unregister(name)
	self.m_callbackTbl[name] = nil
end

function Client:close()
    self.m_tcp:close()
    self:removeRecvSheduler()
end

function Client:onClose()
    print("Client:onClose")
    self:close()
end

return Client
