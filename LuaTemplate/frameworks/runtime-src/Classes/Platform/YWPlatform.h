#ifndef YWPlatform_hpp
#define YWPlatform_hpp

#include <string>
#include <vector>
#include <functional>


class YWPlatform
{
public:
    /**
     * 获取包版本号
     */
    static std::string getBundleVersion();
    /**
     * 获取唯一标识
     */
    static std::string getUDID();
	/**
	* 创建唯一标识
	*/
	static std::string createUUID();
    /**
     * 设置屏幕常亮
     */
    static void keepScreenOn(bool enable);
    
    /**
     * 获取毫秒级时间戳，win平台下是系统启动时间，其它平台是自1970以来的毫秒数
     */
    static long long getTimeInMilliseconds();
    
    /**
     * 计算MD5值
     */
    static std::string getMD5(const char* buffer, size_t size);
    static std::string getFileMD5(const std::string& filename);
    static std::string getStringMD5(const std::string& str);
    
    /**
     * 获取可写目录路径
     */
    static std::string getDocumentPath();
    
    /**
     * 获取相对路径下的文件列表
     */
    static std::vector<std::string> getFilelist(const std::string& path, const std::string& ext);
    
    /**
     * 拷贝文件
     */
    static void copyfile(std::string& srcPath, std::string& dstPath);
    
    /**
     * 清理30天未使用过的资源
     */
    static void cleanAncientFiles(const std::vector<std::string>& paths);
    /**
     * 获取目录大小
     */
    static long getDirectorySize(const std::string& path);
    
    
    /**
     * 从相册中选图片
     * @param nHandler Lua回调，参数列表(tmpFilename)
     */
    static void pickFromAlbumL(int nHandler, int expectWidth, int expectHeight);
    /**
     * 从相机获取图片
     * @param nHandler Lua回调，参数列表(tmpFilename)
     */
    static void pickFromCameraL(int nHandler, int expectWidth, int expectHeight);
    /**
     * 保存图片到系统相册
     */
    static void savePictureToAlbumL(int nHandler, const std::string& path);
    
    
    /**
     * 创建网络状态监视器，回调中形参值：0无网络，1表示wifi，2表示3g/4g
     */
    static void createNetworkStatusMonitor(const std::function<void(int)>& callback);
    /**
     * 销毁网络状态监视器
     */
    static void destroyNetworkStatusMonitor();
    /**
     * 获取当前网络状态：0无网络，1表示wifi，2表示3g/4g
     */
    static int getNetworkStatus();
};


#endif /* YWPlatform_hpp */
