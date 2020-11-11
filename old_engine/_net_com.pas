

procedure net_clearbuffer;
begin
   net_buf^.len:=0;
end;

function net_UpSocket:boolean;
begin
   net_UpSocket:=false;

   net_period:=0;

   net_buf:=SDLNet_AllocPacket(MaxNetBuffer);
   if (net_buf=nil) then
   begin
      WriteError;
      exit;
   end;

   if(net_nstat=ns_clnt)
   then net_socket:=SDLNet_UDP_Open(0)
   else
     if(net_nstat=ns_srvr)
     then net_socket:=SDLNet_UDP_Open(net_sv_port);

   if (net_socket=nil) then
   begin
      WriteError;
      exit;
   end;

   net_UpSocket:=true;
end;

function InitNET:boolean;
begin
   InitNET:=(SDLNet_Init=0);
   if(InitNET=false)then WriteError;
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
   net_buf^.len:=0;
end;

// READ   //////////////////////////////////////////////////////////////////

function net_readbyte:byte;
begin
   net_readbyte:=0;
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      net_readbyte:=(net_buf^.data+net_buf^.len)^;
      inc(net_buf^.len,1);
   end
end;

function net_readsint:shortint;
begin
   net_readsint:=0;
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      net_readsint:=(net_buf^.data+net_buf^.len)^;
      inc(net_buf^.len,1);
   end
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
   if (net_buf^.len<MaxNetBuffer) then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readint)^, 2);
      inc(net_buf^.len,2);
   end
end;

{function net_readword:word;
begin
   net_readword:=0;
   if (net_buf^.len<MaxNetBuffer) then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readword)^, 2);
      inc(net_buf^.len,2);
   end
end;  }

function net_readcard:cardinal;
begin
   net_readcard:=0;
   if (net_buf^.len<(MaxNetBuffer-2)) then
   begin
      move((net_buf^.data+net_buf^.len)^, (@net_readcard)^, 4);
      inc(net_buf^.len,4);
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
      Dec(sl,1);
   end;
end;

// WRITE       /////////////////////////////////////////////////////////////////

procedure net_writebyte(b:byte);
begin
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      (net_buf^.data+net_buf^.len)^:=b;
      Inc(net_buf^.len,1);
   end;
end;

procedure net_writesint(b:shortint);
begin
   if (net_buf^.len<=MaxNetBuffer) then
   begin
      (net_buf^.data+net_buf^.len)^:=b;
      Inc(net_buf^.len,1);
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

{procedure net_writeword(b:word);
begin
   if (net_buf^.len<MaxNetBuffer) then
   begin
      move( (@b)^, (net_buf^.data+net_buf^.len  )^,2 );
      Inc(net_buf^.len,2);
   end;
end;}

procedure net_writecard(b:cardinal);
begin
   if (net_buf^.len<(MaxNetBuffer-2)) then
   begin
      move( (@b)^, (net_buf^.data+net_buf^.len  )^,4 );
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

////////////////

function net_LastinIP:cardinal;
begin
   net_LastinIP:=net_buf^.address.host;
end;

function net_LastinPort:word;
begin
   net_LastinPort:=net_buf^.address.port;
end;

////////////////////////////////////////////////////////////////////////////////

procedure net_writechat(p:byte);
var i:byte;
begin
   for i:=0 to MaxNetChat do net_writestring(net_chat[p,i]);
end;

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
       if((pls and (1 shl i))>0)or(pl=i)or(i=0)then
       begin
          for t:=MaxNetChat-1 downto 0 do net_chat[i,t+1]:=net_chat[i,t];

          inc(net_chatss[i],1);

          if(pl<=MaxPlayers)then
          begin
             if(i=0)
             then net_chat[i,0]:=_players[pl].name+': '+copy(msg,0,cpl)
             else net_chat[i,0]:=chr(pl)+copy(msg,0,cpl);
          end
          else net_chat[i,0]:=copy(msg,1,cpl);
       end;

      delete(msg,0,cpl);
      dec(stl,cpl);
   end;

   {$IFDEF _FULLGAME}
   vid_mredraw:=true;
   net_chat_shlm:=chat_shlm_t;
   PlaySNDM(snd_chat);
   _rpls_nwrch:=true;
   {$ENDIF}
end;

{$IFDEF _FULLGAME}

procedure net_sv_sport;
begin
   net_sv_port:=s2w(net_sv_pstr);
   net_sv_pstr:=w2s(net_sv_port);
end;

function ip2c(s:string):cardinal;
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

function c2ip(c:cardinal):string;
begin
   c2ip:=b2s(c and $FF )+'.'+b2s((c and $FF00) shr 8)+'.'+b2s((c and $FF0000) shr 16)+'.'+b2s((c and $FF000000) shr 24);
end;

procedure net_cl_saddr;
var sp,sip:string;
    i,sl:byte;
begin
   sl:=length(net_cl_svstr);

   i:=pos(':',net_cl_svstr);
   if(i=1)then
   begin
      sip:='';
      sp :=net_cl_svstr;
      delete(sp,1,i);
   end else
    if(i=sl)or(i=0) then
    begin
       sip:=net_cl_svstr;
       if(i=sl)then delete(sip,sl,1);
       sp:='0';
    end else
     begin
        sip:=copy(net_cl_svstr,1,i-1);
        sp :=copy(net_cl_svstr,i+1,sl-i);
     end;

   net_cl_svip   :=ip2c(sip);
   net_cl_svport :=swap(s2w(sp));

   net_cl_svstr:=c2ip(net_cl_svip)+':'+w2s(swap(net_cl_svport));
end;

procedure net_chat_clear;
begin
   FillChar(net_chat  ,sizeof(net_chat  ),#0);
   FillChar(net_chatss,sizeof(net_chatss),0 );
   FillChar(net_chatls,sizeof(net_chatls),0 );
end;

procedure net_readchat(p:byte);
var i:byte;
begin
   for i:=0 to MaxNetChat do net_chat[HPlayer,i]:=net_readstring;
end;

procedure net_chatm;
begin
   if(net_nstat=ns_clnt)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_chat);
      net_writebyte(net_chat_tar);
      net_writestring(net_chat_str);
      net_send(net_cl_svip,net_cl_svport);
   end;
end;

procedure net_pause;
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

