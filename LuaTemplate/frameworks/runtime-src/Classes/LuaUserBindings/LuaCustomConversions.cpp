#include "LuaCustomConversions.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"


#if COCOS2D_DEBUG >=1
void native_err(lua_State* L,const char* msg,tolua_Error* err, const char* funcName)
{
    if (NULL == L || NULL == err || NULL == msg || 0 == strlen(msg))
        return;
    
    if (msg[0] == '#')
    {
        const char* expected = err->type;
        const char* provided = tolua_typename(L,err->index);
        if (msg[1]=='f')
        {
            int narg = err->index;
            if (err->array)
                CCLOG("%s\n     %s argument #%d is array of '%s'; array of '%s' expected.\n",msg+2,funcName,narg,provided,expected);
            else
                CCLOG("%s\n     %s argument #%d is '%s'; '%s' expected.\n",msg+2,funcName,narg,provided,expected);
        }
        else if (msg[1]=='v')
        {
            if (err->array)
                CCLOG("%s\n     %s value is array of '%s'; array of '%s' expected.\n",funcName,msg+2,provided,expected);
            else
                CCLOG("%s\n     %s value is '%s'; '%s' expected.\n",msg+2,funcName,provided,expected);
        }
    }
}
#endif


bool luaval_to_int32_handler(lua_State* L,int lo,int* outValue, const char* funcName)
{
    tolua_Error err;
    if (toluafix_isfunction(L, lo, "LUA_FUNCTION", 0, &err))
    {
        LUA_FUNCTION handler = toluafix_ref_function(L, lo, 0);
        *outValue = (int)handler;
        return true;
    }
    else
        return luaval_to_int32(L, lo, outValue, funcName);
    return false;
}


void json_to_luaval(lua_State* L, const rapidjson::Value& inValue)
{
    if (nullptr == L)
        return;
    
    if(inValue.IsObject())
    {
        lua_newtable(L);
        
        for (auto itr = inValue.MemberBegin(); itr != inValue.MemberEnd(); ++itr)
        {
            lua_pushstring(L, itr->name.GetString());
            json_to_luaval(L, itr->value);
            lua_rawset(L, -3);
        }
    }
    else if (inValue.IsArray())
    {
        lua_newtable(L);
        
        int index = 1;
        for (auto itr = inValue.Begin(); itr != inValue.End(); ++itr)
        {
            lua_pushnumber(L, (lua_Number)index);
            json_to_luaval(L, *itr);
            lua_rawset(L, -3);
            ++index;
        }
    }
    else if (inValue.IsBool())
    {
        lua_pushboolean(L, inValue.GetBool());
    }
    else if (inValue.IsUint64())
    {
        lua_pushnumber(L, inValue.GetUint64());
    }
    else if (inValue.IsInt64())
    {
        lua_pushnumber(L, inValue.GetInt64());
    }
    else if (inValue.IsDouble())
    {
        lua_pushnumber(L, inValue.GetDouble());
    }
    else if (inValue.IsString())
    {
        lua_pushstring(L, inValue.GetString());
    }
    else if (inValue.IsNull())
    {
        lua_pushnil(L);
    }
    else
        CCASSERT(false, "Not support json value type");
}


bool luaval_to_json(lua_State* L, int lo, rapidjson::Value& ret, rapidjson::MemoryPoolAllocator<>& allocator, const char* funcName)
{
    if ( nullptr == L)
        return false;
    
    tolua_Error tolua_err;
    bool ok = true;
    if (!tolua_istable(L, lo, 0, &tolua_err))
    {
#if COCOS2D_DEBUG >=1
        native_err(L,"#ferror:",&tolua_err,funcName);
#endif
        ok = false;
    }
    
    if (ok)
    {
        size_t len = lua_objlen(L, lo);
        if (len > 0) // array
        {
            ret.SetArray();
            for (size_t i = 0; i < len; i++)
            {
                lua_pushnumber(L, i + 1);
                lua_gettable(L, lo);
                if(lua_istable(L, -1))
                {
                    rapidjson::Value value;
                    luaval_to_json(L, lua_gettop(L), value, allocator);
                    ret.PushBack(value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TSTRING)
                {
                    const char* str = lua_tostring(L, -1);
                    rapidjson::Value value(str, allocator);
                    ret.PushBack(value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TBOOLEAN)
                {
                    bool b = lua_toboolean(L, -1);
                    rapidjson::Value value(b);
                    ret.PushBack(value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TNUMBER)
                {
                    lua_Number n = lua_tonumber(L, -1);
                    lua_Integer m = lua_tointeger(L, -1);
                    rapidjson::Value value;
                    if (n == m)
                        value.SetInt64(m);
                    else
                        value.SetDouble(n);
                    ret.PushBack(value, allocator);
                }
                else
                {
                    CCASSERT(false, "not supported type");
                }
                
                lua_pop(L, 1);
            }
        }
        else // hash table
        {
            ret.SetObject();
            lua_pushnil(L);
            while (0 != lua_next(L, lo))
            {
                const char* key = lua_tostring(L, -2);
                rapidjson::Value name(key, allocator);
                
                if(lua_istable(L, -1))
                {
                    rapidjson::Value value;
                    luaval_to_json(L, lua_gettop(L), value, allocator);
                    ret.AddMember(name, value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TSTRING)
                {
                    const char* str = lua_tostring(L, -1);
                    rapidjson::Value value(str, allocator);
                    ret.AddMember(name, value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TBOOLEAN)
                {
                    bool b = lua_toboolean(L, -1);
                    rapidjson::Value value(b);
                    ret.AddMember(name, value, allocator);
                }
                else if(lua_type(L, -1) == LUA_TNUMBER)
                {
                    lua_Number n = lua_tonumber(L, -1);
                    lua_Integer m = lua_tointeger(L, -1);
                    rapidjson::Value value;
                    if (n == m)
                        value.SetInt64(m);
                    else
                        value.SetDouble(n);
                    ret.AddMember(name, value, allocator);
                }
                else
                {
                    CCASSERT(false, "not supported type");
                }
                
                lua_pop(L, 1);
            }
        }
    }
    return ok;
}


void std_vector_vec2_to_luaval(lua_State * L, const std::vector<cocos2d::Vec2>& inValue)
{
    if (nullptr == L)
        return;
    
    lua_newtable(L);
    
    int index = 1;
    for (const cocos2d::Vec2& value : inValue)
    {
        lua_pushnumber(L, (lua_Number)index);
        vec2_to_luaval(L, value);
        lua_rawset(L, -3);
        ++index;
    }
}


void std_unordered_map_int_string_to_luaval(lua_State* L, const std::unordered_map<int, std::string>& inValue)
{
    if (nullptr == L)
        return;
    
    lua_newtable(L);
    
    for (auto iter = inValue.begin(); iter != inValue.end(); ++iter)
    {
        lua_pushinteger(L, iter->first);
        lua_pushstring(L, iter->second.c_str());
        lua_rawset(L, -3);
    }
}

