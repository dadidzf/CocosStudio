local PointsManager = class("PointsManager")
local Cjson = require("cjson")

function PointsManager:ctor()
    self.m_pointList = {} -- points list (hash table)
    self.m_lineList = {} -- every line store two points index 

    self.m_pointMapLineList = {} -- lines index that one point linked
    self.m_pointMapPointsList = {} -- points index that one point linked
    self.m_linePointsList = {}  -- every line store two points
    self.m_lineHorizontalList = {} -- every line store true - ishorizontal, false - vertical

    self.m_removedPolygonsPtPairList = {} -- every polygon store all points pair(line) in this polygon
    self.m_validPolygonPtPairList = {}
end

function PointsManager:isPointValid(pt)
    if self:getPtIndex(pt) or self:getPtLine(pt) then
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
end

function PointsManager:updatePointMapLineList()
    self.m_pointMapLineList = {}
    for lineIndex, ptIndexPair in ipairs(self.m_lineList) do
        if not self.m_pointMapLineList[ptIndexPair[1]] then
            self.m_pointMapLineList[ptIndexPair[1]] = {}
        end
        if not self.m_pointMapLineList[ptIndexPair[2]] then
            self.m_pointMapLineList[ptIndexPair[2]] = {}
        end

        self.m_pointMapLineList[ptIndexPair[1]][lineIndex] = true
        self.m_pointMapLineList[ptIndexPair[2]][lineIndex] = true
    end
end

function PointsManager:updateLineHorizontalList()
    self.m_lineHorizontalList = {}
    for _, ptIndexPair in ipairs(self.m_lineList) do
        local pt1Index = ptIndexPair[1]
        local pt2Index = ptIndexPair[2]
        local pt1 = self.m_pointList[pt1Index]
        local pt2 = self.m_pointList[pt2Index]

        table.insert(self.m_lineHorizontalList, pt1.y == pt2.y)
    end
end

function PointsManager:updatePointMapPointsList()
    self.m_pointMapPointsList = {}
    for _, ptIndexPair in ipairs(self.m_lineList) do
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
    for lineIndex, ptIndexPair in ipairs(self.m_lineList) do
        local ptPair = {}
        for _, index in pairs(ptIndexPair) do
            table.insert(ptPair, self.m_pointList[index])
        end

        table.insert(self.m_linePointsList, ptPair)
    end
end

function PointsManager:getLinePointsList()
    self:updateLinePointsList()
    return self.m_linePointsList
end

--[[ 
    add one new line logic
--]]
function PointsManager:addLine(pt1, pt2)
    print("PointsManager:addLine")

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

    return self:linkTwoPoints(pt1Index, pt2Index)
end

-- is this point already in self.m_pointList
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
        local pt1X = pt1.x
        local pt1Y = pt1.y
        local pt2X = pt2.x
        local pt2Y = pt2.y
        local x = pt.x
        local y = pt.y

        if (pt1X == pt2X and pt1X == x and ((y > pt1Y and y < pt2Y) or (y > pt2Y and y < pt1Y))) or
            (pt1Y == pt2Y and pt2Y == y and ((x < pt1X and x > pt2X) or (x < pt2X and x > pt1X))) then
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

function PointsManager:insertPointToLine(newPt, lineIndex, useOldIndex)
    local newPtIndex = useOldIndex or (#self.m_pointList + 1)
    if not useOldIndex then
        table.insert(self.m_pointList, newPtIndex, newPt)
    end

    local line = self.m_lineList[lineIndex]
    local linePt1Index = line[1]
    local linePt2Index = line[2]

    table.remove(self.m_lineList, lineIndex)
    table.insert(self.m_lineList, {newPtIndex, linePt1Index})
    table.insert(self.m_lineList, {newPtIndex, linePt2Index})

    return newPtIndex
end

function PointsManager:linkTwoPoints(ptIndex1, ptIndex2)
    table.insert(self.m_lineList, {ptIndex1, ptIndex2})
    local retLineList = {}
    self:fixOneLineDistancePoint(#self.m_lineList, retLineList)

    print("PointsManager:linkTwoPoints")
    dump(retLineList)
    return retLineList
end

function PointsManager:fixOneLineDistancePoint(lineIndex, retLineList) 
    self:updatePointMapPointsList()
    self:updateLineHorizontalList()

    local pt1Index = self.m_lineList[lineIndex][1]
    local pt2Index = self.m_lineList[lineIndex][2]

    local pt1 = self.m_pointList[pt1Index]
    local pt2 = self.m_pointList[pt2Index]
    local isHorizontal = self.m_lineHorizontalList[lineIndex]
    local y = pt1.y
    local x = pt1.x
    local lineWidth = dd.Constants.EDGE_SEG_WIDTH

    local linePt1Index
    local linePt2Index
    local linePt1
    local linePt2

    local noFix = true
    for index, ptIndexPair in ipairs(self.m_lineList) do
        local isLineHorizontal = self.m_lineHorizontalList[index]
        if (isLineHorizontal and (not isHorizontal)) or (isHorizontal and (not isLineHorizontal)) then
            linePt1Index = ptIndexPair[1]
            linePt2Index = ptIndexPair[2]
            linePt1 = self.m_pointList[linePt1Index] 
            linePt2 = self.m_pointList[linePt2Index]

            local moreCloserPtIndex
            local moreCloserPtNum 
            if isHorizontal then
                if math.abs(linePt1.y - y) < math.abs(linePt2.y - y) then
                    moreCloserPtIndex = linePt1Index
                    moreCloserPtNum = 1
                else
                    moreCloserPtIndex = linePt2Index
                    moreCloserPtNum = 2
                end
            else
                if math.abs(linePt1.x - x) < math.abs(linePt2.x - x) then
                    moreCloserPtIndex = linePt1Index
                    moreCloserPtNum = 1
                else
                    moreCloserPtIndex = linePt2Index
                    moreCloserPtNum = 2
                end
            end
            local moreCloserPt = self.m_pointList[moreCloserPtIndex]

            if table.nums(self.m_pointMapPointsList[moreCloserPtIndex]) <= 1 then
                if isHorizontal then
                    if math.abs(moreCloserPt.y - y) == lineWidth then
                        if (moreCloserPt.x > pt1.x and moreCloserPt.x < pt2.x) or 
                            (moreCloserPt.x < pt1.x and moreCloserPt.x > pt2.x) then
                        --if (moreCloserPt.x - pt1.x)*(moreCloserPt.x - pt2.x) < 0 then
                            moreCloserPt.y = y
                            self:insertPointToLine(moreCloserPt, lineIndex, moreCloserPtIndex)
                            local topIndex = #self.m_lineList
                            self:fixOneLineDistancePoint(topIndex - 1, retLineList)
                            self:fixOneLineDistancePoint(topIndex, retLineList)
                            noFix = false
                            break
                        elseif moreCloserPt.x == pt1.x then
                            self.m_pointList[moreCloserPtIndex] = nil
                            ptIndexPair[moreCloserPtNum] = pt1Index
                        elseif moreCloserPt.x == pt2.x then
                            self.m_pointList[moreCloserPtIndex] = nil
                            ptIndexPair[moreCloserPtNum] = pt2Index
                        end
                    end
                else
                    if math.abs(moreCloserPt.x - x) == lineWidth then
                        if (moreCloserPt.y > pt1.y and moreCloserPt.y < pt2.y) or
                            (moreCloserPt.y < pt1.y and moreCloserPt.y > pt2.y) then
                        --if (moreCloserPt.y - pt1.y)*(moreCloserPt.y - pt2.y) < 0 then
                            moreCloserPt.x = x
                            self:insertPointToLine(moreCloserPt, lineIndex, moreCloserPtIndex)
                            local topIndex = #self.m_lineList
                            self:fixOneLineDistancePoint(topIndex - 1, retLineList)
                            self:fixOneLineDistancePoint(topIndex, retLineList)
                            noFix = false
                            break
                        elseif moreCloserPt.y == pt1.y then 
                            self.m_pointList[moreCloserPtIndex] = nil
                            ptIndexPair[moreCloserPtNum] = pt1Index
                        elseif moreCloserPt.y == pt2.y then
                            self.m_pointList[moreCloserPtIndex] = nil
                            ptIndexPair[moreCloserPtNum] = pt2Index
                        end
                    end
                end
            end
        end
    end

    if noFix then
        table.insert(retLineList, lineIndex)
    end
end

function PointsManager:adjustLine(pt1, pt2)
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
    pt.x = math.floor(pt.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
    pt.y = math.floor(pt.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
end


--[[
    fine close polygon logic
--]]

function PointsManager:adjustBallsPos(ballPosList)
    for _, pos in ipairs(ballPosList) do
        self:adjustPoint(pos)
    end 
end

function PointsManager:clipPolygon(ballPosList, retLineList)
    self:adjustBallsPos(ballPosList)
    
    local alreadyInPolygonLineList = {} -- this line is alreay in one of polygon we have find

    local polygonTobeRemovedPtRecordList = {} -- record all points in polygon to be removed
    local polygonHasBallsPtRecordList = {} -- store all polygon(which store all point pairs(one line)) which has balls

    local pointList = self.m_pointList

    for _, lineIndex in ipairs(retLineList) do
        if true then -- not alreadyInPolygonLineList[lineIndex] then
            local allFindList = self:findlinePolygon(lineIndex)
            for _, polygon in ipairs(allFindList) do
                if self:isBallsInPolygon(ballPosList, polygon) then
                    local polygonPtPairList = {}
                    for _, lineIndex in ipairs(polygon) do
                        alreadyInPolygonLineList[lineIndex] = true
                        local linePtPair = self.m_lineList[lineIndex]
                        local pt1 = pointList[linePtPair[1]]
                        local pt2 = pointList[linePtPair[2]]
                        polygonHasBallsPtRecordList[linePtPair[1]] = true
                        polygonHasBallsPtRecordList[linePtPair[2]] = true
                        table.insert(polygonPtPairList, {pt1, pt2})
                    end
                    table.insert(self.m_validPolygonPtPairList, polygonPtPairList)
                else
                    local polygonPtPairList = {}
                    for _, lineIndex in ipairs(polygon) do
                        alreadyInPolygonLineList[lineIndex] = true
                        local linePtPair = self.m_lineList[lineIndex]
                        local pt1 = pointList[linePtPair[1]]
                        local pt2 = pointList[linePtPair[2]]
                        polygonTobeRemovedPtRecordList[linePtPair[1]] = true
                        polygonTobeRemovedPtRecordList[linePtPair[2]] = true
                        table.insert(polygonPtPairList, clone({pt1, pt2}))
                    end
                    table.insert(self.m_removedPolygonsPtPairList, polygonPtPairList)
                end
            end
        end
    end

    local pointIndexsTobeRemovedList = self:getPointsTobeRemoved(polygonTobeRemovedPtRecordList, polygonHasBallsPtRecordList)
    self:removePoints(pointIndexsTobeRemovedList)
end

function PointsManager:getPointsTobeRemoved(polygonTobeRemovedPtRecordList, polygonHasBallsPtRecordList)
    local retPtIndexList = {}
    for removePtIndex, _ in pairs(polygonTobeRemovedPtRecordList) do
        if not polygonHasBallsPtRecordList[removePtIndex] then
            table.insert(retPtIndexList, removePtIndex)
        end
    end

    return retPtIndexList
end

function PointsManager:removePoints(pointIndexsTobeRemovedList)
    print("PointsManager:removePoints")
    dump(self.m_pointList)
    dump(self.m_lineList)
    dump(pointIndexsTobeRemovedList)

    
    local lineIndexTobeRemovedAll = {}

    for _, ptIndex in ipairs(pointIndexsTobeRemovedList) do
        local linkLineList = self.m_pointMapLineList[ptIndex] 
        self.m_pointList[ptIndex] = nil

        for index, _ in pairs(linkLineList) do
            lineIndexTobeRemovedAll[index] = true
        end
    end

    local newLineList = {}
    for index, linePtIndexPair in ipairs(self.m_lineList) do
        if not lineIndexTobeRemovedAll[index] then
            table.insert(newLineList, linePtIndexPair)
        end
    end

    self.m_lineList = newLineList

    dump(self.m_pointList)
    dump(self.m_lineList)
end

function PointsManager:findlinePolygon(lineIndex)
    self:updatePointMapLineList()
    self:updatePointMapPointsList()

    local allFindList = {}
    local findList = {}
    local findRecordList ={}
    local pointMapLineList = self.m_pointMapLineList
    local lineList = self.m_lineList

    local dnf
    dnf = function (lineIndex, srcIndex, destIndex)
        table.insert(findList, lineIndex)
        findRecordList[lineIndex] = true
        if srcIndex == destIndex then
            if #findList > 3 then
                table.insert(allFindList, clone(findList))
            end
        else
            local ptLinkLineList = pointMapLineList[srcIndex] 
            for lineIndex, _ in pairs(ptLinkLineList) do
                if (not findRecordList[lineIndex]) then
                    local linePtIndexPair = lineList[lineIndex]
                    local nextPtIndex
                    if linePtIndexPair[1] == srcIndex then
                        nextPtIndex = linePtIndexPair[2]
                    else
                        nextPtIndex = linePtIndexPair[1]
                    end

                    dnf(lineIndex, nextPtIndex, destIndex)
                    table.remove(findList, #findList)
                    findRecordList[lineIndex] = nil
                end
            end
        end
    end

    local ptIndexPair = self.m_lineList[lineIndex]
    dnf(lineIndex, ptIndexPair[1], ptIndexPair[2])
    dump(allFindList)
    return allFindList
end

function PointsManager:isBallsInPolygon(ballPosList, polygon)
    for _, ballPos in ipairs(ballPosList) do
        if self:isPointInPolygon(ballPos, polygon) then
            return true
        end
    end

    return false
end

function PointsManager:isPointInPolygon(pt, polygon)
    local crossCount = 0
    local x = pt.x
    local y = pt.y

    for _, polygonLine in ipairs(polygon) do
        local linePtIndexPair = self.m_lineList[polygonLine]
        local polygonPt = self.m_pointList[linePtIndexPair[1]]
        local polygonPtNext = self.m_pointList[linePtIndexPair[2]]

        if x == polygonPt.x and x == polygonPtNext.x and polygonPt.y > y and polygonPtNext.y > y then
            crossCount = crossCount + 1
        elseif (polygonPt.y == polygonPtNext.y) and (polygonPt.y > y) 
            and ((x > polygonPt.x and x < polygonPtNext.x) or (x < polygonPt.x and x > polygonPtNext.x)) then
            crossCount = crossCount + 1
        end
    end

    print("PointsManager:isPointInPolygon", crossCount)

    return crossCount%2 ~= 0
end


return PointsManager