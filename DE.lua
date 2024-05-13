FE = FE or {}

local frame = CreateFrame("Frame", "DisenchantHelperFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(360, 480) -- Width, Height
frame:SetPoint("CENTER") -- Position on the screen
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("Disenchant Helper")

FE.framePool = CreateFramePool("Button", frame, "SecureActionButtonTemplate, ActionButtonTemplate")

local function CreateOrUpdateDisenchantButton(bag, slot, parent, i, item_info)
    local buttonWidth = 45
    local buttonHeight = 45
    local buttonsPerRow = 10

    local xPosition = ((i - 1) % buttonsPerRow) * buttonWidth
    local yPosition = -math.floor((i - 1) / buttonsPerRow) * buttonHeight

    local btn, isNew = FE.framePool:Acquire()
    if isNew then
        btn:SetSize(40, 40)
        btn:EnableMouse(true)
        btn:RegisterForClicks("AnyUp", "AnyDown")
        --print("new")

    end

    btn:SetPoint("Center", parent, "TOPLEFT", xPosition, yPosition)
    btn:SetAttribute("type", "spell")
    btn:SetAttribute("spell", 13262)
    btn:SetAttribute("target-bag", bag)
    btn:SetAttribute("target-slot", slot)
    btn:SetNormalTexture(item_info[10])
    btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(item_info[18])
    GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end)
    btn:Show()
end

local function UpdateGearList()
    FE.framePool:ReleaseAll() -- Free all frames for reuse
    local i = 0
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID then
                local _, _, _, _, _, itemType = GetItemInfo(itemID)
                if itemType == "Armor" or itemType == "Weapon" then
                    local item_info = {GetItemInfo(itemID)}
                    local item_link = C_Container.GetContainerItemLink(bag,slot)
                    item_info[18] = item_link
                    if item_info[3] > 1 then 
                        CreateOrUpdateDisenchantButton(bag, slot, frame, i, item_info)
                        i = i + 1
                    end
                end
            end
        end
    end
end

FE.DE_SHOW = false

local function tick() 
    if FE.DE_SHOW then
        --print("Tick...")
        UpdateGearList()
        C_Timer.After(1, tick)
    end
    
end

frame:SetScript("OnShow", function()

   UpdateGearList() 
    
end)

SLASH_DE1 = "/ezde"
SlashCmdList["EZDE"] = function(msg)

    if FE.DE_SHOW then
        frame:Hide()
        FE.DE_SHOW = false
    else
        frame:Show()
        FE.DE_SHOW = true
        tick()
    end
end