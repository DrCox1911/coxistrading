--[[
#########################################################################################################
#	@mod:		CoxisShop - A money-based item and skill shop                                           #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 		https://theindiestone.com/forums/index.php?/topic/20228-coxis-shop/											       										#
#########################################################################################################
--]]

require "ISUI/ISCollapsableWindow"

UICoxisTrading = ISCollapsableWindow:derive("UICoxisTrading");
UICoxisTrading.instance = {}

function UICoxisTrading:initialise()
	ISCollapsableWindow.initialise(self);
end

function UICoxisTrading:createChildren()
	ISCollapsableWindow.createChildren(self);
	local th = self:titleBarHeight()
	local rh = self:resizeWidgetHeight()
	self.panel = ISTabPanel:new(0, th, self.width, self.height-th-rh);
	self.panel:initialise();
	self:addChild(self.panel);
	
	-- Tab with weapon stuff
	self.tradingScreen = UICoxisTradingPanel:new(0, 8, 634, 460, self.playerId, self.invItems, self.tradingPartner);
	self.tradingScreen:initialise();
	self.panel:addView(getText('UI_CoxisTrading_TradeWindow'), self.tradingScreen);
	-------------------------
end

function UICoxisTrading:render()
	ISCollapsableWindow.render(self)

	if JoypadState.players[self.playerId+1] then
		self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
		self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
	end
end

function UICoxisTrading:reloadButtons()
	self.tradingScreen:reloadButtons();
end

function UICoxisTrading:setAcceptDeal()
	self.tradingScreen:setAcceptDeal();
end

function UICoxisTrading:setDeclineDeal()
	self.tradingScreen:setDeclineDeal();
end

function UICoxisTrading:setTradingQuit()
	self.tradingScreen:setTradingQuit();
end

function UICoxisTrading:close()
	local luanet = LuaNet:getInstance();
	local module = luanet.getModule("CoxisTrading", true);
	
	module.sendPlayer(self.tradingPartner, "tradingquit", self.tradingPartner);
	
	self:setVisible(false);
end

function UICoxisTrading:onGainJoypadFocus(joypadData)
	ISCollapsableWindow.onGainJoypadFocus(self, joypadData)
	joypadData.focus = self.panel:getActiveView()
end

function UICoxisTrading:onJoypadDown(button, joypadData)
	if button == Joypad.LBumper or button == Joypad.RBumper then
		if #self.panel.viewList < 2 then return end
		local viewIndex
		for i,v in ipairs(self.panel.viewList) do
			if v.view == self.panel:getActiveView() then
				viewIndex = i
				break
			end
		end
		if button == Joypad.LBumper then
			if viewIndex == 1 then
				viewIndex = #self.panel.viewList
			else
				viewIndex = viewIndex - 1
			end
		end
		if button == Joypad.RBumper then
			if viewIndex == #self.panel.viewList then
				viewIndex = 1
			else
				viewIndex = viewIndex + 1
			end
		end
		self.panel:activateView(self.panel.viewList[viewIndex].name)
--		setJoypadFocus(self.playerId, self.panel:getActiveView())
		joypadData.focus = self.panel:getActiveView()
	end
end

function UICoxisTrading:new (x, y, width, height, player, invItems, tradingPartner)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
--	o:noBackground();
	o:setTitle(getText("UI_UICoxisTrading_WindowTitle"))
	o.playerId = player;
	UICoxisTrading.instance[player] = o;
	o.invItems = invItems;
	o.tradingPartner = tradingPartner;
	return o;
end