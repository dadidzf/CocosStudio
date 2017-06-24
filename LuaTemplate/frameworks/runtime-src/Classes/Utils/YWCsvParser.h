#ifndef __YW_CSV_PARSER__
#define __YW_CSV_PARSER__

#include <string>
#include <vector>
#include "cocos2d.h"

/**
 * Csv解析器，支持Mac及Windows换行符，支持单元格内双引号，以及文本单元换行
 * 测试样例：
    Year,Make,Model,Description,Price
    1997,Ford,E350,"ac, abs, moon",3000.00
    1999,Chevy,"Venture ""Extended Edition""","",4900.00
    1999,Chevy,"Venture ""Extended Edition, Very Large""",,5000.00
    1996,Jeep,Grand Cherokee,"MUST SELL!
    air, moon roof, loaded",4799.00
 */
class YWCsvParser : public cocos2d::Ref
{
public:
    YWCsvParser(const std::string& path, char delimiter = ',', char quoter = '"');
    cocos2d::ValueVector readCsvRow();
    bool hasNextRow() const;
private:
    std::string _strCache;
    const char* _cursor;
    const char* _end;
    char _delimiter;
    char _quoter;
};

#endif /* defined(__YW_CSV_PARSER__) */
