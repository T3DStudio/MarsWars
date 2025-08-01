

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

function net_UpSocket:boolean;
begin
   net_UpSocket:=false;

   net_dispose;

   net_period:=0;

   net_buffer:=SDLNet_AllocPacket(MaxNetBuffer);
   if (net_buffer=nil) then
   begin
      WriteSDLError;
      exit;
   end;

   if(net_status=ns_client)
   then net_socket:=SDLNet_UDP_Open(0)
   else
     if(net_status=ns_server)
     then net_socket:=SDLNet_UDP_Open(net_port);

   if (net_socket=nil) then
   begin
      WriteSDLError;
      exit;
   end;

   net_UpSocket:=true;
end;

function InitNET:boolean;
begin
   InitNET:=(SDLNet_Init=0);
   if(InitNET=false)then WriteSDLError;
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

procedure net_buff(w:boolean;vs:integer;p:pointer);
begin
   if(net_bufpos>MaxNetBuffer)then exit;
   if((MaxNetBuffer-net_bufpos)<vs)then exit;
   if(w=false)and((net_buffer^.len-net_bufpos)<vs)then exit;

   if(w)
   then move(p^,(net_buffer^.data+net_bufpos)^,     vs)
   else move(   (net_buffer^.data+net_bufpos)^, p^, vs);
   inc(net_bufpos,vs);
end;

function net_readbyte:byte;
begin
   net_readbyte:=0;
   net_buff(false,SizeOf(net_readbyte),@net_readbyte);
end;

function net_readsint:shortint;
begin
   net_readsint:=0;
   net_buff(false,SizeOf(net_readsint),@net_readsint);
end;

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
   net_buff(false,SizeOf(net_readint),@net_readint);
end;

function net_readword:word;
begin
   net_readword:=0;
   net_buff(false,SizeOf(net_readword),@net_readword);
end;

function net_readcard:cardinal;
begin
   net_readcard:=0;
   net_buff(false,SizeOf(net_readcard),@net_readcard);
end;

function net_readsingle:single;
begin
   net_readsingle:=0;
   net_buff(false,SizeOf(net_readsingle),@net_readsingle);
end;

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

procedure net_writebyte  (b:byte    );begin net_buff(true,SizeOf(b),@b);end;
procedure net_writesint  (b:shortint);begin net_buff(true,SizeOf(b),@b);end;
procedure net_writechar  (b:char    );begin net_writebyte(ord (b));end;
procedure net_writebool  (b:boolean );begin net_writebyte(byte(b));end;
procedure net_writeint   (b:integer );begin net_buff(true,SizeOf(b),@b);end;
procedure net_writeword  (b:word    );begin net_buff(true,SizeOf(b),@b);end;
procedure net_writecard  (b:cardinal);begin net_buff(true,SizeOf(b),@b);end;
procedure net_writesingle(b:single  );begin net_buff(true,SizeOf(b),@b);end;

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
   net_port:=s2w(menu_ServerPort);
   menu_ServerPort:=w2s(net_port);
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

procedure menu_GetClientAddress;
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
   p    :=pos(':',menu_ClientAddress);
   if(p>0)then
   begin
      addr_str:=copy(menu_ClientAddress,1,p-1);
      delete(menu_ClientAddress,1,p);
      port_str:=menu_ClientAddress;
   end
   else
   begin
      addr_str:=menu_ClientAddress;
      port_str:='10666';
   end;

   net_cl_svport:=swap(s2w(port_str));
   port_str:=w2s(swap(net_cl_svport));

   ipc:=ip2c(addr_str,@isIP);
   if(isIP)then
   begin
      net_cl_svip  :=ipc;
      menu_ClientAddress:=c2ip(net_cl_svip)+':'+port_str;
   end
   else
   begin
      menu_ClientAddress:=addr_str+':'+port_str;
      addr_str+=#0;
      pstr:=@addr_str[1];
      if(SDLNet_ResolveHost(ipstruct,pstr,net_cl_svport)=0)
      then net_cl_svip:=ipstruct.host
      else net_cl_svip:=0;
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
procedure net_surrender;
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_PlayerSurrender);
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

procedure net_SendMapMark(x,y:integer);
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_map_mark);
      net_writeint(x);
      net_writeint(y);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

{$ENDIF}

