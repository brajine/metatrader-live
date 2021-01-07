#property copyright     "brajine@metatrader.live"
#property link          "http://metatrader.live"

#include "MTTransport.mqh"

class MTLive {
private:
   static int       socket;
   static int       serverPort;
   static string    serverIp;
   static string    self_name;
   static string    get_page();
   static string    get_freq();
   static void      err_print(int code);
   static void      print_msg(TradesMsg &msg);
   static bool      empty(string str);
   static void      make_diff(TradesMsg &msg, bool reset);
   static void      compose_data(TradesMsg &msg, bool reset);
public:
   static void      Init(string ip, int port);
   static int       Update();
   static void      DeInit();
};

string MTLive::self_name = "MTLive: ";
int    MTLive::socket   = -1;
int    MTLive::serverPort;
string MTLive::serverIp;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

string MTLive::get_page() {
   if ( !empty(myPage) ) return myPage; 
   else return IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

string MTLive::get_freq() {
   switch ( updateFreq ) {
      case oneSecond: return "second";
      case oneMinute:
      default: return "minute";
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void MTLive::Init(string ip, int port) {
   if ( empty(ip) || port <= 0 || port >= 65536 ) {
      Print(MTLive::self_name, "Server address or port is not provided");
      return;
   }
   
   // Currently, maximum update rate allowed is one message per second.
   // Please don't exceed update frequency as server may ban such connection.
   switch ( updateFreq ) {
   case oneSecond: 
      EventSetTimer(1);
      break;
   case oneMinute: 
   default:
      EventSetTimer(60);
   }
   
   MTLive::serverIp = ip;
   MTLive::serverPort = port;
   MTLive::Update();
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void MTLive::DeInit() {
   EventKillTimer();
   SocketClose(socket);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void MTLive::err_print(int code) {
   // Output network error description
   switch ( code ) {
      case 4014: Print(MTLive::self_name, "WebRequest is not allowed. Please add \"", Ip, "\" in Tools > Options > Expert Advisors"); ExpertRemove(); break;
      case 5272: Print(MTLive::self_name, "Server is not available"); break;
      case 5273: Print(MTLive::self_name, "Server refuses connection"); break;
      default: Print(MTLive::self_name, "Error ", code, ": can not connect to server");
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

int MTLive::Update() {
   static bool sync = false;
   // Try to reconnect if socket is not writable
   if ( !SocketIsWritable(MTLive::socket) ) {
      SocketClose(MTLive::socket);

      MTLive::socket = SocketCreate(SOCKET_DEFAULT);
      if ( MTLive::socket == INVALID_HANDLE ) {            
         err_print(GetLastError());
         return -1;
      }
   
      bool connected = SocketConnect(MTLive::socket, MTLive::serverIp, MTLive::serverPort, 1000);
      if ( !connected ) {
         err_print(GetLastError());
         return -1;
      }
      sync = true;
   }

   // Failed to reconnect
   if ( !SocketIsWritable(MTLive::socket) ) {
      return 01;
   }
   
   if ( sync ) Print(MTLive::self_name, "Connection is successful");
   
   // Send encoded message
   TradesMsg msg;
   MTLive::compose_data(msg, sync);
   bool sent = MTTransport::Send(socket, msg, sync);
   if ( !sent ) {
      err_print(GetLastError());
      return -1;
   }

   // Read response
   ResponseMsg resp;
   bool received = MTTransport::Recv(socket, resp);
   if ( !received ) {
      err_print(GetLastError());
      return -1;
   }
   
   if ( !empty(resp.Message) ) Print(MTLive::self_name, resp.Message);
   if ( !empty(resp.Error) ) {
      Print(MTLive::self_name, "Server returned error: ", resp.Error);
      ExpertRemove();
      return -1;
   }

   sync = false;
   return 0;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void MTLive::compose_data(TradesMsg &msg, bool reset) {
   // Collect actual data for Update message  

   msg.Page = MTLive::get_page();
   msg.ClientVersion = VERSION;
   msg.UpdateFreq = MTLive::get_freq();

   
   if ( SendAccountInfo ) {
      msg.Name        = SEND_NAME ? AccountInfoString(ACCOUNT_NAME) : NULL;
      msg.Login       = SEND_LOGIN ? IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) : NULL;
      msg.Balance     = SEND_BALANCE ? DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) : NULL;
      msg.Equity      = SEND_EQUITY ? DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) : NULL;
      msg.Margin      = SEND_MARGIN ? DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN), 2) : NULL;
      msg.FreeMargin  = SEND_FREEMARGIN ? DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) : NULL;
      msg.MarginLevel = SEND_MARGINLEVEL ? DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) : NULL;
      msg.ProfitTotal = SEND_PROFITTOTAL ? DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2) : NULL;
      msg.Server      = SEND_SERVER ? AccountInfoString(ACCOUNT_SERVER) : NULL;
      msg.Company     = SEND_COMPANY ? AccountInfoString(ACCOUNT_COMPANY) : NULL;
   }
  
   int sz = PositionsTotal() + OrdersTotal();
   ArrayResize(msg.Orders, sz);
   
   int i, p, precision;
   for ( i = 0; i < PositionsTotal(); i++ ) {
      msg.Orders[i].Ticket = IntegerToString(PositionGetTicket(i));
      msg.Orders[i].Market = PositionGetString(POSITION_SYMBOL);
      precision = (int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL), SYMBOL_DIGITS);
      msg.Orders[i].TimeOpen = TimeToString((datetime)PositionGetInteger(POSITION_TIME), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      msg.Orders[i].Type = IntegerToString(PositionGetInteger(POSITION_TYPE));
      msg.Orders[i].InitVolume = NULL;
      msg.Orders[i].CurVolume = DoubleToString(PositionGetDouble(POSITION_VOLUME), 2);
      msg.Orders[i].PriceOpen = DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN), precision);
      msg.Orders[i].SL = DoubleToString(PositionGetDouble(POSITION_SL), precision);
      msg.Orders[i].TP = DoubleToString(PositionGetDouble(POSITION_TP), precision);
      msg.Orders[i].Swap = DoubleToString(PositionGetDouble(POSITION_SWAP), 2);
      msg.Orders[i].PriceSL = NULL;
      msg.Orders[i].Profit = DoubleToString(PositionGetDouble(POSITION_PROFIT), 2);
   }
   for ( p = i, i = 0; i < OrdersTotal(); i++, p++ ) {
      msg.Orders[p].Ticket = IntegerToString(OrderGetTicket(i));
      msg.Orders[p].Market = OrderGetString(ORDER_SYMBOL);
      precision = (int)SymbolInfoInteger(OrderGetString(ORDER_SYMBOL), SYMBOL_DIGITS);
      msg.Orders[p].TimeOpen = TimeToString((datetime)OrderGetInteger(ORDER_TIME_SETUP), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      msg.Orders[p].Type = IntegerToString(OrderGetInteger(ORDER_TYPE));
      msg.Orders[p].InitVolume = DoubleToString(OrderGetDouble(ORDER_VOLUME_INITIAL), 2);
      msg.Orders[p].CurVolume = DoubleToString(OrderGetDouble(ORDER_VOLUME_CURRENT), 2);
      msg.Orders[p].PriceOpen = DoubleToString(OrderGetDouble(ORDER_PRICE_OPEN), precision);
      msg.Orders[p].SL = DoubleToString(OrderGetDouble(ORDER_SL), precision);
      msg.Orders[p].TP = DoubleToString(OrderGetDouble(ORDER_TP), precision);
      msg.Orders[p].Swap = NULL;     
      msg.Orders[p].PriceSL = DoubleToString(OrderGetDouble(ORDER_PRICE_STOPLIMIT), precision);
      msg.Orders[p].Profit = NULL;
   }
   
   make_diff(msg, reset);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTLive::make_diff(TradesMsg &msg, bool reset) {
   TradesMsg diff;
   static TradesMsg prev;
   if ( reset ) ZeroMemory(prev);
 
   // Make the difference
   diff.Page = (prev.Page != msg.Page) ? msg.Page : NULL;
   diff.ClientVersion = (prev.ClientVersion != msg.ClientVersion) ? msg.ClientVersion : NULL;
   diff.UpdateFreq = (prev.UpdateFreq != msg.UpdateFreq) ? msg.UpdateFreq : NULL;
   diff.Name = (prev.Name != msg.Name) ? msg.Name : NULL;
   diff.Login = (prev.Login != msg.Login) ? msg.Login : NULL;
   diff.Server = (prev.Server != msg.Server) ? msg.Server : NULL;
   diff.Company = (prev.Company != msg.Company) ? msg.Company : NULL;
   diff.Balance = (prev.Balance != msg.Balance) ? msg.Balance : NULL;
   diff.Equity = (prev.Equity != msg.Equity) ? msg.Equity : NULL;
   diff.Margin = (prev.Margin != msg.Margin) ? msg.Margin : NULL;
   diff.FreeMargin = (prev.FreeMargin != msg.FreeMargin) ? msg.FreeMargin : NULL;
   diff.MarginLevel = (prev.MarginLevel != msg.MarginLevel) ? msg.MarginLevel : NULL;
   diff.ProfitTotal = (prev.ProfitTotal != msg.ProfitTotal) ? msg.ProfitTotal : NULL;

   ArrayResize(diff.Orders, ArraySize(msg.Orders));
   ArrayResize(prev.Orders, ArraySize(msg.Orders));

   for ( int i = 0; i < ArraySize(msg.Orders); i++ ) {
      diff.Orders[i].Ticket = msg.Orders[i].Ticket;
      diff.Orders[i].Market = (prev.Orders[i].Market != msg.Orders[i].Market) ? msg.Orders[i].Market : NULL; 
      diff.Orders[i].TimeOpen = (prev.Orders[i].TimeOpen != msg.Orders[i].TimeOpen) ? msg.Orders[i].TimeOpen : NULL; 
      diff.Orders[i].Type = (prev.Orders[i].Type != msg.Orders[i].Type) ? msg.Orders[i].Type : NULL; 
      diff.Orders[i].InitVolume = (prev.Orders[i].InitVolume != msg.Orders[i].InitVolume) ? msg.Orders[i].InitVolume : NULL; 
      diff.Orders[i].CurVolume = (prev.Orders[i].CurVolume != msg.Orders[i].CurVolume) ? msg.Orders[i].CurVolume : NULL; 
      diff.Orders[i].PriceOpen = (prev.Orders[i].PriceOpen != msg.Orders[i].PriceOpen) ? msg.Orders[i].PriceOpen : NULL; 
      diff.Orders[i].SL = (prev.Orders[i].SL != msg.Orders[i].SL) ? msg.Orders[i].SL : NULL; 
      diff.Orders[i].TP = (prev.Orders[i].TP != msg.Orders[i].TP) ? msg.Orders[i].TP : NULL; 
      diff.Orders[i].Swap = (prev.Orders[i].Swap != msg.Orders[i].Swap) ? msg.Orders[i].Swap : NULL; 
      diff.Orders[i].PriceSL = (prev.Orders[i].PriceSL != msg.Orders[i].PriceSL) ? msg.Orders[i].PriceSL : NULL; 
      diff.Orders[i].Profit = (prev.Orders[i].Profit != msg.Orders[i].Profit) ? msg.Orders[i].Profit : NULL; 
   }
   
   // Save state
   prev.Page = msg.Page;
   prev.ClientVersion = msg.ClientVersion;
   prev.UpdateFreq = msg.UpdateFreq;
   prev.Name = msg.Name;
   prev.Login = msg.Login;
   prev.Server = msg.Server;
   prev.Company = msg.Company;
   prev.Balance = msg.Balance;
   prev.Equity = msg.Equity;
   prev.Margin = msg.Margin;
   prev.FreeMargin = msg.FreeMargin;
   prev.MarginLevel = msg.MarginLevel;
   prev.ProfitTotal = msg.ProfitTotal;
   for ( int i = 0; i < ArraySize(msg.Orders); i++ ) {
      prev.Orders[i] = msg.Orders[i];
   }
   
   // Return the difference
   msg = diff;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

void MTLive::print_msg(TradesMsg &msg) {
   Print("{\"Page\":\"" + msg.Page + "\", \"ClientVersion\":\"" + msg.ClientVersion + "\", \"UpdateFreq\":\"" + msg.UpdateFreq + "\", \"Name\":\"" + msg.Name + "\", \"Login\":\"" + msg.Login + "\", \"Server\":\"" + msg.Server + "\", \"Company\":\"" + msg.Company + "\",");
   Print("   \"Balance\":\"" + msg.Balance + "\", \"Equity\":\"" + msg.Equity + "\", \"Margin\":\"" + msg.Margin + "\", \"FreeMargin\":\"" + msg.FreeMargin + "\", \"MarginLevel\":\"" + msg.MarginLevel + "\" ,\"ProfitTotal\":\"" + msg.ProfitTotal + "\" ,\"Orders\":[");
   for ( int i = 0; i < ArraySize(msg.Orders); i++ ) {
      string c = "";
      if ( i < ArraySize(msg.Orders) - 1 ) c = ",";
      Print("     {\"Ticket\":\"" + msg.Orders[i].Ticket + "\", \"Symbol\":\"" + msg.Orders[i].Market + "\", \"TimeOpen\":\"" + msg.Orders[i].TimeOpen + "\", \"Type\":\"" + msg.Orders[i].Type + "\", \"InitVolume\":\"" + msg.Orders[i].InitVolume + "\", ");
      Print("      \"CurVolume\":\"" + msg.Orders[i].CurVolume + "\", \"PriceOpen\":\"" + msg.Orders[i].PriceOpen + "\", \"SL\":\"" + msg.Orders[i].SL + "\", TP\":\"" + msg.Orders[i].TP + "\", \"Swap\":\"" + msg.Orders[i].Swap + "\", \"PriceSL\":\"" + msg.Orders[i].PriceSL + "\", \"Profit\":\"" + msg.Orders[i].Profit + "\"}" + c);
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

bool MTLive::empty(string str) {
   if ( str == NULL || str == "" ) return true;
   return false;
}