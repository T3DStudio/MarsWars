

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

   net_period:=0;

   net_buffer:=SDLNet_AllocPacket(MaxNetBuffer);
   if(net_buffer=nil)then
   begin
      WriteSDLError('SDLNet_AllocPacket');
      exit;
   end;

   net_socket:=SDLNet_UDP_Open(port);
   if(net_socket=nil)then
   begin
      WriteSDLError('SDLNet_UDP_Open');
      exit;
   end;

   net_UpSocket:=true;
end;

function InitNET:boolean;
begin
   InitNET:=(SDLNet_Init=0);
   if(not InitNET)then WriteSDLError('SDLNet_Init');
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

procedure txt_ValidateServerPort;
begin
   net_port:=s2w(net_sv_pstr);
   net_sv_pstr:=w2s(net_port);
end;

function ip2c(s:shortstring;isip:pboolean):cardinal;
{$IFNDEF FULLGAME}
const chars_digits           : set of Char = ['0'..'9'];
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

procedure txt_ValidateServerAddr;
var
addr_str,
port_str: shortstring;
pstr    : PChar;
    p   : byte;
  ipc   : cardinal;
 isip   : boolean;
ipstruct: TIPaddress;
begin
   addr_str:='';
   port_str:='';
   p    :=pos(':',net_cl_svaddr);
   if(p>0)then
   begin
      addr_str:=copy(net_cl_svaddr,1,p-1);
      delete(net_cl_svaddr,1,p);
      port_str:=net_cl_svaddr;
   end
   else
   begin
      addr_str:=net_cl_svaddr;
      port_str:='10666';
   end;

   net_cl_svport:=swap(s2w(port_str));
   port_str:=w2s(swap(net_cl_svport));

   ipc:=ip2c(addr_str,@isip);
   if(isip)then
   begin
      net_cl_svip  :=ipc;
      net_cl_svaddr:=c2ip(net_cl_svip)+':'+port_str;
   end
   else
   begin
      net_cl_svaddr:=addr_str+':'+port_str;
      addr_str+=#0;
      pstr:=@addr_str[1];
      if(SDLNet_ResolveHost(@ipstruct,pstr,net_cl_svport)=0)then
      begin
         net_cl_svip:=ipstruct.host;
         //room_log_add(sv_clroom,log_local,net_cl_svaddr+': resolved host to '+c2ip(cl_net_svip));
      end
      else
      begin
         net_cl_svip:=0;
         //room_log_add(sv_clroom,log_local,net_cl_svaddr+': resolve host fail');
      end;
   end;
end;


{procedure net_cl_saddr;
var sp,sip:shortstring;
      i,sl:byte;
begin
   sl:=length(net_cl_svaddr);

   i:=pos(':',net_cl_svaddr);
   if(i=1)then
   begin
      sip:='';
      sp :=net_cl_svaddr;
      delete(sp,1,i);
   end
   else
    if(i=sl)or(i=0) then
    begin
       sip:=net_cl_svaddr;
       if(i=sl)then delete(sip,sl,1);
       sp:='0';
    end
    else
    begin
       sip:=copy(net_cl_svaddr,1,i-1);
       sp :=copy(net_cl_svaddr,i+1,sl-i);
    end;

   net_cl_svip   :=ip2c(sip);
   net_cl_svport :=swap(s2w(sp));

   net_cl_svaddr:=c2ip(net_cl_svip)+':'+w2s(swap(net_cl_svport));
end;}

procedure net_send_chat(targets:byte;msg:shortstring);
begin
   if(net_status=ns_client)and(targets>0)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_log_chat);
      net_writebyte(targets);
      net_writestring(msg);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_send_byte(b:byte);
begin
   if(net_status=ns_client)then
   begin
      // nmid_pause
      net_clearbuffer;
      net_writebyte(b);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_send_MIDByte(mid,bval:byte);
begin
   net_clearbuffer;
   net_writebyte(mid);
   net_writebyte(bval);
   net_send(net_cl_svip,net_cl_svport);
end;
procedure net_send_MIDBool(mid:byte;bval:boolean);
begin
   net_clearbuffer;
   net_writebyte(mid);
   net_writebool(bval);
   net_send(net_cl_svip,net_cl_svport);
end;
procedure net_send_MIDInt(mid,ival:byte);
begin
   net_clearbuffer;
   net_writebyte(mid);
   net_writeint (ival);
   net_send(net_cl_svip,net_cl_svport);
end;
procedure net_send_MIDCard(mid:byte;cval:cardinal);
begin
   net_clearbuffer;
   net_writebyte(mid);
   net_writecard(cval);
   net_send(net_cl_svip,net_cl_svport);
end;

procedure net_send_PlayerSlot(PlayerTarget,newPlayerSlot:byte);
begin
   net_clearbuffer;
   net_writebyte(nmid_lobbby_playerslot);
   net_writebyte(PlayerTarget);
   net_writebyte(newPlayerSlot);
   net_send(net_cl_svip,net_cl_svport);
end;
procedure net_send_PlayerRace(PlayerTarget,newPlayerRace:byte);
begin
   net_clearbuffer;
   net_writebyte(nmid_lobbby_playerrace);
   net_writebyte(PlayerTarget);
   net_writebyte(newPlayerRace);
   net_send(net_cl_svip,net_cl_svport);
end;
procedure net_send_PlayerTeam(PlayerTarget,newPlayerTeam:byte);
begin
   net_clearbuffer;
   net_writebyte(nmid_lobbby_playerteam);
   net_writebyte(PlayerTarget);
   net_writebyte(newPlayerTeam);
   net_send(net_cl_svip,net_cl_svport);
end;


procedure net_disconnect;
begin
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_player_leave);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_SendMapMark(x,y:integer);
begin
   net_clearbuffer;
   net_writebyte(nmid_map_mark);
   net_writeint(x);
   net_writeint(y);
   net_send(net_cl_svip,net_cl_svport);
end;

{$ENDIF}

