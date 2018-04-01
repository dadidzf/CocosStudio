
--------------------------------
-- @module YWPlatform
-- @parent_module dd

--------------------------------
-- 保存图片到系统相册
-- @function [parent=#YWPlatform] savePictureToAlbumL 
-- @param self
-- @param #int nHandler
-- @param #string path
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 拷贝文件
-- @function [parent=#YWPlatform] copyfile 
-- @param self
-- @param #string srcPath
-- @param #string dstPath
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 创建网络状态监视器，回调中形参值：0无网络，1表示wifi，2表示3g/4g
-- @function [parent=#YWPlatform] createNetworkStatusMonitor 
-- @param self
-- @param #function callback
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 获取可写目录路径
-- @function [parent=#YWPlatform] getDocumentPath 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 清理30天未使用过的资源
-- @function [parent=#YWPlatform] cleanAncientFiles 
-- @param self
-- @param #array_table paths
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 获取相对路径下的文件列表
-- @function [parent=#YWPlatform] getFilelist 
-- @param self
-- @param #string path
-- @param #string ext
-- @return array_table#array_table ret (return value: array_table)
        
--------------------------------
-- 从相册中选图片<br>
-- param nHandler Lua回调，参数列表(tmpFilename)
-- @function [parent=#YWPlatform] pickFromAlbumL 
-- @param self
-- @param #int nHandler
-- @param #int expectWidth
-- @param #int expectHeight
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 设置屏幕常亮
-- @function [parent=#YWPlatform] keepScreenOn 
-- @param self
-- @param #bool enable
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 获取唯一标识
-- @function [parent=#YWPlatform] getUDID 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 获取包版本号
-- @function [parent=#YWPlatform] getBundleVersion 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 获取毫秒级时间戳，win平台下是系统启动时间，其它平台是自1970以来的毫秒数
-- @function [parent=#YWPlatform] getTimeInMilliseconds 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 获取当前网络状态：0无网络，1表示wifi，2表示3g/4g
-- @function [parent=#YWPlatform] getNetworkStatus 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 从相机获取图片<br>
-- param nHandler Lua回调，参数列表(tmpFilename)
-- @function [parent=#YWPlatform] pickFromCameraL 
-- @param self
-- @param #int nHandler
-- @param #int expectWidth
-- @param #int expectHeight
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 获取目录大小
-- @function [parent=#YWPlatform] getDirectorySize 
-- @param self
-- @param #string path
-- @return long#long ret (return value: long)
        
--------------------------------
-- 销毁网络状态监视器
-- @function [parent=#YWPlatform] destroyNetworkStatusMonitor 
-- @param self
-- @return YWPlatform#YWPlatform self (return value: YWPlatform)
        
--------------------------------
-- 
-- @function [parent=#YWPlatform] getFileMD5 
-- @param self
-- @param #string filename
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#YWPlatform] getStringMD5 
-- @param self
-- @param #string str
-- @return string#string ret (return value: string)
        
--------------------------------
-- 创建唯一标识
-- @function [parent=#YWPlatform] createUUID 
-- @param self
-- @return string#string ret (return value: string)
        
return nil
