--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 		https://theindiestone.com/forums/index.php?/topic/20228-coxis-shop/											       										#
#########################################################################################################
--]]

require "ISUI/ISPanelJoypad"
require "ISUI/ISLayoutManager"

UICoxisTradingPanel = ISPanelJoypad:derive("UICoxisTradingPanel");
UICoxisTradingList = ISScrollingListBox:derive("UICoxisTradingList");
UICoxisTradingScrollbar = ISScrollBar:derive("UICoxisTradingScrollbar");

CoxisTradingUI = {};

-- CoxisShopUI.checkPrice = function(_target, _onmousedown, _self)
	-- local splitstring = luautils.split(_onmousedown, "|");

	-- if _self.char:getModData().playerMoney < tonumber(splitstring[2]) then
		-- _self.parent.buttons[1]:setEnable(false);
	-- else
		-- _self.parent.buttons[1]:setEnable(true);
	-- end
-- end

CoxisTradingUI.proposeItem = function(_target, _onmousedown, _self)
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("CoxisTrading", true);
	--local item
	_self:removeItem(_onmousedown:getName());
	_self.parent.CoxisProposedList:addItem(_onmousedown:getName(), _onmousedown);
	local itemsOnly = {};
	local namesOnly = {};
	local mX, mY = ISCoordConversion.ToWorld(_self.char:getX(), _self.char:getY(), 0);
	mX = math.floor( mX );
	mY = math.floor( mY );
	local square = _self.char:getCurrentSquare();
	--square:setZ(square:getZ() + 2);
	print("playerX: " .. _self.char:getX());
	print("playerY: " .. _self.char:getY());
	print("playerZ: " .. _self.char:getZ());
	print("square: " .. tostring(square));
	print("squareX: " .. tostring(square:getX()));
	print("squareY: " .. tostring(square:getY()));
	print("squareZ: " .. tostring(square:getZ()))
	for _, itemEntry in ipairs(_self.parent.CoxisProposedList.items) do		
			table.insert(itemsOnly, itemEntry.item)
			table.insert(namesOnly, itemEntry.text)
	end
	
	for _,i in ipairs(itemsOnly) do
		--local worlditem = IsoWorldInventoryObject.new(i, square, 0, 0, 0);
		--i:setWorldItem(worlditem);
		--square:AddWorldInventoryItem(i, 0, 0, 0, true);
		--worlditem:transmitCompleteItemToServer();
		i:save(i:getByteData(), true);
		print("bytebuffer: " .. tostring(i:getByteData()));
		--print("worlditem: " .. tostring(worlditem));
	end
	
	--module.sendPlayer(_self.parent.tradingPartner, "updateproposed", namesOnly, square:getX(), square:getY(), square:getZ());
	
	
end

CoxisTradingUI.withdrawItem = function(_target, _onmousedown, _self)
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("CoxisTrading", true);
	
	_self:removeItem(_onmousedown:getName());
	_self.parent.CoxisInventoryList:addItem(_onmousedown:getName(), _onmousedown);
	
	--module.sendPlayer(_self.parent.tradingPartner, "updateproposed", _self.items)
end

function UICoxisTradingPanel:initialise()
	ISPanelJoypad.initialise(self);
	self:create();
end

function UICoxisTradingPanel:render()
	local y = 42;

	self:drawText(getText('UI_CoxisTrading_You') .. ": " .. self.char:getUsername(), 20, y, 1,1,1,1, UIFont.Medium);
	self:drawText(getText('UI_CoxisTrading_TradingPartner') .. ": " .. self.tradingPartner:getUsername(), 416, y, 1,1,1,1, UIFont.Medium);	
end

function UICoxisTradingPanel:create()
	local y = 60;

	local label = ISLabel:new(16, y, 20, getText('UI_CoxisTrading_YourInventory'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);
	
	label = ISLabel:new(216, y, 20, getText('UI_CoxisTrading_YourProposal'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);
	
	label = ISLabel:new(416, y, 20, getText('UI_CoxisTrading_PartnerProposal'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(label);

	local rect = ISRect:new(16, y + 20, 602, 1, 0.6, 0.6, 0.6, 0.6);
	self:addChild(rect);
	
	self.CoxisInventoryList = UICoxisTradingList:new(16, y + 30, 200, 300, self.char, self.playerId, self);
    self.CoxisInventoryList:initialise()
    self.CoxisInventoryList:instantiate()
    self.CoxisInventoryList.itemheight = 22
	self.CoxisInventoryList.onmousedblclick = CoxisTradingUI.proposeItem;
    self.CoxisInventoryList.font = UIFont.NewSmall
    self.CoxisInventoryList.drawBorder = true
    self:addChild(self.CoxisInventoryList)
	
	for _,item in ipairs(self.items) do
		self.CoxisInventoryList:addItem(item:getName(), item);
		--print(item:getName());
	end
	
	self.CoxisProposedList = UICoxisTradingList:new(216, y + 30, 200, 300, self.char, self.playerId, self);
    self.CoxisProposedList:initialise()
    self.CoxisProposedList:instantiate()
    self.CoxisProposedList.itemheight = 22
	self.CoxisProposedList.onmousedblclick = CoxisTradingUI.withdrawItem;
    self.CoxisProposedList.font = UIFont.NewSmall
    self.CoxisProposedList.drawBorder = true
    self:addChild(self.CoxisProposedList)
	
	self.CoxisTradingList = UICoxisTradingList:new(416, y + 30, 200, 300, self.char, self.playerId, self);
    self.CoxisTradingList:initialise()
    self.CoxisTradingList:instantiate()
    self.CoxisTradingList.itemheight = 22
	--self.CoxisTradingList.onmousedown = CoxisTradingUI.withdrawItem;
    self.CoxisTradingList.font = UIFont.NewSmall
    self.CoxisTradingList.drawBorder = true
    self:addChild(self.CoxisTradingList)
	
	self.CoxisAcceptDealBtn = self:createButton(16, 410, self.onBtnClick, "acceptdeal", getText('UI_CoxisTrading_AcceptDeal'));
	self.CoxisDeclineDealBtn = self:createButton(216, 410, self.onBtnClick, "declinedeal", getText('UI_CoxisTrading_DeclineDeal'));
	self.buttons["declinedeal"]:setEnable(false);
	
	self.CoxisYourDealState = ISLabel:new(416, 410, 20, getText('UI_CoxisTrading_YouDeclined'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(self.CoxisYourDealState);
	
end

function UICoxisTradingPanel:createButton(x, y, _function, _internal, _label)
	local label = nil;
	label = _label;--
	local button = ISButton:new(x, y, 100, 25, label, self, _function);
	button:initialise();
	button.internal = _internal;
	button.borderColor = {r=1, g=1, b=1, a=0.1};
	--button.playerId = playerId;
	--button.char = player;
	button:setFont(UIFont.Small);
	button:ignoreWidthChange();
	button:ignoreHeightChange();
	self:addChild(button);
	--table.insert(self.buttons, button);
	self.buttons[_internal] = button;
end

function UICoxisTradingPanel:onBtnClick(button, x, y)
	-- manage the item
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("CoxisTrading", true);
	
	if button.internal == "acceptdeal" then
		-- disable the ability to alter the deal
		self.CoxisProposedList.onmousedblclick = nil;
		self.CoxisInventoryList.onmousedblclick = nil;
		-- #todo: send other player that user accepts deal, items can´t be edited when deal is accepted
		module.sendPlayer(self.tradingPartner, "acceptdeal", self.tradingPartner)
		
		self:removeChild(self.CoxisYourDealState);
		self.CoxisYourDealState = ISLabel:new(416, 410, 20, getText('UI_CoxisTrading_YouAccepted'), 1, 1, 1, 0.8, UIFont.Small, true);
		self:addChild(self.CoxisYourDealState);
		
		self.buttons["declinedeal"]:setEnable(true);
		button:setEnable(false)
		
		
	elseif button.internal == "declinedeal" then
		self.CoxisProposedList.onmousedblclick = CoxisTradingUI.withdrawItem;
		self.CoxisInventoryList.onmousedblclick = CoxisTradingUI.proposeItem;
		
		module.sendPlayer(self.tradingPartner, "declinedeal", self.tradingPartner)
		
		self:removeChild(self.CoxisYourDealState);
		self.CoxisYourDealState = ISLabel:new(416, 410, 20, getText('UI_CoxisTrading_YouDeclined'), 1, 1, 1, 0.8, UIFont.Small, true);
		self:addChild(self.CoxisYourDealState);
		
		self.buttons["acceptdeal"]:setEnable(true);
		button:setEnable(false);
	end
	--self:reloadButtons()
end

function UICoxisTradingPanel:setAcceptDeal()
	print("deal accepted! Showing it in UI")
	
	if self.CoxisPartnerDealState then
		self:removeChild(self.CoxisPartnerDealState);
	end
	
	self.CoxisPartnerDealState = ISLabel:new(416, 430, 20, getText('UI_CoxisTrading_PartnerAccepted'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(self.CoxisPartnerDealState);
	self.CoxisProposedList.onmousedblclick = nil;
	self.CoxisInventoryList.onmousedblclick = nil;
	
	self.buttons["acceptdeal"]:setEnable(true);
	self.buttons["declinedeal"]:setEnable(true);
end

function UICoxisTradingPanel:setDeclineDeal()
	print("deal declined! Showing it in UI")
	
	if self.CoxisPartnerDealState then
		self:removeChild(self.CoxisPartnerDealState);
	end
	
	self.CoxisPartnerDealState = ISLabel:new(416, 430, 20, getText('UI_CoxisTrading_PartnerDeclined'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(self.CoxisPartnerDealState);
	self.CoxisProposedList.onmousedblclick = CoxisTradingUI.withdrawItem;
	self.CoxisInventoryList.onmousedblclick = CoxisTradingUI.proposeItem;
	
	self.buttons["acceptdeal"]:setEnable(true);
	self.buttons["declinedeal"]:setEnable(false);
end

function UICoxisTradingPanel:setTradingQuit()
	print("trading quit! Showing it in UI")
	
	if self.CoxisPartnerDealState then
		self:removeChild(self.CoxisPartnerDealState);
	end
	
	self.CoxisPartnerDealState = ISLabel:new(416, 430, 20, getText('UI_CoxisTrading_PartnerQuit'), 1, 1, 1, 0.8, UIFont.Small, true);
	self:addChild(self.CoxisPartnerDealState);
	self.CoxisProposedList.onmousedblclick = nil;
	self.CoxisInventoryList.onmousedblclick = nil;
	self.buttons["acceptdeal"]:setEnable(false);
	self.buttons["declinedeal"]:setEnable(false);
end

function UICoxisTradingPanel:reloadButtons()
	local index = 1;
	if self.CoxisTradingList.selected > 0 then
		index = self.CoxisTradingList.selected;
	end

	if #self.CoxisTradingList.items > 0 then
		local selectedItem = self.CoxisTradingList.items[index].item;
		local splitstring = luautils.split(selectedItem, "|");

		if self.char:getModData().playerMoney < tonumber(splitstring[2]) then
			self.buttons[1]:setEnable(false);
		else
			self.buttons[1]:setEnable(true);
		end
	else
		self.buttons[1]:setEnable(false);
	end
end

function UICoxisTradingPanel:loadJoypadButtons()
	self:clearJoypadFocus()
	self.joypadButtonsY = {}
	self:insertNewLineOfButtons(self.buttons[1])
	self:insertNewLineOfButtons(self.buttons[2])
	self:insertNewLineOfButtons(self.buttons[3])
	self:insertNewLineOfButtons(self.buttons[4], self.buttons[5]);
	self:insertNewLineOfButtons(self.buttons[6], self.buttons[7]);
	self.joypadIndex = 1
	self.joypadIndexY = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
end

function UICoxisTradingPanel:onJoypadDown(button, joypadData)
	if button == Joypad.AButton then
		ISPanelJoypad.onJoypadDown(self, button, joypadData)
	end
	if button == Joypad.BButton then
		ISCoxisShopUpgradeTab.instance[self.playerId]:setVisible(false)
		joypadData.focus = nil
	end
	if button == Joypad.LBumper then
		ISCoxisShopUpgradeTab.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
	if button == Joypad.RBumper then
		ISCoxisShopUpgradeTab.instance[self.playerId]:onJoypadDown(button, joypadData)
	end
end

function UICoxisTradingPanel:new(x, y, width, height, player, _items, _tradingPartner)
	local o = {};
	o = ISPanelJoypad:new(x, y, width, height);
	o:noBackground();
	setmetatable(o, self);
    self.__index = self;
	o.char = getSpecificPlayer(player);
	o.playerId = player;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.buttons = {};
	o.items = _items;
	o.tradingPartner = _tradingPartner;
	o.CoxisTradingList = nil;
	o.CoxisInventoryList = nil;
	o.CoxisProposedList = nil;
	o.CoxisYourDealState = nil;
	o.CoxisPartnerDealState = nil;
   return o;
end

-- **************************************************************************************
-- redefining the ISScrollingListBox:onBuyMouseDown to pass more variables
-- **************************************************************************************
function UICoxisTradingList:onMouseDown(x, y)
	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = #self.items;
	end
	if row < 1 then
		row = 1;
	end

	self.selected = row;
	
	if self.onmousedown then
		self.onmousedown(self.target, self.items[self.selected].item, self);
	end
end

function UICoxisTradingList:onMouseDoubleClick(x, y)
	if self.onmousedblclick and self.items[self.selected] ~= nil then
		self.onmousedblclick(self.target, self.items[self.selected].item, self);
	end
end

function UICoxisTradingList:render()
    if self.joypadFocused then
        self:drawRectBorder(0, -self:getYScroll(), self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(1, 1-self:getYScroll(), self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    end
	if self.mouseoverselected ~= -1 and self.mouseoverselected ~= nil and self.count >= self.mouseoverselected then
		local item = self.items[self.mouseoverselected].item;

		if self.toolRender then
			self.toolRender:setItem(item)
		else
			self.toolRender = ISToolTipInv:new(item)
			self.toolRender:initialise()
			self.toolRender:addToUIManager()
			self.toolRender:setX(self:getMouseX())
			self.toolRender:setY(self:getMouseY())
			self.toolRender.followMouse = not self.doController
		end
	elseif self.toolRender then
		self.toolRender:removeFromUIManager()
		self.toolRender:setVisible(false)
		self.toolRender = nil
	end
	
end

function UICoxisTradingList:addItem(name, item)
    local i = {}
    i.text=name;
    i.item=item;
	i.tooltip = item:getTooltip();
    i.itemindex = self.count + 1;
	i.height = self.itemheight
    table.insert(self.items, i);
    self.count = self.count + 1;
    self:setScrollHeight(self:getScrollHeight()+i.height);
    return i;
end

function UICoxisTradingList:new(x, y, width, height, player, playerId, parent)
	local o = {}
	--o.data = {}
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
	o:noBackground();
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9};
	o.altBgColor = {r=0.2, g=0.3, b=0.2, a=0.1}
	-- Since these were broken before, don't draw them by default
	o.altBgColor = nil
	o.drawBorder = false
	o.width = width;
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.font = UIFont.Large
	o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
	o.itemPadY = 7
	o.itemheight = o.fontHgt + o.itemPadY * 2;
	o.selected = 1;
    o.count = 0;
	o.itemheightoverride = {}
	o.items = {}
	o.char = player;
	o.playerId = playerId;
	o.parent = parent;
	return o
end
