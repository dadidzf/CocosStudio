#include "YWPlatform.h"
#include "YWPlatformAPI.h"
#include "CCLuaEngine.h"
#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/stat.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <windows.h>
#include <fstream>
#else
#include <dirent.h>
#include <unistd.h>
#include <fcntl.h>
#include <cstdio>
#endif

USING_NS_CC;


std::string YWPlatform::getBundleVersion()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    return p_getVersionStr();
#else
    return "0.9.28";
#endif
}


std::string YWPlatform::getUDID()
{
    return p_getUDID();
}


std::string YWPlatform::createUUID()
{
    return p_createUUID();
}


void YWPlatform::keepScreenOn(bool enable)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    p_keepScreenOn(enable);
#endif
}


long long YWPlatform::getTimeInMilliseconds()
{
    return utils::getTimeInMilliseconds();
}


std::string YWPlatform::getMD5(const char* buffer, size_t size)
{
    return p_md5(buffer, (uint32_t)size);
}

std::string YWPlatform::getStringMD5(const std::string &str)
{
    return p_md5(str.c_str(), (uint32_t)str.length());
}

std::string YWPlatform::getFileMD5(const std::string &filename)
{
    Data data = FileUtils::getInstance()->getDataFromFile(filename);
    if (data.isNull())
        return "";
    return p_md5((char*)data.getBytes(), (uint32_t)data.getSize());
}


std::string YWPlatform::getDocumentPath()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    extern std::string getCurAppPath();
    std::string dir = getCurAppPath() + "/";
#else
    std::string dir = FileUtils::getInstance()->getWritablePath();
#endif
    return dir;
}


std::vector<std::string> YWPlatform::getFilelist(const std::string& path, const std::string& ext)
{
    std::string dir;
    if (path[0] == '/')
        dir = path;
    else
        dir = YWPlatform::getDocumentPath() + path;
    std::vector<std::string> filelist;
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    extern void ansiToUtf8(char*, int);
    std::string temp = dir + "*" + ext;
    
    const int BUFFER_SIZE = 10240;
    WIN32_FIND_DATAA stFD; //存放文件信息的结构体
    HANDLE h = FindFirstFileA(temp.c_str(), &stFD);
    if (h != INVALID_HANDLE_VALUE)
    {
        char buf[BUFFER_SIZE] = { 0 };
        strcpy(buf, stFD.cFileName);
        ansiToUtf8(buf, BUFFER_SIZE);
        buf[strlen(buf) - 4] = '\0';
        filelist.push_back(buf);
        while (FindNextFileA(h, &stFD))
        {
            memset(buf, 0, BUFFER_SIZE);
            strcpy(buf, stFD.cFileName);
            ansiToUtf8(buf, BUFFER_SIZE);
            buf[strlen(buf) - 4] = '\0';
            filelist.emplace_back(buf);
        }
        FindClose(h);
    }
#else
    DIR* dp = opendir(dir.c_str());
    if (dp)
    {
        struct dirent* entry;
        while ((entry = readdir(dp)) != nullptr)
        {
            if (strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0)
                continue;
            
            const char* ret = entry->d_name;
            ret = strstr(ret, ext.c_str());
            if (ret != nullptr)
                filelist.emplace_back(entry->d_name, ret - entry->d_name);
        }
        closedir(dp);
    }
#endif
    return filelist;
}


void YWPlatform::copyfile(std::string &srcPath, std::string &dstPath)
{
    if (srcPath[0] != '/')
        srcPath = YWPlatform::getDocumentPath() + srcPath;
    if (dstPath[0] != '/')
        dstPath = YWPlatform::getDocumentPath() + dstPath;
    
    std::string path(dstPath);
    path.erase(path.rfind('/'));
    FileUtils::getInstance()->createDirectory(path);
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    std::ifstream src(srcPath, std::ios::binary);
    std::ofstream dst(dstPath, std::ios::binary);
    dst << src.rdbuf();
#else
    char buf[BUFSIZ];
    size_t size;
    
    int source = open(srcPath.c_str(), O_RDONLY, 0);
    int dest = open(dstPath.c_str(), O_WRONLY | O_CREAT, S_IRWXU | S_IRWXG | S_IRWXO);
    
    while ((size = read(source, buf, BUFSIZ)) > 0)
        write(dest, buf, size);
    
    close(source);
    close(dest);
    
    chmod(dstPath.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
#endif
}


#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

void recurCleanAncientFile(const std::string& path, time_t threshold)
{
    DIR* dp = opendir(path.c_str());
    if (dp)
    {
        struct dirent* entry;
        while ((entry = readdir(dp)) != nullptr)
        {
            if (strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0)
                continue;
            std::string file(path);
            file += entry->d_name;
            
            struct stat st;
            if (stat(file.c_str(), &st) == 0)
            {
                if (S_ISDIR(st.st_mode))
                {
                    file += "/";
                    recurCleanAncientFile(file, threshold);
                }
                else
                {
                    if (st.st_mtime < threshold)
                        remove(file.c_str());
                }
            }
        }
        closedir(dp);
    }
}

void recurGetFileSize(const std::string& path, long * size)
{
    DIR* dp = opendir(path.c_str());
    if (dp)
    {
        struct dirent* entry;
        while ((entry = readdir(dp)) != nullptr)
        {
            if (strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0)
                continue;
            std::string file(path);
            file += entry->d_name;
            
            struct stat st;
            if (stat(file.c_str(), &st) == 0)
            {
                if (S_ISDIR(st.st_mode))
                {
                    file += "/";
                    recurGetFileSize(file, size);
                }
                else
                {
                    *size += st.st_size;
                }
            }
        }
        closedir(dp);
    }
}

#endif


void YWPlatform::cleanAncientFiles(const std::vector<std::string>& paths)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    time_t threshold = time(nullptr) - 3600 * 24 * 30;
    for (auto path : paths)
        recurCleanAncientFile(YWPlatform::getDocumentPath() + path, threshold);
#endif
}


long YWPlatform::getDirectorySize(const std::string &path)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    long size = 0;
    recurGetFileSize(YWPlatform::getDocumentPath() + path, &size);
    return size;
#else
    return 0L;
#endif
}



void YWPlatform::pickFromAlbumL(int nHandler, int expectWidth, int expectHeight)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    p_pickFromAlbum([nHandler](const std::string& filename){
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushString(filename.c_str());
        stack->executeFunctionByHandler(nHandler, 1);
        stack->removeScriptHandler(nHandler);
        stack->clean();
    }, expectWidth, expectHeight);
#else
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    stack->pushString("");
    stack->executeFunctionByHandler(nHandler, 1);
    stack->removeScriptHandler(nHandler);
    stack->clean();
#endif
}


void YWPlatform::pickFromCameraL(int nHandler, int expectWidth, int expectHeight)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    p_pickFromCamera([nHandler](const std::string& filename){
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushString(filename.c_str());
        stack->executeFunctionByHandler(nHandler, 1);
        stack->removeScriptHandler(nHandler);
        stack->clean();
    }, expectWidth, expectHeight);
#else
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    stack->pushString("");
    stack->executeFunctionByHandler(nHandler, 1);
    stack->removeScriptHandler(nHandler);
    stack->clean();
#endif
    
}


void YWPlatform::savePictureToAlbumL(int nHandler, const std::string &path)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    std::string dir;
    if (path[0] == '/')
        dir = path;
    else
        dir = YWPlatform::getDocumentPath() + path;
    
    p_saveToAlbum([nHandler](bool result){
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushBoolean(result);
        stack->executeFunctionByHandler(nHandler, 1);
        stack->removeScriptHandler(nHandler);
        stack->clean();
    }, dir);
#else
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    stack->pushBoolean(false);
    stack->executeFunctionByHandler(nHandler, 1);
    stack->removeScriptHandler(nHandler);
    stack->clean();
#endif
}


void YWPlatform::createNetworkStatusMonitor(const std::function<void (int)> &callback)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    p_createNetworkStatusMonitor(callback);
#endif
}


void YWPlatform::destroyNetworkStatusMonitor()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    p_destroyNetworkStatusMonitor();
#endif
}


int YWPlatform::getNetworkStatus()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    return p_getNetworkStatus();
#else
    return 1;
#endif
}

