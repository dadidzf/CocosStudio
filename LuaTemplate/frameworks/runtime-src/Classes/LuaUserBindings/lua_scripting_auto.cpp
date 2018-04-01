#include "lua_scripting_auto.hpp"
#include "YWStrUtil.h"
#include "YWCsvParser.h"
#include "Triangulate.h"
#include "ActionMore.h"
#include "YWPlatform.h"
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

int lua_scripting_Triangulate_process(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Triangulate",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::vector<cocos2d::Vec2> arg0;
        ok &= luaval_to_std_vector_vec2(tolua_S, 2, &arg0, "Triangulate:process");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_Triangulate_process'", nullptr);
            return 0;
        }
        std::vector<cocos2d::Vec2> ret = Triangulate::process(arg0);
        std_vector_vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Triangulate:process",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_Triangulate_process'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_Triangulate_area(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Triangulate",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::vector<cocos2d::Vec2> arg0;
        ok &= luaval_to_std_vector_vec2(tolua_S, 2, &arg0, "Triangulate:area");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_Triangulate_area'", nullptr);
            return 0;
        }
        double ret = Triangulate::area(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Triangulate:area",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_Triangulate_area'.",&tolua_err);
#endif
    return 0;
}
static int lua_scripting_Triangulate_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Triangulate)");
    return 0;
}

int lua_register_scripting_Triangulate(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"Triangulate");
    tolua_cclass(tolua_S,"Triangulate","Triangulate","",nullptr);

    tolua_beginmodule(tolua_S,"Triangulate");
        tolua_function(tolua_S,"process", lua_scripting_Triangulate_process);
        tolua_function(tolua_S,"area", lua_scripting_Triangulate_area);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Triangulate).name();
    g_luaType[typeName] = "Triangulate";
    g_typeCast["Triangulate"] = "Triangulate";
    return 1;
}

int lua_scripting_CircleBy_initWithDuration(lua_State* tolua_S)
{
    int argc = 0;
    CircleBy* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CircleBy",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CircleBy*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_scripting_CircleBy_initWithDuration'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 4) 
    {
        double arg0;
        cocos2d::Vec2 arg1;
        double arg2;
        bool arg3;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "CircleBy:initWithDuration");

        ok &= luaval_to_vec2(tolua_S, 3, &arg1, "CircleBy:initWithDuration");

        ok &= luaval_to_number(tolua_S, 4,&arg2, "CircleBy:initWithDuration");

        ok &= luaval_to_boolean(tolua_S, 5,&arg3, "CircleBy:initWithDuration");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_CircleBy_initWithDuration'", nullptr);
            return 0;
        }
        bool ret = cobj->initWithDuration(arg0, arg1, arg2, arg3);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CircleBy:initWithDuration",argc, 4);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_CircleBy_initWithDuration'.",&tolua_err);
#endif

    return 0;
}
int lua_scripting_CircleBy_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"CircleBy",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        double arg0;
        cocos2d::Vec2 arg1;
        double arg2;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "CircleBy:create");
        ok &= luaval_to_vec2(tolua_S, 3, &arg1, "CircleBy:create");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "CircleBy:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_CircleBy_create'", nullptr);
            return 0;
        }
        CircleBy* ret = CircleBy::create(arg0, arg1, arg2);
        object_to_luaval<CircleBy>(tolua_S, "CircleBy",(CircleBy*)ret);
        return 1;
    }
    if (argc == 4)
    {
        double arg0;
        cocos2d::Vec2 arg1;
        double arg2;
        bool arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "CircleBy:create");
        ok &= luaval_to_vec2(tolua_S, 3, &arg1, "CircleBy:create");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "CircleBy:create");
        ok &= luaval_to_boolean(tolua_S, 5,&arg3, "CircleBy:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_CircleBy_create'", nullptr);
            return 0;
        }
        CircleBy* ret = CircleBy::create(arg0, arg1, arg2, arg3);
        object_to_luaval<CircleBy>(tolua_S, "CircleBy",(CircleBy*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "CircleBy:create",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_CircleBy_create'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_CircleBy_constructor(lua_State* tolua_S)
{
    int argc = 0;
    CircleBy* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_CircleBy_constructor'", nullptr);
            return 0;
        }
        cobj = new CircleBy();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"CircleBy");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CircleBy:CircleBy",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_CircleBy_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_scripting_CircleBy_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (CircleBy)");
    return 0;
}

int lua_register_scripting_CircleBy(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"CircleBy");
    tolua_cclass(tolua_S,"CircleBy","CircleBy","cc.ActionInterval",nullptr);

    tolua_beginmodule(tolua_S,"CircleBy");
        tolua_function(tolua_S,"new",lua_scripting_CircleBy_constructor);
        tolua_function(tolua_S,"initWithDuration",lua_scripting_CircleBy_initWithDuration);
        tolua_function(tolua_S,"create", lua_scripting_CircleBy_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CircleBy).name();
    g_luaType[typeName] = "CircleBy";
    g_typeCast["CircleBy"] = "CircleBy";
    return 1;
}

int lua_scripting_YWPlatform_savePictureToAlbumL(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        std::string arg1;
        ok &= luaval_to_int32_handler(tolua_S, 2,(int *)&arg0, "YWPlatform:savePictureToAlbumL");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "YWPlatform:savePictureToAlbumL");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_savePictureToAlbumL'", nullptr);
            return 0;
        }
        YWPlatform::savePictureToAlbumL(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:savePictureToAlbumL",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_savePictureToAlbumL'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_copyfile(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWPlatform:copyfile");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "YWPlatform:copyfile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_copyfile'", nullptr);
            return 0;
        }
        YWPlatform::copyfile(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:copyfile",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_copyfile'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_createNetworkStatusMonitor(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::function<void (int)> arg0;
        do {
			// Lambda binding for lua is not supported.
			assert(false);
		} while(0)
		;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_createNetworkStatusMonitor'", nullptr);
            return 0;
        }
        YWPlatform::createNetworkStatusMonitor(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:createNetworkStatusMonitor",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_createNetworkStatusMonitor'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getDocumentPath(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getDocumentPath'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::getDocumentPath();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getDocumentPath",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getDocumentPath'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_cleanAncientFiles(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::vector<std::string> arg0;
        ok &= luaval_to_std_vector_string(tolua_S, 2, &arg0, "YWPlatform:cleanAncientFiles");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_cleanAncientFiles'", nullptr);
            return 0;
        }
        YWPlatform::cleanAncientFiles(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:cleanAncientFiles",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_cleanAncientFiles'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getFilelist(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWPlatform:getFilelist");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "YWPlatform:getFilelist");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getFilelist'", nullptr);
            return 0;
        }
        std::vector<std::string> ret = YWPlatform::getFilelist(arg0, arg1);
        ccvector_std_string_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getFilelist",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getFilelist'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_pickFromAlbumL(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        int arg0;
        int arg1;
        int arg2;
        ok &= luaval_to_int32_handler(tolua_S, 2,(int *)&arg0, "YWPlatform:pickFromAlbumL");
        ok &= luaval_to_int32_handler(tolua_S, 3,(int *)&arg1, "YWPlatform:pickFromAlbumL");
        ok &= luaval_to_int32_handler(tolua_S, 4,(int *)&arg2, "YWPlatform:pickFromAlbumL");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_pickFromAlbumL'", nullptr);
            return 0;
        }
        YWPlatform::pickFromAlbumL(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:pickFromAlbumL",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_pickFromAlbumL'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_keepScreenOn(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "YWPlatform:keepScreenOn");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_keepScreenOn'", nullptr);
            return 0;
        }
        YWPlatform::keepScreenOn(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:keepScreenOn",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_keepScreenOn'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getUDID(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getUDID'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::getUDID();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getUDID",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getUDID'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getBundleVersion(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getBundleVersion'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::getBundleVersion();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getBundleVersion",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getBundleVersion'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getTimeInMilliseconds(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getTimeInMilliseconds'", nullptr);
            return 0;
        }
        long long ret = YWPlatform::getTimeInMilliseconds();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getTimeInMilliseconds",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getTimeInMilliseconds'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getNetworkStatus(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getNetworkStatus'", nullptr);
            return 0;
        }
        int ret = YWPlatform::getNetworkStatus();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getNetworkStatus",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getNetworkStatus'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_pickFromCameraL(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        int arg0;
        int arg1;
        int arg2;
        ok &= luaval_to_int32_handler(tolua_S, 2,(int *)&arg0, "YWPlatform:pickFromCameraL");
        ok &= luaval_to_int32_handler(tolua_S, 3,(int *)&arg1, "YWPlatform:pickFromCameraL");
        ok &= luaval_to_int32_handler(tolua_S, 4,(int *)&arg2, "YWPlatform:pickFromCameraL");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_pickFromCameraL'", nullptr);
            return 0;
        }
        YWPlatform::pickFromCameraL(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:pickFromCameraL",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_pickFromCameraL'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getDirectorySize(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWPlatform:getDirectorySize");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getDirectorySize'", nullptr);
            return 0;
        }
        long ret = YWPlatform::getDirectorySize(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getDirectorySize",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getDirectorySize'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_destroyNetworkStatusMonitor(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_destroyNetworkStatusMonitor'", nullptr);
            return 0;
        }
        YWPlatform::destroyNetworkStatusMonitor();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:destroyNetworkStatusMonitor",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_destroyNetworkStatusMonitor'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getFileMD5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWPlatform:getFileMD5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getFileMD5'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::getFileMD5(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getFileMD5",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getFileMD5'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_getStringMD5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "YWPlatform:getStringMD5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_getStringMD5'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::getStringMD5(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:getStringMD5",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_getStringMD5'.",&tolua_err);
#endif
    return 0;
}
int lua_scripting_YWPlatform_createUUID(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"YWPlatform",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_scripting_YWPlatform_createUUID'", nullptr);
            return 0;
        }
        std::string ret = YWPlatform::createUUID();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "YWPlatform:createUUID",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_scripting_YWPlatform_createUUID'.",&tolua_err);
#endif
    return 0;
}
static int lua_scripting_YWPlatform_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (YWPlatform)");
    return 0;
}

int lua_register_scripting_YWPlatform(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"YWPlatform");
    tolua_cclass(tolua_S,"YWPlatform","YWPlatform","",nullptr);

    tolua_beginmodule(tolua_S,"YWPlatform");
        tolua_function(tolua_S,"savePictureToAlbumL", lua_scripting_YWPlatform_savePictureToAlbumL);
        tolua_function(tolua_S,"copyfile", lua_scripting_YWPlatform_copyfile);
        tolua_function(tolua_S,"createNetworkStatusMonitor", lua_scripting_YWPlatform_createNetworkStatusMonitor);
        tolua_function(tolua_S,"getDocumentPath", lua_scripting_YWPlatform_getDocumentPath);
        tolua_function(tolua_S,"cleanAncientFiles", lua_scripting_YWPlatform_cleanAncientFiles);
        tolua_function(tolua_S,"getFilelist", lua_scripting_YWPlatform_getFilelist);
        tolua_function(tolua_S,"pickFromAlbumL", lua_scripting_YWPlatform_pickFromAlbumL);
        tolua_function(tolua_S,"keepScreenOn", lua_scripting_YWPlatform_keepScreenOn);
        tolua_function(tolua_S,"getUDID", lua_scripting_YWPlatform_getUDID);
        tolua_function(tolua_S,"getBundleVersion", lua_scripting_YWPlatform_getBundleVersion);
        tolua_function(tolua_S,"getTimeInMilliseconds", lua_scripting_YWPlatform_getTimeInMilliseconds);
        tolua_function(tolua_S,"getNetworkStatus", lua_scripting_YWPlatform_getNetworkStatus);
        tolua_function(tolua_S,"pickFromCameraL", lua_scripting_YWPlatform_pickFromCameraL);
        tolua_function(tolua_S,"getDirectorySize", lua_scripting_YWPlatform_getDirectorySize);
        tolua_function(tolua_S,"destroyNetworkStatusMonitor", lua_scripting_YWPlatform_destroyNetworkStatusMonitor);
        tolua_function(tolua_S,"getFileMD5", lua_scripting_YWPlatform_getFileMD5);
        tolua_function(tolua_S,"getStringMD5", lua_scripting_YWPlatform_getStringMD5);
        tolua_function(tolua_S,"createUUID", lua_scripting_YWPlatform_createUUID);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(YWPlatform).name();
    g_luaType[typeName] = "YWPlatform";
    g_typeCast["YWPlatform"] = "YWPlatform";
    return 1;
}
TOLUA_API int register_all_scripting(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"dd",0);
	tolua_beginmodule(tolua_S,"dd");

	lua_register_scripting_YWCsvParser(tolua_S);
	lua_register_scripting_YWPlatform(tolua_S);
	lua_register_scripting_Triangulate(tolua_S);
	lua_register_scripting_CircleBy(tolua_S);
	lua_register_scripting_YWStrUtil(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

