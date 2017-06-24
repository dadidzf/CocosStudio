#include "base/ccConfig.h"
#ifndef __scripting_h__
#define __scripting_h__

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_all_scripting(lua_State* tolua_S);











#endif // __scripting_h__
