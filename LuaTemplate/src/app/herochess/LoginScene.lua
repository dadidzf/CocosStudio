local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
local Client = import ".network.Client"

LoginScene.RESOURCE_FILENAME = "LoginScene.csb"
LoginScene.RESOURCE_BINDING = {
    ["panel_wechat"] = {varname = "m_panelWechat"},
    ["panel_wechat.btn_wechat"] = {varname = "m_btnWechat", events = {{ event = "click", method = "onWechat" }}},
    ["panel_wechat.btn_agreement"] = {varname = "m_btnAgreement", events = {{ event = "click", method = "onAgreement" }}},
    ["panel_wechat.checkbox_agreement"] = {varname = "m_checkbox_agreement"},

    ["panel_register"] = {varname = "m_panelRegister"},
    ["panel_register.node_user_id"] = {varname = "m_bgUserId"},
    ["panel_register.login_pos"] = {varname = "m_loginPos"},
    ["panel_register.node_user_password"] = {varname = "m_bgPassWord"},
    ["panel_register.btn_register"] = {varname = "m_btnRegister", events = {{ event = "click", method = "onRegister" }}},
    ["panel_register.btn_login"] = {varname = "m_btnLogin", events = {{ event = "click", method = "onLogin" }}},
    ["panel_register.btn_random_id"] = {varname = "m_btnRandomId", events = {{ event = "click", method = "onRandomId" }}},

    ["herochess_agreement_bg_11"] = {varname = "m_bgAgreement"},
    ["herochess_agreement_bg_11.btn_close"] = {varname = "m_btnAgreementClose", events = {{ event = "click", method = "onAgreementClose" }}},
    ["herochess_agreement_bg_11.panel_agreement.text_agreement"] = {varname = "m_textAgreement"}
}

function LoginScene:onCreate()
    dd.NetworkClient:connect("192.168.0.104", 16800)
    print("LoginScene:onCreate....")
    self:initUI()
    self:initRegisterStatus()
end

function LoginScene:initUI()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_checkbox_agreement:onEvent(handler(self, self.onCheckBoxAgreement))

    self.m_txtUserId = self:createTextField("请输入6位用户账号")
    self.m_txtUserId:setCascadeColorEnabled(true)
    self.m_bgUserId:addChild(self.m_txtUserId)

    self.m_txtPassword = self:createTextField("请输入6位用户密码")
    self.m_bgPassWord:addChild(self.m_txtPassword)

    self.m_willShowWechatLogin = false
end

function LoginScene:initRegisterStatus()
    self.m_isRegister = false
    self.m_leftPos = cc.p(self.m_loginPos:getPositionX(), self.m_loginPos:getPositionY())
    self.m_centerPos = cc.p(self.m_btnLogin:getPositionX(), self.m_btnLogin:getPositionY())
    self.m_rightPos = cc.p(self.m_btnRegister:getPositionX(), self.m_btnRegister:getPositionY())
end

function LoginScene:showPanel()
    if self.m_willShowWechatLogin then
        self.m_panelWechat:setVisible(true)
    else
        self.m_panelRegister:setVisible(true)
    end
end

function LoginScene:onRandomId()
    dd.NetworkClient:sendBlockMsg("login.get_account", {}, function ( ... )
        local tb = ...
        dump(tb)
        self.m_txtUserId:setText(tostring(tb.account))
    end)
end

function LoginScene:onRegister()
    if self.m_isRegister then
        dd.NetworkClient:close()
        dd.NetworkClient:connect("192.168.18.107", 16800)
        dd.NetworkClient:sendBlockMsg(
            "login.register", 
            {account = self.m_txtUserId:getText(), passwd = self.m_txtPassword:getText()}, 
            function ( ... ) dump({...}) end
        )
    else
        self.m_btnLogin:runAction(cc.MoveTo:create(0.2, self.m_leftPos)) 
        self.m_btnRegister:runAction(cc.MoveTo:create(0.2, self.m_centerPos))
        self.m_btnRandomId:setVisible(true)
        self.m_btnLogin:setScale(0.8)
        self.m_btnRegister:setScale(1)
        self.m_isRegister = true
        self.m_txtUserId:setEnabled(false)

        dd.NetworkClient:sendBlockMsg("login.get_account", {}, function ( ... )
            local tb = ...
            dump(tb)
            self.m_txtUserId:setText(tostring(tb.account))
        end)
    end
end

function LoginScene:onLogin()
    if self.m_isRegister then
        self.m_btnLogin:runAction(cc.MoveTo:create(0.2, self.m_centerPos)) 
        self.m_btnRegister:runAction(cc.MoveTo:create(0.2, self.m_rightPos))
        self.m_btnRandomId:setVisible(false)
        self.m_btnLogin:setScale(1)
        self.m_btnRegister:setScale(0.8)
        self.m_isRegister = false
        self.m_txtUserId:setEnabled(true)
    else
        local account = tonumber(self.m_txtUserId:getText())
        local passwd = self.m_txtPassword:getText()
        dd.NetworkClient:sendBlockMsg("login.login", {account = account, passwd = passwd}, function ( ... )
            dump({...}) 
            dd.NetworkClient:close()
            dd.NetworkClient:connect("192.168.0.104", 16802)
            dd.NetworkClient:sendBlockMsg("login.login_baseapp", {account = self.m_txtUserId:getText(), token = "token"}, function ( ... )
                dump({...})
            end)
        end)
    end
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

function LoginScene:createTextField(placeHolder)
    local editTxt = ccui.EditBox:create(cc.size(300, 60), "herochess_input_box.png", ccui.TextureResType.plistType)
    editTxt:setName("inputTxt")
    editTxt:setAnchorPoint(0.5,0.5)
    editTxt:setFontSize(36)
    editTxt:setPlaceHolder(placeHolder)
    editTxt:setMaxLength(6)                             
    editTxt:setFontColor(cc.c4b(255, 255, 255, 255))
    editTxt:setPlaceholderFontColor(cc.BLACK)
    editTxt:setFontName("Arial") 
    editTxt:setPlaceholderFontSize(24)
    editTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE) 
    editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) 
    editTxt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    editTxt:registerScriptEditBoxHandler(function(eventname, sender) self:editboxHandle(eventname, sender) end)
    editTxt:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS)
    editTxt.m_placeHolder = placeHolder
    editTxt:setText("")

    return editTxt
end

function LoginScene:editboxHandle(strEventName, sender)
    if strEventName == "began" then
        sender:setPlaceHolder("")
    elseif strEventName == "ended" then 
        sender:setPlaceHolder(sender.m_placeHolder)
    elseif strEventName == "return" then
    elseif strEventName == "changed" then
    end
end

return LoginScene
