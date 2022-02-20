
function net_NewPlayer(sip:cardinal;sp:word):byte;
var i:byte;
begin
   net_NewPlayer:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_None)then
      begin
         net_NewPlayer:=i;
         nip          :=sip;
         nport        :=sp;
         state        :=PS_Play;
         ttl          :=0;
         {$IFNDEF _FULLGAME}
         PlayersAddLog(i,0,lmt_game,'MarsWars dedicated server, '+str_ver,false);
         PlayersAddLog(i,0,lmt_game,'Type -h/-help command'              ,false);
         {$ENDIF}
         break;
      end;
end;

function net_GetPlayer(aip:cardinal;ap:word;cnew:boolean):byte;
var i:byte;
begin
   net_GetPlayer:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_Play)and(nip=aip)and(nport=ap)then
      begin
         net_GetPlayer:=i;
         ttl:=0;
         {$IFNDEF _FULLGAME}
         if(ttl>=ClientTTL)then vid_menu_redraw:=true;
         {$ENDIF}
         break;
      end;

   if(net_GetPlayer=0)and(G_Started=false)and(cnew)then net_GetPlayer:=net_NewPlayer(aip,ap);
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
      if(s<>name)then vid_menu_redraw:=true;

      if(g_mode in [gm_2fort,gm_3fort,gm_inv,gm_aslt])
      then i:=net_readbyte
      else
      begin
         i:=team;
         team:=net_readbyte;
         if(i<>team)then vid_menu_redraw:=true;
      end;

      i:=race;
      race :=net_readbyte;
      mrace:=race;
      if(i<>mrace)then vid_menu_redraw:=true;

      i:=byte(ready);
      ready:=net_readbool;
      if((i>0)<>ready)then vid_menu_redraw:=true;

      PNU  :=net_readbyte;

      log_n_cl:=net_readcard;

      if(log_n_cl=log_n)then net_logsend_pause:=0;
   end;
end;

procedure net_WriteGameData(pid:byte);
var i:byte;
begin
   net_writebyte(nmid_lobby_info);
   net_writebool(G_Started);

   for i:=0 to MaxPlayers do
    with _Players[i] do
    begin
       net_writestring(name );
       net_writebyte  (team );
       net_writebyte  (mrace);
       net_writebyte  (state);
       net_writebool  (ready);
       net_writeword  (ttl  );
       if(G_Started)then
       net_writebyte  (race);
    end;

   net_writebyte(pid      );
   net_writebyte(HPlayer  );

   net_writeint (map_mw   );
   net_writebyte(map_liq  );
   net_writebyte(map_obs  );
   net_writecard(map_seed );
   net_writebool(map_sym  );

   net_writebool(g_addon  );
   net_writebyte(g_mode   );
   net_writebyte(g_start_base    );
   net_writebool(g_show_positions);
   net_writebyte(g_ai_slots      );
end;

procedure net_GServer;
var mid,pid,i:byte;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      {if(mid=nmid_getinfo)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_getinfo);
         net_writebyte(ver);
         net_writebool(g_started);
         net_writebool(g_addon  );
         net_writebyte(g_mode   );
         for i:=1 to MaxPlayers do
          with _players[i] do
           if(state>ps_none)
           then net_writestring(name)
           else net_writestring(''  );
         net_send(net_lastinip,net_lastinport);
         continue;
      end;}

      if(mid=nmid_connect)then
      begin
         i:=net_readbyte;
         if(i<>ver)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_wrong_ver);
            net_send(net_lastinip,net_lastinport);
            continue;
         end;
         pid:=net_GetPlayer(net_lastinip,net_lastinport,true);
         if(pid=0)then
         begin
            net_clearbuffer;
            if(g_started)
            then net_writebyte(nmid_game_started)
            else net_writebyte(nmid_server_full );
            net_send(net_lastinip,net_lastinport);
            continue;
         end;

         if(G_Started=false)then net_ReadPlayerData(pid);

         net_clearbuffer;
         net_WriteGameData(pid);
         net_send(net_lastinip,net_lastinport);
      end
      else   // other net mess
      begin
         pid:=net_GetPlayer(net_lastinip,net_lastinport,false);
         if(pid>0)then
         begin
            case mid of
nmid_log_chat    : begin
                      i:=net_readbyte;
                      GameLogChat(pid,i,net_readstring,false);    // chat
                      {$IFNDEF _FULLGAME}
                      if(G_Started=false)then
                       with(_players[pid])do
                        if(log_lt[log_i]=lmt_chat)then _parseCmd(log_ls[log_i],pid);
                      {$ENDIF}
                      continue;
                   end;
nmid_player_leave: begin

                      GameLogPlayerLeave(pid);
                      if(G_Started=false)then PlayerSetState(pid,ps_none);
                      continue;
                   end;
            else
               if(G_Started)then
               case mid of
nmid_order      : with _players[pid]do
                  begin
                     o_x0:=net_readint;
                     o_y0:=net_readint;
                     o_x1:=net_readint;
                     o_y1:=net_readint;
                     o_a0:=net_readbyte;
                     o_id:=net_readbyte;
                  end;
nmid_client_info: with _players[pid] do
                  begin
                     PNU     :=net_readbyte;
                     log_n_cl:=net_readcard;
                     if(log_n_cl=log_n)then net_logsend_pause:=0;
                  end;
nmid_pause      : begin
                     if(G_Status=pid)
                     then G_Status:=gs_running
                     else
                       if(G_Status<>HPlayer)or(G_Status=gs_running)then G_Status:=pid;
                    {$IFNDEF _FULLGAME}
                    vid_menu_redraw:=true;
                    {$ENDIF}
                  end;
               end
               else
                 if(mid=nmid_swapp)then
                 begin
                    i:=net_readbyte;
                    PlayersSwap(i,pid);
                    {$IFNDEF _FULLGAME}
                    vid_menu_redraw:=true;
                    {$ENDIF}
                 end;
            end;
         end
         else
         begin
            net_clearbuffer;
            net_writebyte(nmid_notconnected);
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
            net_writebyte(nmid_snapshot);
            net_writebyte(G_Status);
            if(G_Status=gs_running)
            then _wclinet_gframe(i,false);
            net_send(nip,nport);
         end;

         if(net_logsend_pause<=0)and(log_n_cl<>log_n)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_chatclupd);
            _wudata_chat(i,@log_n_cl,false);
            net_send(nip,nport);
            net_logsend_pause:=fr_2hfps;
         end;
      end;

   net_period+=1;
   net_period:=net_period mod fr_2hfps;
end;

{$IFDEF _FULLGAME}

procedure net_ReadMapData;
var redraw_menu,new_map:boolean;
function _rmByte(pv:pbyte    ):boolean;var v:byte    ;begin v:=pv^;pv^:=net_readbyte;_rmByte:=(v<>pv^);end;
function _rmWord(pv:pword    ):boolean;var v:word    ;begin v:=pv^;pv^:=net_readword;_rmWord:=(v<>pv^);end;
function _rmInt (pv:pinteger ):boolean;var v:integer ;begin v:=pv^;pv^:=net_readint ;_rmInt :=(v<>pv^);end;
function _rmCard(pv:pcardinal):boolean;var v:cardinal;begin v:=pv^;pv^:=net_readcard;_rmCard:=(v<>pv^);end;
function _rmBool(pv:pboolean ):boolean;var v:boolean ;begin v:=pv^;pv^:=net_readbool;_rmBool:=(v<>pv^);end;
begin
   redraw_menu:=false;
   new_map    :=false;

   if(_rmInt (@map_mw          ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmByte(@map_liq         ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmByte(@map_obs         ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmCard(@map_seed        ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmBool(@map_sym         ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmBool(@g_addon         ))then begin redraw_menu:=redraw_menu or true;end;
   if(_rmByte(@g_mode          ))then begin redraw_menu:=redraw_menu or true;new_map:=new_map or true;end;
   if(_rmByte(@g_start_base    ))then begin redraw_menu:=redraw_menu or true;end;
   if(_rmBool(@g_show_positions))then begin redraw_menu:=redraw_menu or true;end;
   if(_rmByte(@g_ai_slots      ))then begin redraw_menu:=redraw_menu or true;end;

   Map_premap;

   if(redraw_menu)then vid_menu_redraw:=true;
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
      case mid of
nmid_server_full : begin
                      net_m_error:=str_sfull;
                      vid_menu_redraw:=true;
                   end;
nmid_wrong_ver   : begin
                      net_m_error:=str_sver;
                      vid_menu_redraw:=true;
                   end;
nmid_game_started: begin
                      net_m_error:=str_sgst;
                      vid_menu_redraw:=true;
                   end;
nmid_notconnected: begin
                      G_Started:=false;
                      _menu:=true;
                      PlayerReady:=false;
                      GameDefaultAll;
                   end;
nmid_chatclupd   : begin
                      _rudata_chat(HPlayer,false);
                      net_chat_shlm:=chat_shlm_t;
                      net_period:=0;
                   end;
nmid_lobby_info  : begin
                      gst:=net_readbool;

                      for i:=0 to MaxPlayers do
                       with _Players[i] do
                       begin
                          name := net_readstring;
                          team := net_readbyte;
                          mrace:= net_readbyte;
                          state:= net_readbyte;
                          ready:= net_readbool;
                          ttl  := net_readint;
                          if(gst)
                          then race:= net_readbyte
                          else race:= mrace;
                       end;

                      HPlayer    :=net_readbyte;
                      net_cl_svpl:=net_readbyte;

                      net_ReadMapData;
                      net_m_error:='';

                      if(gst<>G_Started)then
                      begin
                         G_Started:=gst;
                         if(G_Started)then
                         begin
                            _menu:=false;
                            ServerSide:=false;
                            //if(g_mode=gm_coop)then _make_coop;
                            MoveCamToPoint(map_psx[HPlayer] , map_psy[HPlayer]);
                         end
                         else
                         begin
                            _menu:=true;
                            PlayerReady:=false;
                            GameDefaultAll;
                         end;
                      end;
                   end;
      end;

      if(G_Started)then
      begin
         if(mid=nmid_snapshot)then
         begin
            G_Status:=net_readbyte;

            if(G_Status=gs_running)
            then _rclinet_gframe(HPlayer,false);
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
         net_writestring(PlayerName );
         net_writebyte  (PlayerTeam );
         net_writebyte  (PlayerRace );
         net_writebool  (PlayerReady);
         net_writebyte  (_cl_pnua[net_pnui]);
         net_writecard  (net_log_n  );
      end
      else
      begin
         net_writebyte(nmid_client_info);
         net_writebyte(_cl_pnua[net_pnui]);
         net_writecard(net_log_n);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   net_period+=1;
   net_period:=net_period mod fr_2hfps;
   if(net_cl_svttl<ClientTTL)then
   begin
      net_cl_svttl+=1;
      if(net_cl_svttl=fr_fps   )then vid_menu_redraw:=true;
      if(net_cl_svttl=ClientTTL)then G_Status:=gs_waitserver;
   end;
end;

{$ENDIF}

