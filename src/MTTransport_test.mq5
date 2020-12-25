#property copyright     "brajine@metatrader.live"
#property link          "http://metatrader.live"
#property description   "MetaTrader.live client"
#property description   "Stream account data to metatrader.live"
#define   VERSION       "1.0"
#property version       VERSION

input string TestServer = "10.0.2.2";
input uint   TestPort   = 8182;

#include "MTTransport.mqh"

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void OnStart() {
   bool passed = false;

   if ( !MTTransportTest::ServerConnect() ) {
      return;
   }
   
   if ( !MTTransportTest::Connection() ) Print("Connection test failed");
   if ( !MTTransportTest::Page() ) Print("Page test failed");
   if ( !MTTransportTest::ClientVersion() ) Print("ClientVersion test failed");
   if ( !MTTransportTest::UpdateFrequency() ) Print("UpdateFrequency test failed");
   if ( !MTTransportTest::Name() ) Print("Name test failed");
   if ( !MTTransportTest::Login() ) Print("Login test failed");
   if ( !MTTransportTest::Server() ) Print("Server test failed");
   if ( !MTTransportTest::Company() ) Print("Company test failed");
   if ( !MTTransportTest::Balance() ) Print("Balance test failed");
   if ( !MTTransportTest::Equity() ) Print("Equity test failed");
   if ( !MTTransportTest::Margin() ) Print("Margin test failed");
   if ( !MTTransportTest::FreeMargin() ) Print("FreeMargin test failed");
   if ( !MTTransportTest::MarginLevel() ) Print("MarginLevel test failed");
   if ( !MTTransportTest::ProfitTotal() ) Print("ProfitTotal test failed");

   if ( !MTTransportTest::OrderTicket() ) Print("Ticket test failed");
   if ( !MTTransportTest::OrderMarket() ) Print("Market test failed");
   if ( !MTTransportTest::OrderTimeOpen() ) Print("TimeOpen test failed");
   if ( !MTTransportTest::OrderType() ) Print("Type test failed");
   if ( !MTTransportTest::OrderInitVolume() ) Print("InitVolume test failed");
   if ( !MTTransportTest::OrderCurVolume() ) Print("CurVolume test failed");
   if ( !MTTransportTest::OrderPriceOpen() ) Print("PriceOpen test failed");
   if ( !MTTransportTest::OrderStopLoss() ) Print("StopLoss test failed");
   if ( !MTTransportTest::OrderTakeProfit() ) Print("TakeProfit test failed");
   if ( !MTTransportTest::OrderSwap() ) Print("Swap test failed");
   if ( !MTTransportTest::OrderPriceSL() ) Print("PriceSL test failed");
   if ( !MTTransportTest::OrderProfit() ) Print("Profit test failed");

   if ( !MTTransportTest::HeavyMessage() ) Print("HeavyMessage test failed");
      
   MTTransportTest::Disconnect();
   Print("Test finished");
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

class MTTransportTest {
private:
   static int socket;
public:
   static bool ServerConnect();
   static void Disconnect();
   
   static bool Connection();
   static bool Page();
   static bool ClientVersion();
   static bool UpdateFrequency();
   static bool Name();
   static bool Login();
   static bool Server();
   static bool Company();
   static bool Balance();
   static bool Equity();
   static bool Margin();
   static bool FreeMargin();
   static bool MarginLevel();
   static bool ProfitTotal();
   static bool OrderTicket();
   static bool OrderMarket();
   static bool OrderTimeOpen();
   static bool OrderType();
   static bool OrderInitVolume();
   static bool OrderCurVolume();
   static bool OrderPriceOpen();
   static bool OrderStopLoss();
   static bool OrderTakeProfit();
   static bool OrderSwap();
   static bool OrderPriceSL();
   static bool OrderProfit();
   static bool HeavyMessage();
};

int MTTransportTest::socket = -1;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Page() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Page = "page";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::ClientVersion() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.ClientVersion = "1.0";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::UpdateFrequency() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.UpdateFreq = "second";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Name() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Name = "name";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Login() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Login = "login";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Server() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Server = "server";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Company() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Company = "company";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Balance() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Balance = "balance";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Equity() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Equity = "equity";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Margin() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.Margin = "margin";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::FreeMargin() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.FreeMargin = "freemargin";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::MarginLevel() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.MarginLevel = "marginlevel";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::ProfitTotal() {
   TradesMsg msg;
   ZeroMemory(msg);
   msg.ProfitTotal = "profittotal";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderTicket() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderMarket() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].Market = "market";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderTimeOpen() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].TimeOpen = "timeopen";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderType() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].Type = "type";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderInitVolume() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].InitVolume = "initvolume";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderCurVolume() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].CurVolume = "curvolume";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderPriceOpen() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].PriceOpen = "priceopen";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderStopLoss() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].SL = "stoploss";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderTakeProfit() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].TP = "takeprofit";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderSwap() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].Swap = "swap";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderPriceSL() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].PriceSL = "pricesl";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::OrderProfit() {
   TradesMsg msg;
   ZeroMemory(msg);
   ArrayResize(msg.Orders, 1);
   msg.Orders[0].Ticket = "111";
   msg.Orders[0].Profit = "profit";

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::HeavyMessage() {
   TradesMsg msg;
   msg.Page = "page";
   msg.ClientVersion = "clientversion";
   msg.UpdateFreq = "second";
   msg.Name = "name";
   msg.Login = "login";
   msg.Server = "server";
   msg.Company = "company";
   msg.Balance = "balance";
   msg.Equity = "equity";
   msg.Margin = "margin";
   msg.FreeMargin = "freemargin";
   msg.MarginLevel = "marginlevel";
   msg.ProfitTotal = "profittotal";

   int cnt = 10;
   ArrayResize(msg.Orders, cnt);
   
   for ( int i = 0; i < cnt; i++ ) {
      string n = IntegerToString(i);
      string tick = n + n + n; 
      msg.Orders[i].Ticket = tick;
      msg.Orders[i].Market = tick;
      msg.Orders[i].TimeOpen = tick;
      msg.Orders[i].Type = tick;
      msg.Orders[i].InitVolume = tick;
      msg.Orders[i].CurVolume = tick;
      msg.Orders[i].PriceOpen = tick;
      msg.Orders[i].SL = tick;
      msg.Orders[i].TP = tick;
      msg.Orders[i].Swap = tick;
      msg.Orders[i].PriceSL = tick;
      msg.Orders[i].Profit = tick;
   }

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::Connection() {
   TradesMsg msg;
   ZeroMemory(msg);

   if ( MTTransport::Send(socket, msg, false) >= 0 ) return true;
   return false;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransportTest::ServerConnect() {
   MTTransportTest::socket = SocketCreate(SOCKET_DEFAULT);
   if ( socket == INVALID_HANDLE ) {            
      Print("Failed to create a socket: ", GetLastError());
      return false;
   }
   
   if ( !SocketConnect(socket, TestServer, TestPort, 1000) ) {
      Print("Failed to connect to server: ", GetLastError());
      return false;
   }
   
   return true;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransportTest::Disconnect() {
   SocketClose(socket);
}
