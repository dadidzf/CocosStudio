-- Csv解析工具
local CsvUtil = class("CsvUtil")

--[[ 示例 解析csv文件
local o = cc.load("utils").CsvUtil.parseFile("res/configs/foundation.csv")
dump(o)
--]]
function CsvUtil.parseFile(path)
    print("[CSV Load]: " ..  path)
    local parser = dd.YWCsvParser:new(path)
    local index = -1
    local header = nil
    local ret = {}
    local hasIdField = false
    while parser:hasNextRow() do
    	index = index + 1
        local row = parser:readCsvRow()
        if index == 0 then
        	header = row
            for _, v in ipairs(header) do
                if v == "id" then
                    hasIdField = true
                    break
                end
            end
        else
        	local t = {}
        	for i,v in ipairs(row) do
        		t[header[i]] = v
        	end
            if hasIdField then
                ret[t["id"]] = t
            else
            	table.insert(ret, t)
            end
        end
    end
    return ret
end

return CsvUtil