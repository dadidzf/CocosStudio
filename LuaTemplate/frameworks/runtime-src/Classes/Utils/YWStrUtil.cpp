#include "YWStrUtil.h"
#include "json/writer.h"
#include "json/stringbuffer.h"
#include <zlib.h>


static const int STR_BUFFER_SIZE {1024 * 40};

std::string YWStrUtil::format(const char * fmt, ...)
{
	char buf[STR_BUFFER_SIZE] = { 0 };
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, STR_BUFFER_SIZE, fmt, args);
	va_end(args);
	return std::string(buf);
}

std::vector<std::string> _split(const char* begin, const char* end, const char delim)
{
	std::vector<std::string> ret;
	const char* p = begin;
	while (p <= end)
	{
		if (*p == delim)
		{
            ret.emplace_back(begin, p);
			p = begin = p + 1;
			continue;
		}

		++p;
	}
    ret.emplace_back(begin, end);
	return ret;
}

std::vector<std::string> YWStrUtil::split(const std::string& str, const char delim)
{
	return _split(&str[0], &str[str.size()], delim);
}

std::vector<int> _split2Int(const char* begin, const char* end, const char delim)
{
    char buf[INTBUF_SIZE];
    std::vector<int> ret;
    const char* p = begin;
    while (p <= end)
    {
        if (*p == delim)
        {
            memset(buf, 0, INTBUF_SIZE);
            memcpy(buf, begin, p - begin);
            ret.emplace_back(atoi(buf));
            p = begin = p + 1;
            continue;
        }
        
        ++p;
    }
    memset(buf, 0, INTBUF_SIZE);
    memcpy(buf, begin, end - begin);
    ret.emplace_back(atoi(buf));
    return ret;
}

std::vector<int> YWStrUtil::splitToInt(const std::string &str, const char delim)
{
    return _split2Int(&str[0], &str[str.size()], delim);
}

std::string& YWStrUtil::trim(std::string &str)
{
    auto predicate = [](const char& ch){ return ch != ' '; };
    str.erase(str.begin(), std::find_if(str.begin(), str.end(), predicate));
    str.erase(std::find_if(str.rbegin(), str.rend(), predicate).base(), str.end());
    return str;
}

std::string YWStrUtil::stringify(const rapidjson::Document & doc)
{
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
	const char* ret = buffer.GetString();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	char buf[STR_BUFFER_SIZE] = { 0 };
	strcpy(buf, ret);
	extern void utf8ToAnsi(char*, int);
	utf8ToAnsi(buf, STR_BUFFER_SIZE);
	return buf;
#else
	return ret;
#endif
}


rapidjson::Document YWStrUtil::parse(const std::string &str)
{
    rapidjson::Document d;
    if (str.length() > 0)
    {
        d.Parse(str.c_str());
        if (d.HasParseError())
            CCLOGERROR("\nERROR: [JSON parse error] Offset(%zu) <%s>\n", d.GetErrorOffset(), str.c_str());
    }
    return d;
}


cocos2d::Value _convertToValue(const rapidjson::Value& doc)
{
    if(doc.IsObject())
    {
        cocos2d::ValueMap valMap;
        for (auto itr = doc.MemberBegin(); itr != doc.MemberEnd(); ++itr)
            valMap[itr->name.GetString()] = _convertToValue(itr->value);
        return cocos2d::Value(valMap);
    }
    else if (doc.IsArray())
    {
        cocos2d::ValueVector valVec;
        for (auto itr = doc.Begin(); itr != doc.End(); ++itr)
            valVec.push_back(_convertToValue(*itr));
        return cocos2d::Value(valVec);
    }
    else if (doc.IsBool())
        return cocos2d::Value(doc.GetBool());
    else if (doc.IsInt())
        return cocos2d::Value(doc.GetInt());
    else if (doc.IsDouble())
        return cocos2d::Value(doc.GetDouble());
    else if (doc.IsString())
        return cocos2d::Value(doc.GetString());
    else if (doc.IsNull())
        return cocos2d::Value();
    else
        CCASSERT(false, "Not support json value type");
}


cocos2d::Value YWStrUtil::toValue(const std::string &str)
{
    rapidjson::Document d;
    if (str.length() > 0)
    {
        d.Parse(str.c_str());
        if (d.HasParseError())
            CCLOGERROR("\nERROR: [JSON parse error] Offset(%zu) <%s>\n", d.GetErrorOffset(), str.c_str());
    }
    return _convertToValue(d);
}


cocos2d::Value YWStrUtil::toValue(const rapidjson::Document &doc)
{
    return _convertToValue(doc);
}


void _convertToJson(const cocos2d::Value& value, rapidjson::Value& doc, rapidjson::MemoryPoolAllocator<>& allocator)
{
    auto type = value.getType();
    if(type == cocos2d::Value::Type::MAP)
    {
        doc.SetObject();
        const cocos2d::ValueMap& map = value.asValueMap();
        for(auto itr = map.begin(); itr != map.end(); ++itr)
        {
            rapidjson::Value n;
            n.SetString(itr->first.c_str(), allocator);
            rapidjson::Value v;
            _convertToJson(itr->second, v, allocator);
            doc.AddMember(n, v, allocator);
        }
    }
    else if(type == cocos2d::Value::Type::VECTOR)
    {
        doc.SetArray();
        const cocos2d::ValueVector& vector = value.asValueVector();
        for(auto itr = vector.begin(); itr != vector.end(); ++itr)
        {
            rapidjson::Value v;
            _convertToJson(*itr, v, allocator);
            doc.PushBack(v, allocator);
        }
    }
    else if(type == cocos2d::Value::Type::STRING)
        doc.SetString(value.asString().c_str(), allocator);
    else if(type == cocos2d::Value::Type::INTEGER || type == cocos2d::Value::Type::BYTE)
        doc.SetInt(value.asInt());
    else if(type == cocos2d::Value::Type::DOUBLE || type == cocos2d::Value::Type::FLOAT)
        doc.SetDouble(value.asDouble());
    else if(type == cocos2d::Value::Type::BOOLEAN)
        doc.SetBool(value.asBool());
    else if (type == cocos2d::Value::Type::NONE)
        doc.SetNull();
    else
        CCASSERT(false, "Not support cocos value type");
}


rapidjson::Document YWStrUtil::toJson(const cocos2d::Value &map)
{
    rapidjson::Document doc;
    _convertToJson(map, doc, doc.GetAllocator());
    return doc;
}


cocos2d::Data YWStrUtil::deflate(const std::string &str)
{
    unsigned char out[STR_BUFFER_SIZE];
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    
    strm.avail_in = (uInt)str.size();
    strm.next_in = (unsigned char*)str.c_str();
    strm.avail_out = STR_BUFFER_SIZE;
    strm.next_out = out;
    
    cocos2d::Data result;
    int ret = deflateInit(&strm, Z_DEFAULT_COMPRESSION);
    if (ret != Z_OK)
    {
        CCLOGERROR("Zlib cannot be initialize!");
        return result;
    }
    
    do
    {
        ret = ::deflate(&strm, Z_FINISH);
        if (ret != Z_STREAM_END && strm.avail_out == 0)
        {
            CCLOGERROR("Zlib buffer is too small!");
            break;
        }
        
    } while (ret != Z_STREAM_END);
    
    deflateEnd(&strm);
    if (ret == Z_STREAM_END);
        result.copy(out, STR_BUFFER_SIZE - strm.avail_out);
    return result;
}


std::string YWStrUtil::inflate(const cocos2d::Data &data)
{
    unsigned char out[STR_BUFFER_SIZE];
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    
    strm.avail_in = (uInt)data.getSize();
    strm.next_in = data.getBytes();
    strm.avail_out = STR_BUFFER_SIZE;
    strm.next_out = out;
    
    std::string result;
    int ret = inflateInit(&strm);
    if (ret != Z_OK)
    {
        CCLOGERROR("Zlib cannot be initialize!");
        return result;
    }
    
    do
    {
        ret = ::inflate(&strm, Z_NO_FLUSH);
        if (ret == Z_NEED_DICT || ret == Z_DATA_ERROR)
        {
            CCLOGERROR("Zlib data error!");
            break;
        }
        if (ret == Z_MEM_ERROR)
        {
            CCLOGERROR("Zlib cannot alloc memory!");
            break;
        }
        if (ret != Z_STREAM_END && strm.avail_out == 0)
        {
            CCLOGERROR("Zlib buffer is too small!");
            break;
        }
        
    } while (ret != Z_STREAM_END);
    
    inflateEnd(&strm);
    if (ret == Z_STREAM_END)
        result.assign((char*)out, STR_BUFFER_SIZE - strm.avail_out);
    return result;
}


int YWStrUtil::isNumber(const char *str)
{
    const char* c = str;
    if (*c == '+' || *c == '-') // 首字符为正负号直接跳过
        ++c;
    
    bool hasDot = false;
    bool hasNum = false;
    while (*c != 0)
    {
        if (*c >= '0' && *c <= '9')
            hasNum = true;
        else if (*c == '.' && hasDot == false)
            hasDot = true;
        else // 非数值或点号，多于一个点号，必定是字符串
            return 0;
        ++c;
    }
    return hasNum ? (hasDot ? 2 : 1) : 0;
}


int YWStrUtil::getCharacterCount(const std::string text, int nonASCIIasCount)
{
    int count = 0;
    for (auto c : text)
    {
        if ((c & 0xc0) == 0xc0)
            count += nonASCIIasCount;
        else if (c >> 7 == 0)
            ++count;
    }
    return count;
}


std::string YWStrUtil::cutString(const std::string text, int length, int nonASCIIasCount)
{
    int count = 0;
    size_t size = text.length();
    for (size_t i = 0; i < size; ++i)
    {
        auto c = text[i];
        if ((c & 0xc0) == 0xc0)
            count += nonASCIIasCount;
        else if (c >> 7 == 0)
            ++count;
        if (count > length)
            return text.substr(0, i);
    }
    return text;
}



#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

void utf8ToAnsi(char * buf, int size)
{
    int wcsLen = ::MultiByteToWideChar(CP_UTF8, NULL, buf, strlen(buf), NULL, 0);
    wchar_t* wszString = new wchar_t[wcsLen + 1];
    ::MultiByteToWideChar(CP_UTF8, NULL, buf, strlen(buf), wszString, wcsLen);
    wszString[wcsLen] = '\0';
    
    int ansiLen = ::WideCharToMultiByte(CP_ACP, NULL, wszString, wcslen(wszString), NULL, 0, NULL, NULL);
    memset(buf, 0, size);
    ::WideCharToMultiByte(CP_ACP, NULL, wszString, wcslen(wszString), buf, ansiLen, NULL, NULL);
    delete[] wszString;
}

void ansiToUtf8(char * buf, int size)
{
    int wcsLen = ::MultiByteToWideChar(CP_ACP, NULL, buf, strlen(buf), NULL, 0);
    wchar_t* wszString = new wchar_t[wcsLen + 1];
    ::MultiByteToWideChar(CP_ACP, NULL, buf, strlen(buf), wszString, wcsLen);
    wszString[wcsLen] = '\0';
    
    int utf8Len = ::WideCharToMultiByte(CP_UTF8, NULL, wszString, wcslen(wszString), NULL, 0, NULL, NULL);
    memset(buf, 0, size);
    ::WideCharToMultiByte(CP_UTF8, NULL, wszString, wcslen(wszString), buf, utf8Len, NULL, NULL);
    delete[] wszString;
}


#endif
