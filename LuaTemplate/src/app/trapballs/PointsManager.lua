local PointsManager = class("PointsManager")
local Cjson = require("cjson")

function PointsManager:ctor()
    self.m_pointList = {} -- points list (hash table)
    self.m_lineList = {} -- every line store two points index 

    self.m_pointMapPointsList = {} -- points index that one point linked
    self.m_linePointsList = {}  -- every line store two points
end

function PointsManager:isPointValid(pt)
    if self:getPtIndex(pt) or self:getPtLine(pt) or pt.x < self.m_minX or
        pt.x > self.m_maxX or pt.y < self.m_minY or pt.y > self.m_maxY then
        return false
    end

    return true
end

function PointsManager:encode()
    local tb = {self.m_pointList, self.m_lineList}
    return Cjson.encode(tb)
end

function PointsManager:load(jsonStr)
    local tb = Cjson.decode(jsonStr)
    self.m_pointList = tb[1]
    self.m_lineList = tb[2]

    self:updateList()
end

function PointsManager:updateList()
    print("PointsManager:updateList")
    dump(self.m_lineList)
    self:updateLinePointsList()
    self:updatePointMapPointsList()
    self:updateMaxMinPt()

    dump(self.m_pointList)
    dump(self.m_pointMapPointsList)
end

function PointsManager:updateMaxMinPt()
    local minX = 0
    local minY = 0
    local maxX = 0 
    local maxY = 0
    for _, pt in pairs(self.m_pointList) do
        if minX > pt.x then minX = pt.x end
        if minY > pt.y then minY = pt.y end
        if maxX < pt.x then maxX = pt.x end 
        if maxY < pt.y then maxY = pt.y end
    end

    self.m_minX = minX
    self.m_minY = minY
    self.m_maxX = maxX
    self.m_maxY = maxY
end

function PointsManager:updatePointMapPointsList()
    self.m_pointMapPointsList = {}
    for _, ptIndexPair in pairs(self.m_lineList) do
        local pt1Index = ptIndexPair[1]
        local pt2Index = ptIndexPair[2]
        if not self.m_pointMapPointsList[pt1Index] then
            self.m_pointMapPointsList[pt1Index] = {}
        end
        if not self.m_pointMapPointsList[pt2Index] then
            self.m_pointMapPointsList[pt2Index] = {}
        end
        self.m_pointMapPointsList[pt1Index][pt2Index] = true
        self.m_pointMapPointsList[pt2Index][pt1Index] = true
    end
end

function PointsManager:updateLinePointsList()
    self.m_linePointsList = {}
    for lineIndex, ptIndexPair in pairs(self.m_lineList) do
        local ptPair = {}
        for _, index in pairs(ptIndexPair) do
            table.insert(ptPair, self.m_pointList[index])
        end

        table.insert(self.m_linePointsList, ptPair)
    end
end

function PointsManager:getLinePointsList()
    return self.m_linePointsList
end

function PointsManager:getMaxMinList()
    return self.m_maxMinList
end

--[[ 
    add one new line logic
--]]
function PointsManager:addLine(pt1, pt2)
    print("PointsManager:addLine")
    dump(pt1)
    dump(pt2)

    local startTime = socket.gettime()
    local pt1Index = self:getPtIndex(pt1)
    local pt1LineIndex = self:getPtLine(pt1)

    if pt1Index then
    elseif pt1LineIndex then
        print("1")
        pt1Index = self:insertPointToLine(pt1, pt1LineIndex)
    else
        print("2")
        pt1Index = self:addSinglePoint(pt1)
    end

    local pt2Index = self:getPtIndex(pt2)
    local pt2LineIndex = self:getPtLine(pt2)
    if pt2Index then
    elseif pt2LineIndex then
        print("3")
        pt2Index = self:insertPointToLine(pt2, pt2LineIndex)
    else
        print("4")
        pt2Index = self:addSinglePoint(pt2)
    end 

    self:linkTwoPoints(pt1Index, pt2Index)

    self:updateList()

    print("PointsManager:addLine cost time", socket.gettime() - startTime)
end

-- is this point alreay in self.m_pointList
function PointsManager:getPtIndex(pt)
    for index, comparePt in pairs(self.m_pointList) do
        if comparePt.x == pt.x and comparePt.y == pt.y then
            return index
        end
    end

    return nil
end

function PointsManager:getPtLine(pt)
    for index, ptIndexTb in pairs(self.m_lineList) do
        local pt1 = self.m_pointList[ptIndexTb[1]]
        local pt2 = self.m_pointList[ptIndexTb[2]]
        local diff = dd.Constants.EDGE_SEG_WIDTH

        if (pt1.x == pt2.x and pt1.x == pt.x and ((pt.y - pt1.y)*(pt.y - pt2.y)) < 0) or
            (pt1.y == pt2.y and pt2.y == pt.y and ((pt.x - pt1.x)*(pt.x - pt2.x)) < 0) then
            return index
        end
    end
    return nil
end

function PointsManager:addSinglePoint(pt)
    local newPtIndex = #self.m_pointList + 1
    table.insert(self.m_pointList, newPtIndex, pt)

    return newPtIndex
end

function PointsManager:insertPointToLine(newPt, lineIndex)
    local newPtIndex = #self.m_pointList + 1
    local line = self.m_lineList[lineIndex]
    local linePt1Index = line[1]
    local linePt2Index = line[2]

    table.insert(self.m_pointList, newPtIndex, newPt)

    table.remove(self.m_lineList, lineIndex)
    table.insert(self.m_lineList, {newPtIndex, linePt1Index})
    table.insert(self.m_lineList, {newPtIndex, linePt2Index})

    return newPtIndex
end

function PointsManager:linkTwoPoints(ptIndex1, ptIndex2)
    table.insert(self.m_lineList, {ptIndex1, ptIndex2})
    self:fixOneLineDistancePoint(#self.m_lineList)
end

function PointsManager:fixOneLineDistancePoint(lineIndex) 
    self:updatePointMapPointsList()

    local pt1Index = self.m_lineList[lineIndex][1]
    local pt2Index = self.m_lineList[lineIndex][2]

    local pt1 = self.m_pointList[pt1Index]
    local pt2 = self.m_pointList[pt2Index]
    local isHorizontal = pt1.y == pt2.y
    local y = pt1.y
    local x = pt1.x
    local lineWidth = dd.Constants.EDGE_SEG_WIDTH

    print("PointsManager:fixOneLineDistancePoint 1", pt1.x, pt1.y, pt2.x, pt2.y)

    local newPoint 
    local linePt1Index
    local linePt2Index
    local linePt1
    local linePt2

    for index, ptIndexPair in ipairs(self.m_lineList) do
        linePt1Index = ptIndexPair[1]
        linePt2Index = ptIndexPair[2]
        linePt1 = self.m_pointList[linePt1Index] 
        linePt2 = self.m_pointList[linePt2Index]

        local moreCloserPtIndex
        if isHorizontal then
            if math.abs(linePt1.y - y) < math.abs(linePt2.y - y) then
                moreCloserPtIndex = linePt1Index
            else
                moreCloserPtIndex = linePt2Index
            end
        else
            if math.abs(linePt1.x - x) < math.abs(linePt2.x - x) then
                moreCloserPtIndex = linePt1Index
            else
                moreCloserPtIndex = linePt2Index
            end
        end
        local moreCloserPt = self.m_pointList[moreCloserPtIndex]

        if table.nums(self.m_pointMapPointsList[moreCloserPtIndex]) <= 1 then
            if isHorizontal then
                if (moreCloserPt.x - pt1.x)*(moreCloserPt.x - pt2.x) < 0 then
                    if math.abs(moreCloserPt.y - y) == lineWidth then
                        newPoint = cc.p(moreCloserPt.x, y)
                        moreCloserPt.y = y
                        break
                    end
                end
            else
                if (moreCloserPt.y - pt1.y)*(moreCloserPt.y - pt2.y) < 0 then
                    if math.abs(moreCloserPt.x - x) == lineWidth then
                        newPoint = cc.p(x, moreCloserPt.y)
                        moreCloserPt.x = x
                        break
                    end
                end
            end
        end
    end

    if newPoint then
        print("PointsManager:fixOneLineDistancePoint 2", newPoint.x, newPoint.y, linePt1.x, linePt1.y, linePt2.x, linePt2.y)
        self:insertPointToLine(newPoint, lineIndex)
    end
end

function PointsManager:adjustLine(pt1, pt2)
    self:maxMinAdjust(pt1)
    self:maxMinAdjust(pt2)

    if math.abs(pt1.x - pt2.x) < math.abs(pt1.y - pt2.y) then
        local x = math.floor(pt1.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
        pt1.x = x
        pt2.x = x
        pt1.y = math.floor(pt1.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
        pt2.y = math.floor(pt2.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
    else
        local y = math.floor(pt1.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
        pt1.y = y
        pt2.y = y
        pt1.x = math.floor(pt1.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
        pt2.x = math.floor(pt2.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
    end
end

function PointsManager:adjustPoint(pt)
    self:maxMinAdjust(pt)
    pt.x = math.floor(pt.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
    pt.y = math.floor(pt.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
end

function PointsManager:maxMinAdjust(pt)
    if pt.x > self.m_maxX then pt.x = self.m_maxX end 
    if pt.y > self.m_maxY then pt.y = self.m_maxY end 
    if pt.x < self.m_minX then pt.x = self.m_minX end 
    if pt.y < self.m_minY then pt.y = self.m_minY end 
end

return PointsManager