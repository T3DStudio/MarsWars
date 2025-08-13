
procedure Dedicated_Init;
begin
   if(net_UpSocket(net_ServerPort))then
   begin
      net_status:=ns_server;
      PlayersSetDefault;
   end
   else GameCycle :=false;

   menu_update:=true;
end;

procedure Dedicated_Code;
begin
   case G_Started of
false: if(PlayersAllReady)then
       begin
          menu_update:=true;
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
   with g_gplayers[p] do
     if(state=ps_none)
     then   Dedicated_screenLine(PlayerStateString(p),1,name,7,'--'           ,25, ''         ,35, '',0, '',0)
     else
       if(observer)
       then Dedicated_screenLine(PlayerStateString(p),1,name,7,str_observer   ,25, '-'        ,35, '',0, '',0)
       else Dedicated_screenLine(PlayerStateString(p),1,name,7,str_race[mrace],25, b2s(team+1),35, '',0, '',0);
end;

function SVGameStatus:shortstring;
begin
   if(g_started)
   then SVGameStatus:=str_GameStarted
   else SVGameStatus:=str_GameLobby;
   case G_status of
gs_running    : ;
0..LastPlayer : SVGameStatus:=str_GamePaused+b2s(G_Status+1);
gs_win_team0..
gs_win_team7  : SVGameStatus:=str_GameEnded+b2s(G_Status-gs_win_team0);
   end;
end;

procedure Dedicated_Screen;
begin
   if(menu_update)then
   begin
      clrscr;
      consoley:=0;
      menu_update:=false;
   end;

   if(consoley<=fr_fps1)then
   begin
      case consoley of
      0 : writeln(str_wcaption,' ',str_cprt,str_UDPPort,net_ServerPort);
      1 : writeln(str_GameStatus, SVGameStatus);
      2 : writeln(str_GameOptions);
      4 : writeln('   ',str_game_FixedPositions,b2c[g_FixedPositions]);
      6 : writeln('   ',str_game_AISlots       ,g_AISlots            );
      8 : writeln('   ',str_game_DefeatedObs   ,b2c[g_DefeatedObs ]  );
      10: writeln;
      12: writeln(str_MapOptions);
      14: Dedicated_screenLine(str_map_Scenario               ,1, str_map_Generators                 ,15, str_map_Seed ,30, str_map_Size ,45, str_map_Obstacles    ,55, str_map_Symmetry ,70);
      16: Dedicated_screenLine(str_map_ScenarioL[map_scenario],1, str_map_GeneratorsL[map_generators],15, c2s(map_seed),30, i2s(map_size),45, strMX(map_ObstaclesF),55, b2c[map_symmetry],70);
      18: writeln;
      20: Dedicated_screenLine(str_PlayerState,1,str_Player,7,str_srace,25,str_team ,35, '',0, '',0);   // captions
      22: ps(0);
      24: ps(1);
      26: ps(2);
      28: ps(3);
      30: ps(4);
      32: ps(5);
      34: ps(6);
      36: ps(7);
      end;

      consoley+=1;
   end;
end;
