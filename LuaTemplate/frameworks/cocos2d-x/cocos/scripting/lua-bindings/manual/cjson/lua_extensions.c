
#include "scripting/lua-bindings/manual/cjson/lua_extensions.h"

#if __cplusplus
extern "C" {
#endif
    
// lua_cjson
#include "cjson/lua_cjson.h"

static luaL_Reg luax_exts[] = {
    {"cjson", luaopen_cjson_safe},
    {NULL, NULL}
};

static void luaopen_lua_extensions(lua_State *L)
{
    // load extensions
    luaL_Reg* lib = luax_exts;
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    for (; lib->func; lib++)
    {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 2);
}
    
void register_cjson_module(lua_State *L)
{
    luaopen_lua_extensions(L);
}


#if __cplusplus
} // extern "C"
#endif
