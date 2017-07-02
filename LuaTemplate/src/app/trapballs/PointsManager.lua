local PointsManager = class("PointsManager")
local Cjson = require("cjson")

function PointsManager:ctor()
    -- m_pointList and m_lineList should keep consistency from beginning to end
    self.m_pointList = {} -- points list (hash table)
    self.m_lineList = {} -- every line store two points index 

    self.m_pointMapLineList = {} -- lines index that one point linked
    self.m_pointMapPointsList = {} -- points index that one point linked
    self.m_linePointsList = {}  -- every line store two points
    self.m_lineHorizontalList = {} -- every line store true - ishorizontal, false - vertical

    self.m_removedPolygonsPtPairList = {} -- every polygon store all points pair(line) in this polygon
    self.m_validPolygonPtIndexPairList = {}

    -- once we put a clipline in the valid polygons, we create below two tables
    self.m_filterPolygonPtIndexList = {}
    self.m_otherPolygonPtIndexList = {}
end

function PointsManager:isPtInOneValidPolygon(pt)
    self:adjustPoint(pt)

    if self:getPtIndex(pt) or self:getPtLine(pt) then
        return false
    end
    
    self.m_clickPolygonIndex =  self:getPolygonIndexAndFilterPointList(pt)
    if self.m_clickPolygonIndex then
        return true
    else
        return false
    end
end

function PointsManager:encode()
    local tb = {self.m_pointList, self.m_lineList}
    return Cjson.encode(tb)
end

function PointsManager:load(jsonStr)
    local tb = Cjson.decode(jsonStr)
    self.m_pointList = tb[1]
    self.m_lineList = tb[2]
    self.m_validPolygonPtIndexPairList = {tb[3]}

    dump(tb)
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
        table.insert(ptPair, self.m_pointList[ptIndexPair[1]])
        table.insert(ptPair, self.m_pointList[ptIndexPair[2]])
        table.insert(ptPair, lineIndex)

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
function PointsManager:addLine(pt1, pt2, ballsPosList)
    print("PointsManager:addLine")

    self.m_ballsPosList = ballsPosList
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
    self.m_ballsPosList = nil
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

function PointsManager:findPtLineIndex(ptIndex1, ptIndex2)
    self:updatePointMapLineList()
    for lineIndex, _ in pairs(self.m_pointMapLineList[ptIndex1]) do
        for lineIndex2, _ in pairs(self.m_pointMapLineList[ptIndex2]) do
            if lineIndex == lineIndex2 then
                return lineIndex
            end
        end
    end

    return nil
end

function PointsManager:linkTwoPoints(ptIndex1, ptIndex2)
    table.insert(self.m_lineList, {ptIndex1, ptIndex2})
    self:clipPolygon(#self.m_lineList)
    self:fixOneLineDistancePoint(ptIndex1, ptIndex2)
end

function PointsManager:fixOneLineDistancePoint(pt1Index, pt2Index) 
    self:updatePointMapPointsList()
    self:updateLineHorizontalList()

    local pt1 = self.m_pointList[pt1Index]
    local pt2 = self.m_pointList[pt2Index]
    local lineIndex = self:findPtLineIndex(pt1Index, pt2Index)
    local isHorizontal = (pt1.y == pt2.y)
    local y = pt1.y
    local x = pt1.x
    local lineWidth = dd.Constants.EDGE_SEG_WIDTH

    local linePt1Index
    local linePt2Index
    local linePt1
    local linePt2

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
                            moreCloserPt.y = y
                            self:insertPointToLine(moreCloserPt, lineIndex, moreCloserPtIndex)
                            self:clipPolygon(index)
                            if self.m_pointList[pt1Index] then
                                self:fixOneLineDistancePoint(pt1Index, moreCloserPtIndex)
                            else
                                self:fixOneLineDistancePoint(pt2Index, moreCloserPtIndex)
                            end
                            return
                        end
                    end
                else
                    if math.abs(moreCloserPt.x - x) == lineWidth then
                        if (moreCloserPt.y > pt1.y and moreCloserPt.y < pt2.y) or
                            (moreCloserPt.y < pt1.y and moreCloserPt.y > pt2.y) then
                            moreCloserPt.x = x
                            self:insertPointToLine(moreCloserPt, lineIndex, moreCloserPtIndex)
                            self:clipPolygon(index)
                            if self.m_pointList[pt1Index] then
                                self:fixOneLineDistancePoint(pt1Index, moreCloserPtIndex)
                            else
                                self:fixOneLineDistancePoint(pt2Index, moreCloserPtIndex)
                            end
                            return
                        end
                    end
                end
            end
        end
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

function PointsManager:getPolygonIndexAndFilterPointList(pt)
    print("PointsManager:getPolygonIndexAndFilterPointList")
    dump(self.m_validPolygonPtIndexPairList, "self.m_validPolygonPtIndexPairList")
    
    local findPolygonIndex = nil
    local polygonClickedPtIndexRecordList = {}
    local otherPolygonPtIndexRecordList = {}

    for index, polygonPtIndexList in ipairs(self.m_validPolygonPtIndexPairList) do
        if self:isPointInPolygonPtIndexList(pt, polygonPtIndexList) then
            findPolygonIndex = index
            for _, ptIndexPair in ipairs(polygonPtIndexList) do
                local ptIndex1 = ptIndexPair[1]
                local ptIndex2 = ptIndexPair[2]
                polygonClickedPtIndexRecordList[ptIndex1] = true
                polygonClickedPtIndexRecordList[ptIndex2] = true
            end
        else
            for _, ptIndexPair in ipairs(polygonPtIndexList) do
                local ptIndex1 = ptIndexPair[1]
                local ptIndex2 = ptIndexPair[2]
                otherPolygonPtIndexRecordList[ptIndex1] = true
                otherPolygonPtIndexRecordList[ptIndex2] = true
            end
        end
    end

    local filterPtIndexList = clone(otherPolygonPtIndexRecordList)
    for index, _ in pairs(polygonClickedPtIndexRecordList) do
        filterPtIndexList[index] = nil
    end

    dump(filterPtIndexList, "filterPtIndexList")
    dump(otherPolygonPtIndexRecordList, "otherPolygonPtIndexRecordList")

    self.m_filterPolygonPtIndexList = filterPtIndexList
    self.m_otherPolygonPtIndexList = otherPolygonPtIndexRecordList

    return findPolygonIndex
end

function PointsManager:getLineCenterPt(lineIndex)
    local ptIndexPair = self.m_lineList[lineIndex]
    local pt1 = self.m_pointList[ptIndexPair[1]]
    local pt2 = self.m_pointList[ptIndexPair[2]]

    return cc.pMul(cc.pAdd(pt1, pt2), 0.5)
end

function PointsManager:clipPolygon(clipLineIndex)
    local ballPosList = self.m_ballsPosList
    self:adjustBallsPos(ballPosList)
    
    local polygonTobeRemovedPtRecordList = {} -- record all points in polygon to be removed
    local polygonHasBallsPtRecordList = {} -- store all polygon(which store all point pairs(one line)) which has balls

    local pointList = self.m_pointList
    local linePtIndexPair = self.m_lineList[clipLineIndex]

    local allFindList = self:findlinePolygon(clipLineIndex, self.m_filterPolygonPtIndexList)
    if self.m_clickPolygonIndex then
        if #allFindList == 2 then
            table.remove(self.m_validPolygonPtIndexPairList, self.m_clickPolygonIndex)
        end
    else
        assert(false, "It should not be here ! ") 
    end

    for _, polygon in ipairs(allFindList) do
        if self:isBallsInPolygon(ballPosList, polygon) then
            local polygonPtPairList = {}
            local polygonPtIndexPairList = {}
            for _, lineIndex in ipairs(polygon) do
                local linePtPair = self.m_lineList[lineIndex]
                local pt1 = pointList[linePtPair[1]]
                local pt2 = pointList[linePtPair[2]]
                polygonHasBallsPtRecordList[linePtPair[1]] = true
                polygonHasBallsPtRecordList[linePtPair[2]] = true
                table.insert(polygonPtPairList, {pt1, pt2})
                table.insert(polygonPtIndexPairList, {linePtPair[1], linePtPair[2]})
            end
            table.insert(self.m_validPolygonPtIndexPairList, polygonPtIndexPairList)
        else
            local polygonPtPairList = {}
            for _, lineIndex in ipairs(polygon) do
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

    if #allFindList == 2 then
        local pointIndexsTobeRemovedList = self:getPointsTobeRemoved(polygonTobeRemovedPtRecordList, 
            polygonHasBallsPtRecordList, self.m_otherPolygonPtIndexList)
        self:removePoints(pointIndexsTobeRemovedList)
    end

    self:updateValidPolyPtIndex(linePtIndexPair)
    --self:updateLines()
end

function PointsManager:isPtBetweenLine(pt, linePt1, linePt2)
    if pt.x == linePt1.x and pt.x == linePt2.x and 
        ((pt.y < linePt1.y and pt.y > linePt2.y) or (pt.y < linePt2.y and pt.y > linePt1.y)) then
        return true
    elseif pt.y == linePt1.y and pt.y == linePt2.y and 
        ((pt.x < linePt1.x and pt.x > linePt2.x) or (pt.x < linePt1.x and pt.x > linePt2.x)) then
        return true
    end

    return false
end

function PointsManager:updateLines()
    local ptIndexRefByPolygonList = {}
    for _, polygonPtIndexList in ipairs(self.m_validPolygonPtIndexPairList) do
        for _, ptIndexPair in ipairs(polygonPtIndexList) do
            local ptIndex1 = ptIndexPair[1]
            local ptIndex2 = ptIndexPair[2]
            if not ptIndexRefByPolygonList[ptIndex1] then
                ptIndexRefByPolygonList[ptIndex1] = 0
            end
            if not ptIndexRefByPolygonList[ptIndex2] then
                ptIndexRefByPolygonList[ptIndex2] = 0
            end

            ptIndexRefByPolygonList[ptIndex1] = ptIndexRefByPolygonList[ptIndex1] + 1
            ptIndexRefByPolygonList[ptIndex2] = ptIndexRefByPolygonList[ptIndex2] + 1
        end
    end

    local lineIndexToBeRemoved = {}
    for index, linePtIndexPair in ipairs(self.m_lineList) do
        local linePt1RefByPolygonCount = ptIndexRefByPolygonList[linePtIndexPair[1]] or 0
        local linePt2RefByPolygonCount = ptIndexRefByPolygonList[linePtIndexPair[2]] or 0
        if linePt1RefByPolygonCount == 4 and linePt2RefByPolygonCount == 4 then
            table.insert(lineIndexToBeRemoved, index, true) 
        end
    end

    local newLineList = {}
    for index, ptIndexPair in ipairs(self.m_lineList) do
        if not lineIndexToBeRemoved[index] then
            table.insert(newLineList, ptIndexPair) 
        end
    end

    self.m_lineList = ptIndexPair
end

function PointsManager:updateValidPolyPtIndex(linePtIndexPair)
    local ptIndex1 = linePtIndexPair[1]
    local ptIndex2 = linePtIndexPair[2]

    local pt1 = self.m_pointList[ptIndex1] 
    local pt2 = self.m_pointList[ptIndex2] 

    for index = 1, #self.m_validPolygonPtIndexPairList - 1 do
        local polygonPtIndexList = self.m_validPolygonPtIndexPairList[index]
        for polygonIndex = 1, #polygonPtIndexList do
            local ptIndexPair = polygonPtIndexList[polygonIndex]
            local polyLinePt1 = self.m_pointList[ptIndexPair[1]] 
            local polyLinePt2 = self.m_pointList[ptIndexPair[2]] 
            if self:isPtBetweenLine(pt1, polyLinePt1, polyLinePt2) then
                table.remove(polygonPtIndexList, polygonIndex)
                table.insert(polygonPtIndexList, {ptIndex1, ptIndexPair[1]})
                table.insert(polygonPtIndexList, {ptIndex1, ptIndexPair[2]})
                break
            elseif self:isPtBetweenLine(pt2, polyLinePt1, polyLinePt2) then
                table.remove(polygonPtIndexList, polygonIndex)
                table.insert(polygonPtIndexList, {ptIndex2, ptIndexPair[1]})
                table.insert(polygonPtIndexList, {ptIndex2, ptIndexPair[2]})
                break
            end
        end
    end

    print("PointsManager:updateValidPolyPtIndex")
    dump(self.m_validPolygonPtIndexPairList, "self.m_validPolygonPtIndexPairList")
end

function PointsManager:getPointsTobeRemoved(polygonTobeRemovedPtRecordList, polygonHasBallsPtRecordList, otherPolygonPtIndexRecordList)
    print("PointsManager:getPointsTobeRemoved")  
    dump(polygonTobeRemovedPtRecordList, "polygonTobeRemovedPtRecordList")
    dump(polygonHasBallsPtRecordList, "polygonHasBallsPtRecordList")
    
    local retPtIndexList = {}
    for removePtIndex, _ in pairs(polygonTobeRemovedPtRecordList) do
        if not polygonHasBallsPtRecordList[removePtIndex] and not otherPolygonPtIndexRecordList[removePtIndex] then
            table.insert(retPtIndexList, removePtIndex)
        end
    end

    return retPtIndexList
end

function PointsManager:removePoints(pointIndexsTobeRemovedList)
    print("PointsManager:removePoints")
    dump(pointIndexsTobeRemovedList, "pointIndexsTobeRemovedList")
    if next(pointIndexsTobeRemovedList) == nil then
        return
    end

    local lineIndexTobeRemovedAll = {}

    for _, ptIndex in ipairs(pointIndexsTobeRemovedList) do
        local linkLineList = self.m_pointMapLineList[ptIndex] 
        self.m_pointList[ptIndex] = nil

        for index, _ in pairs(linkLineList) do
            local ptIndexPair = self.m_lineList[index]
            local anotherPtIndex
            if ptIndexPair[1] == ptIndex then
                anotherPtIndex = ptIndexPair[2]
            else
                anotherPtIndex = ptIndexPair[1]
            end
            if table.nums(self.m_pointMapLineList[anotherPtIndex]) <= 1 then
                self.m_pointList[anotherPtIndex] = nil
            end

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
end

function PointsManager:findlinePolygon(lineIndex, filterPtIndexList)
    filterPtIndexList = filterPtIndexList or {}
    self:updatePointMapLineList()
    self:updatePointMapPointsList()

    local allFindList = {}
    local findList = {}
    local findPtIndexRecordList ={}
    local pointMapLineList = self.m_pointMapLineList
    local lineList = self.m_lineList

    local dnf
    dnf = function (lineIndex, srcIndex, destIndex)
        table.insert(findList, lineIndex)
        findPtIndexRecordList[srcIndex] = true
        if srcIndex == destIndex then
            if #findList > 3 then
                table.insert(allFindList, clone(findList))
            end
        else
            local ptLinkLineList = pointMapLineList[srcIndex] 
            for lineIndex, _ in pairs(ptLinkLineList) do
                local linePtIndexPair = lineList[lineIndex]
                local nextPtIndex
                if linePtIndexPair[1] == srcIndex then
                    nextPtIndex = linePtIndexPair[2]
                else
                    nextPtIndex = linePtIndexPair[1]
                end

                if (not findPtIndexRecordList[nextPtIndex]) and (not filterPtIndexList[nextPtIndex]) then
                    dnf(lineIndex, nextPtIndex, destIndex)
                    table.remove(findList, #findList)
                    findPtIndexRecordList[nextPtIndex] = nil
                end
            end
        end
    end

    local ptIndexPair = self.m_lineList[lineIndex]
    dnf(lineIndex, ptIndexPair[1], ptIndexPair[2])
    dump(allFindList, "allFindList")
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

function PointsManager:isPointInPolygonPtIndexList(pt, polygonPtIndexList)
    local crossCount = 0
    local x = pt.x
    local y = pt.y

    for _, polygonPtIndexPair in ipairs(polygonPtIndexList) do
        local polygonPt = self.m_pointList[polygonPtIndexPair[1]]
        local polygonPtNext = self.m_pointList[polygonPtIndexPair[2]]

        if x == polygonPt.x and x == polygonPtNext.x and polygonPt.y > y and polygonPtNext.y > y then
            crossCount = crossCount + 1
        elseif (polygonPt.y == polygonPtNext.y) and (polygonPt.y > y) 
            and ((x > polygonPt.x and x < polygonPtNext.x) or (x < polygonPt.x and x > polygonPtNext.x)) then
            crossCount = crossCount + 1
        end
    end

    print("PointsManager:isPointInPolygonPtIndexList", crossCount)

    return crossCount%2 ~= 0
end


return PointsManager