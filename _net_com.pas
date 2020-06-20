
procedure net_clearbuffer;
begin
   net_buf^.len:=0;
   net_msglen:=0;
   net_msgrbn:=0;
end;

procedure net_dispose;
begin
   if(net_buf<>nil)then
   begin
      SDLNet_FreePacket(net_buf);
      net_buf:=nil;
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

   net_period:=0;
   net_dispose;

   if(net_nstat=ns_none)then exit;

   net_buf:=SDLNet_AllocPacket(MaxNetBuffer);
   if (net_buf=nil) then
   begin
      WriteError(SDL_GetError);
      exit;
   end;

   if(net_nstat=ns_clnt)
   then net_socket:=SDLNet_UDP_Open(0)
   else
     if(net_nstat=ns_srvr)
     then net_socket:=SDLNet_UDP_Open(net_sv_port);

   if (net_socket=nil) then
   begin
      WriteError(SDL_GetError);
      exit;
   end;

   net_UpSocket:=true;
end;

procedure _InitNET;
begin
   if(SDLNet_Init<>0)then
   begin
      WriteError(SDL_GetError);
      halt;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure net_send(ip:cardinal; port:word);
begin
   net_buf^.address.host:=ip;
   net_buf^.address.port:=port;
   SDLNet_UDP_Send(net_socket,-1,net_buf)
end;

function net_receive:integer;
begin
   net_clearbuffer;
   net_receive:=SDLNet_UDP_Recv(net_Socket,net_buf);
   net_msglen:=net_buf^.len;
   net_buf^.len:=0;
end;

// READ   //////////////////////////////////////////////////////////////////////

function net_readbyte(def:byte=0):byte;
var siz:byte;
begin
   siz:=SizeOf(net_readbyte);
   net_readbyte:=def;
   if (net_buf^.len<=MaxNetBuffer)and((net_msglen-net_msgrbn)>=siz)then
   begin
      net_readbyte:=(net_buf^.data+net_buf^.len)^;
      inc(net_buf^.len,siz);
      inc(net_msgrbn,siz);
   end
end;

function net_readsint(def:shortint=0):shortint;
var siz:byte;
begin
   siz:=SizeOf(net_readsint);
   net_readsint:=def;
   if (net_buf^.len<=MaxNetBuffer)and((net_msglen-net_msgrbn)>=siz)then
   begin
      net_readsint:=(net_buf^.data+net_buf^.len)^;
      inc(net_buf^.len,siz);
      inc(net_msgrbn,siz);
   end
end;

function net_readchar(def:char=#0):char;
begin
   net_readchar:=chr(net_readbyte(ord(def)));
end;

function net_readbool:boolean;
begin
   net_readbool:=(net_readbyte>0);
end;

function net_readint(def:integer=0):integer;
var siz:byte;
begin
   siz:=SizeOf(net_readint);
   net_readint:=def;
   if (net_buf^.len<MaxNetBuffer)and((net_msglen-net_msgrbn)>=siz)then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readint)^, siz);
      inc(net_buf^.len,siz);
      inc(net_msgrbn,siz);
   end
end;

function net_readword(def:word=0):word;
var siz:byte;
begin
   siz:=SizeOf(net_readword);
   net_readword:=def;
   if (net_buf^.len<MaxNetBuffer)and((net_msglen-net_msgrbn)>=siz)then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readword)^, siz);
      inc(net_buf^.len, siz);
      inc(net_msgrbn, siz);
   end
end;

function net_readcard(def:cardinal=0):cardinal;
var siz:byte;
begin
   siz:=SizeOf(net_readcard);
   net_readcard:=def;
   if (net_buf^.len<(MaxNetBuffer-2))and((net_msglen-net_msgrbn)>=siz)then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readcard)^, siz);
      inc(net_buf^.len, siz);
      inc(net_msgrbn, siz);
   end
end;

function net_readstring:shortstring;
var sl:integer;
begin
   net_readstring:='';
   sl:=net_readbyte;
   if ((net_buf^.len+sl)>MaxNetBuffer) then sl:=MaxNetBuffer-net_buf^.len;
   while (sl>0) do
   begin
      net_readstring:=net_readstring+net_readchar;
      dec(sl,1);
   end;
end;

// WRITE       /////////////////////////////////////////////////////////////////

procedure net_writebyte(b:byte);
begin
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      (net_buf^.data+net_buf^.len)^:=b;
      inc(net_buf^.len,1);
   end;
end;

procedure net_writesint(b:shortint);
begin
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      (net_buf^.data+net_buf^.len)^:=b;
      inc(net_buf^.len,1);
   end;
end;

procedure net_writechar(b:char);
begin
   net_writebyte(ord(b));
end;

procedure net_writebool(b:boolean);
begin
   if b
   then net_writebyte(1)
   else net_writebyte(0);
end;

procedure net_writeint(b:integer);
begin
   if (net_buf^.len<MaxNetBuffer) then
   begin
      move( (@b)^, (net_buf^.data+net_buf^.len  )^,2 );
      Inc(net_buf^.len,2);
   end;
end;

procedure net_writeword(b:word);
begin
   if (net_buf^.len<MaxNetBuffer) then
   begin
      move( (@b)^, (net_buf^.data+net_buf^.len  )^,2 );
      Inc(net_buf^.len,2);
   end;
end;

procedure net_writecard(b:cardinal);
begin
   if (net_buf^.len<(MaxNetBuffer-2)) then
   begin
      move( (@b)^, (net_buf^.data+net_buf^.len  )^,4);
      Inc(net_buf^.len,4);
   end;
end;

procedure net_writestring(s:shortstring);
var sl,x:byte;
begin
   sl:=length(s);
   x:=1;

   net_writebyte(sl);

   while (net_buf^.len<=MaxNetBuffer)and(x<=sl) do
   begin
      net_writechar(s[x]);
      Inc(x,1);
   end;
end;

////////////////////////////////////////////////////////////////////////////////

function net_LastinIP:cardinal;
begin
   net_LastinIP:=net_buf^.address.host;
end;

function net_LastinPort:word;
begin
   net_LastinPort:=net_buf^.address.port;
end;

////////////////////////////////////////////////////////////////////////////////

procedure net_chat_add(msg:shortstring;pl,pls:byte);
var i,t,stl,cpl:byte;
begin
   stl:=length(msg);
   while(stl>0)do
   begin
      if(stl>ChatLen)
      then cpl:=ChatLen
      else cpl:=stl;

      for i:=0 to MaxPlayers do
       if((pls and (1 shl i))>0)or(HPlayer=i)or(i=0)then
        with _players[i] do
        begin
           for t:=MaxNetChat-1 downto 0 do chatm[t+1]:=chatm[t];

           inc(chats,1);

           if(pl<=MaxPlayers)then
           begin
              if(i=0)
              then chatm[0]:=_players[pl].name+': '+copy(msg,1,cpl)
              else chatm[0]:=chr(pl)+copy(msg,1,cpl);
           end
           else chatm[0]:=copy(msg,1,cpl);
        end;

      delete(msg,1,cpl);
      dec(stl,cpl);
   end;

   vid_mredraw:=true;
   {$IFDEF _FULLGAME}
   if((pls and (1 shl HPlayer))>0)then
   begin
      for t:=MaxNetChat downto 0 do net_clchatm[t]:=_players[HPlayer].chatm[t];
      ui_chat_shlm:=chat_shlm_t;
      _rpls_nwrch:=true;
      PlayGSND(snd_chat);
   end;
   if(_menu)and(m_chat)then ui_chat_shlm:=0;
   {$ENDIF}
end;

procedure net_writechat(p:byte);
var i:byte;
begin
   with _players[p] do
    for i:=0 to MaxNetChat do net_writestring(chatm[i]);
end;

{$IFDEF _FULLGAME}

procedure net_chat_clear;
begin
   FillChar(net_clchatm,SizeOf(net_clchatm),0);
   net_clchats:=255;
end;

function ip2c(s:shortstring):cardinal;
var i,l,r:byte;
    e:array[0..3] of byte = (0,0,0,0);
begin
   r:=0;
   l:=length(s);
   if(l>0)then
    for i:=1 to l do
     if(s[i]='.')then
     begin
        inc(r,1);
        if(r>3)then break;
     end
     else e[r]:=s2b(b2s(e[r])+s[i]);
   ip2c:=cardinal((@e)^);
end;

function c2ip(c:cardinal):shortstring;
begin
   c2ip:=b2s(c and $FF )+'.'+b2s((c and $FF00) shr 8)+'.'+b2s((c and $FF0000) shr 16)+'.'+b2s((c and $FF000000) shr 24);
end;

procedure net_sv_sport;
begin
   net_sv_port:=s2w(net_sv_pstr);
   net_sv_pstr:=w2s(net_sv_port);
end;

procedure net_cl_saddr;
var sp,sip:shortstring;
    i,sl:byte;
begin
   sl:=length(net_cl_svstr);

   i:=pos(':',net_cl_svstr);
   if(i=1)then
   begin
      sip:='';
      sp :=net_cl_svstr;
      delete(sp,1,i);
   end
   else
    if(i=sl)or(i=0) then
    begin
       sip:=net_cl_svstr;
       if(i=sl)then delete(sip,sl,1);
       sp:='0';
    end
    else
    begin
       sip:=copy(net_cl_svstr,1,i-1);
       sp :=copy(net_cl_svstr,i+1,sl-i);
    end;

   net_cl_svip   :=ip2c(sip);
   net_cl_svport :=swap(s2w(sp));

   net_cl_svstr:=c2ip(net_cl_svip)+':'+w2s(swap(net_cl_svport));
end;

procedure net_readchat;
var i:byte;
begin
   for i:=0 to MaxNetChat do net_clchatm[i]:=net_readstring;
end;

procedure net_chatm;
begin
   if(net_nstat=ns_clnt)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_chat);
      net_writebyte(ui_chattar);
      net_writestring(ui_chat_str);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_cl_pause;
begin
   if(net_nstat=ns_clnt)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_pause);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_plout;
begin
   if(net_nstat=ns_clnt)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_plout);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_swapp(p1:byte);
begin
   if(net_nstat=ns_clnt)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_swapp);
      net_writebyte(p1);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;
{$ENDIF}




