--[[
#########################################################################################################
#	@mod:		CoxisTrading - A trading-option to pass items along in MP                               #
#	@author: 	Dr_Cox1911					                                                            #
#	@notes:		Many thanks to RJ´s LastStand code and all the other modders out there					#
#	@notes:		For usage instructions check forum link below                                  			#
#	@link: 												       										#
#########################################################################################################
--]]

CoxisTradingClient = {};
CoxisTradingClient.luanet = nil;
CoxisTradingClient.module = nil;
CoxisTradingClient.network = false;
CoxisTradingClient.tradingUI = nil;
CoxisTradingClient.tradingInitiated = false;
CoxisTradingClient.square = nil;
CoxisTradingClient.itemNames = {};
CoxisTradingClient.debug = true;
CoxisTradingClient.debugPlayer = nil;




CoxisTradingClient.tradeContext = function(_player, _context, _worldobjects, _test)
	if _test and ISWorldObjectContextMenu.Test then return true end
	local otherplayer = nil;
	
	-- we get the thumpable item (like wall/door/furniture etc.) if exist on the tile we right clicked
	for i,v in ipairs(_worldobjects) do
		square = v:getSquare();
		--print(instanceof(v, "IsoPlayer"));
		if instanceof(v, "IsoPlayer") then
			--print("found player");
			otherplayer = v;
		end
    end
	
	if otherplayer then
		--print(otherplayer:getUsername());
		CoxisTradingClient.debugPlayer = otherplayer;
		tradeMenu =  _context:addOption(getText('UI_CoxisTrading_ContextTrade'), _worldobjects, CoxisTradingClient.showTradingUI, otherplayer);
		--tradeMenu =  _context:addOption("Trade", _worldobjects, nil)
	end
end

CoxisTradingClient.showTradingUI = function(_worldobjects, _otherplayer)
	local player = getPlayer();
	local items = player:getInventory():getItems();
	local itemsTable = {};
	for i = 1, items:size() do
        itemsTable[i] = items:get(i - 1);
    end
	if _otherplayer and not CoxisTradingClient.tradingInitiated then
		print(_otherplayer:getUsername());
		print(instanceof(_otherplayer, "IsoPlayer"));
		CoxisTradingClient.module.sendPlayer(_otherplayer, "tradingrequest", _otherplayer)
	end
	--if not CoxisTradingClient.tradingUI then
		local x = getPlayerScreenLeft(0)
		local y = getPlayerScreenTop(0)
		CoxisTradingClient.tradingUI = UICoxisTrading:new(x+70,y+50,636,508, 0, itemsTable, _otherplayer)
		CoxisTradingClient.tradingUI:initialise()
		CoxisTradingClient.tradingUI:addToUIManager()
		CoxisTradingClient.tradingUI:setVisible(false)
	--end
	
	if CoxisTradingClient.tradingUI:getIsVisible() then
		CoxisTradingClient.tradingUI:setVisible(false)
		CoxisTradingClient.tradingInitiated = false;
	else
		CoxisTradingClient.tradingUI:setVisible(true)
		CoxisTradingClient.tradingInitiated = true;
	end
	
end

CoxisTradingClient.acceptTradeRequest = function(_sourceplayer, _receivingplayer)
	print("got trade request!")
	print("request from: " .. tostring(_sourceplayer:getUsername()));
	--print("to: " .. tostring(_receivingplayer:getUsername()));
	--print("instance: " .. tostring(instanceof(_receivingplayer, "IsoPlayer" )));
	--if _receivingplayer and instanceof(_receivingplayer, "IsoPlayer" ) then
		CoxisTradingClient.tradingInitiated = true;
		CoxisTradingClient.showTradingUI(nil, _sourceplayer);
		
	--end

end

CoxisTradingClient.acceptDeal = function(_sourceplayer, _receivingplayer)
	print("deal accepted by: " .. tostring(_sourceplayer:getUsername()));
	CoxisTradingClient.tradingUI:setAcceptDeal();
end

CoxisTradingClient.declineDeal = function(_sourceplayer, _receivingplayer)
	print("deal declined by: " .. tostring(_sourceplayer:getUsername()));
	CoxisTradingClient.tradingUI:setDeclineDeal();
end

CoxisTradingClient.tradingQuit = function(_sourceplayer, _receivingplayer)
	print("trading quit by: " .. tostring(_sourceplayer:getUsername()));
	--if CoxisTradingClient.tradingInitiated then
		CoxisTradingClient.tradingUI:setTradingQuit();
		CoxisTradingClient.tradingInitiated = false;
	--end
end

CoxisTradingClient.updateProposed = function(_sourceplayer, _itemNames, _sqX, _sqY, _sqZ)
	CoxisTradingClient.square = getWorld():getCell():getGridSquare(_sqX, _sqY, _sqZ);
	CoxisTradingClient.itemNames = _itemNames;
	-- local wobj = square:getWorldObjects();
	-- local helper = #_itemNames;
	-- print("helper: " .. tostring(helper));
	-- print("wobj size: " .. tostring(wobj:size()));
	Events.OnTickEvenPaused.Add(CoxisTradingClient.updateItems);
	
	-- repeat
		-- for i = 0, wobj:size(), 1 do
			-- for _,n in pairs(_itemNames) do
				-- print("worldobject: " .. tostring(wobj:get(i):getItem():getName()));
				-- print("itemname: " .. tostring(n));
				-- if wobj:get(i):getItem():getName() == n then
					-- helper = helper - 1;
					-- table.remove(_itemNames, n);
					-- break
				-- end
			-- end
		-- end
	-- until helper == 0
	-- print("done looking, found all items");
end

CoxisTradingClient.updateItems = function()
	local helper = #CoxisTradingClient.itemNames;
	
	for x=CoxisTradingClient.square:getX()-1, CoxisTradingClient.square:getX()+1 do
		for y=CoxisTradingClient.square:getY()-1, CoxisTradingClient.square:getY()+1 do
			local square = getCell():getGridSquare(x,y,CoxisTradingClient.square:getZ());
			local wobj = square and square:getWorldObjects() or nil;
			if wobj ~= nil then
				print("helper: " .. tostring(helper));
				print("wobj size: " .. tostring(wobj:size()));
				
				
				
					for i = 0, wobj:size(), 1 do
						for _,n in pairs(CoxisTradingClient.itemNames) do
							print("worldobject: " .. tostring(wobj:get(i):getItem():getName()));
							print("itemname: " .. tostring(n));
							if wobj:get(i):getItem():getName() == n then
								helper = helper - 1;
								table.remove(CoxisTradingClient.itemNames, n);
								break
							end
						end
					end
				
				print("done looking, found all items");
				Events.OnTickEvenPaused.Remove(CoxisTradingClient.updateItems);
			end
		end
	end

end
-- **************************************************************************************
-- handling key presses here
-- **************************************************************************************
CoxisTradingClient.onKeyPressed = function(_key)
		if _key == Keyboard.KEY_O then
			if CoxisTradingClient.debugPlayer then
				local player = getPlayer();
				CoxisTradingClient.module.sendPlayer(CoxisTradingClient.debugPlayer, "tradingrequest", CoxisTradingClient.debugPlayer)
			end
		end
end

-- **************************************************************************************
-- if LuaNet is all running, register all the needed Commands and stuff
-- **************************************************************************************
CoxisTradingClient.init = function()
	if isClient() then
		print("...CoxisTrading...INIT CLIENT")
		CoxisTradingClient.luanet = LuaNet:getInstance();
		LuaNet:getInstance().setDebug( true );
		CoxisTradingClient.module = CoxisTradingClient.luanet.getModule("CoxisTrading", CoxisTradingClient.debug);
		CoxisTradingClient.luanet.setDebug(CoxisTradingClient.debug);
		CoxisTradingClient.module.addCommandHandler("tradingrequest", CoxisTradingClient.acceptTradeRequest);
		CoxisTradingClient.module.addCommandHandler("updateproposed", CoxisTradingClient.updateProposed);
		CoxisTradingClient.module.addCommandHandler("acceptdeal", CoxisTradingClient.acceptDeal);
		CoxisTradingClient.module.addCommandHandler("declinedeal", CoxisTradingClient.declineDeal);
		CoxisTradingClient.module.addCommandHandler("tradingquit", CoxisTradingClient.tradingQuit);
		--CoxisTradingClient.module.addCommandHandler("transfer", CoxisTradingClient.transferItems);
		
		Events.OnKeyPressed.Add(CoxisTradingClient.onKeyPressed);
		Events.OnFillWorldObjectContextMenu.Add(CoxisTradingClient.tradeContext)
		print("...CoxisTrading...INIT CLIENT DONE")
	end
end



-- **************************************************************************************
-- init the client with LuaNet
-- **************************************************************************************
CoxisTradingClient.initMP = function()
	if isClient() then
		LuaNet:getInstance().onInitAdd(CoxisTradingClient.init);
	end
end

CoxisTradingClient.initSP = function()
	if (not(isClient()) and not(isServer())) then
		Events.OnFillWorldObjectContextMenu.Add(CoxisTradingClient.tradeContext)
	end	
end


Events.OnConnected.Add(CoxisTradingClient.initMP)
Events.OnGameStart.Add(CoxisTradingClient.initSP)