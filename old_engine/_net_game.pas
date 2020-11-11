
function NewP(sip:cardinal;sp:word):byte;
var i:byte;
begin
   NewP:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_None)then
      begin
         nip   := sip;
         nport := sp;
         NewP  := i;
         state := PS_Play;
         ttl   := 0;
         {$IFNDEF _FULLGAME}
         net_chat_add('MarsWars dedicated server, '+str_ver,0,1 shl i);
         net_chat_add('Type -h/-help command'              ,0,1 shl i);
         {$ENDIF}
         break;
      end;
end;

function A2P(sip:cardinal;sp:word;crtn:boolean):byte;
var i:byte;
begin
   A2P:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_Play)and(nip=sip)and(nport=sp)then
      begin
         {$IFNDEF _FULLGAME}
         if(ttl>=ClientTTL)then vid_mredraw:=true;
         {$ENDIF}
         A2P:=i;
         ttl:=0;
         break;
      end;

   if(A2P=0)and(G_Started=false)and(crtn)then A2P:=NewP(sip,sp);
end;

procedure net_ReadPlayerData(pid:byte);
var i:byte;
    s:shortstring;
begin
   with _Players[pid] do
   begin
      s:=name;
      name :=net_readstring;
      if(length(name)>NameLen)then setlength(name,NameLen);
      if(s<>name)then vid_mredraw:=true;

      if(g_mode in [gm_2fort,gm_3fort,gm_inv,gm_coop])
      then i:=net_readbyte
      else
      begin
         i:=team;
         team:=net_readbyte;
         if(i<>team)then vid_mredraw:=true;
      end;

      i:=race;
      race :=net_readbyte;
      mrace:=race;
      if(i<>mrace)then vid_mredraw:=true;

      i:=byte(ready);
      ready:=net_readbool;
      if((i>0)<>ready)then vid_mredraw:=true;

      net_chatls[pid]:=net_readbyte;
      PNU            :=net_readbyte;
   end;
end;

procedure net_GServer;
var mid,pid,i:byte;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      if(mid=nmid_getinfo)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_getinfo);
         net_writebyte(ver);
         net_writebool(g_started);
         net_writebool(g_addon);
         net_writebyte(g_mode);
         for i:=1 to MaxPlayers do
          with _players[i] do
          begin
             net_writestring(name);
             net_writebyte(race);
             net_writebyte(team);
          end;
         net_send(net_lastinip,net_lastinport);
         continue;
      end;

      if(mid=nmid_connect)then
      begin
         i:=net_readbyte;
         if(i<>ver)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_sver);
            net_send(net_lastinip,net_lastinport);
            continue;
         end;
         pid:=A2P(net_lastinip,net_lastinport,true);
         if(pid=0) then
         begin
            net_clearbuffer;
            if(g_started)
            then net_writebyte(nmid_sgst)
            else net_writebyte(nmid_sfull);
            net_send(net_lastinip,net_lastinport);
            continue;
         end;

         if(G_Started=false)then net_ReadPlayerData(pid);

         net_clearbuffer;
         net_writebyte(nmid_startinf);
         net_writebool(G_Started);
         for i:=1 to MaxPlayers do
          with _Players[i] do
          begin
             net_writestring(name);
             net_writebyte  (team);
             net_writebyte  (race);
             net_writebyte  (mrace);
             net_writebyte  (state);
             net_writebool  (ready);
             net_writeint   (ttl);
          end;

         net_writebyte(pid);
         net_writebyte(HPlayer);

         net_writeint (map_mw   );
         net_writebyte(map_liq  );
         net_writebyte(map_obs  );
         net_writecard(map_seed );
         net_writebool(g_addon  );
         net_writebyte(g_mode   );
         net_writebyte(g_startb );
         net_writebool(g_shpos  );
         net_writebyte(g_aislots);

         net_send(net_lastinip,net_lastinport);
      end
      else   // other net mess
      begin
         pid:=A2P(net_lastinip,net_lastinport,false);
         if(pid>0)then
         begin
            if(mid=nmid_chat)then
            begin
               i:=net_readbyte;
               net_chat_add(net_readstring,pid,i);    // chat
               {$IFNDEF _FULLGAME}
               if(G_Started=false)then _parseCmd(net_chat[pid,0],pid);
               {$ENDIF}
            end;

            if(mid=nmid_plout)then
            begin
               net_chat_add(_players[pid].name+str_plout,pid,255);
               //_kill_player(pid);
               if(G_Started=false)then
               begin
                  _players[pid].state:=ps_none;
                  _playerSetState(pid);
               end;
               exit;
            end;

            if(G_Started)then
            begin
               if(mid=nmid_order)then
                with _players[pid]do
                begin
                   o_x0:=net_readint;
                   o_y0:=net_readint;
                   o_x1:=net_readint;
                   o_y1:=net_readint;
                   o_id:=net_readbyte;
                end;

               if(mid=nmid_clinf) then
                with _players[pid] do
                begin
                   PNU :=net_readbyte;
                   net_chatls[pid]:=net_readbyte;
                end;

               if(mid=nmid_pause)then
               begin
                  if(G_Paused=pid)
                  then G_Paused:=0
                  else
                    if(G_Paused<>HPlayer)or(G_Paused=0)then G_Paused:=pid;
                  {$IFNDEF _FULLGAME}
                  vid_mredraw:=true;
                  {$ENDIF}
               end;
            end
            else
            begin
               if(mid=nmid_swapp)then
               begin
                  i:=net_readbyte;
                  _swapPlayers(i,pid);
                  {$IFNDEF _FULLGAME}
                  vid_mredraw:=true;
                  {$ENDIF}
               end;
            end;
         end
         else
         begin
            net_clearbuffer;
            net_writebyte(nmid_ncon);
            net_send(net_lastinip,net_lastinport);
         end;
      end;
   end;

   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _players[i] do
      if(state=PS_Play)and(ttl<ClientTTL)then
      begin
         if(G_Started)and((net_period mod NetTickN)=0)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_shap);
            net_writebyte(G_Paused);
            if(G_Paused=0)
            then _wclinet_gframe(i,false)
            else net_writebyte(G_WTeam);
            net_send(nip,nport);
         end;

         if(net_period=i)and(net_chatls[i]<>net_chatss[i])then
         begin
            net_clearbuffer;
            net_writebyte(nmid_chatclupd);
            net_writebyte(net_chatss[i]);
            net_writechat(i);
            net_send(nip,nport);
         end;
      end;

   inc(net_period,1);
   net_period:=net_period mod vid_hfps;
end;

{$IFDEF _FULLGAME}

procedure net_readmap;
var i:integer;
    b:byte;
    c:cardinal;
   rm:boolean;
begin
   rm:=false;

   i:=map_mw;
   map_mw   := net_readint;
   if(i<>map_mw  )then rm:=true;

   b:=map_liq;
   map_liq  := net_readbyte;
   if(b<>map_liq )then rm:=true;

   b:=map_obs;
   map_obs  := net_readbyte;
   if(b<>map_obs )then rm:=true;

   c:=map_seed;
   map_seed := net_readcard;
   if(c<>map_seed)then rm:=true;

   g_addon  := net_readbool;

   b:=g_mode;
   g_mode   := net_readbyte;
   if(c<>g_mode  )then rm:=true;


   g_startb := net_readbyte;
   g_shpos  := net_readbool;
   g_aislots:= net_readbyte;

   if(rm)then Map_premap;
   vid_mredraw:=true;
end;

procedure net_GClient;
var mid,i:byte;
    gst:boolean;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   if(net_lastinip=net_cl_svip)and(net_lastinport=net_cl_svport)then
   begin
      net_cl_svttl:=0;
      mid:=net_readbyte;

      if(mid=nmid_sfull) then
      begin
         net_m_error:=str_sfull;
         vid_mredraw:=true;
      end;

      if(mid=nmid_sver) then
      begin
         net_m_error:=str_sver;
         vid_mredraw:=true;
      end;

      if(mid=nmid_sgst) then
      begin
         net_m_error:=str_sgst;
         vid_mredraw:=true;
      end;

      if(mid=nmid_ncon)then
      begin
         G_Started:=false;
         _menu:=true;
         PlayerReady:=false;
         DefGameObjects;
      end;

      if(mid=nmid_chatclupd)then
      begin
         i:=net_readbyte;
         if(net_chatls[HPlayer]<>i)then
         begin
            PlaySNDM(snd_chat);
            _rpls_nwrch:=true;
         end;
         net_chatls[HPlayer]:=i;
         net_readchat(HPlayer);
         net_chat_shlm:=chat_shlm_t;
      end;

      if(mid=nmid_startinf)then
      begin
         gst:=net_readbool;

         for i:=1 to MaxPlayers do
          with _Players[i] do
          begin
             name := net_readstring;
             team := net_readbyte;
             race := net_readbyte;
             mrace:= net_readbyte;
             state:= net_readbyte;
             ready:= net_readbool;
             ttl  := net_readint;
          end;

         HPlayer:=net_readbyte;
         net_cl_svpl:=net_readbyte;

         net_readmap;
         net_m_error:='';

         if(gst<>G_Started)then
         begin
            G_Started:=gst;
            if(G_Started)then
            begin
               _menu:=false;
               onlySVCode:=false;
               //if(g_mode=gm_coop)then _make_coop;
               _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
            end
            else
            begin
               _menu:=true;
               PlayerReady:=false;
               DefGameObjects;
            end;
         end;
      end;

      if(G_Started)then
      begin
         if(mid=nmid_shap)then
         with _players[HPlayer] do
         begin
            G_paused:=net_readbyte;

            if(G_paused=0)
            then _rclinet_gframe(HPlayer,false)
            else G_WTeam:=net_readbyte;
         end;
      end;
   end;

   if(net_period=0)then
   begin
      net_clearbuffer;
      if (G_Started=false) then
      begin
         net_writebyte  (nmid_connect);
         net_writebyte  (ver);
         net_writestring(PlayerName);
         net_writebyte  (PlayerTeam);
         net_writebyte  (PlayerRace);
         net_writebool  (PlayerReady);
         net_writebyte  (net_chatls[HPlayer]);
         net_writebyte  (_cl_pnua[net_pnui]);
      end
      else
      begin
         net_writebyte(nmid_clinf);
         net_writebyte(_cl_pnua[net_pnui]);
         net_writebyte(net_chatls[HPlayer]);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   inc(net_period,1);net_period:=net_period mod vid_hfps;
   if(net_cl_svttl<ClientTTL)then
   begin
      inc(net_cl_svttl,1);
      if(net_cl_svttl=vid_fps)then vid_mredraw:=true;
      if(net_cl_svttl=ClientTTL)then G_Paused:=net_cl_svpl;
   end;
end;

{$ENDIF}

