#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "lua_binding_manual.h"
#include "network/CCDownloader.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

USING_NS_CC;

static int& lua_dd_Downloader_get_handler()
{
    static int s_downloaderHandler = 0;
    return s_downloaderHandler;
}

static void lua_dd_Downloader_constructor_setCallBacks(network::Downloader* downloader)
{
	// define progress callback
	downloader->onTaskProgress = [](const network::DownloadTask& task,
		int64_t bytesReceived,
		int64_t totalBytesReceived,
		int64_t totalBytesExpected)
	{
        int handler = lua_dd_Downloader_get_handler();
		if (0 != handler)
		{
			LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushString("onProgress");
            stack->pushString(task.identifier.c_str());
			stack->pushLong(bytesReceived);
			stack->pushLong(totalBytesReceived);
			stack->pushLong(totalBytesExpected);
			stack->executeFunctionByHandler(handler, 5);
			stack->clean();
		}
	};
    
    // define success callback
    downloader->onDataTaskSuccess = [](const cocos2d::network::DownloadTask& task,
                                           std::vector<unsigned char>& data)
    {
        int handler = lua_dd_Downloader_get_handler();
		if (0 != handler)
		{
            CCLOG("Success to download data");
			LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushString("onDataSuccess");
            stack->pushString(task.identifier.c_str());
            stack->pushString(std::string(data.begin(), data.end()).c_str(), (int)data.size());
			stack->executeFunctionByHandler(handler, 3);
			stack->clean();
		}
    };

	downloader->onFileTaskSuccess = [](const cocos2d::network::DownloadTask& task)
	{
		CCLOG("Success to download file : %s to path(%s)"
			, task.requestURL.c_str()
			, task.storagePath.c_str());
        int handler = lua_dd_Downloader_get_handler();
		if (0 != handler)
		{
			LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushString("onFileSuccess");
            stack->pushString(task.identifier.c_str());
			stack->executeFunctionByHandler(handler, 2);
			stack->clean();
		}
	};

	downloader->onTaskError = [](const cocos2d::network::DownloadTask& task,
		int errorCode,
		int errorCodeInternal,
		const std::string& errorStr)
	{
		CCLOG("Failed to download : %s to path(%s) error code(%d), internal error code(%d) desc(%s)"
			, task.requestURL.c_str()
			, task.storagePath.c_str()
			, errorCode
			, errorCodeInternal
			, errorStr.c_str());
        int handler = lua_dd_Downloader_get_handler();
		if (0 != handler)
		{
			LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushString("onTaskFailed");
            stack->pushString(task.identifier.c_str());
			stack->executeFunctionByHandler(handler, 2);
			stack->clean();
		}
	};
}

static void lua_dd_Downloader_remove_handler(lua_State* L)
{
    int handler = lua_dd_Downloader_get_handler();
    if (0 != handler)
    {
        toluafix_remove_function_by_refid(L, handler);
    }
}

static int lua_collect_Downloader (lua_State* L)
{
    network::Downloader* self = (network::Downloader*) tolua_tousertype(L,1,0);
	CC_SAFE_DELETE(self);
    lua_dd_Downloader_remove_handler(L);

    return 0;
}

static int lua_dd_Downloader_constructor(lua_State* L)
{
    int argc = 0;
	network::Downloader* self = nullptr;
    
    argc = lua_gettop(L)-1;
    if (argc == 0)
    {
		self = new (std::nothrow) network::Downloader();
        tolua_pushusertype(L, (void*)self, "dd.Downloader");
        tolua_register_gc(L, lua_gettop(L));
		lua_dd_Downloader_constructor_setCallBacks(self);
        return 1;
    }
    
    luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d \n", "Downloader",argc, 0);
    return 0;
}

/*
params:
	@url
	@task Id -- string
*/
static int lua_dd_Downloader_downloadData(lua_State* L)
{
    int argc = 0;
	network::Downloader* self = nullptr;
	bool ok = true;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"dd.Downloader",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (network::Downloader*) tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_dd_Downloader_downloadData'\n", nullptr);
		return 0;
    }
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 2)
	{
		std::string arg0;
		std::string arg1;

		ok &= luaval_to_std_string(L, 2, &arg0, "Downloader:downloadData");
		ok &= luaval_to_std_string(L, 3, &arg1, "Downloader:downloadData");

		if (!ok)
		{
			tolua_error(L, "invalid arguments in function 'lua_dd_Downloader_downloadData'", nullptr);
			return 0;
		}

		self->createDownloadDataTask(arg0, arg1);

		return 0;
	}

    luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d\n", "dd.Downloader.downloadData",argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_dd_Downloader_downloadData'.",&tolua_err);
    return 0;
#endif
}

/*
params:
	@url
	@Absolute FilePath
	@task Id -- string
*/
static int lua_dd_Downloader_downloadFile(lua_State* L)
{
    int argc = 0;
	network::Downloader* self = nullptr;
	bool ok = true;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"dd.Downloader",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (network::Downloader*) tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_dd_Downloader_downloadFile'\n", nullptr);
		return 0;
    }
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 3)
	{
		std::string arg0;
		std::string arg1;
        std::string arg2;

		ok &= luaval_to_std_string(L, 2, &arg0, "Downloader:downloadFile");
		ok &= luaval_to_std_string(L, 3, &arg1, "Downloader:downloadFile");
		ok &= luaval_to_std_string(L, 4, &arg2, "Downloader:downloadFile");

		if (!ok)
		{
			tolua_error(L, "invalid arguments in function 'lua_dd_Downloader_downloadFile'", nullptr);
			return 0;
		}

		self->createDownloadFileTask(arg0, arg1, arg2);

		return 0;
	}

    luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d\n", "dd.Downloader.downloadFile",argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_dd_Downloader_downloadFile'.",&tolua_err);
    return 0;
#endif
}

static int lua_dd_Downloader_registCallBack(lua_State* L)
{
    int argc = 0;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L, 1, "dd.Downloader", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 1)
	{
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(L, 2, "LUA_FUNCTION", 0, &tolua_err))
            goto tolua_lerror;
#endif
        
        lua_dd_Downloader_remove_handler(L);
        int& handler = lua_dd_Downloader_get_handler();
        handler = (toluafix_ref_function(L, 2, 0));

		return 0;
	}

    luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d\n", "dd.Downloader.registCallBack",argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_dd_Downloader_registerCallBack'.",&tolua_err);
    return 0;
#endif
}

static void extendDownloader(lua_State* L)
{
	tolua_usertype(L, "dd.Downloader");
    tolua_cclass(L, "Downloader", "dd.Downloader", "", lua_collect_Downloader);
    tolua_beginmodule(L, "Downloader");
        tolua_function(L, "new", lua_dd_Downloader_constructor);
        tolua_function(L, "downloadFile", lua_dd_Downloader_downloadFile);
        tolua_function(L, "downloadData", lua_dd_Downloader_downloadData);
        tolua_function(L, "registCallBack", lua_dd_Downloader_registCallBack);
	tolua_endmodule(L);
}

int register_user_manual(lua_State* L)
{
	tolua_open(L);
	tolua_module(L, "dd",0);

	tolua_beginmodule(L,"dd");

	extendDownloader(L);

	tolua_endmodule(L);
	return 1;
}
