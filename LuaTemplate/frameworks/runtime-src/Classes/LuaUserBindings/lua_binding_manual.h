#ifndef __LUA_BINDING_MANUAL_H__
#define __LUA_BINDING_MANUAL_H__

#include "cocos2d.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int register_user_manual(lua_State* L);

#endif  // __APP_DELEGATE_H__

