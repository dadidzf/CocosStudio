#ifndef YWPlatformAPI_h
#define YWPlatformAPI_h

#include <string>
#include <functional>


std::string p_getVersionStr();

std::string p_getUDID();

std::string p_createUUID();

std::string p_md5(const char* buf, uint32_t size);


#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

void p_keepScreenOn(bool enable);


void p_pickFromAlbum(const std::function<void(const std::string& filename)>& callback, int expectWidth, int expectHeight);

void p_pickFromCamera(const std::function<void(const std::string& filename)>& callback, int expectWidth, int expectHeight);

void p_saveToAlbum(const std::function<void(bool)>& callback, const std::string& path);


void p_createNetworkStatusMonitor(const std::function<void(int)>& callback);

void p_destroyNetworkStatusMonitor();

int p_getNetworkStatus();

#endif

#endif /* YWPlatformAPI_h */
