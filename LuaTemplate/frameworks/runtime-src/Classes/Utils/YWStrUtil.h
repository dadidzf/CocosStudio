#ifndef __YW_STR_UTIL__
#define __YW_STR_UTIL__

#include "json/document.h"
#include "cocos2d.h"

#define FORMAT(...) YWStrUtil::format(__VA_ARGS__)
#define SPLIT(str, delim) YWStrUtil::split(str, delim)
#define SPLIT2INT(str, delim) YWStrUtil::splitToInt(str, delim)
#define N2S(i) YWStrUtil::toString(i)
#define S2I(s) YWStrUtil::toInt(s)

#define INTBUF_SIZE 20

/*
 * 字符串工具
 */
class YWStrUtil
{
public:
    
	static std::string format(const char* fmt, ...);

	static std::vector<std::string> split(const std::string& str, const char delim);

    static std::vector<int> splitToInt(const std::string& str, const char delim);
    
    static std::string& trim(std::string& str);

	static std::string stringify(const rapidjson::Document& doc);
    
    static rapidjson::Document parse(const std::string& str);
    
    static cocos2d::Value toValue(const std::string& str);
    
    static cocos2d::Value toValue(const rapidjson::Document& doc);
    
    static rapidjson::Document toJson(const cocos2d::Value& map);
    
    static cocos2d::Data deflate(const std::string& str);
    
    static std::string inflate(const cocos2d::Data& data);

    static inline std::string toString(int32_t i)
    {
        char buf[INTBUF_SIZE] = { 0 };
        sprintf(buf, "%d", i);
        return std::string(buf);
    }
    static inline std::string toString(uint32_t i)
    {
        char buf[INTBUF_SIZE] = { 0 };
        sprintf(buf, "%u", i);
        return std::string(buf);
    }
	static inline std::string toString(int64_t i)
	{
		char buf[INTBUF_SIZE] = { 0 };
		sprintf(buf, "%lld", i);
		return std::string(buf);
	}
    static inline std::string toString(uint64_t i)
    {
        char buf[INTBUF_SIZE] = { 0 };
        sprintf(buf, "%llu", i);
        return std::string(buf);
    }
    static inline std::string toString(float f)
    {
        char buf[INTBUF_SIZE] = { 0 };
        sprintf(buf, "%f", f);
        return std::string(buf);
    }

	static inline int toInt(const std::string& str)
	{
		return std::atoi(str.c_str());
	}
	static inline int toInt(const char* str)
	{
		return std::atoi(str);
	}
    
    /**
     * 是否数值
     * @return 0是字符串，1是整数，2是浮点数
     */
    static int isNumber(const char* str);
    
    /**
     * 获取UTF8格式字符串的字符数量
     * @param text UTF8格式字符串
     * @param nonASCIIasCount 非ASCII字符算多少个字符
     * @return 字符数量
     */
    static int getCharacterCount(const std::string text, int nonASCIIasCount = 1);
    /**
     * 获取指定长度的文本
     * @param text            UTF8格式的字符串
     * @param length          截取长度
     * @param nonASCIIasCount 非ASCII字符算多少个字符
     * @return 截取后的字符串
     */
    static std::string cutString(const std::string text, int length, int nonASCIIasCount = 1);
    
};


#endif // !__YW_STR_UTIL__
