
procedure Dedicated_Init;
begin
   if(net_UpSocket(net_ServerPort))then
   begin
      net_status:=ns_server;
      PlayersSetDefault;
      //game_MakeRandomSkirmish;
   end
   else GameCycle :=false;

   menu_update:=true;
end;

procedure Dedicated_Code;
var GameEnded:boolean;
begin
   case G_Started of
   false: if(g_LobbyTimer<=0)then
            if(PlayersAllReady)and(PlayersNonObserversCount>1)then
              g_LobbyTimer:=g_GameStartTime;
   true : begin
             GameEnded:=Game_IsEnded;
             if(GameEnded)then
               if(g_LobbyTimer<=0)
               then g_LobbyTimer:=ded_GameEndTime
               else
               begin
                  g_LobbyTimer-=1;
                  if(g_LobbyTimer>0)then
                  begin
                     if((g_LobbyTimer mod fr_fps5)=0)then
                       GameLog_EndsIn(g_LobbyTimer div fr_fps1);
                  end;
               end;

             if(NoHumanPlayers)
             or(GameEnded and(g_LobbyTimer=0))then
               GameBreak(false);
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

procedure PlayerDataLine(p:byte);
function PlayerGetPINGStr:shortstring;
begin
   PlayerGetPINGStr:='';
   with g_PlayersMain[p] do
   with g_PlayersTemp[p] do
     if(state=ps_human)then PlayerGetPINGStr:=w2s(net_ping);
end;

begin
   with g_PlayersMain[p] do
     if(state=ps_none)
     then   Dedicated_screenLine(b2s(p+1),1,PlayerStateString(p),3,name,11,'',29,'',39,'',49)
     else
       if(isobserver)
       then Dedicated_screenLine(b2s(p+1),1,PlayerStateString(p),3,name,11,str_observer   ,29, ''         ,39, PlayerGetPINGStr,49)
       else Dedicated_screenLine(b2s(p+1),1,PlayerStateString(p),3,name,11,str_race[mrace],29, b2s(team+1),39, PlayerGetPINGStr,49);
end;

function Dedicated_GameStatusStr:shortstring;
begin
   if(not g_started)
   then Dedicated_GameStatusStr:=str_GameLobby
   else
     case G_status of
     gs_running    : Dedicated_GameStatusStr:=str_GameStarted;
     gs_paused0..
     gs_paused7    : Dedicated_GameStatusStr:=str_GamePaused+g_PlayersMain[G_status-gs_paused0].name;
     gs_waitplayers: Dedicated_GameStatusStr:=str_GameWFPlayers;
     gs_win_team0..
     gs_win_team7  : Dedicated_GameStatusStr:=str_GameEnded+b2s(G_Status-gs_win_team0+1);
     else            Dedicated_GameStatusStr:='UNKNOWN STATUS';
     end;
end;

procedure Dedicated_Screen;
const ded_ScreenUpdatePause = fr_fps4;
function g_AISlotsStr:shortstring;
begin
   if(g_AISlots>0)
   then g_AISlotsStr:=ai_name(g_AISlots,255)
   else g_AISlotsStr:='NO';
end;

begin
   if(menu_update)and(console_y>ded_ScreenUpdatePause)then
   begin
      clrscr;
      console_y:=0;
      menu_update:=false;
   end;

   if(console_y<=ded_ScreenUpdatePause)then
   begin
      case console_y of
      0 : writeln(str_wcaption,' ',str_cprt,str_UDPPort,net_ServerPort);
      2 : writeln(str_GameStatus, Dedicated_GameStatusStr);
      4 : writeln(str_GameOptions);
      6 : Dedicated_screenLine(str_game_FixedPositions,1, str_game_AISlots,25, str_game_NoNewObservers,50, '' ,1,'',55,'',70);
      8 : Dedicated_screenLine(b2c[g_FixedPositions]  ,1, g_AISlotsStr    ,25, b2c[g_NewObservers]    ,50, '' ,1,'',55,'',70);
      10: writeln;
      12: writeln(str_MapOptions);
      14: Dedicated_screenLine(str_map_Scenario               ,1, str_map_Generators                 ,15, str_map_Seed ,30, str_map_Size  ,45, str_map_Template               ,55, str_map_Symmetry               ,70);
      16: Dedicated_screenLine(str_map_ScenarioL[map_scenario],1, str_map_GeneratorsL[map_generators],15, c2s(map_seed),30, i2s(map_Size1),45, str_map_TemplateL[map_Template],55, str_map_SymmetryL[map_symmetry],70);
      18: writeln;
      20: Dedicated_screenLine('#',1,str_State                ,3, str_Player,11,str_srace,29,str_team ,39, str_ping,49);   // captions
      22: PlayerDataLine(0);
      24: PlayerDataLine(1);
      26: PlayerDataLine(2);
      28: PlayerDataLine(3);
      30: PlayerDataLine(4);
      32: PlayerDataLine(5);
      34: PlayerDataLine(6);
      36: PlayerDataLine(7);
      end;

      console_y+=1;
   end;
end;
