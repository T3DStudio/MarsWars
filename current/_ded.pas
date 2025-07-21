
procedure Dedicated_Init;
begin
   net_status:=ns_server;
   if(net_UpSocket=false)then
   begin
      net_dispose;
      net_status:=ns_none;
      GameCycle :=false;
   end
   else
   begin
      //LocalPlayer:=0;
      PlayersSetDefault;
   end;

   screen_redraw:=true;
end;

procedure Dedicated_Code;
begin
   case G_Started of
false: if(PlayersReadyStatus)then
       begin
          screen_redraw:=true;
          G_Started:=true;
          GameStartSkirmish;
       end;
true : if(PlayerAllOut)then
       begin
          G_Started:=false;
          GameDefaultAll;
       end;
   end;
end;

procedure Dedicated_screenLine(s1:shortstring;x1:byte;
                               s2:shortstring;x2:byte;
                               s3:shortstring;x3:byte;
                               s4:shortstring;x4:byte;
                               s5:shortstring;x5:byte;
                               s6:shortstring;x6:byte);
var s: shortstring;
procedure ss(sp:pshortstring;x:byte);
var i,t:byte;
begin
   i:=x+length(sp^);
   t:=length(s);
   if(i>t)then i:=t;
   t:=1;
   while(x<i)do
   begin
      s[x]:=sp^[t];
      x+=1;
      t+=1;
   end;
end;
begin
   s:='                                                                                 ';
   if(x1>0)then ss(@s1,x1);
   if(x2>0)then ss(@s2,x2);
   if(x3>0)then ss(@s3,x3);
   if(x4>0)then ss(@s4,x4);
   if(x5>0)then ss(@s5,x5);
   if(x6>0)then ss(@s6,x6);
   writeln(s);
end;

procedure ps(p:byte);
begin
   if(p=0)
   then        Dedicated_screenLine(str_PlayerName,1   , str_plstat          ,15, str_srace      ,25, str_team ,35, '',0, '',0)   // captions
   else with g_players[p] do
        if(state=ps_none)
        then   Dedicated_screenLine(name          ,1   , PlayerGetStatus(p)  ,15, '--'           ,25, ''       ,35, '',0, '',0)
        else
          if(team=0)
          then Dedicated_screenLine(name          ,1   , PlayerGetStatus(p)  ,15, str_observer   ,25, t2c(team),35, '',0, '',0)
          else Dedicated_screenLine(name          ,1   , PlayerGetStatus(p)  ,15, str_race[mrace],25, t2c(team),35, '',0, '',0);
end;

function SVGameStatus:shortstring;
begin
   if(g_started)
   then SVGameStatus:=str_GameStarted
   else SVGameStatus:=str_GameLobby;
   case G_status of
gs_running    : ;
1..MaxPlayers : SVGameStatus:=str_GamePaused+b2s(G_Status)
   else
     if(gs_win_team0<=G_status)and(G_status<=gs_win_team6)then SVGameStatus:=str_GameEnded+b2s(G_Status-gs_win_team0);
   end;
end;

procedure Dedicated_Screen;
begin
   if(screen_redraw)then
   begin
      clrscr;
      consoley:=0;
      screen_redraw:=false;
   end;

   if(consoley<=fr_fps1)then
   begin
      case consoley of
      0 : writeln(str_wcaption,' ',str_cprt,str_UDPPort,net_port);
      1 : writeln(str_GameStatus, SVGameStatus);
      2 : writeln(str_GameOptions);
      4 : writeln('   ',str_game_FixedPositions,b2c[g_FixedPositions]           );
      6 : writeln('   ',str_game_AISlots       ,g_AISlots                       );
      8 : writeln('   ',str_game_DefeatedObs   ,b2c[g_DefeatedObs ]             );
      10: writeln;
      12: writeln(str_MapOptions);
      14: Dedicated_screenLine(str_map_Scenario               ,1, str_map_Generators                 ,15, str_map_Seed ,30, str_map_Size ,45, str_map_Obstacles   ,55, str_map_Symmetry ,70);
      16: Dedicated_screenLine(str_map_ScenarioL[map_scenario],1, str_map_GeneratorsL[map_generators],15, c2s(map_seed),30, i2s(map_size),45, strMX(map_obstacles),55, b2c[map_symmetry],70);
      18: writeln;
      20: ps(0);
      22: ps(1);
      24: ps(2);
      26: ps(3);
      28: ps(4);
      30: ps(5);
      32: ps(6);
      end;

      consoley+=1;
   end;
end;
