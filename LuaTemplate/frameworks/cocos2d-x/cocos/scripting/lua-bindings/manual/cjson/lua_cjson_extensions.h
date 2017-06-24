
#ifndef __LUA_CJSON_EXTENSIONS_H_
#define __LUA_CJSON_EXTENSIONS_H_

#if defined(_USRDLL)
    #define LUA_EXTENSIONS_DLL     __declspec(dllexport)
#else         /* use a DLL library */
    #define LUA_EXTENSIONS_DLL
#endif

#if __cplusplus
extern "C" {
#endif

#include "lauxlib.h"

/// @cond
void LUA_EXTENSIONS_DLL register_cjson_module(lua_State *L);
/// @endcond
    
#if __cplusplus
}
#endif

#endif /* __LUA_CJSON_EXTENSIONS_H_ */
