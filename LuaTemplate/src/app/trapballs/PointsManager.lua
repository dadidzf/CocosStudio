local PointsManager = class("PointsManager")
local Cjson = require("cjson")

local _ONE_POINT_DISTANCE = 3

function PointsManager:ctor()
    self.m_pointList = {} -- points list (hash table)
    self.m_lineList = {} -- every line store two points index 

    self.m_pointMapPointsList = {} -- points index that one point linked
    self.m_linePointsList = {}  -- every line store two points
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
    self:updateLinePointsList()
    self:updatePointMapPointsList()
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

--[[ 
    add one new line logic
--]]
function PointsManager:addLine(pt1, pt2)
    local pt1Index = self:getPtIndex(pt1)
    local pt1LineIndex, crossPt1 = self:getPtLine(pt1)

    if pt1Index then
    elseif pt1LineIndex then
        print("1")
        pt1Index = self:insertPointToLine(crossPt1, pt1LineIndex)
    else
        print("2")
        pt1Index = self:addSinglePoint(pt1)
    end

    local pt2Index = self:getPtIndex(pt2)
    local pt2LineIndex, crossPt2 = self:getPtLine(pt2)
    if pt2Index then
    elseif pt2LineIndex then
        print("3")
        pt2Index = self:insertPointToLine(crossPt2, pt2LineIndex)
    else
        print("4")
        pt2Index = self:addSinglePoint(pt2)
    end 

    self:linkTwoPoints(pt1Index, pt2Index)

    self:updateList()
end

-- is this point alreay in self.m_pointList
function PointsManager:getPtIndex(pt)
    for index, comparePt in pairs(self.m_pointList) do
        if math.abs(comparePt.x - pt.x) < _ONE_POINT_DISTANCE and math.abs(comparePt.y - pt.y) < 1 then
            return index
        end
    end

    return nil
end

function PointsManager:getPtLine(pt)
    for index, ptIndexTb in pairs(self.m_lineList) do
        local pt1 = self.m_pointList[ptIndexTb[1]]
        local pt2 = self.m_pointList[ptIndexTb[2]]

        local vecPt1Pt2 = cc.pSub(pt2, pt1)
        local vecPt1Pt = cc.pSub(pt, pt1)
        local pt1pt2Len = cc.pGetLength(vecPt1Pt2)
        local len1 = cc.pDot(vecPt1Pt, vecPt1Pt2)/pt1pt2Len

        if len1 > 0 then
            local vecPt2Pt1 = cc.pSub(pt1, pt2)
            local vecPt2Pt = cc.pSub(pt, pt2)
            local len2 = cc.pDot(vecPt2Pt, vecPt2Pt1)/pt1pt2Len

            if len2 > 0 then
                local crossPt = cc.pAdd(pt2, cc.pMul(vecPt2Pt1, len2/pt1pt2Len))
                local len = cc.pGetLength(cc.pSub(pt, crossPt))
                if len < _ONE_POINT_DISTANCE then
                    return index, crossPt
                end
            end
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
    self:adjustLinkLine(ptIndex1, ptIndex2)
    table.insert(self.m_lineList, {ptIndex1, ptIndex2})
end

function PointsManager:adjustLinkLine(ptIndex1, ptIndex2)
    local pt1Pt = self.m_pointList[ptIndex1] 
    local pt2Pt = self.m_pointList[ptIndex2]

    if math.abs(pt1Pt.x - pt2Pt.x) < math.abs(pt1Pt.y - pt2Pt.y) then
        pt1Pt.x = pt2Pt.x
    else
        pt1Pt.y = pt2Pt.y
    end
end

return PointsManager