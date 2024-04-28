
function net_NewPlayer(sip:cardinal;sp:word):byte;
var i:byte;
begin
   net_NewPlayer:=0;
   for i:=1 to MaxPlayers do
    if(i<>PlayerClient)then
     with g_players[i] do
      if(state=ps_none)then
      begin
         net_NewPlayer:=i;
         nip          :=sip;
         nport        :=sp;
         state        :=PS_Play;
         ttl          :=0;
         {$IFNDEF _FULLGAME}
         GameLogCommon(i,0,'MarsWars dedicated server, '+str_ver,false);
         GameLogCommon(i,0,'Type -h/-help command'              ,false);
         {$ENDIF}
         break;
      end;
end;

function net_GetPlayer(aip:cardinal;ap:word;MakeNew:boolean):byte;
var i:byte;
begin
   net_GetPlayer:=0;
   for i:=1 to MaxPlayers do
    if(i<>PlayerClient)then
     with g_players[i] do
      if(state=PS_Play)and(nip=aip)and(nport=ap)then
      begin
         net_GetPlayer:=i;
         if(ttl>=fr_fps1)then {$IFDEF _FULLGAME}menu_update{$ELSE}screen_redraw{$ENDIF}:=true;
         ttl:=0;
         break;
      end;

   if(net_GetPlayer=0)and(G_Started=false)and(MakeNew)then net_GetPlayer:=net_NewPlayer(aip,ap);
end;

procedure net_SvReadPlayerData(pid:byte);
var   i:byte;
oldname:shortstring;
begin
   with g_players[pid] do
   begin
      oldname:=name;
      name   :=net_readstring;
      name   :=ValidateStr(name,NameLen,@k_kbstr);
      if(oldname<>name)then {$IFDEF _FULLGAME}menu_update{$ELSE}screen_redraw{$ENDIF}:=true;

      i    :=byte(ready);
      ready:=net_readbool;
      if((i>0)<>ready)then {$IFDEF _FULLGAME}menu_update{$ELSE}screen_redraw{$ENDIF}:=true;

      PNU     :=net_readbyte;
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
    with g_players[i] do
    begin
       net_writestring(name );
       net_writebyte  (team );
       net_writebyte  (slot_race);
       net_writebyte  (state);
       net_writebyte  (slot_state);
       net_writebool  (ready);
       net_writeword  (ttl  );
       if(G_Started)then
       net_writebyte  (race );
    end;

   net_writebyte(pid        );
   net_writebyte(PlayerLobby);

   net_writeint (map_mw      );
   net_writebyte(map_type    );
   net_writecard(map_seed    );
   net_writebyte(map_symmetry);

   net_writebyte(g_mode           );
   net_writebyte(g_start_base     );
   net_writebool(g_fixed_positions);
   net_writebyte(g_ai_slots       );
   net_writebyte(g_generators     );
   net_writebool(g_deadobservers  );

   if(G_Started)and(not g_fixed_positions)then
    for i:=1 to MaxPlayers do
    begin
       net_writeint(map_psx[i]);
       net_writeint(map_psy[i]);
    end;
end;

procedure net_ReadMapMark(pid:byte);
var x,y:integer;
begin
   x:=net_readint;
   y:=net_readint;
   GameLogMapMark(pid,x,y);
end;

procedure net_WriteGameInfo;
var i:byte;
begin
   net_writebyte(nmid_localadv);
   net_writebyte(g_version);
   net_writebyte(g_mode);
   for i:=1 to MaxPlayers do
     with g_players[i] do
       if(state=ps_none)
       then net_writestring('')
       else net_writestring(name);
end;

procedure net_Server;
var mid,
    pid,
    i  :byte;
net_period_step
       :boolean;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      if(mid=nmid_getinfo)then
      begin
         net_clearbuffer;
         net_WriteGameInfo;
         net_send(net_LastinIP,net_LastinPort);
         continue;
      end;

      if(mid=nmid_connect)then
      begin
         i:=net_readbyte;
         if(i<>g_version)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_wrong_ver);
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,true);
         if(pid=0)then
         begin
            net_clearbuffer;
            if(g_started)
            then net_writebyte(nmid_game_started)
            else net_writebyte(nmid_server_full );
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;

         if(not G_Started)then net_SvReadPlayerData(pid);

         net_clearbuffer;
         net_WriteGameData(pid);
         net_send(net_LastinIP,net_LastinPort);
      end
      else   // other net mess
      begin
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,false);
         if(pid>0)then
         begin
            case mid of
nmid_log_chat    : begin
                      i:=net_readbyte;
                      GameLogChat(pid,i,net_readstring,false);    // chat
                      continue;
                   end;
nmid_player_leave: begin
                      GameLogPlayerLeave(pid);
                      if(not G_Started)
                      then PlayerSetState(pid,ps_none)//PlayerSlotChangeState(0,pid,ps_opened,false)
                      else PlayerKill(pid,false);
                      {$IFNDEF _FULLGAME}
                      screen_redraw:=true;
                      {$ENDIF}
                      continue;
                   end;
            else
               if(G_Started)then
                 case mid of
nmid_order       : with g_players[pid]do
                   begin
                      o_x0:=net_readint;
                      o_y0:=net_readint;
                      o_x1:=net_readint;
                      o_y1:=net_readint;
                      o_a0:=net_readint;
                      o_id:=net_readbyte;
                   end;
nmid_map_mark    : net_ReadMapMark(pid);
nmid_client_info : with g_players[pid] do
                   begin
                      PNU     :=net_readbyte;
                      log_n_cl:=net_readcard;
                      if(log_n_cl=log_n)then net_logsend_pause:=0;
                   end;
nmid_pause       : begin
                      if(G_Status<>gs_running)and(G_Status<=MaxPlayers)then
                      begin
                         G_Status:=gs_running;
                         GameLogChat(pid,255,str_PlayerResumed,false);
                      end
                      else
                        if(G_Status=gs_running)then
                        begin
                           G_Status:=pid;
                           GameLogChat(pid,255,str_PlayerPaused,false);
                        end;
                     {$IFNDEF _FULLGAME}
                     screen_redraw:=true;
                     {$ENDIF}
                   end;
                 end
               else
                 case mid of
nmid_lobbby_mapsize    :;
nmid_lobbby_type       :;
nmid_lobbby_symmetry   :;
nmid_lobbby_gamemode   :;
nmid_lobbby_playerslot :;
nmid_lobbby_playerteam :;
nmid_lobbby_playerrace :;
                 end;
            end;
         end
         else
         begin
            net_clearbuffer;
            net_writebyte(nmid_notconnected);
            net_send(net_LastinIP,net_LastinPort);
         end;
      end;
   end;

   net_period_step:=(net_period mod NetTickN)=0;

   for i:=1 to MaxPlayers do
    if(i<>PlayerClient)then
     with g_players[i] do
      if(state=PS_Play)and(ttl<ClientTTL)then
      begin
         if(G_Started)and(net_period_step)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_snapshot);
            net_writebyte(G_Status);
            if(G_Status=gs_running)
            then wclinet_gframe(i,false);
            net_send(nip,nport);
         end;

         if(net_logsend_pause<=0)and(log_n_cl<>log_n)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_log_upd);
            wudata_log(i,@log_n_cl,false);
            net_send(nip,nport);
            net_logsend_pause:=fr_fpsd2;
         end;
      end;

   net_period+=1;
   net_period:=net_period mod fr_fpsd2;

   if(net_localAdv)and(not G_Started)then
     if(net_localAdv_timer<=0)then
     begin
        net_localAdv_timer:=net_localAdv_time;
        net_clearbuffer;
        net_WriteGameInfo;
        net_send(net_localAdv_ip,net_svlsearch_portS);
     end
     else net_localAdv_timer-=1;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   CLIENT

{$IFDEF _FULLGAME}

procedure net_ClReadMapData(StartGame:boolean);
var
redraw_menu,
new_map     : boolean;
i           : byte;
function rByte(pv:pbyte    ):boolean;var v:byte    ;begin v:=pv^;pv^:=net_readbyte;rByte:=(v<>pv^);end;
function rWord(pv:pword    ):boolean;var v:word    ;begin v:=pv^;pv^:=net_readword;rWord:=(v<>pv^);end;
function rInt (pv:pinteger ):boolean;var v:integer ;begin v:=pv^;pv^:=net_readint ;rInt :=(v<>pv^);end;
function rCard(pv:pcardinal):boolean;var v:cardinal;begin v:=pv^;pv^:=net_readcard;rCard:=(v<>pv^);end;
function rBool(pv:pboolean ):boolean;var v:boolean ;begin v:=pv^;pv^:=net_readbool;rBool:=(v<>pv^);end;
begin
   redraw_menu:=false;
   new_map    :=false;

   if(rInt (@map_mw           ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@map_type         ))then begin redraw_menu:=true;new_map:=true;end;
   if(rCard(@map_seed         ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@map_symmetry     ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@g_mode           ))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@g_start_base     ))then begin redraw_menu:=true;              end;
   if(rBool(@g_fixed_positions))then begin redraw_menu:=true;new_map:=true;end;
   if(rByte(@g_ai_slots       ))then begin redraw_menu:=true;              end;
   if(rByte(@g_generators     ))then begin redraw_menu:=true;new_map:=true;end;
   if(rBool(@g_deadobservers  ))then begin redraw_menu:=true;              end;

   if(new_map    )then Map_premap;
   if(redraw_menu)then menu_update:=true;

   if(StartGame)and(not g_fixed_positions)then
    for i:=1 to MaxPlayers do
    begin
       map_psx[i]:=net_readint;
       map_psy[i]:=net_readint;
    end;
end;

procedure net_ClReadPlayerData(pid:byte);
var   i:integer;
oldname:shortstring;
begin
   with g_players[pid] do
   begin
      oldname:=name;
      name   :=net_readstring;
      name   :=ValidateStr(name,NameLen,@k_kbstr);
      if(oldname<>name)then menu_update:=true;

      i      :=team;
      team   :=net_readbyte;
      if(i<>team)then menu_update:=true;

      i      :=slot_race;
      slot_race:=net_readbyte;
      if(i<>slot_race)then menu_update:=true;

      i      :=state;
      state  :=net_readbyte;
      if(i<>state)then menu_update:=true;

      i      :=slot_state;
      slot_state:=net_readbyte;
      if(i<>slot_state)then menu_update:=true;

      i      :=byte(ready);
      ready  :=net_readbool;
      if(i<>byte(ready))then menu_update:=true;

      i      :=ttl;
      ttl    :=net_readint;
      if((i< fr_fps1)and(ttl>=fr_fps1))
      or((i>=fr_fps1)and(ttl< fr_fps1))then menu_update:=true;
   end;
end;

procedure net_Client;
var
mid,i:byte;
gst  :boolean;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   if(net_LastinIP=net_cl_svip)and(net_LastinPort=net_cl_svport)then
   begin
      if(net_cl_svttl>=ServerTTL)then menu_update:=true;
      net_cl_svttl:=0;

      mid:=net_readbyte;
      case mid of
nmid_server_full : begin
                      net_status_str:=str_ServerFull;
                      menu_update   :=true;
                   end;
nmid_wrong_ver   : begin
                      net_status_str:=str_WrongVersion;
                      menu_update   :=true;
                   end;
nmid_game_started: begin
                      net_status_str:=str_GameStarted;
                      menu_update   :=true;
                   end;
nmid_notconnected: begin
                      G_Started     :=false;
                      menu_state    :=true;
                      PlayerReady   :=false;
                      GameDefaultAll;
                   end;
nmid_log_upd     : begin
                      rudata_log(PlayerClient,false);
                      log_LastMesTimer:=log_LastMesTime;
                      net_period:=0;
                   end;
nmid_lobby_info  : begin
                      gst:=net_readbool;

                      for i:=0 to MaxPlayers do
                       with g_players[i] do
                       begin
                          net_ClReadPlayerData(i);
                          if(gst)
                          then race:= net_readbyte
                          else race:= slot_race;
                          PlayerSetSkirmishTech(i);
                       end;

                      i:=PlayerClient;
                      PlayerClient:=net_readbyte;if(PlayerClient<>i)then menu_update:=true;
                      i:=PlayerLobby;
                      PlayerLobby :=net_readbyte;if(PlayerLobby <>i)then menu_update:=true;

                      net_ClReadMapData(gst);
                      net_status_str:='';

                      if(gst<>G_Started)then
                      begin
                         G_Started:=gst;
                         if(G_Started)then
                         begin
                            menu_state:=false;
                            ServerSide:=false;
                            GameCameraMoveToPoint(map_psx[PlayerClient],map_psy[PlayerClient]);
                            if(g_players[PlayerClient].team=0)then ui_tab:=3;
                         end
                         else
                         begin
                            menu_state:=true;
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
            then rclinet_gframe(PlayerClient,false,false);
         end;
      end;
   end;

   if(net_period=0)then
   begin
      net_clearbuffer;
      if(not G_Started) then
      begin
         net_writebyte(nmid_connect);
         net_writebyte(g_version   );
         net_writebool(PlayerReady );
         net_writebyte(cl_UpT_array[net_pnui]);
         net_writecard(net_log_n   );
      end
      else
      begin
         net_writebyte(nmid_client_info);
         net_writebyte(cl_UpT_array[net_pnui]);
         net_writecard(net_log_n);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   net_period+=1;
   net_period:=net_period mod fr_fpsd2;
   if(net_cl_svttl<ServerTTL)then
   begin
      net_cl_svttl+=1;
      if(net_cl_svttl=ServerTTL)then
      begin
         menu_update:=true;
         G_Status:=gs_waitserver;
      end;
   end;
end;

procedure net_DiscoweringUpdate(aip:cardinal;aport:word;ainfo:shortstring);
var i,e:word;
begin
   e:=0;
   if(net_svsearch_listn>0)then
    for i:=0 to net_svsearch_listn-1 do
     with net_svsearch_list[i] do
      if(aip=ip)and(aport=port)then
      begin
         e:=i+1;
         break;
      end;

   if(e=0)then
    if(net_svsearch_listn<net_svsearch_listn.MaxValue)then
    begin
       net_svsearch_listn+=1;
       setlength(net_svsearch_list,net_svsearch_listn);
       with net_svsearch_list[net_svsearch_listn-1] do
       begin
          ip  :=aip;
          port:=aport;
       end;
       e:=net_svsearch_listn;
       menu_update:=true;
    end;

    if(e>0)then
     with net_svsearch_list[e-1] do
     begin
        if(info<>ainfo)then menu_update:=true;
        info:=ainfo;
     end;
end;

procedure net_Discowering;
var mid,v,i:byte;
          s:shortstring;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      case mid of
nmid_localadv : begin
                   v:=net_readbyte;
                   if(v=g_version)then
                   begin
                      v:=net_readbyte;
                      if(v in allgamemodes)then
                      begin
                         s:='';
                         for i:=0 to MaxPlayers do _ADDSTR(@s,net_readstring,sep_comma);
                         s:=c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_gmode[v]+'  '+s;
                         net_DiscoweringUpdate(net_LastinIP,net_LastinPort,s);
                         continue;
                      end;
                   end;
                   net_DiscoweringUpdate(net_LastinIP,net_LastinPort,c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_WrongVersion);
                end;
      end;
   end;
end;

{$ENDIF}

