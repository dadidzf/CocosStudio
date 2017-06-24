#include "scripting/lua-bindings/auto/lua_scripting_auto.hpp"
#include "YWStrUtil.h"
#include "YWCsvParser.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "LuaCustomConversions.h"

int lua_scripting_YWStrUtil_stringify(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWStrUtil",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        rapidjson::Document arg0;
        ok &= luaval_to_json(tolua_S, 2, arg0, arg0.GetAllocator(), "YWStrUtil:stringify");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_stringify'", nullptr);
            return 0;
        }
        std::string ret = YWStrUtil::stringify(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWStrUtil:stringify",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWStrUtil_stringify'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWStrUtil_isNumber(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWStrUtil",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "YWStrUtil:isNumber"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_isNumber'", nullptr);
            return 0;
        }
        int ret = YWStrUtil::isNumber(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWStrUtil:isNumber",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWStrUtil_isNumber'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWStrUtil_cutString(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWStrUtil",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        int arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWStrUtil:cutString");
        ok &= luaval_to_int32_handler(tolua_S, 3,(int *)&arg1, "YWStrUtil:cutString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_cutString'", nullptr);
            return 0;
        }
        std::string ret = YWStrUtil::cutString(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    if (argc == 3)
    {
        std::string arg0;
        int arg1;
        int arg2;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWStrUtil:cutString");
        ok &= luaval_to_int32_handler(tolua_S, 3,(int *)&arg1, "YWStrUtil:cutString");
        ok &= luaval_to_int32_handler(tolua_S, 4,(int *)&arg2, "YWStrUtil:cutString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_cutString'", nullptr);
            return 0;
        }
        std::string ret = YWStrUtil::cutString(arg0, arg1, arg2);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWStrUtil:cutString",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWStrUtil_cutString'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWStrUtil_parse(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWStrUtil",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWStrUtil:parse");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_parse'", nullptr);
            return 0;
        }
        rapidjson::Document ret = YWStrUtil::parse(arg0);
        json_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWStrUtil:parse",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWStrUtil_parse'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWStrUtil_getCharacterCount(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWStrUtil",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWStrUtil:getCharacterCount");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_getCharacterCount'", nullptr);
            return 0;
        }
        int ret = YWStrUtil::getCharacterCount(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    if (argc == 2)
    {
        std::string arg0;
        int arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWStrUtil:getCharacterCount");
        ok &= luaval_to_int32_handler(tolua_S, 3,(int *)&arg1, "YWStrUtil:getCharacterCount");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWStrUtil_getCharacterCount'", nullptr);
            return 0;
        }
        int ret = YWStrUtil::getCharacterCount(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWStrUtil:getCharacterCount",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWStrUtil_getCharacterCount'.",&tolua_err);
#endif
    return 0;
}
static int lua_scripting_YWStrUtil_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (YWStrUtil)");
    return 0;
}

int lua_register_scripting_YWStrUtil(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"YWStrUtil");
    tolua_cclass(tolua_S,"YWStrUtil","YWStrUtil","",nullptr);

    tolua_beginmodule(tolua_S,"YWStrUtil");
        tolua_function(tolua_S,"stringify", lua_scripting_YWStrUtil_stringify);
        tolua_function(tolua_S,"isNumber", lua_scripting_YWStrUtil_isNumber);
        tolua_function(tolua_S,"cutString", lua_scripting_YWStrUtil_cutString);
        tolua_function(tolua_S,"parse", lua_scripting_YWStrUtil_parse);
        tolua_function(tolua_S,"getCharacterCount", lua_scripting_YWStrUtil_getCharacterCount);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(YWStrUtil).name();
    g_luaType[typeName] = "YWStrUtil";
    g_typeCast["YWStrUtil"] = "YWStrUtil";
    return 1;
}

int lua_scripting_YWCsvParser_readCsvRow(lua_State* tolua_S)
{
    int argc = 0;
    YWCsvParser* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"YWCsvParser",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (YWCsvParser*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_scripting_YWCsvParser_readCsvRow'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWCsvParser_readCsvRow'", nullptr);
            return 0;
        }
        cocos2d::ValueVector ret = cobj->readCsvRow();
        ccvaluevector_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "YWCsvParser:readCsvRow",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWCsvParser_readCsvRow'.",&tolua_err);
#endif

    return 0;
}
int lua_scripting_YWCsvParser_hasNextRow(lua_State* tolua_S)
{
    int argc = 0;
    YWCsvParser* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"YWCsvParser",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (YWCsvParser*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_scripting_YWCsvParser_hasNextRow'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWCsvParser_hasNextRow'", nullptr);
            return 0;
        }
        bool ret = cobj->hasNextRow();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "YWCsvParser:hasNextRow",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWCsvParser_hasNextRow'.",&tolua_err);
#endif

    return 0;
}
int lua_scripting_YWCsvParser_constructor(lua_State* tolua_S)
{
    int argc = 0;
    YWCsvParser* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWCsvParser:YWCsvParser");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWCsvParser_constructor'", nullptr);
            return 0;
        }
        cobj = new YWCsvParser(arg0);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"YWCsvParser");
        return 1;
    }
    if (argc == 2) 
    {
        std::string arg0;
        int32_t arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWCsvParser:YWCsvParser");

        ok &= luaval_to_int32(tolua_S, 3,&arg1, "YWCsvParser:YWCsvParser");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWCsvParser_constructor'", nullptr);
            return 0;
        }
        cobj = new YWCsvParser(arg0, arg1);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"YWCsvParser");
        return 1;
    }
    if (argc == 3) 
    {
        std::string arg0;
        int32_t arg1;
        int32_t arg2;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWCsvParser:YWCsvParser");

        ok &= luaval_to_int32(tolua_S, 3,&arg1, "YWCsvParser:YWCsvParser");

        ok &= luaval_to_int32(tolua_S, 4,&arg2, "YWCsvParser:YWCsvParser");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWCsvParser_constructor'", nullptr);
            return 0;
        }
        cobj = new YWCsvParser(arg0, arg1, arg2);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"YWCsvParser");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "YWCsvParser:YWCsvParser",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWCsvParser_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_scripting_YWCsvParser_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (YWCsvParser)");
    return 0;
}

int lua_register_scripting_YWCsvParser(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"YWCsvParser");
    tolua_cclass(tolua_S,"YWCsvParser","YWCsvParser","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"YWCsvParser");
        tolua_function(tolua_S,"new",lua_scripting_YWCsvParser_constructor);
        tolua_function(tolua_S,"readCsvRow",lua_scripting_YWCsvParser_readCsvRow);
        tolua_function(tolua_S,"hasNextRow",lua_scripting_YWCsvParser_hasNextRow);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(YWCsvParser).name();
    g_luaType[typeName] = "YWCsvParser";
    g_typeCast["YWCsvParser"] = "YWCsvParser";
    return 1;
}
TOLUA_API int register_all_scripting(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"dd",0);
	tolua_beginmodule(tolua_S,"dd");

	lua_register_scripting_YWCsvParser(tolua_S);
	lua_register_scripting_YWStrUtil(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

