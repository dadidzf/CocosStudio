#include "YWCsvParser.h"
#include "YWStrUtil.h"

static const int STR_BUFFER_SIZE {1024 * 10};

YWCsvParser::YWCsvParser(const std::string& path, char delimiter, char quoter)
: _delimiter(delimiter)
, _quoter(quoter)
{
    _strCache = cocos2d::FileUtils::getInstance()->getStringFromFile(path);
    _cursor = &_strCache[0];
    _end = &_strCache[_strCache.size()];
}


cocos2d::Value _getValue(char* buff)
{
    int type = YWStrUtil::isNumber(buff);
    if (type == 1)
        return cocos2d::Value(std::atoi(buff));
    else if (type == 2)
        return cocos2d::Value(std::atof(buff));
    return cocos2d::Value(buff);
}


cocos2d::ValueVector YWCsvParser::readCsvRow()
{
	cocos2d::ValueVector row;
    bool inQuoter = false;
    
    char buff[STR_BUFFER_SIZE] = {0};
    int index = 0;
    
    while(_cursor < _end)
    {
        char c = *_cursor;
        if (!inQuoter && c == _quoter) // begin quoter
        {
            inQuoter = true;
        }
        else if (inQuoter && c == _quoter) // the quoter in quoter
        {
            if (*(_cursor + 1) == _quoter) // double quoter to one
                buff[index++] = (++_cursor, c);
            else // end quoter
                inQuoter = false;
        }
        else if (!inQuoter && c == _delimiter) // end cell
        {
            row.push_back(_getValue(buff));
            memset(buff, 0, index);
            index = 0;
        }
        else if (!inQuoter && (c == '\r' || c == '\n')) // end row
        {
            row.push_back(_getValue(buff));
            memset(buff, 0, index);
            index = 0;
            
            ++_cursor;
            if (_cursor < _end && *_cursor == '\n')
                ++_cursor;
            break;
        }
        else
        {
            buff[index++] = c;
        }
        
        ++_cursor;
        if (_cursor == _end && (index > 0 || *(_cursor - 1) == _delimiter))
        {
            row.push_back(_getValue(buff));
            memset(buff, 0, index);
            index = 0;
        }
    }
    return row;
}


bool YWCsvParser::hasNextRow() const
{
    return _cursor < _end;
}

