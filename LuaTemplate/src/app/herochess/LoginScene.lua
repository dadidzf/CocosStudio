local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
local Client = import ".network.Client"

LoginScene.RESOURCE_FILENAME = "LoginScene.csb"
LoginScene.RESOURCE_BINDING = {
    ["panel_wechat"] = {varname = "m_panelWechat"},
    ["panel_wechat.btn_wechat"] = {varname = "m_btnWechat", events = {{ event = "click", method = "onWechat" }}},
    ["panel_wechat.btn_agreement"] = {varname = "m_btnAgreement", events = {{ event = "click", method = "onAgreement" }}},
    ["panel_wechat.checkbox_agreement"] = {varname = "m_checkbox_agreement"},

    ["herochess_agreement_bg_11"] = {varname = "m_bgAgreement"},
    ["herochess_agreement_bg_11.btn_close"] = {varname = "m_btnAgreementClose", events = {{ event = "click", method = "onAgreementClose" }}},
    ["herochess_agreement_bg_11.panel_agreement.text_agreement"] = {varname = "m_textAgreement"}
}

function LoginScene:onCreate()
    local disY = 80
    local inc = 1
    local fntSize = 64

    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_checkbox_agreement:onEvent(handler(self, self.onCheckBoxAgreement))
    
    local account
    dd.NetworkClient:connect("192.168.18.107", 16800)


    -- ccui.Text:create("Get Account", "", fntSize)
    --     :setAnchorPoint(cc.p(0, 0.5))
    --     :move(36, display.height*0.9)
    --     :addTo(self)
    --     :setTouchEnabled(true)
    --     :onClick(function ()
    --         print("Login -- ")
    --         dd.NetworkClient:sendBlockMsg("login.get_account", {}, function ( ... )
    --             local tb = ...
    --             dump(tb)
    --             account = tb.account
    --         end)
    --     end)

    -- ccui.Text:create("Register", "", fntSize)
    --     :setAnchorPoint(cc.p(0, 0.5))
    --     :move(36, display.height*0.65)
    --     :addTo(self)
    --     :setTouchEnabled(true)
    --     :onClick(function ()
    --         print("BaseApp --")
    --         dd.NetworkClient:close()
    --         dd.NetworkClient:connect("192.168.18.107", 16800)
    --         dd.NetworkClient:sendBlockMsg("login.register", {account = account, passwd = "123456"}, function ( ... )
    --             dump({...})
    --         end)
    --     end)

    -- ccui.Text:create("CreateRoom", "", fntSize)
    --     :setAnchorPoint(cc.p(0, 0.5))
    --     :move(36, display.height*0.40)
    --     :addTo(self)
    --     :setTouchEnabled(true)
    --     :onClick(function ()
    --         print("create room --")
    --         dd.NetworkClient:sendBlockMsg("room.create_room", {game_id = 1}, function ( ... )
    --             dump({...})
    --         end)
    --     end)

    -- ccui.Text:create("JoinRoom", "", fntSize)
    --     :setAnchorPoint(cc.p(0, 0.5))
    --     :move(36, display.height*0.15)
    --     :addTo(self)
    --     :setTouchEnabled(true)
    --     :onClick(function ()
    --         print("JoinRoom")
    --         dd.NetworkClient:sendBlockMsg("room.join_room", {room_id = 123456}, function ( ... )
    --             dump({...})
    --         end)
    --     end)

    -- dd.NetworkClient:register("room.user_enter", function ( ... )
    --     dump({...})
    -- end)

    -- ccui.Text:create("BaseApp", "", fntSize)
    --  :setAnchorPoint(cc.p(0, 0.5))
    --  :move(36, display.height*0.65)
    --  :addTo(self)
    --  :setTouchEnabled(true)
    --  :onClick(function ()
    --      print("BaseApp --")
    --      dd.NetworkClient:close()
    --      dd.NetworkClient:connect("192.168.18.107", 16802)
    --      dd.NetworkClient:sendBlockMsg("login.login_baseapp", {account = "123456", token = "token"}, function ( ... )
    --          dump({...})
    --      end)
    --  end)

    -- ccui.Text:create("CreateRoom", "", fntSize)
    --  :setAnchorPoint(cc.p(0, 0.5))
    --  :move(36, display.height*0.40)
    --  :addTo(self)
    --  :setTouchEnabled(true)
    --  :onClick(function ()
    --      print("create room --")
    --      dd.NetworkClient:sendBlockMsg("room.create_room", {game_id = 1}, function ( ... )
    --          dump({...})
    --      end)
    --  end)


    --self:onCreateTextField()
end


function LoginScene:onCheckBoxAgreement()
    self.m_btnWechat:setEnabled(self.m_checkbox_agreement:isSelected())
end

function LoginScene:onWechat()
end

function LoginScene:onAgreement()
    self.m_bgAgreement:setVisible(not self.m_bgAgreement:isVisible())
end

function LoginScene:onAgreementClose()
    self.m_bgAgreement:setVisible(false)
end

function LoginScene:onCreateTextField()
    local editTxt = ccui.EditBox:create(cc.size(600, 200), "sdk_close_btn.png")  --输入框尺寸，背景图片
        editTxt:setName("inputTxt")
        editTxt:setAnchorPoint(0.5,0.5)
        editTxt:setPosition(display.cx,display.height*0.45)                        --设置输入框的位置
        editTxt:setFontSize(36)                            --设置输入设置字体的大小
        editTxt:setMaxLength(8)                             --设置输入最大长度为6
        editTxt:setFontColor(cc.c4b(124,92,63,255))         --设置输入的字体颜色
        editTxt:setFontName("Arial")                       --设置输入的字体为simhei.ttf
        editTxt:setPlaceHolder("请输入账号")               --设置预制提示文本
        editTxt:setPlaceholderFontSize(36)
        editTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)  --输入键盘返回类型，done，send，go等KEYBOARD_RETURNTYPE_DONE
        editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) --输入模型，如整数类型，URL，电话号码等，会检测是否符合
        editTxt:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) --输入框的事件，主要有光标移进去，光标移出来，以及输入内容改变等
        editTxt:setInputFlag(cc.EDITBOX_INPUT_MODE_EMAILADDR)
        self:addChild(editTxt,5)
    --  editTxt:setHACenter() --输入的内容锚点为中心，与anch不同，anch是用来确定控件位置的，而这里是确定输入内容向什么方向展开(。。。说不清了。。自己测试一下)
end

--输入框事件处理
function LoginScene:editboxHandle(strEventName,sender)
    if strEventName == "began" then
        sender:setText("")                                      --光标进入，清空内容/选择全部
        sender:setPlaceHolder("")
    elseif strEventName == "ended" then
                                                                --当编辑框失去焦点并且键盘消失的时候被调用
    elseif strEventName == "return" then
                                                                --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    elseif strEventName == "changed" then
                                                                --输入内容改变时调用 
    end
end

return LoginScene
