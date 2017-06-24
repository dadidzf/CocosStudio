#ifndef LuaCustomConversions_hpp
#define LuaCustomConversions_hpp

#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "json/document.h"

#if COCOS2D_DEBUG >=1
void native_err(lua_State*,const char*,tolua_Error*, const char* funcName);
#endif


bool luaval_to_int32_handler(lua_State* L,int lo,int* outValue, const char* funcName = "");

void json_to_luaval(lua_State* L, const rapidjson::Value& inValue);

bool luaval_to_json(lua_State* L, int lo, rapidjson::Value& ret, rapidjson::MemoryPoolAllocator<>& allocator, const char* funcName = "");

void std_vector_vec2_to_luaval(lua_State* L, const std::vector<cocos2d::Vec2>& inValue);

void std_unordered_map_int_string_to_luaval(lua_State* L, const std::unordered_map<int, std::string>& inValue);

template <class T>
bool luaval_to_std_vector_object(lua_State* L, int lo, const char* type, std::vector<T*>& ret, const char* funcName = "")
{
    if (nullptr == L || lua_gettop(L) < lo)
        return false;
    
    tolua_Error tolua_err;
    bool ok = true;
    
    if (!tolua_istable(L, lo, 0, &tolua_err))
    {
#if COCOS2D_DEBUG >=1
        native_err(L, "#ferror:", &tolua_err, funcName);
#endif
        ok = false;
    }
    
    if (ok)
    {
        size_t len = lua_objlen(L, lo);
        T* value;
        for (size_t i = 0; i < len; i++)
        {
            lua_pushnumber(L, i + 1);
            lua_gettable(L, lo);
            
            ok &= luaval_to_object<T>(L, -1, type, &value, funcName);
            if (ok)
            {
                ret.push_back(value);
            }
            
            lua_pop(L, 1);
        }
    }
    
    return ok;
}

template <class T>
void std_vector_object_to_luaval(lua_State* L, const char* type, const std::vector<T*>& inValue)
{
    if (nullptr == L)
        return;
    
    lua_newtable(L);
    
    int index = 1;
    for (T* value : inValue)
    {
        lua_pushnumber(L, (lua_Number)index);
        object_to_luaval(L, type, value);
        lua_rawset(L, -3);
        ++index;
    }
}

#endif /* LuaCustomConversions_hpp */
