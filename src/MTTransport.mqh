#property copyright     "brajine@metatrader.live"
#property link          "http://metatrader.live"

#define BYTEVECTOR_ID   6
#define ARRAYTYPE_ID    17
#define VECTORTYPE_ID   19
#define STRUCTTYPE_ID   20
#define MAPTYPE_ID      23

struct OrderType {
   string Ticket;
	string Market;
	string TimeOpen;
	string Type;
	string InitVolume;
	string CurVolume;
	string PriceOpen;
	string SL;
	string TP;
	string Swap;
	string PriceSL;
	string Profit;
};

struct TradesMsg {
	string Page;         
	string ClientVersion;
	string UpdateFreq;
	string Name;
	string Login;
	string Server;
	string Company;
	string Balance;
	string Equity;
	string Margin;
	string FreeMargin;
	string MarginLevel;
	string ProfitTotal;
	OrderType Orders[];
};

struct ResponseMsg {
   string Error;
   string Message;
};

class MTTransport {
private:
   static string decode_string(char &data[], int &ptr, int &skip);
   static int  decode_ulong(char &buf[], int pos, ulong &val);
   static int  decode_int(char &buf[], int pos, int &val);
   static void print_hex(unsigned char &data[]);
   static void encode_key(char &buf[], string str);
   static void encode_field(char &buf[], string str, int &skip);
   static void encode_array(char &buf[], string &arr[], int &skip);
   static void start_struct_type(char &buf[], string name, int id);
   static void end_type_definition(char &buf[]);
   static void end_struct_type(char &buf[]);
   static void end_struct(char &buf[]);
   static void append_zero(char &buf[]);
   static void append_bytes(char &buf[], char &bt[]);
   static void encode_array_type(char &buf[], int id, int elem_type, int delta);
   static void encode_map_type(char &buf[], string name, int id, int elem_type, int delta);
   static void encode_field_type(char &buf[], string name, int id);
   static void start_type_definition(char &buf[], int id, int type);
   static void encode_int(char &buf[], int i);
   static void encode_string(char &buf[], string s);
   static void encode_ulong(char &buf[], ulong ull);
   static void encode_message(char &data[], TradesMsg &msg, bool reset);
   static void decode_response(unsigned char &data[], ResponseMsg &resp);
   static bool empty(string str);
public:
   static bool Recv(int socket, ResponseMsg &resp);
   static bool Send(int socket, TradesMsg &msg, bool reset);
};

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// Return false in case of error
bool MTTransport::Recv(int socket, ResponseMsg &resp) {
   const int ch = 3;
   int n, len;
   char data[];

   // Read & skip the header
   if ( SocketRead(socket, data, ch, 1000) != ch ) return false;
   n = decode_int(data, 0, len);   
   if ( n <= 0 ) return false;
   if ( len == 3 && n == 1 ) {
      // Header-less empty message, means Ok
      SocketRead(socket, data, 1, 1000); // Trailing \0
      return true;
   }
   if ( SocketRead(socket, data, len - (ch - n), 1000) != len - (ch - n) ) return false;   
      
   // Read message body
   if ( SocketRead(socket, data, ch, 1000) != ch ) return false;   
   n = decode_int(data, 0, len);
   if ( n <= 0 ) return false;
   if ( SocketRead(socket, data, len - (ch - n), 1000) != len - (ch - n) ) return false;   
      
   decode_response(data, resp);
   return true;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransport::Send(int socket, TradesMsg &msg, bool reset) {
   char data[];   
   encode_message(data, msg, reset);
   int s = SocketSend(socket, data, ArraySize(data));
   return s > 0;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_message(char &data[], TradesMsg &msg, bool reset) {
   int type_id = 65, field_type = 66, arr_id = 67;
   char bt[2] = {0x33, 0x33};   
   static bool headerSent = 0;
   if ( reset ) headerSent = 0;
   
   // Encoding header
   if ( !headerSent ) {
      char buf[];
      headerSent = !headerSent;
      
      // type id  (negated)
      start_type_definition(buf, type_id, STRUCTTYPE_ID);
      start_struct_type(buf, "TradesMsg", type_id); 
      
      // field delta
      encode_ulong(buf, 1);
  
      // length of field array
      encode_ulong(buf, 14);
      encode_field_type(buf, "Page", BYTEVECTOR_ID);
      encode_field_type(buf, "ClientVersion", BYTEVECTOR_ID);
      encode_field_type(buf, "UpdateFreq", BYTEVECTOR_ID);
      encode_field_type(buf, "Name", BYTEVECTOR_ID);
      encode_field_type(buf, "Login", BYTEVECTOR_ID);
      encode_field_type(buf, "Server", BYTEVECTOR_ID);
      encode_field_type(buf, "Company", BYTEVECTOR_ID);      
      encode_field_type(buf, "Balance", BYTEVECTOR_ID);
      encode_field_type(buf, "Equity", BYTEVECTOR_ID);
      encode_field_type(buf, "Margin", BYTEVECTOR_ID);
      encode_field_type(buf, "FreeMargin", BYTEVECTOR_ID);
      encode_field_type(buf, "MarginLevel", BYTEVECTOR_ID);
      encode_field_type(buf, "ProfitTotal", BYTEVECTOR_ID);
      encode_field_type(buf, "Orders", arr_id);

      // end struct type
      end_struct_type(buf);
      end_type_definition(buf);
      
      // Writing message len and copy full message to resulting buffer
      encode_ulong(data, ArraySize(buf)); 
      ArrayCopy(data, buf, ArraySize(data));
      ArrayFree(buf);
      
      // Encoding Array type
      start_type_definition(buf, arr_id, MAPTYPE_ID);
      encode_map_type(buf, "map[string]data.OrderType", arr_id, field_type, 1);
      end_type_definition(buf);

      // Writing message len and copy full message to resulting buffer
      encode_ulong(data, ArraySize(buf)); 
      ArrayCopy(data, buf, ArraySize(data));
      ArrayFree(buf);
      
      // Writing Orders[] header
      start_type_definition(buf, field_type, STRUCTTYPE_ID);
      encode_array_type(buf, arr_id, field_type, 2);
      
      // field delta
      encode_ulong(buf, 1);
  
      // length of field array
      encode_ulong(buf, 11);
      encode_field_type(buf, "Symbol", BYTEVECTOR_ID);
      encode_field_type(buf, "TimeOpen", BYTEVECTOR_ID);
      encode_field_type(buf, "Type", BYTEVECTOR_ID);
      encode_field_type(buf, "InitVolume", BYTEVECTOR_ID);
      encode_field_type(buf, "CurVolume", BYTEVECTOR_ID);
      encode_field_type(buf, "PriceOpen", BYTEVECTOR_ID);
      encode_field_type(buf, "SL", BYTEVECTOR_ID);      
      encode_field_type(buf, "TP", BYTEVECTOR_ID);
      encode_field_type(buf, "Swap", BYTEVECTOR_ID);
      encode_field_type(buf, "PriceSL", BYTEVECTOR_ID);
      encode_field_type(buf, "Profit", BYTEVECTOR_ID);

      end_type_definition(buf);
      end_struct_type(buf);   // End header
      
      // Writing message len and copy full message to resulting buffer
      encode_ulong(data, ArraySize(buf)); 
      ArrayCopy(data, buf, ArraySize(data));
      ArrayFree(buf);
      
   }

   // Encoding struct body
   int skip = 0; // skip = field delta, how many fields were NULL (skipped) before
   char buf[];

   encode_int(buf, type_id);

   encode_field(buf, msg.Page, skip);
	encode_field(buf, msg.ClientVersion, skip);
	encode_field(buf, msg.UpdateFreq, skip);
	encode_field(buf, msg.Name, skip);
	encode_field(buf, msg.Login, skip);
	encode_field(buf, msg.Server, skip);
	encode_field(buf, msg.Company, skip);
	encode_field(buf, msg.Balance, skip);
	encode_field(buf, msg.Equity, skip);
	encode_field(buf, msg.Margin, skip);
	encode_field(buf, msg.FreeMargin, skip);
	encode_field(buf, msg.MarginLevel, skip);
	encode_field(buf, msg.ProfitTotal, skip);

   if ( ArraySize(msg.Orders) > 0 ) {
      encode_ulong(buf, skip + 1);   
      encode_ulong(buf, ArraySize(msg.Orders));
 
      for (int i = 0; i < ArraySize(msg.Orders); i++) {
         skip = 0;
         encode_key(buf, msg.Orders[i].Ticket);
//         encode_field(buf, msg.Orders[i].Ticket, skip);
         encode_field(buf, msg.Orders[i].Market, skip);
         encode_field(buf, msg.Orders[i].TimeOpen, skip);
         encode_field(buf, msg.Orders[i].Type, skip);
         encode_field(buf, msg.Orders[i].InitVolume, skip);
         encode_field(buf, msg.Orders[i].CurVolume, skip);
         encode_field(buf, msg.Orders[i].PriceOpen, skip);
         encode_field(buf, msg.Orders[i].SL, skip);
         encode_field(buf, msg.Orders[i].TP, skip);
         encode_field(buf, msg.Orders[i].Swap, skip);
         encode_field(buf, msg.Orders[i].PriceSL, skip);
         encode_field(buf, msg.Orders[i].Profit, skip);
         // End order
         end_struct_type(buf);
      }
   }

   // End msg
   end_struct_type(buf);

   // Writing message len and copy full message to resulting buffer
   encode_ulong(data, ArraySize(buf)); 
   ArrayCopy(data, buf, ArraySize(data));
   ArrayFree(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::decode_response(unsigned char &data[], ResponseMsg &resp) {
   for ( int skip = 1, ptr = 0, i = 0; i < 2; ) {
      string str = decode_string(data, ptr, skip);
      i += skip;
      if ( !empty(str) ) {
         switch ( i ) {
            case 1: resp.Error = str; break;
            case 2: resp.Message = str; break;
         }
      }
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
string MTTransport::decode_string(char &data[], int &ptr, int &skip) {
   string s = "";
   if ( ptr + 1 < ArraySize(data) ) {
      skip = data[ptr];
      int sz = data[ptr + 1];
      if ( ptr + 2 + sz < ArraySize(data) ) {
         s = CharArrayToString(data, ptr + 2, sz);
         ptr += sz + 2;
      }
   }
   
   return s;   
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::print_hex(unsigned char &data[]) {
   string res = "";
   for ( int i = 0; i < ArraySize(data); i++ ) {
      res += StringFormat("%.2X ", data[i]);
      if ( StringLen(res) >= 90 ) {
         Print(res);
         res = "";
      }
   }
   if ( !empty(res) ) {
      Print(res);
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_key(char &buf[], string str) {
  if ( !empty(str) ) {
    encode_string(buf, str);
  }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_field(char &buf[], string str, int &skip) {
  if ( !empty(str) ) {
    encode_ulong(buf, 1 + skip);
    encode_string(buf, str);
    skip = 0;
  } else skip++;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_array(char &buf[], string &arr[], int &skip) {
   if ( ArraySize(arr) > 0 ) {
      encode_ulong(buf, 1 + skip);
      encode_ulong(buf, ArraySize(arr));
      for ( int i = 0; i < ArraySize(arr); i++ ) {
         if ( !empty(arr[i]) ) {
            encode_string(buf, arr[i]);
         } else skip++;
      }
      skip = 0;
   } else {
      skip++;
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::start_struct_type(char &buf[], string name, int id) {
   encode_ulong(buf, 1);  
   encode_field_type(buf, name, id);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::end_type_definition(char &buf[]) {
   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::end_struct_type(char &buf[]) {
   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::end_struct(char &buf[]) {
   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::append_zero(char &buf[]) {
   ArrayResize(buf, ArraySize(buf) + 1);
   buf[ArraySize(buf) - 1] = 0;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::append_bytes(char &buf[], char &bt[]) {
   ArrayCopy(buf, bt, ArraySize(buf));
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_array_type(char &buf[], int id, int elem_type, int delta) {
  if (elem_type != 0) {
    encode_ulong(buf, 1);
    encode_ulong(buf, delta);
    encode_int(buf, elem_type);
  }

   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_map_type(char &buf[], string name, int id, int elem_type, int delta) {
  encode_ulong(buf, 1);
  encode_field_type(buf, name, id);

  if (elem_type != 0) {
    encode_ulong(buf, 1);
    encode_ulong(buf, 12); // Map suffix
    encode_ulong(buf, delta);
    encode_int(buf, elem_type);
  }

   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_field_type(char &buf[], string name, int id) {
   int fieldDelta = 1;
  
   if ( empty(name) ) {
      fieldDelta++;
   } else {
      encode_ulong(buf, fieldDelta);
      encode_string(buf, name);
   }
  
   if ( id != 0 ) {
      encode_ulong(buf, fieldDelta);
      encode_int(buf, id);
   }
   
   append_zero(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::start_type_definition(char &buf[], int id, int type) {
   encode_int(buf, -1 * id);
   
   int type_delta = 0;
   switch (type) {
      case ARRAYTYPE_ID:
         type_delta = 1;
         break;
      case VECTORTYPE_ID:
         type_delta = 2;
         break;
      case STRUCTTYPE_ID:
      default:
         type_delta = 3;
         break;
      case MAPTYPE_ID:
         type_delta = 4;
         break;
   }
   
   encode_ulong(buf, type_delta);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_int(char &buf[], int i) {
   unsigned int u;
   if ( i < 0 ) {
      u = (~i << 1) | 1;
   } else {
      u = (i << 1);
   }
   encode_ulong(buf, u);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_string(char &buf[], string s) {
   encode_ulong(buf, StringLen(s));
   StringToCharArray(s, buf, ArraySize(buf), StringLen(s));
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

int MTTransport::decode_int(char &buf[], int pos, int &val) {
   ulong v;
   int ret = decode_ulong(buf, pos, v);
   val = (int)v;
   return ret;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

int MTTransport::decode_ulong(char &buf[], int pos, ulong &val) {
   // Parse ulong into val parameter,
   // Return it's length in bytes
   if ( (uchar)buf[pos] > 0 && (uchar)buf[pos] < 128 ) {
      val = buf[pos];
      return 1;
   }
   
   int len = (int)(~buf[pos] + 1);
   val = 0;
   for ( int i = 0; i < len; i++ ) {
      val |= ((uchar)(buf[pos + 1 + i]) << (8 * (len - i - 1)));
   }
   return len;
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

void MTTransport::encode_ulong(char &buf[], ulong ull) {
   if ( ull < 128 ) {
      ArrayResize(buf, ArraySize(buf) + 1);
      buf[ArraySize(buf) - 1] = (char)ull;
      return;
   }

   int last = ArraySize(buf);
   int sz = 1;
   ulong t = 0x00000000000000FF;
   for ( int i = 7; i >= 0; i-- ) {
      ulong tt = t << (i * 8);
      char b = (char)((tt & ull) >> (i * 8));
      if ( b != 0 || sz > 1 ) {
         ArrayResize(buf, last + sz + 1);
         buf[last + sz] = b;
         sz++;
      }      
   }
   
   if ( sz > 1 ) {
      buf[last] = (char)(-1 * (sz - 1));
   }

   last = ArraySize(buf);
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

bool MTTransport::empty(string str) {
   if ( str == NULL || str == "" ) return true;
   return false;
}