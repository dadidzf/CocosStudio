
--------------------------------
-- @module YWStrUtil
-- @parent_module dd

--------------------------------
-- 
-- @function [parent=#YWStrUtil] stringify 
-- @param self
-- @param #json.GenericDocument<json.UTF8<char>, json.MemoryPoolAllocator<json.CrtAllocator>, json.CrtAllocator> doc
-- @return string#string ret (return value: string)
        
--------------------------------
-- 是否数值<br>
-- return 0是字符串，1是整数，2是浮点数
-- @function [parent=#YWStrUtil] isNumber 
-- @param self
-- @param #char str
-- @return int#int ret (return value: int)
        
--------------------------------
-- 获取指定长度的文本<br>
-- param text            UTF8格式的字符串<br>
-- param length          截取长度<br>
-- param nonASCIIasCount 非ASCII字符算多少个字符<br>
-- return 截取后的字符串
-- @function [parent=#YWStrUtil] cutString 
-- @param self
-- @param #string text
-- @param #int length
-- @param #int nonASCIIasCount
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#YWStrUtil] parse 
-- @param self
-- @param #string str
-- @return GenericDocument<UTF8<char>, MemoryPoolAllocator<CrtAllocator>, CrtAllocator>#GenericDocument<UTF8<char>, MemoryPoolAllocator<CrtAllocator>, CrtAllocator> ret (return value: json.GenericDocument<json.UTF8<char>, json.MemoryPoolAllocator<json.CrtAllocator>, json.CrtAllocator>)
        
--------------------------------
-- 获取UTF8格式字符串的字符数量<br>
-- param text UTF8格式字符串<br>
-- param nonASCIIasCount 非ASCII字符算多少个字符<br>
-- return 字符数量
-- @function [parent=#YWStrUtil] getCharacterCount 
-- @param self
-- @param #string text
-- @param #int nonASCIIasCount
-- @return int#int ret (return value: int)
        
return nil
