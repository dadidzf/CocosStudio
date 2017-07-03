local BindingUtil = class("BindingUtil")

function BindingUtil.binding(self, resourceNode, binding)
    for nodeName, nodeBinding in pairs(binding) do
        local names = string.split(nodeName, '.')
        local node = resourceNode
        for _, name in ipairs(names) do
            node = node:getChildByName(name)
            if node == nil then
                print("[WARNING] Not Found Node: " .. nodeName)
                break
            end
        end

        if node then
            if nodeBinding.varname then
                self[nodeBinding.varname] = node
            end
            
            for _, param in ipairs(nodeBinding.events or {}) do
                if param.event == "touch" then
                    node:onTouch(handler(self, self[param.method]))
                elseif param.event == "click" then
                    node:onClick(handler(self, self[param.method]))
                end
            end
        end
    end
end

return BindingUtil