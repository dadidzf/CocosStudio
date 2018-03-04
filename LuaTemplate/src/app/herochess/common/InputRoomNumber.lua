local InputRoomNumber = class("InputRoomNumber", cc.load("mvc").ViewBase)

InputRoomNumber.RESOURCE_FILENAME = "InputRoomNumber.csb"
InputRoomNumber.RESOURCE_BINDING = {
    ["herochess_bigarea_1.num_0"] = {varname = "Btn0", events = { { event = "click", method = "onBtn0" }}},
    ["herochess_bigarea_1.num_1"] = {varname = "Btn1", events = { { event = "click", method = "onBtn1" }}},
    ["herochess_bigarea_1.num_2"] = {varname = "Btn2", events = { { event = "click", method = "onBtn2" }}},
    ["herochess_bigarea_1.num_3"] = {varname = "Btn3", events = { { event = "click", method = "onBtn3" }}},
    ["herochess_bigarea_1.num_4"] = {varname = "Btn4", events = { { event = "click", method = "onBtn4" }}},
    ["herochess_bigarea_1.num_5"] = {varname = "Btn5", events = { { event = "click", method = "onBtn5" }}},
    ["herochess_bigarea_1.num_6"] = {varname = "Btn6", events = { { event = "click", method = "onBtn6" }}},
    ["herochess_bigarea_1.num_7"] = {varname = "Btn7", events = { { event = "click", method = "onBtn7" }}},
    ["herochess_bigarea_1.num_8"] = {varname = "Btn8", events = { { event = "click", method = "onBtn8" }}},
    ["herochess_bigarea_1.num_9"] = {varname = "Btn9", events = { { event = "click", method = "onBtn9" }}},
    ["herochess_bigarea_1.del"] = {varname = "deleteBtn", events = { { event = "click", method = "onDelete" }}},
    ["herochess_bigarea_1.clear"] = {varname = "clearBtn", events = { { event = "click", method = "onClear" }}},
    ["herochess_bigarea_1.btn_close"] = {varname = "closeBtn", events = { { event = "click", method = "onClose" }}},

    ["herochess_bigarea_1.pos1"] = {varname = "m_charPos1"},
    ["herochess_bigarea_1.pos2"] = {varname = "m_charPos2"},
    ["herochess_bigarea_1.pos3"] = {varname = "m_charPos3"},
    ["herochess_bigarea_1.pos4"] = {varname = "m_charPos4"},
    ["herochess_bigarea_1.pos5"] = {varname = "m_charPos5"},
    ["herochess_bigarea_1.pos6"] = {varname = "m_charPos6"}
}

function InputRoomNumber:ctor(callBackFunc)
    self.super.ctor(self)
    self:showMask(nil, 168)
    self.m_roomNumber = ""
    self:showRoomNumber()
    self.m_callBackFunc = callBackFunc
end

function InputRoomNumber:showRoomNumber()
    local posList = {self.m_charPos1, self.m_charPos2, self.m_charPos3, 
                        self.m_charPos4, self.m_charPos5, self.m_charPos6}
    local len = string.len(self.m_roomNumber)
    for i = 1, 6 do
        if i <= len then
            posList[i]:setString(string.sub(self.m_roomNumber, i, i))
        else
            posList[i]:setString("")
        end
    end
end

function InputRoomNumber:pressNum(num)
    self.m_roomNumber = self.m_roomNumber .. tostring(num)
    self:showRoomNumber()

    if string.len(self.m_roomNumber) >= 6 then
        self:onClose()
    end
end

function InputRoomNumber:onBtn0()
    self:pressNum(0)
end

function InputRoomNumber:onBtn1()
    self:pressNum(1)
end

function InputRoomNumber:onBtn2()
    self:pressNum(2)
end

function InputRoomNumber:onBtn3()
    self:pressNum(3)
end

function InputRoomNumber:onBtn4()
    self:pressNum(4)
end

function InputRoomNumber:onBtn5()
    self:pressNum(5)
end

function InputRoomNumber:onBtn6()
    self:pressNum(6)
end

function InputRoomNumber:onBtn7()
    self:pressNum(7)
end

function InputRoomNumber:onBtn8()
    self:pressNum(8)
end

function InputRoomNumber:onBtn9()
    self:pressNum(9)
end

function InputRoomNumber:onDelete()
    self.m_roomNumber = string.sub(self.m_roomNumber, 1, string.len(self.m_roomNumber) - 1)
    self:showRoomNumber()
end

function InputRoomNumber:onClear()
    self.m_roomNumber = ""
    self:showRoomNumber()
end

function InputRoomNumber:onClose()
    self.m_callBackFunc(tonumber(self.m_roomNumber))
    self:removeFromParent()
end

return InputRoomNumber