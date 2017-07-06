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

    self.m_validPolygonPtIndexPairList = {}

    -- once we put a clipline in the valid polygons, we create below two tables
    self.m_filterPolygonPtIndexList = {}
    self.m_otherPolygonPtIndexList = {}

    -- triangle lists
    self.m_removedPolygonTriangleLists = {}
end

function PointsManager:getLineRectWithLineWidth(p1, p2, lineWidth)
    local halfSegWidth = dd.Constants.EDGE_SEG_WIDTH/2
    local pt1 = clone(p1)
    local pt2 = clone(p2)
    if pt1.x == pt2.x then
        pt1.x = pt1.x - halfSegWidth
        pt2.x = pt2.x + halfSegWidth
    else
        pt1.y = pt1.y - dd.Constants.EDGE_SEG_WIDTH/2
        pt2.y = pt2.y + dd.Constants.EDGE_SEG_WIDTH/2
    end

    return pt1, pt2
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

    print("----------------------------------", dd.Triangulate:area(self:getSerialPolygonPtList(tb[3])))
    self:getAllValidPolygonTriangleList()
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

function PointsManager:getPointIndexMapLines()
    self:updatePointMapLineList()
    return self.m_pointMapLineList
end

function PointsManager:getLinePointsList()
    self:updateLinePointsList()
    return self.m_linePointsList
end

function PointsManager:getOneLinePointPair(lineIndex)
    local linePtIndexPair = self.m_lineList[lineIndex]
    return {self.m_pointList[linePtIndexPair[1]], self.m_pointList[linePtIndexPair[2]]}
end

--[[ 
    add one new line logic
--]]
function PointsManager:addLine(pt1, pt2, ballsPosList)
    print("PointsManager:addLine")
    dump(pt1, "pt1")
    dump(pt2, "pt2")

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
end

function PointsManager:adjustLine(pt1, pt2)
    print("PointsManager:adjustLine")
    if math.abs(pt1.x - pt2.x) < math.abs(pt1.y - pt2.y) then
        local x = self:adjustVal(pt1.x)
        pt1.x = x
        pt2.x = x
        pt1.y = self:adjustVal(pt1.y)
        pt2.y = self:adjustVal(pt2.y)
    else
        local y = self:adjustVal(pt1.y)
        pt1.y = y
        pt2.y = y
        pt1.x = self:adjustVal(pt1.x)
        pt2.x = self:adjustVal(pt2.x)
    end
end

function PointsManager:adjustPoint(pt)
    pt.x = math.floor(pt.x/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
    pt.y = math.floor(pt.y/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH
end

function PointsManager:adjustVal(val)
    val = math.floor(val/dd.Constants.EDGE_SEG_WIDTH)*dd.Constants.EDGE_SEG_WIDTH

    return val
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
    
    local pointList = self.m_pointList
    local linePtIndexPair = self.m_lineList[clipLineIndex]

    local allFindList = self:findlinePolygon(clipLineIndex, self.m_filterPolygonPtIndexList)
    if self.m_clickPolygonIndex then
        if #allFindList == 2 then
            table.remove(self.m_validPolygonPtIndexPairList, self.m_clickPolygonIndex)
        else
            if #allFindList ~= 0 then
                assert(false, "Should just be two polygon !")
            end
        end
    else
        assert(false, "It should not be here ! ") 
    end

    for _, polygon in ipairs(allFindList) do
        if self:isBallsInPolygon(ballPosList, polygon) then
            local polygonPtIndexPairList = {}
            for _, lineIndex in ipairs(polygon) do
                local linePtPair = self.m_lineList[lineIndex]
                local pt1 = pointList[linePtPair[1]]
                local pt2 = pointList[linePtPair[2]]
                table.insert(polygonPtIndexPairList, {linePtPair[1], linePtPair[2]})
            end
            table.insert(self.m_validPolygonPtIndexPairList, polygonPtIndexPairList)
        else
            local polygonPtIndexPairList = {}
            for _, lineIndex in ipairs(polygon) do
                local linePtPair = self.m_lineList[lineIndex]
                local pt1 = pointList[linePtPair[1]]
                local pt2 = pointList[linePtPair[2]]
                table.insert(polygonPtIndexPairList, {linePtPair[1], linePtPair[2]})
            end
            table.insert(self.m_removedPolygonTriangleLists, 
                dd.Triangulate:process(self:getSerialPolygonPtList(polygonPtIndexPairList)))
        end
    end

    self:updateValidPolyPtIndex(linePtIndexPair)
    self:updateLines()
    self:updatePoints()
end

function PointsManager:isPtBetweenLine(pt, linePt1, linePt2)
    if pt.x == linePt1.x and pt.x == linePt2.x and 
        ((pt.y < linePt1.y and pt.y > linePt2.y) or (pt.y < linePt2.y and pt.y > linePt1.y)) then
        return true
    elseif pt.y == linePt1.y and pt.y == linePt2.y and 
        ((pt.x < linePt1.x and pt.x > linePt2.x) or (pt.x > linePt1.x and pt.x < linePt2.x)) then
        return true
    end

    return false
end

function PointsManager:updatePoints()
    self:updatePointMapLineList()

    for ptIndex, _ in pairs(self.m_pointList) do
        if not self.m_pointMapLineList[ptIndex] then
            self.m_pointList[ptIndex] = nil
        end
    end
end

function PointsManager:updateLines()
    local lineIndexToBeRemoved = {}
    for index, linePtIndexPair in ipairs(self.m_lineList) do
        local center = self:getLineCenterPt(index)
        local notInAnyPolygon = true
        for _, polygon in ipairs(self.m_validPolygonPtIndexPairList) do
            if self:isPointInPolygonPtIndexList(center, polygon, true) then
                notInAnyPolygon = false
                break
            end
        end

        if notInAnyPolygon then
            table.insert(lineIndexToBeRemoved, index, true) 
        end
    end

    local newLineList = {}
    for index, ptIndexPair in ipairs(self.m_lineList) do
        if not lineIndexToBeRemoved[index] then
            table.insert(newLineList, ptIndexPair) 
        end
    end

    self.m_lineList = newLineList
    print("PointsManager:updateLines")
    dump(lineIndexToBeRemoved, "lineIndexToBeRemoved")
    dump(self.m_lineList, "self.m_lineList")
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
                table.insert(polygonPtIndexList, polygonIndex, {ptIndex1, ptIndexPair[1]})
                table.insert(polygonPtIndexList, {ptIndex1, ptIndexPair[2]})
                break
            elseif self:isPtBetweenLine(pt2, polyLinePt1, polyLinePt2) then
                table.remove(polygonPtIndexList, polygonIndex)
                table.insert(polygonPtIndexList, polygonIndex, {ptIndex2, ptIndexPair[1]})
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

function PointsManager:isPointInPolygon(pt, polygon, includeOnLine)
    local crossCount = 0
    local x = pt.x
    local y = pt.y

    local leftCount = 0
    local rightCount = 0
    for _, polygonLine in ipairs(polygon) do
        local linePtIndexPair = self.m_lineList[polygonLine]
        local polygonPt = self.m_pointList[linePtIndexPair[1]]
        local polygonPtNext = self.m_pointList[linePtIndexPair[2]]

        if x == polygonPt.x and x == polygonPtNext.x and polygonPt.y > y and polygonPtNext.y > y then
        elseif (polygonPt.y == polygonPtNext.y) and (polygonPt.y > y) then
            if ((x > polygonPt.x and x < polygonPtNext.x) or (x < polygonPt.x and x > polygonPtNext.x)) then
                crossCount = crossCount + 1
            elseif x == polygonPt.x then
                if polygonPtNext.x < x then
                    leftCount = leftCount + 1
                else
                    rightCount = rightCount + 1
                end
            elseif x == polygonPtNext.x then
                if polygonPt.x < x then
                    leftCount = leftCount + 1
                else
                    rightCount = rightCount + 1
                end
            end
        end

        if includeOnLine then
            if (x == polygonPt.x and x == polygonPtNext.x and ((y > polygonPt.y and y < polygonPtNext.y) or 
                (y < polygonPt.y and y > polygonPtNext.y))) or
                (y == polygonPt.y and y == polygonPtNext.y and ((x > polygonPt.x and x < polygonPtNext.x) or 
                (x < polygonPt.x and x > polygonPtNext.x))) then
                return true
            end
        end
    end

    print("PointsManager:isPointInPolygon", crossCount)

    crossCount = crossCount + math.min(leftCount, rightCount)
    return crossCount%2 ~= 0
end

function PointsManager:isPointInPolygonPtIndexList(pt, polygonPtIndexList, includeOnLine)
    local crossCount = 0
    local x = pt.x
    local y = pt.y

    local leftCount = 0
    local rightCount = 0
    for _, polygonPtIndexPair in ipairs(polygonPtIndexList) do
        local ptIndex1 = polygonPtIndexPair[1]
        local ptIndex2 = polygonPtIndexPair[2]
        local polygonPt = self.m_pointList[ptIndex1]
        local polygonPtNext = self.m_pointList[ptIndex2]

        if x == polygonPt.x and x == polygonPtNext.x and polygonPt.y > y and polygonPtNext.y > y then
        elseif (polygonPt.y == polygonPtNext.y) and (polygonPt.y > y) then
            if ((x > polygonPt.x and x < polygonPtNext.x) or (x < polygonPt.x and x > polygonPtNext.x)) then
                crossCount = crossCount + 1
            elseif x == polygonPt.x then
                if polygonPtNext.x < x then
                    leftCount = leftCount + 1
                else
                    rightCount = rightCount + 1
                end
            elseif x == polygonPtNext.x then
                if polygonPt.x < x then
                    leftCount = leftCount + 1
                else
                    rightCount = rightCount + 1
                end
            end
        end

        if includeOnLine then
            if (x == polygonPt.x and x == polygonPtNext.x and ((y > polygonPt.y and y < polygonPtNext.y) or 
                (y < polygonPt.y and y > polygonPtNext.y))) or
                (y == polygonPt.y and y == polygonPtNext.y and ((x > polygonPt.x and x < polygonPtNext.x) or 
                (x < polygonPt.x and x > polygonPtNext.x))) then
                return true
            end
        end
    end

    print("PointsManager:isPointInPolygonPtIndexList", crossCount)

    crossCount = crossCount + math.min(leftCount, rightCount)
    return crossCount%2 ~= 0
end

function PointsManager:getPtIndexMapPtIndexList(polygonPtIndexList)
    local ret = {}
    for _, ptIndexPair in ipairs(polygonPtIndexList) do
        local index1 = ptIndexPair[1]
        if not ret[index1] then
            ret[index1] = {}
        end

        local index2 = ptIndexPair[2]
        if not ret[index2] then
            ret[index2] = {}
        end

        table.insert(ret[index1], index2)
        table.insert(ret[index2], index1)
    end

    return ret
end

function PointsManager:serialPolygon(polygonPtIndexList)
    local ret = {}
    local fromIndex = polygonPtIndexList[1][1]
    local toIndex = polygonPtIndexList[1][2]
    local startIndex = fromIndex

    local ptIndexMapPtIndex = self:getPtIndexMapPtIndexList(polygonPtIndexList)
    repeat
        table.insert(ret, fromIndex)
        local ptIndexPair = ptIndexMapPtIndex[toIndex]
        if ptIndexPair[1] == fromIndex then
            fromIndex = toIndex
            toIndex = ptIndexPair[2]
        else
            fromIndex = toIndex
            toIndex = ptIndexPair[1]
        end
    until(fromIndex == startIndex)


    return ret
end

function PointsManager:getSerialPolygonPtList(polygonPtIndexList)
    local retPtList = {}
    for _, ptIndex in ipairs(self:serialPolygon(polygonPtIndexList)) do
        table.insert(retPtList, self.m_pointList[ptIndex])
    end

    return retPtList
end

function PointsManager:getAllValidPolygonTriangleList()
    local ret = {}
    for _, polygonPtIndexList in ipairs(self.m_validPolygonPtIndexPairList) do
        table.insert(ret, dd.Triangulate:process(self:getSerialPolygonPtList(polygonPtIndexList)))
    end

    return ret
end

function PointsManager:getAllRemovedPolygonTriangleList()
    return self.m_removedPolygonTriangleLists
end

function PointsManager:getAllValidPolygonArea()
    local ret = 0
    for _, polygonPtIndexList in ipairs(self.m_validPolygonPtIndexPairList) do
        ret = ret + math.abs(dd.Triangulate:area(self:getSerialPolygonPtList(polygonPtIndexList)))
    end

    return ret
end


return PointsManager