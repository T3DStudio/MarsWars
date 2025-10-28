

function net_NewPlayer(sip:cardinal;sport:word):byte;
var p:byte;
begin
   net_NewPlayer:=255;
   for p:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(p<>LocalPlayer)then
     {$ENDIF}
       with g_gplayers[p] do
       with g_nplayers[p] do
         if(state=ps_None)then
         begin
            net_NewPlayer:=p;
            net_ip       :=sip;
            net_port     :=sport;
            net_ttl      :=0;
            net_ping     :=0;
            n_u          :=0;
            state        :=ps_human;
            isready        :=false;
            PlayerClearLog(p);
            PlayerSetDefault(p);
            {$IFNDEF _FULLGAME}
            GameLogCommon(p,0,'MarsWars dedicated server, '+str_ver);
            {$ENDIF}
            menu_update:=true;
            break;
         end;
end;

function net_GetPlayer(aip:cardinal;aport:word;MakeNew:boolean):byte;
var p:byte;
begin
   net_GetPlayer:=255;
   for p:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(p<>LocalPlayer)then
     {$ENDIF}
       with g_gplayers[p] do
       with g_nplayers[p] do
         if(state=ps_human)and(net_ip=aip)and(net_port=aport)then
         begin
            net_GetPlayer:=p;
            if(net_ttl>=fr_fps1)then menu_update:=true;
            net_ttl:=0;
            break;
         end;

   if(net_GetPlayer=255)and(not G_Started)and(MakeNew)then net_GetPlayer:=net_NewPlayer(aip,aport);
end;

procedure net_SvReadPlayerData(pid:byte);
var   i:byte;
oldname:shortstring;
begin
   with g_gplayers[pid] do
   with g_nplayers[pid] do
   begin
      oldname:=name;
      name   :=net_readstring;
      if(length(name)>MaxPlayerNameLen)then setlength(name,MaxPlayerNameLen);
      if(oldname<>name)then menu_update:=true;

      i    :=byte(isready);
      isready:=net_readbool;
      if((i>0)<>isready)then
      begin
         GameLogPlayerReady(pid);
         menu_update:=true;
      end;

      PNU     :=net_readbyte;
      log_n_cl:=net_readcard;

      if(log_n_cl=log_n)then net_logsend_pause:=0;
   end;
end;

procedure net_ReadMapMark(pid:byte);
var x,y:integer;
begin
   x:=net_readint;
   y:=net_readint;
   GameLogMapMark(pid,x,y);
end;

procedure net_SendGameInfo(pid:byte);
var p:byte;
begin
   net_clearbuffer;
   net_writebyte(nmid_GameInfo);
   net_writebool(G_Started);

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     with g_nplayers[p] do
     begin
        net_writestring(name );
        if(isobserver)
   then net_writebyte(255  )
   else net_writebyte(team );
        net_writebyte(mrace);
        net_writebyte(state);
        net_writebool(isready);
        net_writeword(net_ttl );
        net_writeword(net_ping);
        if(G_Started)then
        net_writebyte(race );
     end;

   net_writebyte(pid);
   net_writebyte({$IFDEF _FULLGAME}LocalPlayer{$ELSE}255{$ENDIF});

   net_writebyte(map_scenario  );
   net_writebyte(map_generators);
   net_writeint (map_Size      );
   net_writebyte(map_ObstaclesF);
   net_writecard(map_seed      );
   net_writebool(map_Symmetry  );

   net_writebool(g_FixedPositions);
   net_writebyte(g_AISlots       );
   net_writebool(g_DefeatedObs   );

   if(G_Started)and(not g_FixedPositions)then
     for p:=0 to LastPlayer do
     begin
        net_writeint(map_PlayerStartX[p]);
        net_writeint(map_PlayerStartY[p]);
     end;

   with g_nplayers[pid] do
     net_send(net_ip,net_port);
end;

procedure net_Server;
var
mid,pid,
i      : byte;
u,n    : integer;
tping1,
tping2 : cardinal;
pu     : PTUnit;
every2t: boolean;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      if(mid=nmid_connect)then
      begin
         i:=net_readbyte;
         if(i<>g_version)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_WrongVersion);
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,true);
         if(pid=255)then
         begin
            net_clearbuffer;
            if(g_started)
            then net_writebyte(nmid_GameStarted)
            else net_writebyte(nmid_ServerFull );
            net_send(net_LastinIP,net_LastinPort);
            continue;
         end;

         if(not G_Started)then net_SvReadPlayerData(pid);

         net_SendGameInfo(pid);
      end
      else   // other net mess
      begin
         pid:=net_GetPlayer(net_LastinIP,net_LastinPort,false);
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
                                      with g_nplayers[pid] do
                                        net_send(net_ip,net_port);
                                   end;
            nmid_ping_Answer     : begin
                                      tping1:=net_readcard;
                                      tping2:=SDL_GetTicks;
                                      if(tping1<=tping2)then
                                        with g_nplayers[pid] do net_ping:=tping2-tping1;
                                   end;
            nmid_LogMessage      : begin
                                      i:=net_readbyte;
                                      GameLogChat(pid,i,net_readstring);    // chat
                                   end;
            nmid_PlayerLeave     : begin
                                      GameLogPlayerLeave(pid);
                                      if(not G_Started)then
                                        PlayerKill(pid,true);
                                      PlayerSetState(pid,ps_None);
                                      menu_update:=true;
                                   end;
            else
               if(G_Started)then
                 case mid of
                 nmid_order          : with g_gplayers[pid]do
                                       begin
                                          o_x0:=net_readint;
                                          o_y0:=net_readint;
                                          o_x1:=net_readint;
                                          o_y1:=net_readint;
                                          o_a0:=net_readbyte;
                                          o_id:=net_readbyte;

                                          for u:=1 to MaxUnits do
                                            with g_punits[u]^ do
                                              if(hits>0)and(pid=playeri)then unit_UnSelect(g_punits[u]);
                                          n:=net_readint;
                                          while(n>0)do
                                          begin
                                             u:=net_readint;
                                             if(IsUnitRange(u,@pu))then
                                               with pu^ do
                                                 if(hits>0)and(pid=playeri)and(not IsUnitRange(transportU,nil))then unit_Select(pu);
                                             n-=1;
                                          end;
                                       end;
                 nmid_map_mark       : net_ReadMapMark(pid);
                 nmid_ClientData     : with g_gplayers[pid] do
                                       with g_nplayers[pid] do
                                       begin
                                          PNU     :=net_readbyte;
                                          log_n_cl:=net_readcard;
                                          if(log_n_cl=log_n)then net_logsend_pause:=0;
                                       end;
                 nmid_pause          : begin
                                          if(G_Status<=LastPlayer)then
                                          begin
                                             G_Status:=gs_running;
                                             GameLogChat(pid,255,str_gmsg_PlayerResumed);
                                          end
                                          else
                                            if(G_Status=gs_running)then
                                            begin
                                               G_Status:=pid;
                                               GameLogChat(pid,255,str_gmsg_PlayerPaused);
                                            end;
                                         {$IFNDEF _FULLGAME}
                                         menu_update:=true;
                                         {$ENDIF}
                                       end;
                 nmid_PlayerSurrender: menu_update:=menu_update or PlayerSurrender(pid,false);
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
                                                nmid_lobby_PAILevelScroll: menu_update:=menu_update or PlayerAILevelScroll(i,pid,net_readbool,false);
                                                nmid_lobby_PAIToggle     : menu_update:=menu_update or PlayerAIToggle     (i,pid             ,false);
                                                {$ENDIF}
                                                nmid_lobby_PRace         : menu_update:=menu_update or PlayerRaceScroll   (i,pid             ,false);
                                                nmid_lobby_PTeam         : menu_update:=menu_update or PlayerTeamScroll   (i,pid,net_readbool,false);
                                                nmid_lobby_PJumpToSlot   : menu_update:=menu_update or PlayersSwap        (i,pid             ,false);
                                                end;
                                             end;
                 {$IFNDEF _FULLGAME}
                 nmid_lobby_MSeed          : menu_update:=menu_update or GameMapSetSeed(pid,net_readcard,false);
                 nmid_lobby_MScenario,
                 nmid_lobby_MGenerators,
                 nmid_lobby_MSize,
                 nmid_lobby_MObstacles,
                 nmid_lobby_MSymmetry,
                 nmid_lobby_MRandom,

                 nmid_lobby_GFixedPositions,
                 nmid_lobby_GAISlots,
                 nmid_lobby_GDefeatedObs,
                 nmid_lobby_GRandomScirmish: menu_update:= menu_update or GameSetOption(pid,mid,net_readbool,false);
                 {$ENDIF}
                 end;
            end;
         end;
      end;
   end;

   net_period+=1;
   net_period:=net_period mod net_PeriodTime;
   every2t:=(net_period mod NetTickN)=0;
   net_ping_timer+=1;
   net_ping_timer:=net_ping_timer mod net_PingTime;

   for pid:=0 to LastPlayer do
     {$IFDEF _FULLGAME}
     if(pid<>LocalPlayer)then
     {$ENDIF}
       with g_gplayers[pid] do
       with g_nplayers[pid] do
         if(state=ps_human)and(net_ttl<fr_fps1)then
         begin
            case G_Started of
            true : if(every2t)then
                   begin
                      net_clearbuffer;
                      net_writebyte(nmid_snapshot);
                      net_writebyte(G_Status);
                      if(G_Status=gs_running)then
                         wclinet_gframe(pid,false);
                      net_send(net_ip,net_port);
                   end;
            end;

            if(pid=net_ping_timer)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_ping_request);
               net_writecard(SDL_GetTicks);
               net_send(net_ip,net_port);
            end;

            if(net_logsend_pause<=0)and(log_n_cl<>log_n)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_LogUpdate);
               wudata_log(pid,@log_n_cl,false);
               net_send(net_ip,net_port);
               net_logsend_pause:=fr_fpsh;
            end;
         end;

   if(net_svLanAdv)and(not g_Started)then
     if(net_svLanAdv_timer<=0)then
     begin
        net_svLanAdv_timer:=net_svLanAdv_time;
        net_clearbuffer;
        net_writebyte(nmid_LAN_Adv);
        net_writebyte(g_version);
        net_writebyte(map_scenario);
        for pid:=0 to LastPlayer do
          with g_gplayers[pid] do
            if(state=ps_none)
            then net_writestring('')
            else net_writestring(name);
        net_send(net_svLanAdv_ip,net_svLanAdv_portS);
     end
     else net_svLanAdv_timer-=1;
end;


{$IFDEF _FULLGAME}

procedure GameResetNetGame;
begin
   net_dispose;
   GameDefaultAll;
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

procedure net_ClReadMapData(StartGame:boolean);
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
   if(nrByte(@map_generators  ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrInt (@map_Size        ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@map_ObstaclesF  ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrCard(@map_seed        ))then begin redraw_menu:=true;new_map:=true;end;
   if(nrBool(@map_Symmetry    ))then begin redraw_menu:=true;new_map:=true;end;

   if(nrBool(@g_FixedPositions))then begin redraw_menu:=true;new_map:=true;end;
   if(nrByte(@g_AISlots       ))then begin redraw_menu:=true;              end;
   if(nrBool(@g_DefeatedObs   ))then begin redraw_menu:=true;              end;

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

procedure net_ClReadPlayerData(pid:byte);
var i,w:integer;
oldname:shortstring;
begin
   with g_gplayers[pid] do
   with g_nplayers[pid] do
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
      isready  :=net_readbool;
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
        if(net_cl_svttl>=ServerTTL)then menu_update:=true;
        net_cl_svttl:=0;

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
nmid_GameStarted : begin
                      net_ClientError(str_gmsg_GameStarted);
                      exit;
                   end;
nmid_NotConnected: begin
                      G_Started  :=false;
                      MainMenu   :=true;
                      PlayerReady:=false;
                      GameDefaultAll;
                   end;
nmid_LogUpdate   : begin
                      rudata_log(LocalPlayer,false);
                      net_period:=0;
                   end;
nmid_ping_Request: begin
                      tping1:=net_readcard;
                      net_clearbuffer;
                      net_writebyte(nmid_ping_Answer);
                      net_writecard(tping1);
                      net_send(net_cl_svip,net_cl_svport);
                   end;
nmid_GameInfo    : begin
                      svstarted:=net_readbool;

                      for i:=0 to LastPlayer do
                        with g_gplayers[i] do
                        begin
                           net_ClReadPlayerData(i);
                           if(svstarted)
                           then race:= net_readbyte
                           else race:= mrace;
                           PlayerSetSkirmishTech(i);
                        end;

                      i:=LocalPlayer;
                      LocalPlayer:=net_readbyte;
                      if(LocalPlayer<>i)then menu_update:=true;
                      i:=net_cl_Hoster;
                      net_cl_Hoster:=net_readbyte;
                      if(net_cl_Hoster<>i)then menu_update:=true;

                      net_ClReadMapData(svstarted);

                      if(svstarted<>G_Started)then
                      begin
                         G_Started:=svstarted;
                         if(G_Started)then
                         begin
                            MainMenu  :=false;
                            ServerSide:=false;
                            GameLocalStart;
                         end
                         else
                         begin
                            MainMenu:=true;
                            PlayerReady:=false;
                            GameDefaultAll;
                         end;
                      end;
                   end;
nmid_snapshot    : if(G_Started)then
                   begin
                      //menu_msg_Net.mm_time:=0;
                      G_Status:=net_readbyte;
                      if(G_Status=gs_running)then
                        rclinet_gframe(LocalPlayer,false,false);
                   end;
        end;
     end;

   // CLIENT OUTPUT
   if(net_period=0)then
   begin
      net_clearbuffer;
      if(G_Started)then
      begin
         net_writebyte(nmid_ClientData);
         net_writebyte(Quality2Units[net_cl_Quality]);
         net_writecard(net_cl_log_n);
      end
      else
      begin
         net_writebyte  (nmid_connect);
         net_writebyte  (g_version);
         net_writestring(PlayerName );
         net_writebool  (PlayerReady);
         net_writebyte  (Quality2Units[net_cl_Quality]);
         net_writecard  (net_cl_log_n);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   // CLIENT TIMERS
   net_period+=1;
   net_period:=net_period mod net_PeriodTime;
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

////////////////////////////////////////////////////////////////////////////////
//
//    NET LAN SEARCH
//

procedure net_DiscoweringUpdate(aip:cardinal;aport:word;ainfo:shortstring);
var i,e:word;
begin
   e:=0;
   if(net_svsearch_size>0)then
     for i:=0 to net_svsearch_size-1 do
       with net_svsearch_listi[i] do
         if(aip=ip)and(aport=port)then
         begin
            e:=i+1;
            break;
         end;

   if(e=0)then
     if(net_svsearch_size<net_svsearch_size.MaxValue)then
     begin
        net_svsearch_size+=1;
        setlength(net_svsearch_listi,net_svsearch_size);
        setlength(net_svsearch_lists,net_svsearch_size);
        with net_svsearch_listi[net_svsearch_size-1] do
        begin
           ip  :=aip;
           port:=aport;
        end;
        e:=net_svsearch_size;
        menu_update:=true;
     end;

   if(e>0)then
   begin
      e-=1;
      if(net_svsearch_lists[e]<>ainfo)then menu_update:=true;
      net_svsearch_lists[e]:=ainfo;
   end;
end;

procedure net_Discowering;
var mid,v,p:byte;
          s:shortstring;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   begin
      mid:=net_readbyte;
      if(mid<>nmid_LAN_Adv)then continue;

      s:=c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_gmsg_WrongVersion;

      v:=net_readbyte;
      if(v=g_version)then
      begin
         v:=net_readbyte;
         if(v<=mc_last)then
         begin
            s:='';
            for p:=0 to LastPlayer do STRADD(@s,net_readstring,sep_comma);
            s:=c2ip(net_LastinIP)+':'+w2s(swap(net_LastinPort))+' '+str_map_scenariol[v]+'  '+s;
            net_DiscoweringUpdate(net_LastinIP,net_LastinPort,s);
            continue;
         end;
      end;

      net_DiscoweringUpdate(net_LastinIP,net_LastinPort,s);
   end;
end;


{$ENDIF}

