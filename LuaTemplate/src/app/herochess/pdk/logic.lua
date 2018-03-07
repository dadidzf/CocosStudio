-- 方块(Diamond): 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 方块A-10 J Q K
-- 梅花(Club)   : 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 梅花A-10 J Q K
-- 红桃(Heart)  : 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 红桃A-10 J Q K
-- 黑桃(Spade)  : 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 黑桃A-10 J Q K
-- 王(Joker)    : 0x4E 0x4F 大小王
-- 牌型定义

local card_pool = {
    -- 15张玩法(只有一张黑桃2，去除黑桃A外的三张A，无大小王)
    [45] = {
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
        0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
        0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d,
        0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d
    },
    -- 16张玩法(只有一张黑桃2，去除黑桃A外的三张A，无大小王)
    [48] = {
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,
        0x11, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x21, 
        0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d,
        0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d
    }
}

local logic = {}

logic.type = {
    t_1  = "t_1",       -- 单张
    t_1n = "t_1n",      -- 顺子
    t_2  = "t_2",       -- 对
    t_2n = "t_2n",      -- 连对
    t_32 = "t_32",      -- 三带2
    t_32n= "t_32n",     -- 三带二飞机
    t_4  = "t_4",       -- 炸弹
    -- t_41 = "t_41",      -- 四带一
    -- t_42 = "t_42",      -- 四带二
    -- t_43 = "t_43",      -- 四带三
    -- t_king = "t_king",  -- 王炸
}

function logic.shuffle(card_counts)
    local cards_in_order = card_pool[card_counts]
    local cards = logic.clone(cards_in_order)
    math.randomseed(os.time())

    for n = card_counts, 1, -1 do
        local index = math.random(n)
        local temp = cards[n]
        cards[n] = cards[index]
        cards[index] = temp
    end

    local ret_cards = {{}, {}, {}}
    local single_cards_count = card_counts == 48 and 16 or 15
    for k = 1, 3 do
        for i = 1, single_cards_count  do
            ret_cards[k][i] = cards[(k - 1)*single_cards_count + i]
        end
    end

    return ret_cards
end

function logic.sort(cards)
    table.sort(cards, function (a, b)
        return a > b
    end)
end

function logic.sort_for_display(cards)
    table.sort(cards, function (a, b)
        local indexA = logic.get_card_index(a)
        local indexB = logic.get_card_index(b)
        if indexA > indexB then
            return true
        elseif indexA < indexB then
            return false
        else
            return a > b
        end
    end)
end

function logic.get_card_index(card)
    local c = math.fmod(card, 16)
    if c == 0x01 then 
        return 14
    elseif c == 0x02 then
        return 15
    elseif c == 0x0e then
        return 16
    elseif c == 0x0f then
        return 17
    end

    return c
end

function logic.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function logic.analysic_card(out_cards)
    local tmp_cards = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    for _, c in ipairs(out_cards) do
        local index = logic.get_card_index(c)
        tmp_cards[index] = tmp_cards[index] + 1
    end

    local counts = {0, 0, 0, 0}      -- 1, 2, 3, 4组合的数目
    local cards = {{}, {}, {}, {}}   -- 数目分别为1, 2, 3, 4的牌的序列
    for i, _ in ipairs(tmp_cards) do
        local c = tmp_cards[i]
        if c and c ~= 0 then
            counts[c] = counts[c] + 1
            table.insert(cards[c], i)
        end
    end

    return counts, cards
end

-- 获取牌型
function logic.get_type(out_cards, is_last)
    local counts, cards = logic.analysic_card(out_cards)

    if counts[4] > 0 then
        return logic.get_type4(counts, cards, is_last)
    elseif counts[3] > 0 then
        return logic.get_type3(counts, cards, is_last)
    elseif counts[2] > 0 then
        return logic.get_type2(counts, cards)
    elseif counts[1] > 0 then
        return logic.get_type1(counts, cards)
    end
end

function logic.get_type4(counts, cards, is_last)
    if counts[4] == 1 then
        local sum = counts[3] + counts[2] + counts[1]
        if sum == 0 then
            return {t = logic.type.t_4, card = cards[4][1]}
        elseif sum == 1 and counts[1] == 1 then
            return {t = logic.type.t_32, card = cards[4][1]}
        end
    end 

    local cards_temp = logic.clone(cards)
    local counts_temp = logic.clone(counts)
    for _, card in ipairs(cards[4]) do
        table.insert(cards_temp[3], card)
        table.insert(cards_temp[1], card)
        counts_temp[3] = counts_temp[3] + 1
        counts_temp[1] = counts_temp[1] + 1
    end
    cards_temp[4] = {}
    counts_temp[4] = 0
    table.sort(cards_temp[3], function (a, b)
        return a < b
    end)

    return logic.get_type3(counts_temp, cards_temp, is_last)
end

function logic.get_type3(counts, cards, is_last)
    assert(counts[4] == 0, "if run here, cards[4] should have been seperated to cards[1] and cards[3] ! \
        and counts[4] should be 0 !")

    if counts[3] == 1 then
        local sum = counts[1] + 2*counts[2]
        local card = cards[3][1]

        if sum == 2 then
            return {t = logic.type.t_32, card = card}
        else
            if sum < 2 and is_last then
                return {t = logic.type.t_32, card = card}
            end
        end
    else
        local max_continue_tb = logic.get_max_continue(cards[3])
        local card = max_continue_tb[1]
        local n = #max_continue_tb

        local sum = counts[1] + counts[2]*2 + (counts[3] - n)*3
        if sum == n*2 then
            return {t = logic.type.t_32n, card = card, n = n}
        else
            if sum < n*2 and is_last then
                return {t = logic.type.t_32n, card = card, n = n}
            end
        end
    end
end

function logic.get_type2(counts, cards)
    local sum = counts[1] + counts[3] + counts[4]
    if sum > 0 then
        return
    end

    local card = cards[2][1]
    if counts[2] == 1 then
        return {t = logic.type.t_2, card = card}
    else
        if logic.is_continue(cards[2]) then
            if card + counts[2] - 1 >= logic.get_card_index(2) then
                return
            else
                return  {t = logic.type.t_2n, card = card, n = counts[2]}
            end
        else
            return 
        end
    end
end

function logic.get_type1(counts, cards)
    local sum = counts[2] + counts[3] + counts[4]
    if sum > 0 then
        return
    end

    local count = counts[1]
    local card = cards[1][1]
    if count >= 5 then
        if logic.is_continue(cards[1]) then
            if card + counts[1] - 1 >= logic.get_card_index(2) then
                return
            else
                return {t = logic.type.t_1n, card = card, n = count}
            end
        end
    else
        if count == 1 then
            return {t = logic.type.t_1, card = card}
        end
    end
end

function logic.is_continue(cards)
    local last
    for _, c in ipairs(cards) do
        if last and last + 1 ~= c then
            return
        end

        last = c 
    end
    return true
end

function logic.get_all_continue(cards)
    local t = {}
    local last
    local tmp
    for _, c in ipairs(cards) do
        if c >= logic.get_card_index(2) then
            break
        end

        if last and last + 1 ~= c then
            table.insert(t, tmp)
            tmp = nil
        end

        tmp = tmp or {}
        table.insert(tmp, c)
        last = c 
    end

    if tmp then
        table.insert(t, tmp)
    end

    return t
end

function logic.get_max_continue(cards)
    local t = logic.get_all_continue(cards) 

    local m
    for _, v in ipairs(t) do
        if not m then
            m = v
        elseif #v >= #m then
            m = v
        end
    end
    
    return m
end

-- 牌型2是否管得起牌型1
function logic.is_big(info1, info2)
    if info2.t == logic.type.t_4 then
        if info1.t == logic.type.t_4 then
            return info1.card < info2.card
        else
            return true
        end
    else
        if info1.t == logic.type.t_4 then
            return false
        else
            if info1.t ~= info2.t or info1.n ~= info2.n then
                return
            end

            return info1.card < info2.card
        end
    end
end

-- 仅用于服务端判断是否要的起
function logic.is_bigger_cards_exist(out_info, all_cards)
    local counts, cards = logic.analysic_card(all_cards)
    local out_card = out_info.card
    local out_n = out_info.n
    local out_t = out_info.t

    if out_t == logic.type.t_4 then
        return logic.is_bigger_t_4_exist(out_card, counts, cards)
    elseif out_t == logic.type.t_1 then
        return logic.is_bigger_t_1_exist(out_card, counts, cards)
    elseif out_t == logic.type.t_1n then
        return logic.is_bigger_t_1n_exist(out_card, out_n, counts, cards)
    elseif out_t == logic.type.t_2 then
        return logic.is_bigger_t_2_exist(out_card, counts, cards)
    elseif out_t == logic.type.t_2n then
        return logic.is_bigger_t_2n_exist(out_card, out_n, counts, cards)
    elseif out_t == logic.type.t_32 then
        return logic.is_bigger_t_32_exist(out_card, counts, cards)
    elseif out_t == logic.type.t_32n then
        return logic.is_bigger_t_32n_exist(out_card, out_n, counts, cards)
    else
        assert(false, "can not be here !")
    end
end

function logic.is_bigger_t_4_exist(out_card, counts, cards)
    local count4 = counts[4]
    if count4 > 0 and cards[4][count4] > out_card then
        return true
    else
        return false
    end
end

function logic.is_bigger_t_1_exist(out_card, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local count1 = counts[1]
    local count2 = counts[2]
    local count3 = counts[3]

    if count1 > 0 and cards[1][count1] > out_card then
        return true
    elseif count2 > 0 and cards[2][count2] > out_card then
        return true
    elseif count3 > 0 and cards[3][count3] > out_card then
        return true
    else
        return false
    end
end

function logic.is_bigger_t_1n_exist(out_card, out_n, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local cards_temp_1 = logic.clone(cards[1])
    for _, c in ipairs(cards[2]) do
        table.insert(cards_temp_1, c)
    end
    for _, c in ipairs(cards[3]) do
        table.insert(cards_temp_1, c)
    end

    table.sort(cards_temp_1, function (a, b)
        return a < b
    end)

    local t = logic.get_all_continue(cards_temp_1)
    local out_max = out_card + out_n - 1

    for _, continue in ipairs(t) do
        local len = #continue
        local max = continue[len]

        if len >= out_n and max > out_max then
            return true
        end
    end

    return false
end

function logic.is_bigger_t_2_exist(out_card, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local count2 = counts[2]
    local count3 = counts[3]

    if count2 > 0 and cards[2][count2] > out_card then
        return true
    elseif count3 > 0 and cards[3][count3] > out_card then
        return true
    else
        return false
    end
end

function logic.is_bigger_t_2n_exist(out_card, out_n, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local cards_temp_2 = logic.clone(cards[2])
    for _, c in ipairs(cards[3]) do
        table.insert(cards_temp_2, c)
    end

    table.sort(cards_temp_2, function (a, b)
        return a < b
    end)

    local t = logic.get_all_continue(cards_temp_2)
    local out_max = out_card + out_n - 1

    for _, continue in ipairs(t) do
        local len = #continue
        local max = continue[len]

        if len >= out_n and max > out_max then
            return true
        end
    end

    return false
end

function logic.is_bigger_t_32_exist(out_card, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local count3 = counts[3]
    if count3 > 0 and cards[3][count3] > out_card then
        return true
    else
        return false
    end
end

function logic.is_bigger_t_32n_exist(out_card, out_n, counts, cards)
    if counts[4] > 0 then
        return true
    end

    local t = logic.get_all_continue(cards[3])
    local out_max = out_card + out_n - 1

    for _, continue in ipairs(t) do
        local len = #continue
        local max = continue[len]

        if len >= out_n and max > out_max then
            return true
        end
    end

    return false
end

-- function logic.get_bigger_cards(out_info, all_cards)
--     if out_info.t == logic.type.t_4 then
--         return logic.get_bigger_t_4(out_info.card, all_cards)
--     elseif out_info.t == logic.type.t_1 then
--         return logic.get_bigger_t_1(out_info.card, all_cards)
--     elseif out_info.t == logic.type.t_1n then
--         return logic.get_bigger_t_1n(out_info.card, out_info.n, all_cards)
--     elseif out_info.t == logic.type.t_2 then
--         return logic.get_bigger_t_2(out_info.card, all_cards)
--     elseif out_info.t == logic.type.t_2n then
--         return logic.get_bigger_t_2n(out_info.card, out_info.n, all_cards)
--     elseif out_info.t == logic.type.t_32 then
--         return logic.get_bigger_t_32(out_info.card, all_cards)
--     elseif out_info.t == logic.type.t_32n then
--         return logic.get_bigger_t_32n(out_info.card, n, all_cards)
--     else
--         assert(false, "can not be here !")
--     end
-- end

-- function logic.get_bigger_t_1(card, all_cards)
--     local ret_tb = {}
--     for _, c in ipairs(all_cards) do
--         if logic.get_card_index(c) > card then
--             table.insert(ret_tb, c)
--         end
--     end

--     return ret_tb
-- end

-- function logic.get_bigger_t_1n(card, n, all_cards)
-- end

-- function logic.get_bigger_t_2(card, all_cards)
-- end

-- function logic.get_bigger_t_2n(card, n, all_cards)
-- end

-- function logic.get_bigger_t_32(card, all_cards)
-- end

-- function logic.get_bigger_t_32n(card, n, all_cards)
-- end

-- function logic.get_bigger_t_4(card, all_cards)
-- end

return logic
