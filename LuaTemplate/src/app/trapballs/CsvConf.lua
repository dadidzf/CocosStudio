local CsvConf = class(CsvConf)

function CsvConf:ctor()
    self:loadColor()
    self:loadRound()
end

function CsvConf:loadColor()
    self.m_color = cc.load("sdk").CsvUtil.parseFile("csv/color.csv")
    self.m_colorTotalProb = 0
    for _, v in ipairs(self.m_color) do
        self.m_colorTotalProb = self.m_colorTotalProb + v.probability 
    end
end

function CsvConf:loadRound()
    self.m_round = cc.load("sdk").CsvUtil.parseFile("csv/round.csv")
end

function CsvConf:getRoundCfg()
    return self.m_round
end

function CsvConf:getColorCfg()
    return self.m_color
end

function CsvConf:getRandomBgAndBtn()
    local randomProb = math.random(1, self.m_colorTotalProb)
    local count = 0
    for _, v in ipairs(self.m_color) do
        count = count + v.probability
        if randomProb <= count then
            return v
        end
    end
end


return CsvConf