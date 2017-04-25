CoxisTradingServer = {};
CoxisTradingServer.luanet = nil;
CoxisTradingServer.module = nil;

CoxisTradingServer.acceptTradeRequest = function(_sourceplayer, ...)

end

CoxisTradingServer.acceptDeal = function(_sourceplayer, ...)

end

CoxisTradingServer.declineDeal = function(_sourceplayer, ...)

end

CoxisTradingServer.updateProposed = function(_sourceplayer, _itemNames, _sqX, _sqY, _sqZ)

end

CoxisTradingServer.tradingQuit = function(_sourceplayer, ...)

end

-- **************************************************************************************
-- init the server, registering events and whatnot
-- **************************************************************************************
CoxisTradingServer.initServer = function()
	if (isServer()) then
		print("...CoxisTrading...INIT SERVER")
		CoxisTradingServer.luanet = LuaNet:getInstance();
		CoxisTradingServer.module = CoxisTradingServer.luanet.getModule("CoxisTrading", true);
		LuaNet:getInstance().setDebug( true );
	
		CoxisTradingServer.module.addCommandHandler("tradingrequest", CoxisTradingServer.acceptTradeRequest);
		CoxisTradingServer.module.addCommandHandler("updateproposed", CoxisTradingServer.updateProposed);
		CoxisTradingServer.module.addCommandHandler("acceptdeal", CoxisTradingServer.acceptDeal);
		CoxisTradingServer.module.addCommandHandler("declinedeal", CoxisTradingServer.declineDeal);
		CoxisTradingServer.module.addCommandHandler("tradingquit", CoxisTradingServer.tradingQuit);
		--Events.OnZombieDead.Add(CoxisTradingServer.AfterZombieDead);
		
		CoxisTradingServer.network = true;
		--Events.OnClientCommand.Add(CoxisTradingServer.ReceiveFromClient);
		print("...CoxisTrading...INIT SERVER DONE")
	end
end

CoxisTradingServer.initMP = function()
	if isServer() then
		LuaNet:getInstance().onInitAdd(CoxisTradingServer.initServer);
	end
end

Events.OnGameBoot.Add(CoxisTradingServer.initMP)