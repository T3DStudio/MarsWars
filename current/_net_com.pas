

procedure net_clearbuffer;
begin
   net_buffer^.len:=0;
   net_bufpos     :=0;
end;

procedure net_dispose;
begin
   if(net_buffer<>nil)then
   begin
      SDLNet_FreePacket(net_buffer);
      net_buffer:=nil;
   end;

   if(net_socket<>nil)then
   begin
      SDLNet_UDP_Close(net_socket);
      net_socket:=nil;
   end;
end;

function net_UpSocket(port:word):boolean;
begin
   net_UpSocket:=false;

   net_dispose;

   net_TimerBase:=0;

   net_buffer:=SDLNet_AllocPacket(MaxNetBuffer);
   if(net_buffer=nil)then
   begin
      WriteSDLError;
      exit;
   end;

   net_socket:=SDLNet_UDP_Open(port);
   if(net_socket=nil) then
   begin
      WriteSDLError;
      net_dispose;
      exit;
   end;

   net_UpSocket:=true;
end;

function InitNET:boolean;
begin
   InitNET:=(SDLNet_Init=0);
   if(not InitNET)then WriteSDLError;
end;

////////////////////////////////////////////////////////////////////////////////

procedure net_send(ip:cardinal; port:word);
begin
   net_buffer^.len         :=net_bufpos;
   net_buffer^.address.host:=ip;
   net_buffer^.address.port:=port;
   SDLNet_UDP_Send(net_socket,-1,net_buffer);
end;

function net_receive:integer;
begin
   net_clearbuffer;
   net_receive:=SDLNet_UDP_Recv(net_socket,net_buffer);
end;


// READ   //////////////////////////////////////////////////////////////////

function net_BufferBlock(wrt:boolean;count:integer;pResult:pointer):boolean;
begin
   net_BufferBlock:=false;
   if(net_bufpos>=MaxNetBuffer)then exit;
   if((MaxNetBuffer-net_bufpos)<count)then exit;
   if(not wrt)then
     if((net_buffer^.len-net_bufpos)<count)then exit;

   net_BufferBlock:=true;
   if(wrt)
   then move(pResult^,(net_buffer^.data+net_bufpos)^, count)
   else move((net_buffer^.data+net_bufpos)^, pResult^,count);
   net_bufpos+=count;
end;

function net_readbyte:byte;
begin
   net_readbyte:=0;
   net_BufferBlock(false,SizeOf(net_readbyte),@net_readbyte);
end;

{function net_readsint:shortint;
begin
   net_readsint:=0;
   net_BufferBlock(false,SizeOf(net_readsint),@net_readsint);
end;}

function net_readchar:char;
begin
   net_readchar:=chr(net_readbyte);
end;

function net_readbool:boolean;
begin
   net_readbool:=(net_readbyte>0);
end;

function net_readint:integer;
begin
   net_readint:=0;
   net_BufferBlock(false,SizeOf(net_readint),@net_readint);
end;

function net_readword:word;
begin
   net_readword:=0;
   net_BufferBlock(false,SizeOf(net_readword),@net_readword);
end;

function net_readcard:cardinal;
begin
   net_readcard:=0;
   net_BufferBlock(false,SizeOf(net_readcard),@net_readcard);
end;

{function net_readsingle:single;
begin
   net_readsingle:=0;
   net_BufferBlock(false,SizeOf(net_readsingle),@net_readsingle);
end;}

function net_readstring:shortstring;
var sl:byte;
begin
   net_readstring:='';
   sl:=net_readbyte;
   if((net_bufpos+sl)>MaxNetBuffer)then sl:=MaxNetBuffer-net_bufpos;
   while(sl>0)do
   begin
      net_readstring:=net_readstring+net_readchar;
      sl-=1;
   end;
end;


// WRITE       /////////////////////////////////////////////////////////////////

procedure net_writebyte  (b:byte    );begin net_BufferBlock(true,SizeOf(b),@b);end;
//procedure net_writesint  (b:shortint);begin net_BufferBlock(true,SizeOf(b),@b);end;
procedure net_writechar  (b:char    );begin net_writebyte(ord (b));end;
procedure net_writebool  (b:boolean );begin net_writebyte(byte(b));end;
procedure net_writeint   (b:integer );begin net_BufferBlock(true,SizeOf(b),@b);end;
procedure net_writeword  (b:word    );begin net_BufferBlock(true,SizeOf(b),@b);end;
procedure net_writecard  (b:cardinal);begin net_BufferBlock(true,SizeOf(b),@b);end;
//procedure net_writesingle(b:single  );begin net_BufferBlock(true,SizeOf(b),@b);end;

procedure net_writestring(s:shortstring);
var sl,x:byte;
begin
   sl:=length(s);
   x :=1;

   net_writebyte(sl);

   while (net_bufpos<=MaxNetBuffer)and(x<=sl) do
   begin
      net_writechar(s[x]);
      if(x=255)
      then break
      else x+=1;
   end;
end;

////////////////

function net_LastinIP  :cardinal;begin net_LastinIP  :=net_buffer^.address.host;end;
function net_LastinPort:word    ;begin net_LastinPort:=net_buffer^.address.port;end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

procedure menu_GetServerPort;
begin
   net_ServerPort :=s2w(menu_ServerPort);
   menu_ServerPort:=w2s(net_ServerPort );
end;

function ip2c(s:shortstring;isip:pboolean):cardinal;
{$IFNDEF FULLGAME}
const chars_digits : set of Char = ['0'..'9'];
{$ENDIF}
var i,l,
     bn:byte;
     e :array[0..3] of byte = (0,0,0,0);
begin
   ip2c:=0;
   if(isip<>nil)then isip^:=false;
   bn:=0;
   l :=length(s);
   if(l>0)then
     for i:=1 to l do
       if(s[i]='.')then
       begin
          bn+=1;
          if(bn>3)then exit;
       end
       else
         if(s[i] in chars_digits)
         then e[bn]:=s2b(b2s(e[bn])+s[i])
         else exit;
   if(isip<>nil)then isip^:=true;
   ip2c:=cardinal((@e)^);
end;

function c2ip(c:cardinal):shortstring;
begin
   c2ip:=b2s (c and $000000FF)
    +'.'+b2s((c and $0000FF00) shr 8 )
    +'.'+b2s((c and $00FF0000) shr 16)
    +'.'+b2s((c and $FF000000) shr 24);
end;

function DNSCache_Find(dns:shortstring;pip:pcardinal):boolean;
var t:word;
begin
   DNSCache_Find:=false;
   if(net_DNSCache_n>0)then
     for t:=0 to net_DNSCache_n-1 do
       if(dns=net_DNSCache_dns[t])then
       begin
          if(pip<>nil)then pip^:=net_DNSCache_ip[t];
          DNSCache_Find:=true;
          break;
       end;
end;
procedure DNSCache_Add(dns:shortstring;ip:cardinal);
begin
   if(net_DNSCache_n=net_DNSCache_n.MaxValue)then exit;

   if(DNSCache_Find(dns,nil))then exit;

   net_DNSCache_n+=1;
   setlength(net_DNSCache_dns,net_DNSCache_n);
   setlength(net_DNSCache_ip ,net_DNSCache_n);
   net_DNSCache_dns[net_DNSCache_n-1]:=dns;
   net_DNSCache_ip [net_DNSCache_n-1]:=ip;
end;

function menu_GetClientAddress(addr_line:shortstring;pip:pcardinal;pport:pword):shortstring;
var
addr_str,
port_str: shortstring;
pstr    : PChar;
    p   : byte;
  ipc   : cardinal;
 isIP   : boolean;
ipstruct: TIPaddress;
begin
   addr_str:='';
   port_str:='';
   p:=pos(':',addr_line);
   if(p>0)then
   begin
      addr_str:=copy(addr_line,1,p-1);
      delete(addr_line,1,p);
      port_str:=addr_line;
   end
   else
   begin
      addr_str:=addr_line;
      port_str:='10666';
   end;

   pport^:=swap(s2w(port_str));
   port_str:=w2s(swap(pport^));

   ipc:=ip2c(addr_str,@isIP);
   if(isIP)then
   begin
      pip^:=ipc;
      menu_GetClientAddress:=c2ip(pip^)+':'+port_str;
   end
   else
   begin
      menu_GetClientAddress:=addr_str+':'+port_str;
      if(not DNSCache_Find(addr_str,pip))then
      begin
         addr_str+=#0;
         pstr:=@addr_str[1];
         if(SDLNet_ResolveHost(ipstruct,pstr,pport^)=0)
         then pip^:=ipstruct.host
         else pip^:=0;
         setlength(addr_str,length(addr_str)-1);
         if(pip^>0)then
           DNSCache_Add(addr_str,pip^);
      end;
   end;
end;

procedure net_ServerListParseAddrs;
var i:integer;
begin
   if(net_SvList_Size>0)then
   begin
      draw_LoadingScreen(@str_loading_netdns,c_blue);
      for i:=0 to net_SvList_Size-1 do
        with net_SvList_listi[i] do
        begin
           si_line:=menu_GetClientAddress(si_line,@si_ip,@si_port);
           net_SvList_lists[i]:=si_line;
        end;
   end;
end;

function net_ServerListAdd(addr:shortstring;check:boolean;resolve:boolean=true):boolean;
var i:integer;
begin
   net_ServerListAdd:=false;

   if(net_SvList_Size=net_SvList_Size.MaxValue)
   or(length(addr)=0)then exit;

   // check existed
   if(net_SvList_Size>0)then
     for i:=0 to net_SvList_Size-1 do
       with net_SvList_listi[i] do
         if(si_line=addr)then exit;

   net_ServerListAdd:=true;

   if(check)then exit;

   net_SvList_Size+=1;
   setlength(net_SvList_lists,net_SvList_Size);
   setlength(net_SvList_listi,net_SvList_Size);

   with net_SvList_listi[net_SvList_Size-1] do
   begin
      si_ping  :=9999;
      if(resolve)
      then si_line:=menu_GetClientAddress(addr,@si_ip,@si_port)
      else si_line:=addr;
      si_manual:=true;
      net_SvList_lists[net_SvList_Size-1]:=si_line;
   end;
end;

procedure net_send_chat(targets:byte;msg:shortstring);
begin
   if(net_status=ns_client)and(targets>0)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_LogMessage);
      net_writebyte(targets);
      net_writestring(msg);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_pause;
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_pause);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_disconnect;
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_PlayerLeave);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;
procedure net_SendGSettings(bt:byte;bl:boolean);
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(bt);
      net_writebool(bl);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_SendMapMark(x,y,mType:integer);
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_map_mark);
      net_writeint(x);
      net_writeint(y);
      net_writeint(mType);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

{$ENDIF}

