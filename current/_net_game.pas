

function net_NewPlayer(sip:cardinal;sport:word):byte;
var p:byte;
begin
   net_NewPlayer:=255;
   for p:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(p<>LocalPlayer)then
     {$ENDIF}
       with g_PlayersGame[p] do
       with g_PlayersTemp[p] do
         if(state=ps_None)then
         begin
            net_NewPlayer:=p;
            net_ip       :=sip;
            net_port     :=sport;
            net_ttl      :=0;
            net_ping     :=0;
            n_u          :=0;
            state        :=ps_human;
            isready      :=false;
            PlayerClearLog(p);
            PlayerSetDefault(p);
            if(g_started)
            or(g_LobbyTimer>0)then isobserver:=true;
            {$IFNDEF _FULLGAME}
            GameLog_Chat(p,0,'MarsWars dedicated server, '+str_version);
            {$ENDIF}
            menu_update:=true;
            break;
         end;
end;

function net_GetPlayer(aip:cardinal;aport:word):byte;
var p:byte;
begin
   net_GetPlayer:=255;
   for p:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(p<>LocalPlayer)then
     {$ENDIF}
       with g_PlayersGame[p] do
       with g_PlayersTemp[p] do
         if(state=ps_human)and(net_ip=aip)and(net_port=aport)then
         begin
            net_GetPlayer:=p;
            if(net_ttl>=fr_fps1)then menu_update:=true;
            net_ttl:=0;
            break;
         end;
end;

function net_PlayersCheckTTL:boolean;
var p,
c_players,
c_out    :byte;
begin
   c_players:=0;
   c_out    :=0;
   for p:=0 to MaxPlayers do
     with g_PlayersGame[p] do
     with g_PlayersTemp[p] do
       if(state=PS_human)and(not isobserver)and(not isdefeated)then
       begin
          c_players+=1;
          if(net_ttl>=fr_fps1)then c_out+=1;
       end;
   net_PlayersCheckTTL:=(c_out>0)and(c_players>0);
end;

procedure net_ServerReadPlayerData(pid:byte);
var
tbool:boolean;
tstr :shortstring;
begin
   with g_PlayersGame[pid] do
   with g_PlayersTemp[pid] do
   begin
      tstr:=name;
      name:=net_readstring;
      if(length(name)>MaxPlayerNameLen)then setlength(name,MaxPlayerNameLen);
      if(tstr<>name)then menu_update:=true;

      tbool  :=isready;
      isready:=net_readbool;
      if(tbool<>isready)then
        if(not g_started)and(g_LobbyTimer<=0)then
        begin
           GameLog_PlayerReadyStat(pid);
           menu_update:=true;
        end;

      PNU     :=net_readbyte;
      log_n_cl:=net_readcard;

      if(log_n_cl=log_n)then net_TimerLogSend:=0;
   end;
end;

procedure net_ReadMapMark(pid:byte);
var x,y,mType:integer;
begin
   x    :=net_readint;
   y    :=net_readint;
   mType:=net_readint;
   GameLog_MapMark(pid,x,y,mType);
end;

procedure net_WritePlayersDelay;
var p,s:byte;
begin
   s:=0;
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       SetBBit(@s,p,state=ps_human);
   net_writebyte(s);
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     with g_PlayersTemp[p] do
       if(state=ps_human)then
       begin
          net_writeword(net_ttl );
          net_writeword(net_ping);
       end;
end;

procedure net_WriteGameInfo;
var p:byte;
begin
   net_writebyte(g_version);
   net_writebyte(map_scenario);
   net_writebool(g_started);
   if(g_started)then
     net_writebyte(g_status );
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       net_writestring(name);
end;


procedure net_SendGameLobbyInfo(pid:byte);
var p:byte;
begin
   net_clearbuffer;
   net_writebyte(nmid_LobbyInfo);
   net_writebool(g_started);

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     with g_PlayersTemp[p] do
     begin
        net_writestring(name );
        if(isobserver)
   then net_writebyte(255     )
   else net_writebyte(team    );
        net_writebyte(mrace   );
        net_writebyte(state   );
        net_writebool(isready );
        net_writeword(net_ttl );
        net_writeword(net_ping);
        if(g_started)then
        net_writebyte(race    );
     end;

   net_writebyte(pid);
   net_writebyte({$IFDEF _FULLGAME}LocalPlayer{$ELSE}255{$ENDIF});

   net_writebyte(map_scenario  );
   net_writebyte(map_GeneratorT);
   net_writeint (map_Size1     );
   net_writebyte(map_Template  );
   net_writecard(map_seed      );
   net_writebyte(map_Symmetry  );

   net_writebool(g_FixedPositions);
   net_writebyte(g_AISlots       );
   net_writebool(g_NewObservers  );

   if(g_started)and(not g_FixedPositions)then
     for p:=0 to LastPlayer do
     begin
        net_writeint(map_PlayerStartX[p]);
        net_writeint(map_PlayerStartY[p]);
     end;

   with g_PlayersTemp[pid] do
     net_send(net_ip,net_port);
end;

procedure net_ConnectMsg;
var i:byte;
begin
   i:=net_readbyte;
   if(i<>g_version)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_WrongVersion);
      net_send(net_LastinIP,net_LastinPort);
      exit;
   end;
   i:=net_GetPlayer(net_LastinIP,net_LastinPort);
   if(i<=LastPlayer)then
   begin
      if(not g_started)then
        net_ServerReadPlayerData(i);
      net_SendGameLobbyInfo(i);
   end
   else
     if((g_started)or(g_LobbyTimer>0))and(not g_NewObservers)then
     begin
        net_clearbuffer;
        net_writebyte(nmid_NoNewObservers);
        net_send(net_LastinIP,net_LastinPort);
     end
     else
     begin
        i:=net_NewPlayer(net_LastinIP,net_LastinPort);
        if(i>LastPlayer)then
        begin
           net_clearbuffer;
           net_writebyte(nmid_ServerFull);
           net_send(net_LastinIP,net_LastinPort);
        end
        else
        begin
           net_ServerReadPlayerData(i);
           GameLog_PlayerConnected(i);
           net_SendGameLobbyInfo(i);
        end;
     end;
end;

procedure net_Server;
var
mid,pid,
i      : byte;
u,n    : integer;
tpingw : word;
tping1,
tping2 : cardinal;
pu     : PTUnit;
begin
   // REEIVING
   net_clearbuffer;
   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      if(mid=nmid_ServerInfoReq)then
      begin
         tping1:=net_readcard;
         net_clearbuffer;
         net_writebyte(nmid_ServerInfo);
         net_writecard(tping1);
         net_WriteGameInfo;
         net_send(net_LastinIP,net_LastinPort);
         continue;
      end;

      if(mid=nmid_connect)
      then net_ConnectMsg
      else   // other net mess
      begin
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort);
         if(pid>LastPlayer)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_NotConnected);
            net_send(net_LastinIP,net_LastinPort);
         end
         else
         begin
            case mid of
            nmid_ping_Request    : begin
                                      tping1:=net_readcard;
                                      net_clearbuffer;
                                      net_writebyte(nmid_ping_Answer);
                                      net_writecard(tping1);
                                      with g_PlayersTemp[pid] do
                                        net_send(net_ip,net_port);
                                   end;
            nmid_ping_Answer     : begin
                                      tping1:=net_readcard;
                                      tping2:=SDL_GetTicks;
                                      if(tping1<=tping2)then
                                        with g_PlayersTemp[pid] do
                                        begin
                                           tpingw:=net_ping;
                                           net_ping:=tping2-tping1;
                                           if(net_ping<>tpingw)then menu_update:=true;
                                        end;
                                   end;
            nmid_LogMessage      : begin
                                      i:=net_readbyte;
                                      GameLog_Chat(pid,i,net_readstring);    // chat
                                   end;
            nmid_PlayerLeave     : begin
                                      GameLog_PlayerLeave(pid);
                                      case g_started of
                                      false: PlayerSetState(pid,ps_None);
                                      true : begin
                                                PlayerKill(pid,true);
                                                g_PlayersGame[pid].state:=ps_none;
                                             end;
                                      end;
                                      menu_update:=true;
                                   end;
            else
               if(g_started)then
                 case mid of
                 nmid_order          : with g_PlayersGame[pid]do
                                       with g_PlayersTemp[pid]do
                                       begin
                                          o_x0:=net_readint;
                                          o_y0:=net_readint;
                                          o_x1:=net_readint;
                                          o_y1:=net_readint;
                                          o_a0:=net_readbyte;
                                          o_id:=net_readbyte;

                                          for u:=1 to MaxUnits do
                                            with g_punits[u]^ do
                                              if(hits>0)and(pid=playeri)then
                                              begin
                                                 unit_UnSelect(g_punits[u]);
                                                 group:=0;
                                              end;
                                          n:=net_readint;
                                          while(n>0)do
                                          begin
                                             u:=net_readint;
                                             i:=net_readbyte;
                                             if(IsUnitRange(u,@pu))then
                                               with pu^ do
                                                 if(hits>0)and(pid=playeri)and(not IsUnitRange(transportU,nil))then
                                                 begin
                                                    unit_Select(pu);
                                                    group:=i;
                                                 end;
                                             n-=1;
                                          end;
                                       end;
                 nmid_map_mark       : net_ReadMapMark(pid);
                 nmid_ClientData     : with g_PlayersGame[pid] do
                                       with g_PlayersTemp[pid] do
                                       begin
                                          PNU     :=net_readbyte;
                                          log_n_cl:=net_readcard;
                                          if(log_n_cl=log_n)then net_TimerLogSend:=0;
                                          cam_x   :=net_readint;
                                          cam_y   :=net_readint;
                                          cam_w   :=net_readint;
                                          cam_h   :=net_readint;
                                       end;
                 nmid_pause          : begin
                                          if(g_status<=LastPlayer)then
                                          begin
                                             g_status:=gs_running;
                                             GameLog_Resumed(pid);
                                          end
                                          else
                                            if(g_status=gs_running)then
                                            begin
                                               g_status:=pid;
                                               GameLog_Paused(pid);
                                            end;
                                         {$IFNDEF _FULLGAME}
                                         menu_update:=true;
                                         {$ENDIF}
                                       end;
                 nmid_PlayerSurrender: if(PlayerSurrender(pid,false))then menu_update:=true;
                 end
               else
                 case mid of
                 {$IFNDEF _FULLGAME}
                 nmid_lobby_PAILevelScroll,
                 nmid_lobby_PAIToggle,
                 {$ENDIF}
                 nmid_lobby_PRace,
                 nmid_lobby_PTeam,
                 nmid_lobby_PJumpToSlot    : begin
                                                i:=net_readbyte; // player-target
                                                case mid of
                                                {$IFNDEF _FULLGAME}
                                                nmid_lobby_PAILevelScroll: if(PlayerAILevelScroll(i,pid,net_readbool,false))then menu_update:=true;
                                                nmid_lobby_PAIToggle     : if(PlayerAIToggle     (i,pid             ,false))then menu_update:=true;
                                                {$ENDIF}
                                                nmid_lobby_PRace         : if(PlayerRaceScroll   (i,pid             ,false))then menu_update:=true;
                                                nmid_lobby_PTeam         : if(PlayerTeamScroll   (i,pid,net_readbool,false))then menu_update:=true;
                                                nmid_lobby_PJumpToSlot   : if(PlayersSwap        (i,pid             ,false))then menu_update:=true;
                                                end;
                                             end;
                 nmid_lobby_PObserver      : if(PlayerToggleObserver(pid,pid,false))then menu_update:=true;
                 {$IFNDEF _FULLGAME}
                 nmid_lobby_MSeed          : if(GameMapSetSeed(pid,net_readcard,false))then menu_update:=true;
                 nmid_lobby_MScenario,
                 nmid_lobby_MGenerators,
                 nmid_lobby_MSize,
                 nmid_lobby_MTemplate,
                 nmid_lobby_MSymmetry,
                 nmid_lobby_MRandom,

                 nmid_lobby_GFixedPositions,
                 nmid_lobby_GAISlots,
                 nmid_lobby_GNewObservers,
                 nmid_lobby_GRandomScirmish: if(GameSetOption(pid,mid,net_readbool,false))then menu_update:=true;
                 {$ENDIF}
                 end;
            end;
         end;
      end;
   end;

   // PAUSE GAME IF LAG PLAYERS
   if(g_started)then
     case g_status of
     gs_waitplayers,
     gs_running    : begin
                        {$IFNDEF _FULLGAME}
                        i:=g_status;
                        {$ENDIF}
                        if(net_PlayersCheckTTL)
                        then g_status:=gs_waitplayers
                        else g_status:=gs_running;
                        {$IFNDEF _FULLGAME}
                        if(i<>g_status)then menu_update:=true;
                        {$ENDIF}
                     end;
     end;

   // SENDING
   net_TimerBase:=(net_TimerBase+1) mod net_SendTimeServer;
   net_TimerPing:=(net_TimerPing+1) mod net_SendTimePing;

   for pid:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(pid<>LocalPlayer)then
     {$ENDIF}
       with g_PlayersGame[pid] do
       with g_PlayersTemp[pid] do
         if(state=ps_human)and(net_ttl<fr_fps1)then
         begin
            if(g_started)and(net_TimerBase=0)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_GameData);
               net_writebyte(g_status);
               case g_status of
               gs_running    : wclinet_gframe(pid,net_SendTimeServer,false);
               gs_waitplayers: net_WritePlayersDelay;
               end;
               net_send(net_ip,net_port);
            end;

            if(pid=net_TimerPing)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_ping_request);
               net_writecard(SDL_GetTicks);
               net_WritePlayersDelay;
               net_send(net_ip,net_port);
            end;

            if(net_TimerLogSend<=0)and(log_n_cl<>log_n)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_LogUpdate);
               wudata_log(pid,@log_n_cl,false);
               net_send(net_ip,net_port);
               net_TimerLogSend:=fr_fpsh;
            end;
         end;

   // LAN ADVERTISMENT
   if(net_svLanAdv)then
     if(net_svLanAdv_timer<=0)then
     begin
        net_svLanAdv_timer:=net_svLanAdv_time;
        net_clearbuffer;
        net_writebyte(nmid_LAN_Adv);
        net_WriteGameInfo;
        net_send(net_svLanAdv_ip,net_svLanAdv_portS);
     end
     else net_svLanAdv_timer-=1;
end;


{$IFDEF _FULLGAME}

procedure GameResetNetGame;
begin
   net_dispose;
   Game_DefaultAll;
   g_started :=false;
   net_status:=ns_none;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    NET CLIENT
//

procedure net_ClientError(msg:shortstring);
begin
   menu_update:=true;
   menu_msgBox_Set(str_Caption_Multiplayer,msg,mmbt_nothing);
   GameResetNetGame;
end;

procedure net_ReadPlayersDelay;
var
p,s :byte;
pval:word;
begin
   s:=net_readbyte;
   for p:=0 to LastPlayer do
     if(GetBBit(@s,p))then
       with g_PlayersGame[p] do
       with g_PlayersTemp[p] do
       begin
          net_ttl :=net_readword;
          pval    :=net_ping;
          net_ping:=net_readword;
          if(net_ping<>pval)then menu_update:=true;
       end;
end;

procedure net_ClientReadLobbyMapData(StartGame:boolean);
var
redraw_menu,
new_map     : boolean;
p           : byte;
function nrByte(pv:pbyte    ):boolean;var v:byte    ;begin v:=pv^;pv^:=net_readbyte;nrByte:=(v<>pv^);end;
function nrWord(pv:pword    ):boolean;var v:word    ;begin v:=pv^;pv^:=net_readword;nrWord:=(v<>pv^);end;
function nrInt (pv:pinteger ):boolean;var v:integer ;begin v:=pv^;pv^:=net_readint ;nrInt :=(v<>pv^);end;
function nrCard(pv:pcardinal):boolean;var v:cardinal;begin v:=pv^;pv^:=net_readcard;nrCard:=(v<>pv^);end;
function nrBool(pv:pboolean ):boolean;var v:boolean ;begin v:=pv^;pv^:=net_readbool;nrBool:=(v<>pv^);end;
begin
   redraw_menu:=false;
   new_map    :=false;

   if(nrByte(@map_scenario    ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@map_GeneratorT  ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrInt (@map_Size1       ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@map_Template    ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrCard(@map_seed        ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@map_Symmetry    ))then begin redraw_menu:=true;new_map:=true;end;

   if(nrBool(@g_FixedPositions))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@g_AISlots       ))then begin redraw_menu:=true;              end;
   if(nrBool(@g_NewObservers  ))then begin redraw_menu:=true;              end;

   if(new_map    )then
   begin
      Map_Make;
      menu_mseed:=c2s(map_seed);
   end;
   if(redraw_menu)then menu_update:=true;

   if(StartGame)and(not g_FixedPositions)then
     for p:=0 to LastPlayer do
     begin
        map_PlayerStartX[p]:=net_readint;
        map_PlayerStartY[p]:=net_readint;
     end;
end;

procedure net_ClientReadLobbyPlayerData(pid:byte);
var i,w:integer;
oldname:shortstring;
begin
   with g_PlayersGame[pid] do
   with g_PlayersTemp[pid] do
   begin
      oldname:=name;
      name   :=net_readstring;
      if(length(name)>MaxPlayerNameLen)then setlength(name,MaxPlayerNameLen);
      if(oldname<>name)then menu_update:=true;

      i      :=team;
      team   :=net_readbyte;
      if(i<>team)then menu_update:=true;
      i:=integer(isobserver);
      isobserver:=(team>LastPlayer);
      if(isobserver)then team:=0;
      if(i<>integer(isobserver))then menu_update:=true;

      i      :=mrace;
      mrace  :=net_readbyte;
      if(i<>mrace)then menu_update:=true;

      i      :=state;
      state  :=net_readbyte;
      if(i<>state)then menu_update:=true;

      i      :=byte(isready);
      isready:=net_readbool;
      if(i<>byte(isready))then menu_update:=true;

      w      :=net_ttl;
      net_ttl:=net_readword;
      if((i< fr_fps1)and(net_ttl>=fr_fps1))
      or((i>=fr_fps1)and(net_ttl< fr_fps1))then menu_update:=true;

      w       :=net_ping;
      net_ping:=net_readword;
      if(w<>net_ping)then menu_update:=true;
   end;
end;

procedure net_Client;
var mid,i:byte;
svstarted:boolean;
tping1   :cardinal;
begin
   // CLIENT INPUT
   net_clearbuffer;
   while(net_Receive>0)do
     if(net_LastinIP=net_cl_svip)and(net_LastinPort=net_cl_svport)then
     begin
        if(net_cl_svttl>=TTLServer)then menu_update:=true;
        net_cl_svttl:=0;
        if(menu_msg_type=mmbt_netWaitServer)then menu_msg_type:=mmbt_netWaitServer;

        mid:=net_readbyte;
        case mid of
nmid_ServerFull  : begin
                      net_ClientError(str_gmsg_ServerFull);
                      exit;
                   end;
nmid_WrongVersion: begin
                      net_ClientError(str_gmsg_WrongVersion);
                      exit;
                   end;
nmid_NoNewObservers
                 : begin
                      net_ClientError(str_gmsg_NoNewObservers);
                      exit;
                   end;
nmid_NotConnected: begin
                      g_started  :=false;
                      MainMenu   :=true;
                      PlayerReady:=false;
                      Game_DefaultAll;
                   end;
nmid_LogUpdate   : begin
                      rudata_log(LocalPlayer,false);
                      net_TimerBase:=0;
                   end;
nmid_ping_Request: begin
                      tping1:=net_readcard;
                      if(g_started)then
                        net_ReadPlayersDelay;
                      net_clearbuffer;
                      net_writebyte(nmid_ping_Answer);
                      net_writecard(tping1);
                      net_send(net_cl_svip,net_cl_svport);
                   end;
nmid_LobbyInfo    : begin
                      svstarted:=net_readbool;

                      for i:=0 to LastPlayer do
                        with g_PlayersGame[i] do
                        begin
                           net_ClientReadLobbyPlayerData(i);
                           if(svstarted)then
                           begin
                              race:=net_readbyte;
                              PlayerSetSkirmishTech(i);
                           end
                           else race:=mrace;
                        end;

                      i:=LocalPlayer;
                      LocalPlayer:=net_readbyte;
                      if(LocalPlayer<>i)then menu_update:=true;
                      i:=net_cl_Hoster;
                      net_cl_Hoster:=net_readbyte;
                      if(net_cl_Hoster<>i)then menu_update:=true;

                      net_ClientReadLobbyMapData(svstarted);

                      if(svstarted<>g_started)then
                      begin
                         g_started:=svstarted;
                         if(g_started)then
                         begin
                            MainMenu  :=false;
                            ServerSide:=false;
                            GameLocalStart;
                         end
                         else
                         begin
                            MainMenu   :=true;
                            PlayerReady:=false;
                            Game_DefaultAll;
                         end;
                      end;
                   end;
nmid_GameData    : if(g_started)then
                   begin
                      g_status:=net_readbyte;
                      case g_status of
                      gs_running    : rclinet_gframe(LocalPlayer,net_SendTimeServer,false,false);
                      gs_waitplayers: net_ReadPlayersDelay;
                      end;
                   end;
        end;
     end;

   // CLIENT OUTPUT
   if(net_TimerBase=0)then
   begin
      net_clearbuffer;
      if(g_started)then
      begin
         net_writebyte(nmid_ClientData);
         net_writebyte(Quality2Units[net_cl_Quality]);
         net_writecard(net_cl_log_n);
         net_writeint (ui_cam_x);
         net_writeint (ui_cam_y);
         net_writeint (ui_cam_w);
         net_writeint (ui_cam_h);
      end
      else
      begin
         net_writebyte  (nmid_connect);
         net_writebyte  (g_version   );
         net_writestring(PlayerName  );
         net_writebool  (PlayerReady );
         net_writebyte  (Quality2Units[net_cl_Quality]);
         net_writecard  (net_cl_log_n);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   // CLIENT TIMERS
   net_TimerBase+=1;
   case g_started of
   false: net_TimerBase:=net_TimerBase mod net_SendTimeClient1;
   true : net_TimerBase:=net_TimerBase mod net_SendTimeClient2;
   end;
   net_cl_svttl+=1;
   if(net_cl_svttl>=TTLServer)then
   begin
      if(g_started)then g_status:=gs_waitserver;
      if((net_cl_svttl mod fr_fps2)=0)then menu_update:=true;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    SERVER LIST
//

procedure net_ServerList_ItemUpdate(aip:cardinal;aport:word;ainfo:shortstring;aping:cardinal);
var i,e:integer;
function pingChar(p:cardinal):char;
begin
   case p div pingGradeStep of
   0     : pingChar:=tc_lime;
   1     : pingChar:=tc_yellow;
   2     : pingChar:=tc_orange;
   else    pingChar:=tc_red;
   end;
end;
begin
   e:=0;

   if(net_SvList_Size>0)then
     for i:=0 to net_SvList_Size-1 do
       with net_SvList_listi[i] do
         if(aip=si_ip)and(aport=si_port)then
         begin
            e:=i+1;
            break;
         end;

   if(e=0)then
     if(net_SvList_Size<net_SvList_Size.MaxValue)then
     begin
        net_SvList_Size+=1;
        setlength(net_SvList_listi,net_SvList_Size);
        setlength(net_SvList_lists,net_SvList_Size);
        with net_SvList_listi[net_SvList_Size-1] do
        begin
           si_ping:=999;
           si_ip  :=aip;
           si_port:=aport;
           si_line:=c2ip(si_ip)+':'+w2s(swap(si_port));
        end;
        e:=net_SvList_Size;
        menu_update:=true;
     end;

   if(e>0)then
   begin
      e-=1;
      with net_SvList_listi[e] do
      begin
         si_info:=ainfo;
         si_ttl :=0;
         if(aping<aping.MaxValue)then
           si_ping:=aping;
         ainfo:=pingChar(si_ping)+c2s(si_ping)+tc_default+' '+si_line+' '+si_info;
      end;
      if(net_SvList_lists[e]<>ainfo)then menu_update:=true;
      net_SvList_lists[e]:=ainfo;
   end;
end;

function net_ReadGameInfo:shortstring;
var
v:byte;
t:shortstring;
begin
   //c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort));
   net_ReadGameInfo:='';
   // version
   v:=net_readbyte;
   if(v<>g_version)then
   begin
      STRADD(@net_ReadGameInfo,str_gmsg_WrongVersion,sep_space);
      exit;
   end;
   // map scenario
   v:=net_readbyte;
   if(v>mc_last)then
   begin
      STRADD(@net_ReadGameInfo,str_gmsg_WrongVersion,sep_space);
      exit;
   end;
   STRADD(@net_ReadGameInfo,str_map_scenariol[v],sep_space);

   // g_started
   v:=net_readbyte;
   if(v=0)
   then STRADD(@net_ReadGameInfo,str_gstat_lobby,sep_space)
   else
   begin
      v:=net_readbyte;
      if(v=gs_running)
      then STRADD(@net_ReadGameInfo,str_gstat_Started,sep_space)
      else
      begin
         GameGetStatus(v,@t,nil,255);
         STRADD(@net_ReadGameInfo,t,sep_space);
      end;
   end;
   // players
   net_ReadGameInfo+=tc_nl1;
   t:='';
   for v:=0 to LastPlayer do
     STRADD(@t,net_readstring,sep_scomma);
   net_ReadGameInfo+=t;
end;

procedure net_ServerListProc;
var
mid   :byte;
i     :integer;
tping1,
tping2:cardinal;
s     :shortstring;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   begin
      mid:=net_readbyte;
      case mid of
      nmid_LAN_Adv   : begin
                          s:=net_ReadGameInfo;
                          if(length(s)>0)then
                            net_ServerList_ItemUpdate(net_LastinIP,net_LastinPort,s,tping1.MaxValue);
                       end;
      nmid_ServerInfo: begin
                          tping1:=net_readcard;
                          tping2:=SDL_GetTicks;
                          if(tping2>=tping1)then
                          begin
                             s:=net_ReadGameInfo;
                             if(length(s)>0)then
                               net_ServerList_ItemUpdate(net_LastinIP,net_LastinPort,s,tping2-tping1);
                          end;
                       end;
      end;
   end;

   net_TimerBase+=1;
   net_TimerBase:=net_TimerBase mod net_SendTimePing;
   if(net_SvList_Size>0)then
     for i:=0 to net_SvList_Size-1 do
       with net_SvList_listi[i] do
       begin
          if(si_ttl<si_ttl.MaxValue)then si_ttl+=1;
          if(si_ttl=net_ServerListTTL)then net_ServerList_ItemUpdate(si_ip,si_port,si_info,999);

          if(net_TimerBase=2)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_ServerInfoReq);
             net_writecard(SDL_GetTicks);
             net_send(si_ip,si_port);
          end;
       end;
end;


{$ENDIF}

