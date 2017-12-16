local MsgDefine = {}

local _idTbl = {
    -- 登陆协议
    "login.login",
    "login.get_account",
    "login.register",
    "login.login_baseapp",

    -- 系统消息
    "system.update_exp",
    "system.update_golds",

    -- 房间消息
    "room.create_room",
    "room.join_room",
    "room.user_enter",
    "room.user_ready",
    "room.dissolve_room",

    -- 游戏消息
    "game.game_start",

    -- 跑的快 pdk

    "game.game_end",
}

local _nameTbl = {}

for id, name in ipairs(_idTbl) do
    _nameTbl[name] = id
end

local _game_proto_name_list = {}
local _game_start_id = _nameTbl["game.game_start"]
local _game_end_id = _nameTbl["game.game_end"] 
for id = _game_start_id + 1, _game_end_id - 1 do
    table.insert(_game_proto_name_list, _idTbl[id])
end

function MsgDefine.getAllGameProtos()
    return _game_proto_name_list
end

function MsgDefine.nameToId(name)
    return _nameTbl[name]
end

function MsgDefine.idToName(id)
    return _idTbl[id]
end

return MsgDefine
