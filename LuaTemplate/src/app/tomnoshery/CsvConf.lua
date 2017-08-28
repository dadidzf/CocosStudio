local CsvConf = class(CsvConf)

function CsvConf:ctor()
    self:loadFood()
end

function CsvConf:loadFood()
    self.m_food = cc.load("sdk").CsvUtil.parseFile("csv/food.csv")
end

function CsvConf:getFoodCfg()
    return self.m_food
end

return CsvConf
